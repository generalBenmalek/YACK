import 'package:flutter/material.dart';
import '../db/models/contract.dart';
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:yack/widgets/primaryActionButtonAutoLoading.dart';
import 'package:yack/utils/translation_handler.dart';
import 'acceptDeclineContract.dart';
import 'sign_contract.dart';

class ShareContractScreen extends StatelessWidget {
  final Contract contract;

  const ShareContractScreen({super.key, required this.contract});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final jsonString = json.encode({
      'id': contract.mongoId,
      'name': contract.name,
      'price': contract.price,
      'description': contract.description,
      'userA': contract.userA,
    });
    final encodedData = base64Url.encode(utf8.encode(jsonString));
    final link = "yack://contract?data=$encodedData";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          TranslationHandler.get('share_contract'),
          style: theme.textTheme.titleMedium,
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      backgroundColor: color.background,
      body: Stack(
        children: [
          // Hidden button for signing simulation (top-left corner)
          Positioned(
            left: 0,
            top: 0,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SignContractScreen(),
                  ),
                );
              },
              behavior: HitTestBehavior.translucent,
              child: const SizedBox(
                width: 60,
                height: 60,
              ),
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Contract container
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: color.outline.withOpacity(0.5),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: color.surface,
                      boxShadow: [
                        BoxShadow(
                          color: color.shadow.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // QR Code
                        QrImageView(
                          data: link,
                          version: QrVersions.auto,
                          size: 180,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          TranslationHandler.get('scan_contract_prompt'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: color.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Divider
                        const Divider(thickness: 1, height: 10),
                        const SizedBox(height: 20),
                        // Alternative link field
                        Text(
                          TranslationHandler.get('alternative_link'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: color.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const SizedBox(height: 20),
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

                // const SizedBox(height: 30),
                // Proceed Button
                // PrimaryActionButtonAutoReload(
                //   action: TranslationHandler.get('proceed_to_sign'),
                //   onClick: () async {
                //     // Navigate to Accept/Decline screen for confirmation
                //     await Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (_) => AcceptDeclineContractScreen(
                //           title: contract.name,
                //           price: contract.price,
                //           userFirstName: contract.userA,
                //           userLastName: '',
                //           description: contract.description,
                //         ),
                //       ),
                //     );
                //   },
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
