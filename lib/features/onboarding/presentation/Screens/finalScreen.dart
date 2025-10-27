import 'package:flutter/material.dart';
import '../../../../main_screen.dart';
import '../../../../core/services/onboarding_service.dart';

class OnboardingCompletedScreen extends StatefulWidget {
  const OnboardingCompletedScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingCompletedScreen> createState() =>
      _OnboardingCompletedScreenState();
}

class _OnboardingCompletedScreenState extends State<OnboardingCompletedScreen> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    // Automatically complete onboarding and navigate after a brief moment
    _completeOnboardingAndNavigate();
  }

  Future<void> _completeOnboardingAndNavigate() async {
    if (_isNavigating) return;

    setState(() {
      _isNavigating = true;
    });

    // Wait a moment to show the completion screen
    await Future.delayed(const Duration(seconds: 2));

    // Mark onboarding as complete
    await OnboardingService.setOnboardingComplete();

    // Navigate to main screen
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false, // Remove all previous routes
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6B46C1),
              Color(0xFF2D3748),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 100,
                color: Colors.white,
              ),
              SizedBox(height: 30),
              Text(
                'Onboarding Completed!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Welcome to your Fantastic journey',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
