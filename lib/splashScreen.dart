import 'package:flutter/material.dart';
import 'package:live_care/mainPage.dart';

import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    // Start the animation
    _animationController.forward();

    // Navigate to the next screen after the animation is complete
    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Navigate to the next screen (replace SplashScreen with DoctorDetails)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.cyan.shade300, // You can change the background color
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Text(
            'Appointment Booked',
            style: TextStyle(
              letterSpacing: 1,
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
