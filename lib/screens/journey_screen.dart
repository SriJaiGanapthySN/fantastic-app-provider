import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import '../providers/journey_provider.dart';
import '../widgets/journey_card.dart';
import '../widgets/journey_list_item.dart';
import '../widgets/stats_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../utils/blur_container.dart';
import '../widgets/journey_levels_list.dart';
import '../widgets/premium_button.dart';
import '../services/journey_service.dart';
import '../models/skill.dart';
import '../models/skillTrack.dart';
import '../providers/auth_provider.dart';

class JourneyScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? tile;
  const JourneyScreen({Key? key, this.tile}) : super(key: key);

  @override
  ConsumerState<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends ConsumerState<JourneyScreen> {
  late VideoPlayerController _videoController;
  final JourneyService _journeyService = JourneyService();
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset(
        'assets/videos/fc5890dd77de131e0e032b98260ee54cfa710eda.mp4')
      ..initialize().then((_) {
        _videoController.setLooping(true);
        _videoController.play();
        setState(() {});
      });
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    // For testing/debugging, use test03@gmail.com
    setState(() {
      _userEmail = "test03@gmail.com";
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_userEmail == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentJourney = ref.watch(currentJourneyProvider(_userEmail!));
    final journeyStats = ref.watch(journeyStatsProvider(_userEmail!));
    final allJourneys = ref.watch(allJourneysProvider(_userEmail!));

    return Scaffold(
      backgroundColor: const Color(0xFF0E0B1F),
      body: Stack(
        children: [
          // Video Background
          Positioned.fill(
            child: _videoController.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController.value.size.width,
                      height: _videoController.value.size.height,
                      child: VideoPlayer(_videoController),
                    ),
                  )
                : const SizedBox(),
          ),
          // Main Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 32),
                          // Journey Roadmap Title
                          Center(
                            child: ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return LinearGradient(
                                  begin: Alignment(0, 0),
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white,
                                    const Color.fromARGB(154, 0, 0, 0)
                                        .withOpacity(0.7),
                                  ],
                                ).createShader(bounds);
                              },
                              child: const Text(
                                'Journey Roadmap',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.5,
                                  letterSpacing: 0.9,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          // Thinking about next step text
                          Center(
                            child: Text(
                              'Thinking about next step?',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.3,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Text(
                              'This research-based journey would be perfect for you to take on next.',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.7),
                                height: 1.4,
                                letterSpacing: 0.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Current Journey Card
                          currentJourney.when(
                            data: (journey) {
                              if (journey != null) {
                                return journeyStats.when(
                                  data: (stats) => JourneyCard(
                                    title: widget.tile?['title'] ?? 'No Title',
                                    subtitle: widget.tile?['subtitle'] ?? 'No Subtitle',
                                    progress: stats['completion'] ?? '0%',
                                    imageUrl: widget.tile?['imageUrl'] ?? '',
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const JourneyScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  loading: () => const Center(child: CircularProgressIndicator()),
                                  error: (_, __) => JourneyCard(
                                    title: widget.tile?['title'] ?? 'No Title',
                                    subtitle: widget.tile?['subtitle'] ?? 'No Subtitle',
                                    progress: '0%',
                                    imageUrl: widget.tile?['imageUrl'] ?? '',
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const JourneyScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              } else {
                                return JourneyCard(
                                  title: widget.tile?['title'] ??
                                      'Start Your Journey',
                                  subtitle: widget.tile?['subtitle'] ??
                                      'Begin your path to self-improvement',
                                  progress: '0%',
                                  imageUrl: widget.tile?['imageUrl'] ?? null,
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const JourneyScreen(),
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (error, stack) => Center(
                              child: Text(
                                'Error loading journey: $error',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // All Journey Button
                          JourneyListItem(
                            onTap: () {
                              // Handle all journey tap
                            },
                          ),
                          const SizedBox(height: 16),
                          // Progress Stats
                          journeyStats.when(
                            data: (stats) => StatsCard(
                              completionValue: stats['completion'] ?? 0,
                              eventsValue: stats['eventsAchieved'] ?? 0,
                            ),
                            loading: () => const Center(
                                child: CircularProgressIndicator()),
                            error: (_, __) => const Center(
                              child: Text('Error loading stats',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Journey Levels List Section
                          allJourneys.when(
                            data: (journeys) {
                              if (journeys.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No journeys available',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                );
                              }
                              return JourneyLevelsList(
                                journeyId: widget.tile?['objectId'] ?? '',
                                email: _userEmail!,
                                tile: widget.tile,
                                skillTrackId: widget.tile?['objectId'] ?? '',
                                onLevelTap: (levelId) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => JourneyScreen(
                                        tile: widget.tile,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            loading: () => const Center(
                                child: CircularProgressIndicator()),
                            error: (_, __) => const Center(
                              child: Text('Error loading journeys',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom navigation
          Positioned(
            left: 5,
            right: 5,
            bottom: 20,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: BlurContainer(
                borderRadius: 50,
                blur: 1,
                color: Colors.transparent,
                enableGlow: true,
                glowColor: Colors.white,
                glowIntensity: 0.09,
                glowSpread: 0,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  child: BottomNavBar(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
