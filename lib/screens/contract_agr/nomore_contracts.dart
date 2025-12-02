import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yack/utils/translation_handler.dart';

class NoMoreContractsAvailable extends StatelessWidget {
  const NoMoreContractsAvailable({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    // System UI overlay adjusts automatically for dark/light
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
      isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness:
      isDark ? Brightness.dark : Brightness.light,
    ));
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with close icon and title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        Icons.close,
                        size: 24,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        TranslationHandler.get('no_more_contracts_available'),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onBackground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                child: Column(
                  children: [
                    // Image - using local asset
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Center(
                        child: Image.asset(
                          'assets/images/no_more_contracts.png',
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title and subtitle
                    Column(
                      children: [
                        Text(
                          TranslationHandler.get('no_more_contracts_left'),
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onBackground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          TranslationHandler.get('no_more_contracts_description'),
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Upgrade card - navigates to subscription page (Chadli)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/subscription');
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      TranslationHandler.get('go_unlimited'),
                                      style: textTheme.labelSmall?.copyWith(
                                        letterSpacing: 1.25,
                                        color: colorScheme.onPrimary
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      TranslationHandler.get('upgrade_plan'),
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward,
                                size: 32,
                                color: colorScheme.onPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Maybe Later
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        TranslationHandler.get('maybe_later'),
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
