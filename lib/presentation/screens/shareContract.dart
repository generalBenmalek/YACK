import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:yack/data/models/contract/temp_contract.dart';
import 'package:yack/logic/cubits/contract/temp_contract_cubit.dart';
import 'package:yack/logic/cubits/contract/temp_contract_state.dart';
import 'package:yack/logic/cubits/contract/contract_sync_cubit.dart';
import 'package:yack/logic/services/notification/contract_notification_handler.dart';
import 'package:yack/logic/services/notification/notification_service.dart';
import 'package:yack/logic/services/snackBarHandler.dart';
import 'package:yack/logic/services/translation_handler.dart';
import 'package:yack/presentation/screens/acceptDeclineContract.dart';

/// Screen for sharing a temp contract via QR code or text link
/// User A creates the contract and shares it with User B
class ShareContractScreen extends StatefulWidget {
  final TempContract tempContract;
  final String title;
  final String description;
  final double price;

  const ShareContractScreen({
    super.key,
    required this.tempContract,
    required this.title,
    required this.description,
    required this.price,
  });

  @override
  State<ShareContractScreen> createState() => _ShareContractScreenState();
}

class _ShareContractScreenState extends State<ShareContractScreen> {
  late String _qrData;
  late String _shareText;
  bool _isWaitingForUserB = true; // User A always waits for User B to join first
  bool _isWaitingForSign = false;
  bool _userBJoined = false;
  bool _userASigned = false;
  bool _userBSigned = false;
  String? _userBName;
  StreamSubscription<ContractNotificationEvent>? _notificationSubscription;
  StreamSubscription<RemoteMessage>? _firebaseSubscription;

  @override
  void initState() {
    super.initState();
    _generateShareData();
    _setupNotificationListener();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _firebaseSubscription?.cancel();
    super.dispose();
  }

  /// Listen for contract notifications using both ContractNotificationHandler and direct Firebase
  void _setupNotificationListener() {
    final handler = NotificationService().contractHandler;

    // Listen via ContractNotificationHandler
    _notificationSubscription = handler
        .eventsForTempContract(widget.tempContract.tempId)
        .listen(_handleContractEvent);

    // Also listen directly to Firebase messages as fallback
    _firebaseSubscription = FirebaseMessaging.onMessage.listen((message) {
      final data = message.data;

      // DEBUG: Show every Firebase message received
      print('[DEBUG ShareContract] Firebase message received: $data');
      if (mounted) {
        SnackBarHandler.showMessage(
          context,
          '[DEBUG] FCM: ${data['type'] ?? 'no type'} - tempId: ${data['tempId'] ?? 'none'}',
        );
      }

      if (data.isEmpty) return;

      final tempId = data['tempId']?.toString();
      // Only handle notifications for our temp contract
      if (tempId != widget.tempContract.tempId) {
        print('[DEBUG ShareContract] tempId mismatch: got $tempId, expected ${widget.tempContract.tempId}');
        return;
      }

      final type = data['type']?.toString() ?? '';
      print('[DEBUG ShareContract] Handling notification type: $type');

      if (type == 'contractJoin') {
        _handleUserBJoined(data['username']?.toString() ?? '');
      } else if (type == 'contractSign') {
        _handleUserBSigned(data['contractId']?.toString());
      }
    });

    print('[DEBUG ShareContract] Notification listeners set up for tempId: ${widget.tempContract.tempId}');
  }

  /// Handle contract notification event from handler
  void _handleContractEvent(ContractNotificationEvent event) {
    switch (event.type) {
      case ContractNotificationType.contractJoin:
        _handleUserBJoined(event.username ?? '');
        break;
      case ContractNotificationType.contractSign:
        _handleUserBSigned(event.contractId);
        break;
      default:
        break;
    }
  }

  /// Handle when User B joins the contract
  void _handleUserBJoined(String username) {
    if (_userBJoined) return; // Prevent duplicate handling

    setState(() {
      _userBJoined = true;
      _userBName = username;
      _isWaitingForUserB = false;
    });

    // Navigate to accept/decline screen for User A
    _showAcceptDeclineForUserA();
  }

  /// Handle when User B signs the contract
  void _handleUserBSigned(String? contractId) {
    print('[DEBUG ShareContract] _handleUserBSigned called with contractId: $contractId, _isWaitingForSign: $_isWaitingForSign');

    if (!mounted) return;

    setState(() {
      _userBSigned = true;
    });

    SnackBarHandler.showMessage(
      context,
      '${_userBName ?? ''} ${TranslationHandler.get('has_signed_contract')}',
    );

    // Check if both users have signed
    if (_userASigned && _userBSigned) {
      _completeContract();
    }
  }

  /// Complete the contract when both users have signed
  void _completeContract() {
    // Sync will fetch the completed contract from backend
    context.read<ContractSyncCubit>().sync();

    setState(() => _isWaitingForSign = false);

    SnackBarHandler.showSuccess(
      context,
      TranslationHandler.get('contract_saved_successfully'),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// Show accept/decline screen for User A after User B joins
  Future<void> _showAcceptDeclineForUserA() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AcceptDeclineContractScreen(
          title: widget.title,
          price: widget.price,
          userFirstName: _userBName ?? '',
          userLastName: '',
          description: widget.description,
          isUserA: true,
        ),
      ),
    );

