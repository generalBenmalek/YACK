import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
                        'No More Contracts Available',
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
                    // Image
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Center(
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuCgnLO7hJcgz7fiGYeGrIKs4xhCy7vX0W2TEC_KOP7qgtruqOfPjdokze8Nu63k6wHBBRJaYvar9JUYA4twXltF9h_UgrfTU-ZdvjVSyAp3ht1UryGE4UsPkDDzeHp7zUfQUoTuf4RpQ8IFQ35ei3utV5ezr2iRdei5P1Ab_3Vsht0pWg-Cix62YcxnHqHVK4H1miw1nzjpVN5OpwkNI-ZdfZL7nBodAQLD_YGnpVys_t7lTqNWqXOJwc2J5RChGIjJsMzdowMgIilv',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title and subtitle
                    Column(
                      children: [
                        Text(
                          'No More Contracts Left',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onBackground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Sorry, you've used all the contracts available on your current plan.",
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Upgrade card
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
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
                                    'Go Unlimited',
                                    style: textTheme.labelSmall?.copyWith(
                                      letterSpacing: 1.25,
                                      color: colorScheme.onPrimary
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Upgrade Your Plan',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.trending_up,
                              size: 32,
                              color: colorScheme.onPrimary,
                            ),
                          ],
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
                        'Maybe Later',
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
