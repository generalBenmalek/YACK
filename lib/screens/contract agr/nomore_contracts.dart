import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NoMoreContractsAvailable extends StatelessWidget {
  const NoMoreContractsAvailable({super.key});

  @override
  Widget build(BuildContext context) {
    // Define custom colors
    const Color primaryColor = Color(0xFF2ECC71);
    const Color primaryDarkColor = Color(0xFF27AE60);
    const Color textPrimaryColor = Color(0xFF2C3E50);
    const Color textSecondaryColor = Color(0xFF7F8C8D);
    const Color backgroundLightColor = Color(0xFFFFFFFF);
    const Color backgroundDarkColor = Color(0xFF101C22);
    const Color containerLightColor = Color(0xFFF4F6F6);

    // System UI overlay for light theme
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: backgroundLightColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with close icon and title
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(), // Assuming close navigates back
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        Icons.close,
                        size: 24,
                        color: textPrimaryColor,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'No More Contracts Available',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.015 * 18,
                          color: textPrimaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer for symmetry
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
                    const Column(
                      children: [
                        Text(
                          'No More Contracts Left',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.015 * 20,
                            color: textPrimaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Sorry, you've used all the contracts available on your current plan.",
                          style: TextStyle(
                            fontSize: 16,
                            color: textSecondaryColor,
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
                          color: primaryColor,
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
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.25,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Upgrade Your Plan',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.015 * 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.trending_up,
                              size: 32,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Maybe Later
                    GestureDetector(
                      onTap: () {}, // Handle later action
                      child: const Text(
                        'Maybe Later',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textSecondaryColor,
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

