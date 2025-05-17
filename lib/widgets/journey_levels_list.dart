import 'package:fantastic_app_riverpod/providers/journey_provider.dart';
import 'package:fantastic_app_riverpod/screens/journey_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../screens/journey_screen.dart';
import '../utils/blur_container.dart';
import '../providers/journey_levels_provider.dart';
import '../widgets/premium_button.dart';

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

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: journeyService
          .addSkills(widget.skillTrackId, "test03@gmail.com")
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // if (widget.tile != null) ...[
            //   Text(
            //     widget.tile!['title'] ?? 'Journey Title',
            //     style: const TextStyle(
            //       color: Colors.white,
            //       fontSize: 20,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            //   const SizedBox(height: 8),
            //   Text(
            //     widget.tile!['description'] ?? 'Journey Description',
            //     style: TextStyle(
            //       color: Colors.white.withOpacity(0.7),
            //       fontSize: 16,
            //     ),
            //   ),
            //   const SizedBox(height: 24),
            // ],
            // const Text(
            //   'Skills',
            //   style: TextStyle(
            //     color: Colors.white,
            //     fontSize: 20,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
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
              );
            }).toList(),
          ],
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
  }) : super(key: key);

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
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => JourneyRoadmapScreen(),
                                    ),
                                  );
                                },
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
