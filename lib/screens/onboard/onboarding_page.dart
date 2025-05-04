import 'dart:ui';
import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/navigators/navigation_keys.dart';
import 'package:financial_app/screens/onboard/first_page.dart';
import 'package:financial_app/screens/onboard/fourth_page.dart';
import 'package:financial_app/screens/onboard/language_selection.dart';
import 'package:financial_app/screens/onboard/second_page.dart';
import 'package:financial_app/screens/onboard/third_pgae.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int currentPage = 0;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      setState(() {
        currentPage = _controller.page?.round() ?? 0;
      });
    });

    // Set initial status bar style.
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF456EFE),
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF456EFE),
            ),
          ),
          // Change alignment based on the current page
          Align(
            alignment: currentPage == 0
                ? const AlignmentDirectional(0.7, -0.6)
                : currentPage == 1
                    ? const AlignmentDirectional(0.9, -0.4)
                    : currentPage == 2
                        ? const AlignmentDirectional(0.7, 0.1)
                        : const AlignmentDirectional(-0.5, -0.2),
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD9D9D9).withOpacity(0.5),
              ),
            ),
          ),
          Align(
            alignment: currentPage == 0
                ? const AlignmentDirectional(-0.8, -0.6)
                : currentPage == 1
                    ? const AlignmentDirectional(-0.5, -0.3)
                    : currentPage == 2
                        ? const AlignmentDirectional(-0.2, 0.5)
                        : const AlignmentDirectional(0.0, 0.7),
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD9D9D9).withOpacity(0.5),
              ),
            ),
          ),
          Align(
            alignment: currentPage == 0
                ? const AlignmentDirectional(-0.08, 0.8)
                : currentPage == 1
                    ? const AlignmentDirectional(0.08, 0.5)
                    : currentPage == 2
                        ? const AlignmentDirectional(3, 0.2)
                        : const AlignmentDirectional(0.3, -0.5),
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD9D9D9).withOpacity(0.5),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 50.0,
              sigmaY: 50.0,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: 600,
                child: PageView(
                  controller: _controller,
                  children: const [
                    LanguageSelection(),
                    FirstPage(),
                    SecondPage(),
                    ThirdPage(),
                    FourthPage(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero, // Remove internal padding
                        minimumSize: Size.zero, // Remove minimum button size
                        tapTargetSize: MaterialTapTargetSize
                            .shrinkWrap, // Shrink to fit content
                      ),
                      onPressed: () {
                        currentPage != 0
                            ? _controller.jumpToPage(4)
                            : null; //Jump to last page
                      },
                      child: Text(
                        currentPage != 0
                            ? AppLocalizations.of(context).translate('skip')
                            : '',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SmoothPageIndicator(
                      onDotClicked: (index) {
                        _controller.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      controller: _controller,
                      count: 5,
                      effect: const ExpandingDotsEffect(
                        activeDotColor: Colors.white,
                        dotColor: Colors.white30,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(18),
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () {
                        int nextPage = currentPage + 1;
                        if (nextPage < 5) {
                          _controller.animateToPage(
                            nextPage,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          globalNavigatorKey.currentState!
                              .pushReplacementNamed('/login');
                        }
                      },
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.black,
                        size: 15,
                      ),
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
