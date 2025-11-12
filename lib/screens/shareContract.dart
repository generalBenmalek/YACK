import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:yack/utils/snackBarHandler.dart';
import 'package:yack/widgets/primaryActionButtonAutoLoading.dart';
import 'package:yack/utils/translation_handler.dart';

import 'acceptDeclineContract.dart';

class ShareContractScreen extends StatelessWidget {
  final String title;
  final double price;
  final String userFirstName;
  final String userLastName;
  final String contractLink;

  const ShareContractScreen({
    super.key,
    required this.title,
    required this.price,
    required this.userFirstName,
    required this.userLastName,
    required this.contractLink,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

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
      body: Padding(
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
                      data: contractLink,
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
                    TextFormField(
                      initialValue: contractLink,
                      readOnly: true,
                      obscureText: true, // protected
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.copy),
                          color: color.primary,
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: contractLink),
                            );
                            SnackBarHandler.showSuccess(
                              context,
                              TranslationHandler.get('link_copied'),
                            );
                          },
                        ),
                        filled: true,
                        fillColor: color.surfaceVariant.withOpacity(0.4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: color.outline.withOpacity(0.4),
                          ),
                        ),
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: color.onSurface,
                        letterSpacing: 3,
                      ),
                    ),
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

            const SizedBox(height: 30),
            // Proceed Button
            PrimaryActionButtonAutoReload(
              action: TranslationHandler.get('proceed_to_sign'),
              onClick: () async {
                // Navigate to Accept/Decline screen for confirmation
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AcceptDeclineContractScreen(
                      title: title,
                      price: price,
                      userFirstName: userFirstName,
                      userLastName: userLastName,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
