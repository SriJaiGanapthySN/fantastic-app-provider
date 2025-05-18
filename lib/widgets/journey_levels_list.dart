import 'package:fantastic_app_riverpod/providers/journey_provider.dart';
import 'package:fantastic_app_riverpod/screens/journey_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../screens/journey_screen.dart';
import '../utils/blur_container.dart';
import '../providers/journey_levels_provider.dart';
import '../widgets/premium_button.dart';
import '../screens/journey_reveal/journeyscreenrevealtype1.dart';
import '../screens/journey_reveal/journeyscreenrevealtype2.dart';
import '../screens/journey_reveal/journeyscreenrevealtype3.dart';
import '../models/skill.dart';
import '../models/skillTrack.dart';
import '../services/journey_service.dart' as js;

class LevelImage extends StatelessWidget {
  final String imageUrl;
  final String status;
  final bool isInProgress;
  final double size;
  final double animationSize;

  const LevelImage({
    Key? key,
    required this.imageUrl,
    required this.status,
    required this.isInProgress,
    this.size = 104,
    this.animationSize = 240,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Circular anti-clockwise animation (behind the image)
        if (status == 'completed' || status == 'in_progress')
          Positioned(
            left: -(animationSize - size) / 1.44,
            top: -(animationSize - size) / 2,
            child: Lottie.asset(
              'assets/animations/circular anti-clockwise/data.json',
              width: animationSize,
              height: animationSize,
              fit: BoxFit.cover,
              frameRate: FrameRate.max,
              repeat: true,
            ),
          ),
        // Image container
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Circle image with appropriate styling based on status
              if (status == 'locked')
                // Locked levels - black and white
                ColorFiltered(
                  colorFilter: const ColorFilter.matrix([
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0,
                    0,
                    0,
                    1,
                    0,
                  ]),
                  child: ClipOval(
                    child: Image.network(
                      imageUrl,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: size,
                          height: size,
                          color: Colors.transparent,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: size,
                        height: size,
                        color: Colors.transparent,
                        child: const Center(
                          child: Icon(
                            Icons.lock,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                // Completed or in-progress levels - normal color
                ClipOval(
                  child: Image.network(
                    imageUrl,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: size,
                        height: size,
                        color: Colors.transparent,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: size,
                      height: size,
                      color: Colors.transparent,
                      child: Center(
                        child: Icon(
                          isInProgress ? Icons.nightlight : null,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class ConnectingAnimation extends StatelessWidget {
  final bool isTransitionOdd;
  final bool shouldShow;
  final int index;

  const ConnectingAnimation({
    Key? key,
    required this.isTransitionOdd,
    required this.shouldShow,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!shouldShow) return const SizedBox.shrink();

    final delay = Duration(milliseconds: (index * 300) + (isTransitionOdd ? 200 : 0));

    return FutureBuilder(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(width: 120, height: 120);
        }

        // Animation container with 1x size ratio
        return Lottie.asset(
          isTransitionOdd
              ? 'assets/animations/3/data.json'
              : 'assets/animations/1/data.json',
          width: 160,
          height: 180,
          fit: BoxFit.contain,
          frameRate: FrameRate.max,
          repeat: true,
        );
      },
    );
  }
}

class JourneyLevelsList extends ConsumerStatefulWidget {
  final String journeyId;
  final String email;
  final String skillTrackId;
  final Map<String, dynamic>? tile;
  final Function(String) onLevelTap;

  const JourneyLevelsList({
    Key? key,
    required this.journeyId,
    required this.email,
    required this.skillTrackId,
    this.tile,
    required this.onLevelTap,
  }) : super(key: key);

  @override
  ConsumerState<JourneyLevelsList> createState() => _JourneyLevelsListState();
}

class _JourneyLevelsListState extends ConsumerState<JourneyLevelsList>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final Map<int, bool> _visibleAnimations = {};
  final Map<int, AnimationController> _animationControllers = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    final scrollPosition = _scrollController.position.pixels;
    final viewportHeight = _scrollController.position.viewportDimension;

    final journeyLevels = ref.read(journeyLevelsProvider(widget.journeyId));
    journeyLevels.whenData((levels) {
      for (int i = 0; i < levels.length - 1; i++) {
        final itemPosition = i * 200.0;
        final isVisible =
            (itemPosition - scrollPosition).abs() < viewportHeight * 1.5;

        if (isVisible != _visibleAnimations[i]) {
          setState(() {
            _visibleAnimations[i] = isVisible;

            if (isVisible && !_animationControllers.containsKey(i)) {
              final controller = AnimationController(
                vsync: this,
                duration: const Duration(milliseconds: 500),
              );
              _animationControllers[i] = controller;
              controller.forward();
            } else if (!isVisible && _animationControllers.containsKey(i)) {
              _animationControllers[i]!.dispose();
              _animationControllers.remove(i);
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final journeyService = ref.watch(journeyServiceProvider);
    
    // Revert to original implementation for loading skills
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: journeyService
          .addSkills(widget.skillTrackId, widget.email)
          .then((skills) => skills.map((skill) => skill.toMap()).toList()
            ..sort(
                (a, b) => (a['position'] ?? 0).compareTo(b['position'] ?? 0))),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading skills: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        final skills = snapshot.data ?? [];

        if (skills.isEmpty) {
          return const Center(
            child: Text(
              'No skills available',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        // Get the journey type once for all skills
        return FutureBuilder<Map<String, dynamic>>(
          future: journeyService.getJourneyType(widget.skillTrackId, widget.email),
          builder: (context, journeySnapshot) {
            final journeyType = journeySnapshot.data?['type'] ?? '';
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                ...skills.map((skill) {
                  return _LevelItem(
                    title: skill['title'] ?? 'Untitled Skill',
                    description: skill['description'] ?? '',
                    isCompleted: skill['isCompleted'] ?? false,
                    isInProgress: skill['isInProgress'] ?? false,
                    isLocked: skill['isLocked'] ?? false,
                    imageUrl: skill['iosIconUrl'] ?? '',
                    journeyId: widget.journeyId,
                    levelId: skill['objectId'] ?? '',
                    email: widget.email,
                    index: skills.indexOf(skill),
                    isLastItem: skills.indexOf(skill) == skills.length - 1,
                    journeyType: journeyType, // Use the journey type from the snapshot
                    skill: skill, // Pass the entire skill object
                    journeyTile: widget.tile, // Pass journey tile info
                  );
                }).toList(),
              ],
            );
          }
        );
      },
    );
  }
}

class _LevelItem extends StatelessWidget {
  final String title;
  final String description;
  final bool isCompleted;
  final bool isInProgress;
  final bool isLocked;
  final String imageUrl;
  final String journeyId;
  final String levelId;
  final String email;
  final int index;
  final bool isLastItem;
  final String journeyType; // Add journey type parameter
  final Map<String, dynamic> skill; // Add skill map parameter
  final Map<String, dynamic>? journeyTile; // Add journey tile parameter

  const _LevelItem({
    Key? key,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.isInProgress,
    required this.isLocked,
    required this.imageUrl,
    required this.journeyId,
    required this.levelId,
    required this.email,
    required this.index,
    required this.isLastItem,
    required this.journeyType, // Required parameter
    required this.skill, // Required parameter
    this.journeyTile,
  }) : super(key: key);

  // Navigate to the appropriate screen based on journey type
  void _navigateToJourneyReveal(BuildContext context) {
    // First try to get the skill level for this skill
    final journeyService = js.JourneyService();
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    // Get the skill goal data and detect what type it is
    _getSkillTypeAndNavigate(context);
  }
  
  Future<void> _getSkillTypeAndNavigate(BuildContext context) async {
    try {
      final journeyService = js.JourneyService();
      
      // Convert skill map to Skill object
      final skillObj = Skill(
        color: skill['color'] ?? '',
        createdAt: skill['createdAt'] ?? 0,
        goalId: skill['goalId'] ?? '',
        iconUrl: skill['iconUrl'] ?? '',
        iosIconUrl: skill['iosIconUrl'] ?? '',
        objectId: skill['objectId'] ?? '',
        position: skill['position'] ?? 0,
        skillTrackId: skill['skillTrackId'] ?? '',
        title: skill['title'] ?? '',
        updatedAt: skill['updatedAt'] ?? 0,
      );
      
      // Create default skillTrack
      final defaultSkillTrack = skillTrack(
        ctaColor: '',
        bigImageUrl: '',
        imageUrl: '',
        includeInTotalProgress: false,
        type: journeyType,
        isReleased: false,
        color: '',
        skillLevelCount: 0,
        updatedAt: DateTime.now(),
        endTextBis: '',
        endText: '',
        topDecoImageUrl: '',
        chapterDescription: '',
        subtitle: '',
        infoText: '',
        createdAt: DateTime.now(),
        title: '',
        skillCount: 0,
        objectId: journeyId,
      );

      // Close the loading dialog
      Navigator.pop(context);
      
      // Check if it has a goalId - this likely means it's a Type 2 (Goal)
      if (skill['goalId'] != null && skill['goalId'].toString().isNotEmpty) {
        final goalDataResponse = await journeyService.getSkillGoal(email, skill['goalId']);
        
        if (goalDataResponse != null) {
          // Create a safe goalData map with defaults for null values
          final goalData = {
            'goalId': goalDataResponse['goalId'] ?? skill['goalId'] ?? '',
            'title': goalDataResponse['title'] ?? skill['title'] ?? '',
            'objectId': goalDataResponse['objectId'] ?? skill['goalId'] ?? '',
            'description': goalDataResponse['description'] ?? '',
            // Add other required fields with fallbacks
          };
          
          // This is a Type 2 (Goal)
          print("Navigating to Goal screen (Type 2)");
          print("GoalData: $goalData");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Journeyscreenrevealtype2(
                goalData: goalData,
                skill: skillObj,
                email: email,
                skilltrack: defaultSkillTrack,
              ),
            ),
          );
          return;
        }
      }
      
      // Check if it has an objectId that matches a skill level with a motivator type
      final skillLevels = await journeyService.getSkillLevels(email, skillObj.objectId);
      
      for (final level in skillLevels) {
        if (level.containsKey('motivatorId') && level['motivatorId'] != null) {
          // This is a Type 3 (Motivator)
          final motivatorData = {
            'title': skill['title'] ?? '',
            'contentTitle': skill['title'] ?? '',
            'contentUrl': 'https://example.com', // Default value
            'objectId': level['motivatorId'],
          };
          
          print("Navigating to Motivator screen (Type 3)");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Journeyscreentype3(
                motivatorData: motivatorData,
                skill: skillObj,
                email: email,
                skilltrack: defaultSkillTrack,
              ),
            ),
          );
          return;
        }
      }
      
      // If neither of the above, assume it's Type 1 (Letter)
      final letterData = {
        'pagedContent': '{"pages":[{"type":"textAndMedia","text":"Welcome to your journey","media":""}]}',
      };
      
      print("Navigating to Letter screen (Type 1)");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JourneyRevealType1(
            letterData: letterData,
            skill: skillObj,
            email: email,
            skilltrack: defaultSkillTrack,
          ),
        ),
      );
    } catch (e) {
      // Close the loading dialog if there was an error
      Navigator.pop(context);
      print("Error navigating: $e");
      
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Navigation Error'),
          content: Text('Error: $e\n\nTry using the debug buttons below:'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _tryNavigateToType1(context);
              },
              child: Text('Try Type 1'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _tryNavigateToType2(context);
              },
              child: Text('Try Type 2'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _tryNavigateToType3(context);
              },
              child: Text('Try Type 3'),
            ),
          ],
        ),
      );
    }
  }
  
  void _tryNavigateToType1(BuildContext context) {
    // Convert skill map to Skill object
    final skillObj = Skill(
      color: skill['color'] ?? '',
      createdAt: skill['createdAt'] ?? 0,
      goalId: skill['goalId'] ?? '',
      iconUrl: skill['iconUrl'] ?? '',
      iosIconUrl: skill['iosIconUrl'] ?? '',
      objectId: skill['objectId'] ?? '',
      position: skill['position'] ?? 0,
      skillTrackId: skill['skillTrackId'] ?? '',
      title: skill['title'] ?? '',
      updatedAt: skill['updatedAt'] ?? 0,
    );
    
    // Create default skillTrack
    final defaultSkillTrack = skillTrack(
      ctaColor: '',
      bigImageUrl: '',
      imageUrl: '',
      includeInTotalProgress: false,
      type: 'letter',
      isReleased: false,
      color: '',
      skillLevelCount: 0,
      updatedAt: DateTime.now(),
      endTextBis: '',
      endText: '',
      topDecoImageUrl: '',
      chapterDescription: '',
      subtitle: '',
      infoText: '',
      createdAt: DateTime.now(),
      title: '',
      skillCount: 0,
      objectId: journeyId,
    );
    
    // Default letterData for JourneyRevealType1
    final Map<String, dynamic> letterData = {
      'pagedContent': '{"pages":[{"type":"textAndMedia","text":"Welcome to your journey","media":""}]}',
    };
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JourneyRevealType1(
          letterData: letterData,
          skill: skillObj,
          email: email,
          skilltrack: defaultSkillTrack,
        ),
      ),
    );
  }
  
  void _tryNavigateToType2(BuildContext context) {
    // Convert skill map to Skill object
    final skillObj = Skill(
      color: skill['color'] ?? '',
      createdAt: skill['createdAt'] ?? 0,
      goalId: skill['goalId'] ?? '',
      iconUrl: skill['iconUrl'] ?? '',
      iosIconUrl: skill['iosIconUrl'] ?? '',
      objectId: skill['objectId'] ?? '',
      position: skill['position'] ?? 0,
      skillTrackId: skill['skillTrackId'] ?? '',
      title: skill['title'] ?? '',
      updatedAt: skill['updatedAt'] ?? 0,
    );
    
    // Create default skillTrack
    final defaultSkillTrack = skillTrack(
      ctaColor: '',
      bigImageUrl: '',
      imageUrl: '',
      includeInTotalProgress: false,
      type: 'goal',
      isReleased: false,
      color: '',
      skillLevelCount: 0,
      updatedAt: DateTime.now(),
      endTextBis: '',
      endText: '',
      topDecoImageUrl: '',
      chapterDescription: '',
      subtitle: '',
      infoText: '',
      createdAt: DateTime.now(),
      title: '',
      skillCount: 0,
      objectId: journeyId,
    );
    
    // Create goalData
    final Map<String, dynamic> goalData = {
      'goalId': skill['goalId'] ?? '',
      'title': skill['title'] ?? '',
    };
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Journeyscreenrevealtype2(
          goalData: goalData,
          skill: skillObj,
          email: email,
          skilltrack: defaultSkillTrack,
        ),
      ),
    );
  }
  
