import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/premium_button.dart';

class JourneyRoadmapScreen extends StatelessWidget {
  const JourneyRoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0B1F), // Dark background color
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0E0B1F),
              Color(0xFF1A1A2E),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              const Text(
                "Journey Roadmap",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Thinking about next step?",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 16),
              _currentJourneyCard(),
              const SizedBox(height: 20),
              _progressOverview(),
              const SizedBox(height: 20),
              _journeySteps(),
              const SizedBox(height: 20),
              // Premium Button
              const PremiumButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _currentJourneyCard() {
    return _infoCard(
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/moon.svg',
            height: 40,
            width: 40,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "A Fabulous Night",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Build habits to help you sleep soundly",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const Text(
            "2%",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressOverview() {
    return _infoCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _progressItem("2%", "Completion"),
          _progressItem("1/48", "Events Achieved"),
        ],
      ),
    );
  }

  static Widget _progressItem(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  Widget _journeySteps() {
    return Column(
      children: [
        _journeyStep(
            "Manufacture Your Best Night's Sleep", "1/6 achieved", true),
        _journeyStep(
            "Design the Perfect Sleep Environment", "Not yet unlocked", false),
        _journeyStep("Create Your Bedtime Routine", "Not yet unlocked", false),
      ],
    );
  }

  Widget _journeyStep(String title, String status, bool unlocked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: _infoCard(
        child: Row(
          children: [
            Icon(
              unlocked ? Icons.nightlight_round : Icons.lock,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    status,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: unlocked ? () {} : null,
              icon: Icon(
                Icons.arrow_forward_ios,
                color: unlocked ? Colors.white : Colors.white30,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}
