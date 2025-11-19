import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:yack/utils/translation_handler.dart';
import 'package:yack/widgets/primaryActionButton.dart';
import 'package:yack/widgets/titleWidget.dart';
import '../models/OnboardingData.dart';
import '../widgets/hrefTextWidget.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      icon: Icons.edit_document,
      titleKey: 'onboarding_create_contracts_title',
      subtitleKey: 'onboarding_create_contracts_subtitle',
      color: Color(0xFF00D563),
    ),
    OnboardingPage(
      icon: Icons.verified_user,
      titleKey: 'onboarding_secure_verified_title',
      subtitleKey: 'onboarding_secure_verified_subtitle',
      color: Color(0xFF00C2FF),
    ),
    OnboardingPage(
      icon: Icons.folder_open,
      titleKey: 'onboarding_track_agreements_title',
      subtitleKey: 'onboarding_track_agreements_subtitle',
      color: Color(0xFF7C4DFF),
    ),
    OnboardingPage(
      icon: Icons.handshake,
      titleKey: 'onboarding_start_trust_title',
      subtitleKey: 'onboarding_start_trust_subtitle',
      color: Color(0xFF00D563),
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _getStarted() async{
    final userBox = await Hive.openBox('user');
    await userBox.put('didFirstTime', true);

    Navigator.pushReplacementNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
        final theme = Theme.of(context);
        return Scaffold(
          body: SafeArea(
            child: Column(
          spacing: 10,
          children: [
            // Logo at top
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    TranslationHandler.get('app_name'),
                    style: theme.textTheme.titleMedium
                  ),
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                      (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 32 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            if (_currentPage < _pages.length - 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(TranslationHandler.get('remember_app')),
                  const SizedBox(width: 5),
                  HrefWidget(
                    text: TranslationHandler.get('skip'),
                    onClick: _skipToEnd,
                  ),
                ],
              ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: _currentPage < _pages.length - 1
                  ?
                  PrimaryActionButton(action: TranslationHandler.get('next'), onClick: _nextPage)
                  : PrimaryActionButton(action: TranslationHandler.get('get_started'), onClick: _getStarted)
              ),
          ],
        ),
          ),
        );
  }

  Widget _buildPage(OnboardingPage page) {
    final theme = Theme.of(context);


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration/Icon
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: page.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  page.icon,
                  size: 64,
                  color: page.color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          // Title
          TitleWidget(text: TranslationHandler.get(page.titleKey)),
          const SizedBox(height: 16),
          // Subtitle
          Text(
            TranslationHandler.get(page.subtitleKey),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
