import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive/hive.dart';
import 'package:yack/logic/cubits/contract/temp_contract_cubit.dart';
import 'package:yack/logic/cubits/contract/temp_contract_state.dart';
import 'package:yack/logic/cubits/contract/contract_sync_cubit.dart';
import 'package:yack/logic/services/auth/cryptoService.dart';
import 'package:yack/logic/services/notification/contract_notification_handler.dart';
import 'package:yack/logic/services/notification/notification_service.dart';
import 'package:yack/logic/services/snackBarHandler.dart';
import 'package:yack/presentation/theme/theme.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:yack/logic/services/translation_handler.dart';
import 'package:yack/presentation/screens/acceptDeclineContract.dart';

class ScanContractScreen extends StatefulWidget {
  const ScanContractScreen({super.key});

  @override
  State<ScanContractScreen> createState() => _ScanContractScreenState();
}

class _ScanContractScreenState extends State<ScanContractScreen>
    with WidgetsBindingObserver {
  bool _isScanning = false;
  bool _isProcessing = false;
  bool _navigatingAway = false;
  bool _isWaitingForUserASign = false;
  bool _userBSigned = false; // Track if User B has signed
  bool _showManualInput = false;
  MobileScannerController? scannerController;
  StreamSubscription<ContractNotificationEvent>? _notificationSubscription;
  StreamSubscription<RemoteMessage>? _firebaseSubscription;
  final TextEditingController _linkController = TextEditingController();

  // Scanned contract data
  String? _scannedTempId;
  String? _scannedTitle;
  String? _scannedDescription;
  double? _scannedPrice;
  String? _scannedUserAName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resetState();
  }

  void _resetState() {
    if (_navigatingAway || _isProcessing) {
      setState(() {
        _navigatingAway = false;
        _isProcessing = false;
        _isScanning = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notificationSubscription?.cancel();
    _firebaseSubscription?.cancel();
    _linkController.dispose();
    scannerController?.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    if (!mounted || _navigatingAway) return;
    _navigatingAway = true;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    });
  }

  /// Setup notification listener for User B after joining to listen for User A's actions
  void _setupNotificationListenerForTempContract(String tempId) {
    _notificationSubscription?.cancel();
    _firebaseSubscription?.cancel();

    final handler = NotificationService().contractHandler;

    // Listen via ContractNotificationHandler
    _notificationSubscription = handler.eventsForTempContract(tempId).listen((event) async {
      print('[ScanContract] ContractNotificationHandler event: ${event.type}, contractId: ${event.contractId}');

      switch (event.type) {
        case ContractNotificationType.contractSign:
          // User A signed the contract
          if (_isWaitingForUserASign && _userBSigned) {
            // Both users have signed - sync and complete
            await _syncAndNavigateHome();
          }
          break;
        default:
          break;
      }
    });

    // Also listen directly to Firebase messages as fallback
    _firebaseSubscription = FirebaseMessaging.onMessage.listen((message) async {
      final data = message.data;
      if (data.isEmpty) return;

      print('[ScanContract] Firebase message received: $data');

      final notifTempId = data['tempId']?.toString();
      // Only handle notifications for our temp contract
      if (notifTempId != tempId) {
        print('[DEBUG ScanContract] tempId mismatch: got $notifTempId, expected $tempId');
        return;
      }

      final type = data['type']?.toString() ?? '';
      print('[DEBUG ScanContract] Handling notification type: $type');

      if (type == 'contractSign' && _isWaitingForUserASign && _userBSigned) {
        // Both users have signed - sync and complete
        await _syncAndNavigateHome();
      }
    });

    print('[DEBUG ScanContract] Notification listeners set up for tempId: $tempId');
  }

  /// Sync contracts and navigate home
  Future<void> _syncAndNavigateHome() async {
    // Dismiss loading if showing
    if (mounted) {
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (_) {}
    }

    // Sync contracts from backend to get the finalized contract with decrypted data
    context.read<ContractSyncCubit>().sync();

    if (mounted) {
      SnackBarHandler.showSuccess(
        context,
        TranslationHandler.get('contract_saved_successfully'),
      );
    }
    _navigateToHome();
  }

  void _startScanning() {


    setState(() {
      _isScanning = true;
      scannerController = MobileScannerController();
    });
  }

  void _stopScanning() {

    scannerController?.stop();
    scannerController?.dispose();
    scannerController = null;
    if (mounted && !_navigatingAway) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  /// Get user's public key from Hive cache
  Future<String?> _getUserPublicKey() async {
    try {
      final box = await Hive.openBox('user');
      return box.get('publicKey')?.toString();
    } catch (_) {
      return null;
    }
  }

  // Process scanned QR code - store and process like manual input
  void _onQRScanned(String code) {

    _isProcessing = false;
    
    // Stop scanning first
    _stopScanning();

    // Store the scanned code in the controller
    _linkController.text = code;

    // Show manual input section with the scanned code
    setState(() {
      _showManualInput = true;
    });

    // Auto-trigger join after UI updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isProcessing) {
        _onManualLinkSubmit();
      }
    });
  }

  /// Process manual link input (yack://contract?data=...)
  void _onManualLinkSubmit() async {
    final input = _linkController.text.trim();
    if (input.isEmpty) {
      SnackBarHandler.showError(context, TranslationHandler.get('field_required_generic'));
      return;
    }

    if (_isProcessing) return;
    _isProcessing = true;

    setState(() => _showManualInput = false);

    // Handle full QR code data format
    if (input.startsWith('yack://contract?data=')) {
      await _processFullDataUrl(input);
    } else {
      SnackBarHandler.showError(context, TranslationHandler.get('invalid_contract_qr'));
      _isProcessing = false;
    }
  }

  /// Process contract by tempId only (for manual input or simple links)
  Future<void> _processContractByTempId(String tempId) async {
    if (_isProcessing) return;
    _isProcessing = true;

    // Stop scanning if it was active
    _stopScanning();

    setState(() => _showManualInput = false);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
    }

    _scannedTempId = tempId;
    // For manual input, we don't have preview data - will get from server response
    _scannedTitle = '';
    _scannedDescription = '';
    _scannedPrice = 0;
    _scannedUserAName = '';

    // Get user B's public key for encryption
    final publicKey = await _getUserPublicKey();
    if (publicKey == null || publicKey.isEmpty) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        SnackBarHandler.showError(context, TranslationHandler.get('missing_public_key'));
      }
      _isProcessing = false;
      return;
    }

    // For manual input without preview, encrypt placeholder values
    // The actual contract details will come from the server
    final titleUserB = CryptoService.encryptWithPublicKey(
      plaintext: 'Contract',
      publicKeyBase64: publicKey,
    );
    final descriptionUserB = CryptoService.encryptWithPublicKey(
      plaintext: 'Joined via link',
      publicKeyBase64: publicKey,
    );
    final priceUserB = CryptoService.encryptWithPublicKey(
      plaintext: '0',
      publicKeyBase64: publicKey,
    );

    // Join the temp contract immediately
    if (mounted) {
      context.read<TempContractCubit>().join(
        tempId: tempId,
        titleUserB: titleUserB,
        descriptionUserB: descriptionUserB,
        priceUserB: priceUserB,
      );
    }
  }

  /// Process full data URL with embedded contract preview info
  Future<void> _processFullDataUrl(String code) async {
    try {
      // Decode Base64 contract data
      final uri = Uri.parse(code);
      final encodedData = uri.queryParameters['data'];
      if (encodedData == null || encodedData.isEmpty) {
        throw FormatException('Missing contract data');
      }

      final jsonString = utf8.decode(base64Url.decode(encodedData));
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      // Extract contract data
      _scannedTempId = jsonMap['tempId']?.toString();
      _scannedTitle = jsonMap['title']?.toString() ?? '';
      _scannedDescription = jsonMap['description']?.toString() ?? '';
      _scannedPrice = (jsonMap['price'] is num)
          ? (jsonMap['price'] as num).toDouble()
          : double.tryParse(jsonMap['price']?.toString() ?? '0') ?? 0;
      _scannedUserAName = jsonMap['userAName']?.toString() ?? '';

      if (_scannedTempId == null || _scannedTempId!.isEmpty) {
        throw FormatException('Missing tempId');
      }

      if (!mounted) return;

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Get user B's public key for encryption
      final publicKey = await _getUserPublicKey();
      if (publicKey == null || publicKey.isEmpty) {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          SnackBarHandler.showError(context, TranslationHandler.get('missing_public_key'));
        }
        _isProcessing = false;
        _navigateToHome();
        return;
      }

      // Encrypt fields for user B using their own public key
      final titleUserB = CryptoService.encryptWithPublicKey(
        plaintext: _scannedTitle!,
        publicKeyBase64: publicKey,
      );
      final descriptionUserB = CryptoService.encryptWithPublicKey(
        plaintext: _scannedDescription!,
        publicKeyBase64: publicKey,
      );
      final priceUserB = CryptoService.encryptWithPublicKey(
        plaintext: _scannedPrice!.toStringAsFixed(2),
        publicKeyBase64: publicKey,
      );

      // Join the temp contract immediately after scanning
      context.read<TempContractCubit>().join(
        tempId: _scannedTempId!,
        titleUserB: titleUserB,
        descriptionUserB: descriptionUserB,
        priceUserB: priceUserB,
      );

    } catch (e) {
      if (mounted) {
        SnackBarHandler.showError(
          context,
          TranslationHandler.get('failed_to_decode_contract'),
        );
      }
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TempContractCubit, TempContractState>(
      listener: (context, state) async {
        if (state is TempContractJoinSuccess) {
          // Dismiss loading dialog
          if (mounted) {
            try {
              Navigator.of(context, rootNavigator: true).pop();
            } catch (_) {}
          }

          // Setup notification listener for User A's signature
          _setupNotificationListenerForTempContract(state.contract.tempId);

          // Use userA name from server response if we don't have it from scan
          final userAName = (state.contract.userAName != null && state.contract.userAName!.isNotEmpty)
              ? state.contract.userAName!
              : (_scannedUserAName ?? 'Unknown');

          // Store for later use when saving contract
          _scannedUserAName = userAName;

          print('[DEBUG ScanContract] User A name: $userAName (from server: ${state.contract.userAName}, from scan: $_scannedUserAName)');

          // Show accept/decline screen after successfully joining
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => AcceptDeclineContractScreen(
                title: _scannedTitle?.isNotEmpty == true ? _scannedTitle! : 'Contract',
                price: _scannedPrice ?? 0,
                userFirstName: userAName,
                userLastName: '',
                description: _scannedDescription ?? '',
              ),
            ),
          );

          if (result == true) {
            // User B accepted - show loading and sign the contract
            if (mounted) {
              showDialog(
                context: context,
                barrierDismissible: false,
                useRootNavigator: true,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );
            }
            context.read<TempContractCubit>().sign(state.contract.tempId);
          } else {
            // User B declined
            SnackBarHandler.showMessage(
              context,
              TranslationHandler.get('contract_declined'),
            );
            _navigateToHome();
          }
        } else if (state is TempContractSignSuccess) {
          print('[DEBUG ScanContract] TempContractSignSuccess - contractId: ${state.contractId}');

          // User B has signed
          setState(() {
            _userBSigned = true;
          });

          if (state.contractId != null && state.contractId!.isNotEmpty) {
            // Both users signed - contract is finalized, sync and go home
            print('[DEBUG ScanContract] Both signed, syncing contracts...');
            await _syncAndNavigateHome();
          } else {
            // User B signed but User A hasn't signed yet - wait for notification
            print('[DEBUG ScanContract] User B signed, waiting for User A...');
            setState(() {
              _isWaitingForUserASign = true;
            });

            // Keep loading dialog showing while waiting
            if (mounted) {
              SnackBarHandler.showMessage(
                context,
                TranslationHandler.get('waiting_for_user_a_sign'),
              );
            }
          }
        } else if (state is TempContractError) {
          // Dismiss loading dialog
          if (mounted) {
            try {
              Navigator.of(context, rootNavigator: true).pop();
            } catch (_) {}
            SnackBarHandler.showError(context, state.message);
          }
          _isProcessing = false;
          _navigateToHome();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            TranslationHandler.get('scan'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        body: _isScanning
            ? Stack(
                children: [
                  MobileScanner(
                    controller: scannerController,
                    onDetect: (capture) {
                      if (_isProcessing) return;

                      final List<Barcode> barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty) {
                        final String? code = barcodes.first.rawValue;
                        if (code != null) {
                          _isProcessing = true;
                          scannerController?.stop();
                          _onQRScanned(code);
                        }
                      }
                    },
                  ),
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.yackGreen, width: 4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          // Corner decorations
                          Positioned(
                            top: -2,
                            left: -2,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: AppTheme.yackGreen, width: 8),
                                  left: BorderSide(color: AppTheme.yackGreen, width: 8),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: AppTheme.yackGreen, width: 8),
                                  right: BorderSide(color: AppTheme.yackGreen, width: 8),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -2,
                            left: -2,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: AppTheme.yackGreen, width: 8),
                                  left: BorderSide(color: AppTheme.yackGreen, width: 8),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: AppTheme.yackGreen, width: 8),
                                  right: BorderSide(color: AppTheme.yackGreen, width: 8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 100,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          TranslationHandler.get('place_code_in_frame'),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ElevatedButton.icon(
                        onPressed: _stopScanning,
                        icon: const Icon(Icons.stop),
                        label: Text(TranslationHandler.get('stop_scanning')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : _buildInstructions(context),
      ),
    );
  }

  Widget _buildInstructions(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Icon(
            Icons.qr_code_scanner,
            size: 80,
            color: color.primary,
          ),
          const SizedBox(height: 24),
          Text(
            TranslationHandler.get('scan_contract_qr_code'),
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            TranslationHandler.get('scan_instructions'),
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildInstructionItem(
            context,
            Icons.lightbulb_outline,
            TranslationHandler.get('instruction_good_lighting'),
          ),
          const SizedBox(height: 12),
          _buildInstructionItem(
            context,
            Icons.center_focus_strong,
            TranslationHandler.get('instruction_center_code'),
          ),
          const SizedBox(height: 12),
          _buildInstructionItem(
            context,
            Icons.flash_auto,
            TranslationHandler.get('instruction_auto_scan'),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startScanning,
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(TranslationHandler.get('start_scanning')),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Divider with "OR" text
          Row(
            children: [
              Expanded(child: Divider(color: color.outline.withValues(alpha: 0.5))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  TranslationHandler.get('or'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              Expanded(child: Divider(color: color.outline.withValues(alpha: 0.5))),
            ],
          ),
          const SizedBox(height: 24),

          // Manual link paste section
          if (!_showManualInput)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _showManualInput = true),
                icon: const Icon(Icons.link),
                label: Text(TranslationHandler.get('enter_link_manually')),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

          if (_showManualInput) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: color.outline.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    TranslationHandler.get('paste_contract_link'),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _linkController,
                    decoration: InputDecoration(
                      hintText: 'yack://...',
                      prefixIcon: const Icon(Icons.link),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _onManualLinkSubmit(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _showManualInput = false;
                              _linkController.clear();
                            });
                          },
                          child: Text(TranslationHandler.get('cancel')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _onManualLinkSubmit,
                          child: Text(TranslationHandler.get('join_contract')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }
}
