// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_application_vallet_cars/home_pages/home_page.dart';
import 'package:flutter_application_vallet_cars/welcome_and_sign_pages/signup_page.dart';
import 'package:flutter_application_vallet_cars/welcome_and_sign_pages/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
