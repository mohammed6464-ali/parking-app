// ignore_for_file: unused_element

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_vallet_cars/welcome_and_sign_pages/signup_page.dart';

// اسم التطبيق الظاهر بجانب الأيقونة
const String kAppName = 'ValletCar'; // غيّرها لو حابب

void main() => runApp(
  const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OnboardingScreen(),
  ),
);

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pc = PageController();
  int _index = 0;

  final _pages = const [
    _PageData(
      image: 'assets/img/cars-parking.jpg',
      title: 'Find Parking Easily',
      desc:
          'No more endless searching! Spot available parking spots in real time and navigate with ease',
    ),
    _PageData(
      image: 'assets/img/jeep-car.jpg',
      title: 'Book & Pay Fast',
      desc:
          'Reserve your spot in seconds and pay securely. Skip tickets and queues effortlessly',
    ),
    _PageData(
      image: 'assets/img/old-car.jpg',
      title: 'Valet On-Demand',
      desc:
          'Request a valet, hand off your keys, and track your car’s status right from the app',
    ),
  ];

  void _next() {
    if (_index < _pages.length - 1) {
      _pc.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    } else {
      // TODO: وجّه لصفحة الدخول/الرئيسية
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const SignAndRejisterPage()));
    }
  }

  void _skip() =>
      _next(); // نفس سلوك الصورة: يتخطى بسرعة (تقدر توديه Home مباشرة)

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = _pages.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ---- الخلفية (الصور) ----
          PageView.builder(
            controller: _pc,
            itemCount: total,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) {
              final p = _pages[i];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(p.image, fit: BoxFit.cover),
                  // تفتيح أعلى + ضباب خفيف أسفل مثل الصورة
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x66FFFFFF),
                          Color(0x1AFFFFFF),
                          Color(0x80FFFFFF),
                          Color(0xCCFFFFFF),
                        ],
                        stops: [0.0, 0.28, 0.72, 0.90],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // ---- Top bar (progress + logo + Skip) ----
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  // Progress (3 شرائح بعرض الشاشة)
                  Expanded(
                    child: Row(
                      children: List.generate(total, (i) {
                        final active = i == _index;
                        return Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            height: 8,
                            margin: EdgeInsets.only(
                              right: i == total - 1 ? 0 : 10,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? const Color(0xFF3F7CFF)
                                  : const Color(0xFFB9BFCA),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // زر Skip كما في الصورة (حافة رمادية وشفافية خفيفة)
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignAndRejisterPage(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      backgroundColor: Colors.white.withOpacity(.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                        side: BorderSide(color: Colors.black.withOpacity(.15)),
                      ),
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---- شعار + اسم التطبيق (يسار أعلى) ----

          // ---- اللوحة السفلية: العنوان + الوصف + الزر ----
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _pages[_index].title,
                      key: ValueKey(_pages[_index].title),
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        height: 1.15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _pages[_index].desc,
                      key: ValueKey(_pages[_index].desc),
                      style: const TextStyle(
                        fontSize: 16.5,
                        color: Color(0xFF2E3440),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  // زر أزرق دائري كبير بعرض الشاشة مع سهم
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F7CFF),
                        elevation: 0,
                        shape: const StadiumBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _index == total - 1 ? 'Get Started' : 'Next',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageData {
  final String image, title, desc;
  const _PageData({
    required this.image,
    required this.title,
    required this.desc,
  });
}
