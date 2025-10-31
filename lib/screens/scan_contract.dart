import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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

  void _onQRScanned(String code) {
    scannerController?.stop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contract scanned: $code'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.yackGreen,
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Contract'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Place the QR code inside the frame',
                      style: TextStyle(
                        color: AppTheme.yackWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
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
                            'Scan Contract QR Code',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),

                          Text(
                            'Point your camera at the QR code to open the contract.',
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
                                  text: 'Use good lighting',
                                ),
                                const SizedBox(height: 16),
                                _buildInstructionRow(
                                  icon: Icons.center_focus_strong,
                                  text: 'Keep the QR code centered and steady',
                                ),
                                const SizedBox(height: 16),
                                _buildInstructionRow(
                                  icon: Icons.check_circle_outline,
                                  text: 'Scanning happens automatically',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _startScanning,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.yackGreen,
                          foregroundColor: AppTheme.yackWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.qr_code_scanner,
                              color: AppTheme.yackWhite,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Start Scanning',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
