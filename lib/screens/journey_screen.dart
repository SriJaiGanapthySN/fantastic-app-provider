import 'package:fantastic_app_riverpod/screens/all_journey.dart';
import 'package:fantastic_app_riverpod/widgets/single_video_background.dart';
import 'package:flutter/material.dart';

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const BackgroundVideo(
          videoPath: 'assets/videos/backgroundJourneyTask.mp4',
          isLooping: true,
          isMuted: true,
        ),
        SafeArea(child: const AllJourney()),
      ],
    );
  }
}
