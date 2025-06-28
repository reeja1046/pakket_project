import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:pakket/getxcontroller/onboarding_controller.dart';
import 'package:pakket/core/constants/color.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.put(OnboardingController());
    final height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop(); // Exit the app
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: height * 0.05),
                  _buildSkipButton(controller),
                  Obx(
                    () => SizedBox(
                      height: height * 0.74,
                      width: double.infinity,
                      child: Image.asset(
                        controller.onboardingData[controller
                            .currentPage
                            .value]['image']!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
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
                child: _buildBottomContent(controller),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton(controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text('Skip'),
        const SizedBox(width: 7),
        CircleAvatar(
          backgroundColor: CustomColors.baseColor,
          child: IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: controller.skip,
          ),
        ),
        const SizedBox(width: 18),
      ],
    );
  }

  Widget _buildBottomContent(controller) {
    return Column(
      children: [
        // 👉 SmoothPageIndicator added here
        SmoothPageIndicator(
          controller: controller.pageController,
          count: controller.onboardingData.length,
          effect: const JumpingDotEffect(
            dotColor: Colors.white54,
            activeDotColor: Colors.white,
            dotHeight: 8,
            dotWidth: 8,
          ),
          onDotClicked: (index) {
            controller.pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            controller.currentPage.value = index;
          },
        ),

        const SizedBox(height: 14),
        SizedBox(
          height: 120,
          child: PageView.builder(
            controller: controller.pageController,
            itemCount: controller.onboardingData.length,
            onPageChanged: (index) {
              controller.currentPage.value = index;
            },
            itemBuilder: (context, index) {
              final item = controller.onboardingData[index];
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
            onPressed: controller.nextPage,
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