  void _tryNavigateToType3(BuildContext context) {
    // Convert skill map to Skill object
    final skillObj = Skill(
      color: skill['color'] ?? '',
      createdAt: skill['createdAt'] ?? 0,
      goalId: skill['goalId'] ?? '',
      iconUrl: skill['iconUrl'] ?? '',
      iosIconUrl: skill['iosIconUrl'] ?? '',
      objectId: skill['objectId'] ?? '',
      position: skill['position'] ?? 0,
      skillTrackId: skill['skillTrackId'] ?? '',
      title: skill['title'] ?? '',
      updatedAt: skill['updatedAt'] ?? 0,
    );
    
    // Create default skillTrack
    final defaultSkillTrack = skillTrack(
      ctaColor: '',
      bigImageUrl: '',
      imageUrl: '',
      includeInTotalProgress: false,
      type: 'motivator',
      isReleased: false,
      color: '',
      skillLevelCount: 0,
      updatedAt: DateTime.now(),
      endTextBis: '',
      endText: '',
      topDecoImageUrl: '',
      chapterDescription: '',
      subtitle: '',
      infoText: '',
      createdAt: DateTime.now(),
      title: '',
      skillCount: 0,
      objectId: journeyId,
    );
    
    // Create motivatorData
    final Map<String, dynamic> motivatorData = {
      'title': skill['title'] ?? '',
      'contentTitle': skill['title'] ?? '',
      'contentUrl': 'https://example.com',
      'objectId': skill['objectId'] ?? '',
    };
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Journeyscreentype3(
          motivatorData: motivatorData,
          skill: skillObj,
          email: email,
          skilltrack: defaultSkillTrack,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEven = index % 2 == 0;
    
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Add connecting animation behind other elements (first in stack)
            if (!isLastItem)
              Positioned(
                left: isEven ? 35 : null,
                right: !isEven ? 215 : null,
                bottom: -80,
                child: ConnectingAnimation(
                  isTransitionOdd: !isEven,
                  shouldShow: true,
                  index: index,
                ),
              ),
            // Level content (now on top of animation)
            Padding(
              padding: EdgeInsets.only(
                top: 15,
                bottom: 50,
                left: isEven ? 8 : 16,
                right: isEven ? 10 : 8,
              ),
              child: Row(
                children: [
                  if (!isEven) const Spacer(),
                  // Left circular image
                  LevelImage(
                    imageUrl: imageUrl,
                    status: isLocked
                        ? 'locked'
                        : isCompleted
                            ? 'completed'
                            : 'in_progress',
                    isInProgress: isInProgress,
                  ),
                  // Right side content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, top: 16, bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                          if (!isLocked) ...[
                            const SizedBox(height: 6),
                            BlurContainer(
                              borderRadius: 50,
                              child: InkWell(
                                onTap: () => _navigateToJourneyReveal(context),
                                child: Container(
                                  color: const Color.fromARGB(51, 255, 255, 255),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 3),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'View',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
