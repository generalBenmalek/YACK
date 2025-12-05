import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/theme.dart';
import 'package:yack/logic/services/translation_handler.dart';

class SignContractScreen extends StatelessWidget {
  const SignContractScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title:
            Text(TranslationHandler.get('review_contract'), style: textTheme.titleLarge),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Semantics(
                      label: TranslationHandler.get('contract_qr_label'),
                      child: QrImageView(
                        data: 'https://example.com/contract/123456',
                        version: QrVersions.auto,
                        size: 200.0,
                        gapless: false,
                        foregroundColor: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14.0),
                  Text(
                    TranslationHandler.get('scan_contract_securely'),
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 36.0),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      TranslationHandler.get('contract_description_title'),
                      style: textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    TranslationHandler.get('contract_description_body'),
                    textAlign: TextAlign.start,
                    style: textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 30.0),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(TranslationHandler.get('price_label'),
                        style: textTheme.titleLarge),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    '200000.00 DA',
                    textAlign: TextAlign.start,
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.close),
                  label: Text(TranslationHandler.get('decline_contract')),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.yackGreen),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    foregroundColor: AppTheme.yackGreen,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check),
                  label: Text(TranslationHandler.get('sign_contract')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.yackGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
