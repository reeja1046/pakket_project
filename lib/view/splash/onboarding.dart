import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:pakket/core/constants/color.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Buy Groceries Easily\nwith Us',
      'description':
          'It is a long established fact that a reader\nwill be distracted by the readable',
      'image': 'assets/splash/grocery.png',
    },
    {
      'title': 'Fresh Fruits & Vegetables\nDelivered Daily',
      'description':
          'Get farm-fresh fruits and vegetables\ndelivered to your doorstep.',
      'image': 'assets/splash/veg-splash.png',
    },
    {
      'title': 'Quick & Secure Delivery\nfor Non-Veg Items',
      'description':
          'Order fresh meat and seafood\nwith safe and fast delivery.',
      'image': 'assets/splash/nonveg-splash.png',
    },
  ];

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacementNamed('/signup');
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final newPage = _pageController.page?.round() ?? 0;
      if (newPage != _currentPage) {
        setState(() => _currentPage = newPage);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop(); // ✅ This will close the app
        return false; // Prevents the default back navigation
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: height * 0.05),
                  _buildSkipButton(),
                  SizedBox(
                    height: height * 0.74,
                    width: double.infinity,
                    child: Image.asset(
                      _onboardingData[_currentPage]['image']!,
                      fit: BoxFit.cover,
                    ),
                  ),

                  SizedBox(),
                ],
              ),
              Positioned(
                bottom: 30,
                left: 15,
                right: 15,
                child: SvgPicture.asset('assets/splash/rectangle.svg'),
              ),
              Positioned(
                bottom: 45,
                left: 15,
                right: 15,
                child: _buildBottomContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text('Skip'),
        const SizedBox(width: 7),
        CircleAvatar(
          backgroundColor: CustomColors.baseColor,
          child: IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed('/signup'),
          ),
        ),
        const SizedBox(width: 18),
      ],
    );
  }

  Widget _buildBottomContent() {
    return Column(
      children: [
        SmoothPageIndicator(
          controller: _pageController,
          count: _onboardingData.length,
          effect: const JumpingDotEffect(
            dotColor: Colors.white54,
            activeDotColor: Colors.white,
            dotHeight: 8,
            dotWidth: 8,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 120,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              final item = _onboardingData[index];
              return _buildPage(item['title']!, item['description']!);
            },
          ),
        ),
        const SizedBox(height: 30),
        CircleAvatar(
          backgroundColor: Colors.white,
          radius: 25,
          child: IconButton(
            icon: Icon(Icons.arrow_forward, color: CustomColors.baseColor),
            onPressed: _nextPage,
          ),
        ),
      ],
    );
  }

  Widget _buildPage(String title, String description) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
