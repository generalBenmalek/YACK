import 'package:flutter/material.dart';
import 'dart:convert';
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

class _ScanContractScreenState extends State<ScanContractScreen> {
  bool _isScanning = false;
  MobileScannerController? scannerController;

  @override
  void dispose() {
    scannerController?.dispose();
    super.dispose();
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
    setState(() {
      _isScanning = false;
      scannerController = null;
    });
  }

  void _onQRScanned(String code) {
    scannerController?.stop();

    // Step 1: Validate and extract the Base64 string from the link
    if (!code.startsWith('yack://contract?data=')) {
      SnackBarHandler.showError(
        context,
        TranslationHandler.get('invalid_contract_qr'),
      );
      _stopScanning();
      return;
    }

    try {
      // Step 2: Extract the Base64 encoded data from the link
      final uri = Uri.parse(code);
      final encodedData = uri.queryParameters['data'];

      if (encodedData == null || encodedData.isEmpty) {
        throw FormatException('Missing contract data');
      }

      // Step 3: Decode Base64 back into a JSON string
      final jsonString = utf8.decode(base64Url.decode(encodedData));

      // Step 4: Parse the JSON into a Dart map
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      // Step 5: Convert the map into a temporary ContractPreview object
      final contractPreview = ContractPreview.fromJson(jsonMap);

      SnackBarHandler.showSuccess(
        context,
        TranslationHandler.get('contract_decoded_successfully'),
      );

      // Step 6: Display the decoded information to the user
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AcceptDeclineContractScreen(
                title: contractPreview.name,
                price: contractPreview.price,
                userFirstName: contractPreview.userA,
                userLastName: '',
                description: contractPreview.description,
              ),
            ),
          );
        }
      });
    } catch (e) {
      SnackBarHandler.showError(
        context,
        TranslationHandler.get('failed_to_decode_contract'),
      );
      _stopScanning();
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
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;
                if (code != null) _onQRScanned(code);
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