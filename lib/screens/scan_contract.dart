import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yack/db/online.dart' as online_db;
import 'package:yack/db/models/contract.dart';
import 'package:yack/db/models/notification.dart';
import 'package:yack/main.dart';
import 'package:yack/utils/snackBarHandler.dart';
import 'package:yack/models/contract/contract_preview.dart';
import '../theme/theme.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:yack/utils/translation_handler.dart';

import '../widgets/secondaryActionButtonAutoLoading.dart';
import 'acceptDeclineContract.dart';

class ScanContractScreen extends StatefulWidget {
  const ScanContractScreen({super.key});

  @override
  State<ScanContractScreen> createState() => _ScanContractScreenState();
}

class _ScanContractScreenState extends State<ScanContractScreen> with WidgetsBindingObserver {
  bool _isScanning = false;
  bool _isProcessing = false; // Prevent multiple scans - (fixed issue: Chadli)
  bool _navigatingAway = false; // Prevent camera restart during navigation - fixed (Chadli)
  MobileScannerController? scannerController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset flags when screen becomes visible again (e.g., returning from navigation)
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
    scannerController?.dispose();
    super.dispose();
  }

  /// Safely navigate to home, avoiding navigator lock issues
  void _navigateToHome() {
    if (!mounted || _navigatingAway) return;
    _navigatingAway = true;
    
    // Use addPostFrameCallback to ensure navigation happens after current frame
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Use root navigator to properly exit all nested navigators
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    });
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

  // Process scanned QR code and navigate to contract preview (Chadli)
  void _onQRScanned(String code) async {
    // Validate QR format (Chadli)
    if (!code.startsWith('yack://contract?data=')) {
      if (mounted) {
        SnackBarHandler.showError(context, TranslationHandler.get('invalid_contract_qr'));
      }
      // Reset flags and allow scanning again
      _isProcessing = false;
      _navigatingAway = false;
      _startScanning();
      return;
    }

    try {
      // Decode Base64 contract data (Chadli)
      final uri = Uri.parse(code);
      final encodedData = uri.queryParameters['data'];
      if (encodedData == null || encodedData.isEmpty) {
        throw FormatException('Missing contract data');
      }

      final jsonString = utf8.decode(base64Url.decode(encodedData));
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final contractPreview = ContractPreview.fromJson(jsonMap);

      // Check if invitation exists (sharing must be started first)
      final invitationCheck = await online_db.seeInv(contractPreview.id);
      if (invitationCheck['exists'] != true) {
        if (mounted) {
          SnackBarHandler.showError(context, TranslationHandler.get('invitation_not_started'));
        }
        // Reset flags and allow scanning again
        _isProcessing = false;
        _navigatingAway = false;
        _startScanning();
        return;
      }

      if (!mounted) return;

      _navigatingAway = true;
      _stopScanning();
      
      // Navigate to accept/decline screen using userAName (Chadli)
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => AcceptDeclineContractScreen(
            title: contractPreview.name,
            price: contractPreview.price,
            userFirstName: contractPreview.userAName, // Use display name, not UID
            userLastName: '',
            description: contractPreview.description,
          ),
        ),
      );

      // Handle acceptance (Chadli)
      if (result == true) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            useRootNavigator: true,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
        }

        try {
          final currentUser = FirebaseAuth.instance.currentUser;
          final currentUserId = currentUser?.uid ?? 'test_user_${DateTime.now().millisecondsSinceEpoch}';
          
          // Prevent user from accepting their own contract
          if (contractPreview.userA == currentUserId) {
            if (mounted) {
              try {
                Navigator.of(context, rootNavigator: true).pop();
              } catch (_) {}
              SnackBarHandler.showError(context, TranslationHandler.get('cannot_accept_own_contract'));
            }
            _navigateToHome();
            return;
          }
          
          // Save contract to Isar (Chadli)
          final contract = Contract()
            ..externalId = contractPreview.id
            ..name = contractPreview.name
            ..description = contractPreview.description ?? ''
            ..price = contractPreview.price
            ..userA = contractPreview.userA
            ..userAName = contractPreview.userAName
            ..userB = currentUserId
            ..status = ContractStatus.accepted
            ..createdAt = DateTime.now();

          await isar.writeTxn(() async {
            await isar.contracts.put(contract);
          });

          // Create silent notification (Chadli)
          final appNotification = AppNotification()
            ..title = TranslationHandler.get('contract_accepted_notification')
            ..description = TranslationHandler.get('contract_accepted_notification_desc')
            ..createdAt = DateTime.now()
            ..isRead = true
            ..contractId = contract.id;

          await isar.writeTxn(() async {
            await isar.appNotifications.put(appNotification);
          });

          // Sync with Firebase (Chadli)
          if (contractPreview.id.isNotEmpty) {
            try {
              await online_db.acceptContract(
                contractPreview.id, 
                currentUserId,
                {
                  "title": contractPreview.name,
                  "details": contractPreview.description ?? '',
                  "price": contractPreview.price
                },
                contractPreview.userA
              );
            } catch (_) {}
          }

          if (mounted) {
            try {
              Navigator.of(context, rootNavigator: true).pop();
            } catch (_) {}
          }
          
          await Future.delayed(const Duration(milliseconds: 100));

          if (mounted) {
            SnackBarHandler.showSuccess(context, TranslationHandler.get('contract_saved_successfully'));
          }
          
          _navigateToHome();
          return;
        } catch (_) {
          if (mounted) {
            try {
              Navigator.of(context, rootNavigator: true).pop();
            } catch (_) {}
            SnackBarHandler.showError(context, TranslationHandler.get('failed_to_save_contract'));
          }
          await Future.delayed(const Duration(milliseconds: 100));
          _navigateToHome();
          return;
        }
      }
      
      // Handle decline (Chadli)
      if (result == false) {
        try {
          await isar.writeTxn(() async {
            final appNotification = AppNotification()
              ..title = TranslationHandler.get('contract_declined_notification')
              ..description = TranslationHandler.get('contract_declined_notification_desc')
              ..createdAt = DateTime.now()
              ..isRead = true
              ..contractId = null;
            await isar.appNotifications.put(appNotification);
          });
        } catch (_) {}
      }

      _navigateToHome();
    } catch (_) {
      if (mounted) {
        SnackBarHandler.showError(context, TranslationHandler.get('failed_to_decode_contract'));
      }
      // Reset flags and allow scanning again
      _isProcessing = false;
      _navigatingAway = false;
      _startScanning();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(TranslationHandler.get('scan'),
            style: Theme.of(context).textTheme.titleMedium),
      ),
      body: _isScanning
          ? Stack(
        children: [
          MobileScanner(
            controller: scannerController,
            onDetect: (capture) {
              // Extra guard at the callback level
              if (_isProcessing) return;
              
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;
                if (code != null) {
                  // Set processing flag immediately before async call
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
                  Positioned(
                    top: -2,
                    left: -2,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: AppTheme.yackGreen,
                            width: 8,
                          ),
                          left: BorderSide(
                            color: AppTheme.yackGreen,
                            width: 8,
                          ),
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
                          top: BorderSide(
                            color: AppTheme.yackGreen,
                            width: 8,
                          ),
                          right: BorderSide(
                            color: AppTheme.yackGreen,
                            width: 8,
                          ),
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
                          bottom: BorderSide(
                            color: AppTheme.yackGreen,
                            width: 8,
                          ),
                          left: BorderSide(
                            color: AppTheme.yackGreen,
                            width: 8,
                          ),
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
                          bottom: BorderSide(
                            color: AppTheme.yackGreen,
                            width: 8,
                          ),
                          right: BorderSide(
                            color: AppTheme.yackGreen,
                            width: 8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 120,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                TranslationHandler.get('place_code_in_frame'),
                style: TextStyle(
                  color: AppTheme.yackWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Stop Scanning Button
          Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: SecondaryActionButtonAutoReload(
                  action: TranslationHandler.get('stop_scanning'),
                  onClick: _stopScanning)

          ),        ],
      )
          : Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.yackGreenLight,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.yackGreen.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.qr_code_scanner,
                    size: 120,
                    color: AppTheme.yackGreen,
                  ),
                ),
                const SizedBox(height: 40),

                Text(
                  TranslationHandler.get('scan_contract_qr_code'),
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                Text(
                  TranslationHandler.get('scan_instructions'),
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(
                    color: AppTheme.yackGray,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.yackDivider,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildInstructionRow(
                        icon: Icons.camera_alt,
                        text: TranslationHandler.get('instruction_good_lighting'),
                      ),
                      const SizedBox(height: 16),
                      _buildInstructionRow(
                        icon: Icons.center_focus_strong,
                        text: TranslationHandler.get('instruction_center_code'),
                      ),
                      const SizedBox(height: 16),
                      _buildInstructionRow(
                        icon: Icons.check_circle_outline,
                        text: TranslationHandler.get('instruction_auto_scan'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Floating Action Button in ListView
                FloatingActionButton.extended(
                  onPressed: _startScanning,
                  backgroundColor: AppTheme.yackGreen,
                  foregroundColor: AppTheme.yackWhite,
                  elevation: 4,
                  icon: Icon(
                    Icons.qr_code_scanner,
                    color: AppTheme.yackWhite,
                  ),
                  label: Text(
                    TranslationHandler.get('start_scanning'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.yackGreenLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.yackGreen, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}