    if (result == true) {
      // User A accepted - now sign the contract
      _signContract();
    } else if (result == false) {
      // User A declined - go back home
      SnackBarHandler.showMessage(context, TranslationHandler.get('contract_declined'));
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  /// Called when both users have signed and contract is complete
  Future<void> _onContractComplete(String? contractId) async {
    if (contractId != null) {
      // Sync contracts from backend to get the finalized contract
      context.read<ContractSyncCubit>().sync();
    }

    if (mounted) {
      SnackBarHandler.showSuccess(
        context,
        TranslationHandler.get('contract_saved_successfully'),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _generateShareData() {
    // Create shareable data with tempId and contract preview info
    final shareData = {
      'tempId': widget.tempContract.tempId,
      'title': widget.title,
      'description': widget.description,
      'price': widget.price,
      'userAName': widget.tempContract.userAName ?? '',
    };

    final jsonString = json.encode(shareData);
    final encodedData = base64Url.encode(utf8.encode(jsonString));

    // QR code uses same data format as share text for now
    _qrData = 'yack://contract?data=$encodedData';
    // Share text uses full data URL so user B gets contract preview info when pasting
    _shareText = 'yack://contract?data=$encodedData';
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _shareText));
    SnackBarHandler.showSuccess(context, TranslationHandler.get('link_copied'));
  }

  void _signContract() {
    setState(() {
      _isWaitingForSign = true;
      _userASigned = true;
    });
    context.read<TempContractCubit>().sign(widget.tempContract.tempId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return BlocListener<TempContractCubit, TempContractState>(
      listener: (context, state) async {
        print('[DEBUG ShareContract] BlocListener received state: $state');

        if (state is TempContractSignSuccess) {
          print('[DEBUG ShareContract] TempContractSignSuccess - contractId: ${state.contractId}');

          setState(() {
            _userASigned = true;
          });

          if (state.contractId != null && state.contractId!.isNotEmpty) {
            // Both users signed - contract is finalized, sync from backend
            print('[DEBUG ShareContract] Contract finalized from backend');
            _completeContract();
          } else if (_userASigned && _userBSigned) {
            // Both users signed locally - complete the contract
            print('[DEBUG ShareContract] Both users signed locally');
            _completeContract();
          } else {
            // Only this user signed - waiting for other user
            print('[DEBUG ShareContract] Waiting for other user to sign...');
            setState(() => _isWaitingForSign = true);
            SnackBarHandler.showMessage(
              context,
              TranslationHandler.get('waiting_for_acceptance'),
            );
          }
        } else if (state is TempContractError) {
          print('[DEBUG ShareContract] TempContractError: ${state.message}');
          setState(() => _isWaitingForSign = false);
          SnackBarHandler.showError(context, state.message);
        }
      },
      child: PopScope(
        canPop: !_isWaitingForSign,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && _isWaitingForSign) {
            SnackBarHandler.showWarning(
              context,
              TranslationHandler.get('waiting_for_acceptance'),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              TranslationHandler.get('share_contract'),
              style: theme.textTheme.titleMedium,
            ),
            backgroundColor: Colors.transparent,
            centerTitle: true,
          ),
          backgroundColor: color.surface,
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Contract preview card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: color.outline.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: color.surface,
                      boxShadow: [
                        BoxShadow(
                          color: color.shadow.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Contract title
                        Text(
                          widget.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),

                        // Price
                        Text(
                          '${widget.price.toStringAsFixed(2)} ${TranslationHandler.get('currency')}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: color.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // QR Code
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: QrImageView(
                            data: _qrData,
                            version: QrVersions.auto,
                            size: 180,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Status indicator
                        if (_isWaitingForSign) ...[
                          const CircularProgressIndicator(),
                          const SizedBox(height: 12),
                          Text(
                            TranslationHandler.get('waiting_for_acceptance'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: color.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ] else if (_userBJoined) ...[
                          Icon(
                            Icons.check_circle,
                            color: color.primary,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${_userBName ?? ''} ${TranslationHandler.get('contract_joined')}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: color.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ] else ...[
                          Icon(
                            Icons.hourglass_empty,
                            color: color.onSurface.withValues(alpha: 0.5),
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            TranslationHandler.get('scan_contract_prompt'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: color.onSurface.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],

                        const SizedBox(height: 20),
                        const Divider(thickness: 1),
                        const SizedBox(height: 12),

                        // Share text / link
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _shareText,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: color.onSurface.withValues(alpha: 0.6),
                                  fontFamily: 'monospace',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: _copyToClipboard,
                              icon: Icon(Icons.copy, color: color.primary),
                              tooltip: TranslationHandler.get('link_copied'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Warning
                        Text(
                          TranslationHandler.get('share_warning'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: color.error,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Status message - waiting for user B or processing
                if (_isWaitingForUserB && !_userBJoined)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: color.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          TranslationHandler.get('waiting_for_user_b'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: color.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (_isWaitingForSign)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: color.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          TranslationHandler.get('waiting_for_acceptance'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: color.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),

                // Cancel button - always available
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      if (_isWaitingForSign) {
                        SnackBarHandler.showWarning(
                          context,
                          TranslationHandler.get('waiting_for_acceptance'),
                        );
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: color.error,
                    ),
                    child: Text(TranslationHandler.get('cancel')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
