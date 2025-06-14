import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import '../providers/journey_provider.dart';
import '../providers/discover_provider.dart';
import '../providers/nav_provider.dart';
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
    _logJourneyScreenInteraction();
  }

  Future<void> _loadUserEmail() async {
    // For testing/debugging, use test03@gmail.com
    setState(() {
      _userEmail = "test03@gmail.com";
    });
  }

  Future<void> _logJourneyScreenInteraction() async {
    if (_userEmail != null && widget.tile != null) {
      await _journeyService.logJourneyScreenInteraction(
        _userEmail!,
        widget.tile!['objectId'] ?? '',
        'screen_view',
      );
    }
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

    // Debug: Log tile data being passed to journey screen
    print('=== JOURNEY SCREEN TILE DATA DEBUG ===');
    print('widget.tile: ${widget.tile}');
    print('widget.tile objectId: ${widget.tile?['objectId']}');
    print('widget.tile title: ${widget.tile?['title']}');
    
    final journeyId = widget.tile?['objectId'] ?? '6Gr4B9SkA3'; // Use default journey ID for testing
    print('Final journeyId being used: $journeyId');
    print('=========================================');
    
    final journeyStats = ref.watch(journeyStatsProvider(JourneyStatsRequest(
      userEmail: _userEmail!,
      journeyId: journeyId,
    )));
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
                          // Current Journey Card - Use tile data directly instead of currentJourneyProvider
                          journeyStats.when(
                            data: (stats) => JourneyCard(
                              title: widget.tile?['title'] ?? 'No Title',
                              subtitle: widget.tile?['subtitle'] ?? 'No Subtitle',
                              progress: stats['levelCompletion'] ?? '0%',
                              imageUrl: widget.tile?['imageUrl'] ?? '',
                              onTap: () {
                                _journeyService.logJourneyScreenInteraction(
                                  _userEmail!,
                                  widget.tile?['objectId'] ?? '',
                                  'journey_card_tap',
                                );
                              },
                            ),
                            loading: () => JourneyCard(
                              title: widget.tile?['title'] ?? 'No Title',
                              subtitle: widget.tile?['subtitle'] ?? 'No Subtitle',
                              progress: '0%',
                              imageUrl: widget.tile?['imageUrl'] ?? '',
                              onTap: () {
                                _journeyService.logJourneyScreenInteraction(
                                  _userEmail!,
                                  widget.tile?['objectId'] ?? '',
                                  'journey_card_tap',
                                );
                              },
                            ),
                            error: (error, stack) => JourneyCard(
                              title: widget.tile?['title'] ?? 'No Title',
                              subtitle: widget.tile?['subtitle'] ?? 'No Subtitle',
                              progress: '0%',
                              imageUrl: widget.tile?['imageUrl'] ?? '',
                              onTap: () {
                                _journeyService.logJourneyScreenInteraction(
                                  _userEmail!,
                                  widget.tile?['objectId'] ?? '',
                                  'journey_card_tap',
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // All Journey Button
                          JourneyListItem(
                            onTap: () {
                              _journeyService.logJourneyScreenInteraction(
                                _userEmail!,
                                widget.tile?['objectId'] ?? '',
                                'all_journey_tap',
                              );
                              // Navigate to discovery screen with journey tab selected
                              // Set journey tab as selected in discovery screen
                              ref.read(discoverUIStateProvider.notifier).selectButton(0);
                              // Navigate to discovery screen (index 2 in main screen)
                              ref.read(selectedTabProvider.notifier).state = 2;
                              Navigator.pop(context); // Go back to main screen
                            },
                          ),
                          const SizedBox(height: 16),
                          // Progress Stats
                          journeyStats.when(
                            data: (stats) => Column(
                              children: [
                                StatsCard(
                                  completionValue: stats['levelCompletion'] ?? '0%',
                                  eventsValue: stats['eventsCompleted'] ?? '0',
                                  skillCompletionValue: stats['skillCompletion'],
                                  userEmail: _userEmail,
                                ),
                              ],
                            ),
                            loading: () => const Center(
                                child: CircularProgressIndicator()),
                            error: (error, stack) => Column(
                              children: [
                                Center(
                                  child: Text(
                                    'Error loading stats: $error',
                                    style: const TextStyle(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: Text(
                                    'Journey ID: $journeyId',
                                    style: const TextStyle(color: Colors.yellow, fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: Text(
                                    'User: $_userEmail',
                                    style: const TextStyle(color: Colors.yellow, fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
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
                                  _journeyService.logJourneyScreenInteraction(
                                    _userEmail!,
                                    widget.tile?['objectId'] ?? '',
                                    'level_tap',
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
        ],
      ),
    );
  }
}
