import 'package:flutter/material.dart';
import 'package:yack/widgets/primaryActionButtonAutoLoading.dart';
import 'package:yack/utils/snackBarHandler.dart';
import 'package:yack/widgets/secondaryActionButtonAutoLoading.dart';
import 'package:yack/utils/translation_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AcceptDeclineContractScreen extends StatefulWidget {
  final String title;
  final double price;
  final String? description;
  final String userFirstName;
  final String userLastName;

  const AcceptDeclineContractScreen({
    super.key,
    required this.title,
    required this.price,
    required this.userFirstName,
    required this.userLastName,
    this.description,
  });

  @override
  State<AcceptDeclineContractScreen> createState() =>
      _AcceptDeclineContractScreenState();
}

class _AcceptDeclineContractScreenState
    extends State<AcceptDeclineContractScreen> {
  String? _translatedTitle;
  String? _translatedDescription;
  bool _isTranslating = false;

  // Translation using MyMemory API: Chadli
  Future<void> _translateContent() async {
    setState(() => _isTranslating = true);

    try {
      final currentLang = TranslationHandler.currentLanguage;
      final targetLang = currentLang == 'ar'
          ? 'ar'
          : currentLang == 'fr'
          ? 'fr'
          : 'en';

      // translate title
      final titleResponse = await http.get(
        Uri.parse(
          'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(widget.title)}&langpair=en|$targetLang',
        ),
      );

      // translate description
      final descResponse = await http.get(
        Uri.parse(
          'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(widget.description ?? '')}&langpair=en|$targetLang',
        ),
      );

      if (titleResponse.statusCode == 200) {
        // success
        final titleJson = json.decode(titleResponse.body);
        _translatedTitle = titleJson['responseData']['translatedText'];
      }
      if (descResponse.statusCode == 200) {
        // success
        final descJson = json.decode(descResponse.body);
        _translatedDescription = descJson['responseData']['translatedText'];
      }
      setState(() {});
    } catch (e) {
      SnackBarHandler.showError(
        context,
        TranslationHandler.get('translation_failed'),
      );
    } finally {
      setState(() => _isTranslating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          TranslationHandler.get('contract_review'),
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
            // Contract Container
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sender info
                    Row(
                      children: [
                        const Icon(Icons.person, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          TranslationHandler.resolve(
                            'from_user',
                            params: {
                              'name':
                                  '${widget.userFirstName} ${widget.userLastName}',
                            },
                          ),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: color.onSurface.withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 25, thickness: 1),

                    // Centered Contract Title
                    Center(
                      child: Text(
                        _translatedTitle ?? widget.title, // updated
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: color.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(height: 25, thickness: 1),

                    // Description
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text( // updated
                          _translatedDescription ?? widget.description ?? TranslationHandler.get('accept_decline_description'),
                          textAlign: TextAlign.justify,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: color.onSurface.withOpacity(0.85),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Price aligned bottom-right
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        "${TranslationHandler.get('price_label')}: ${widget.price.toStringAsFixed(2)} ${TranslationHandler.get('currency')}",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: color.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Warning message
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: color.errorContainer.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.error.withOpacity(0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: color.error,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      TranslationHandler.get('binding_warning'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: color.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // added translation button: Chadli
            TextButton.icon(
              onPressed: _isTranslating ? null : _translateContent,
              icon: _isTranslating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.translate, size: 18),
              label: Text(TranslationHandler.get('translate_contract')),
            ),
            const SizedBox(height: 12),

            // Accept / Decline buttons (Chadli)
            PrimaryActionButtonAutoReload(
              action: TranslationHandler.get('accept_contract'),
              onClick: () async {
                await Future.delayed(const Duration(milliseconds: 500));
                Navigator.pop(context, true);
              },
            ),
            const SizedBox(height: 5),

            SecondaryActionButtonAutoReload(
              action: TranslationHandler.get('decline_contract'),
              onClick: () {
                Navigator.pop(context, false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
