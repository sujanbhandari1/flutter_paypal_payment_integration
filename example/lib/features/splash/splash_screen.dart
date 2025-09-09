// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    initializeAnimationController();
    navigateToHomeScreen();
    super.initState();
  }


  /// Initializes the animation controller and defines the fade and scale animations.
  ///
  /// The animation controller is set up with a duration of 1100 milliseconds.
  /// The fade animation transitions opacity from 0 to 1 with an ease-in curve.
  /// The scale animation transitions scale from 0.7 to 2.0 with an ease-out curve.

  void initializeAnimationController(){
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }


  navigateToHomeScreen() {
    ///navigate the splash screen to home screen
    ///with some delay
    ///
    Future.delayed(const Duration(seconds: 4),(){
      context.goNamed('home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Text(
                'PayPal Example',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ),

            ),
          ),
        ],
      ),
    );
  }
}
