import 'package:flutter/material.dart';
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

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.edit_document,
      title: 'Create Contracts Easily',
      subtitle: 'Draft and sign agreements in minutes with our intuitive interface',
      color: Color(0xFF00D563),
    ),
    OnboardingPage(
      icon: Icons.verified_user,
      title: 'Secure & Verified',
      subtitle: 'Every contract is tamper-proof and cryptographically protected',
      color: Color(0xFF00C2FF),
    ),
    OnboardingPage(
      icon: Icons.folder_open,
      title: 'Track Agreements',
      subtitle: 'Access and manage all your contracts in one secure place',
      color: Color(0xFF7C4DFF),
    ),
    OnboardingPage(
      icon: Icons.handshake,
      title: 'Start Building Trust',
      subtitle: 'Begin your journey with YACK and secure your agreements today',
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

  void _getStarted() {
    Navigator.pushReplacementNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final screenWidth = MediaQuery.of(context).size.width;

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
                    'YACK',
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
                const Text("Already Know About The App?"),
                const SizedBox(width: 5),
                HrefWidget(
                  text: 'Skip',
                  onClick: _skipToEnd,
                ),
              ],
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: _currentPage < _pages.length - 1
                  ?
                  PrimaryActionButton(action: 'Next', onClick: _nextPage)
                  : PrimaryActionButton(action: 'Get Started', onClick: _getStarted)
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
          TitleWidget(text: page.title),
          const SizedBox(height: 16),
          // Subtitle
          Text(
            page.subtitle,
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
