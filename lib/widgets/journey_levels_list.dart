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
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0, 0, 0, 1, 0,
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

  const ConnectingAnimation({
    Key? key,
    required this.isTransitionOdd,
    required this.shouldShow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!shouldShow) return const SizedBox.shrink();
    
    final delay = isTransitionOdd ? const Duration(milliseconds: 500) : Duration.zero;

    return FutureBuilder(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(width: 120, height: 120);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
          child: Lottie.asset(
            isTransitionOdd 
                ? 'assets/animations/3/data.json'
                : 'assets/animations/1/data.json',
            width: 140,
            height: 140,
            fit: BoxFit.contain,
            frameRate: FrameRate.max,
            repeat: true,
          ),
        );
      },
    );
  }
}

class JourneyLevelsList extends ConsumerStatefulWidget {
  final String journeyId;
  final String email;
  final Function(String) onLevelTap;

  const JourneyLevelsList({
    Key? key,
    required this.journeyId,
    required this.email,
    required this.onLevelTap,
  }) : super(key: key);

  @override
  ConsumerState<JourneyLevelsList> createState() => _JourneyLevelsListState();
}

class _JourneyLevelsListState extends ConsumerState<JourneyLevelsList> with SingleTickerProviderStateMixin {
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
        final isVisible = (itemPosition - scrollPosition).abs() < viewportHeight * 1.5;
        
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
    final journeyLevels = ref.watch(journeyLevelsProvider(widget.journeyId));

    return journeyLevels.when(
      data: (levels) {
        if (levels.isEmpty) {
          return const Center(
            child: Text(
              'No levels available',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Journey Levels',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...levels.map((level) {
              final isCompleted = level['isCompleted'] ?? false;
              final isInProgress = level['isInProgress'] ?? false;
              final isLocked = level['isLocked'] ?? true;
              final imageUrl = level['imageUrl'] ?? '';
              final levelId = level['objectId'] ?? '';

              return GestureDetector(
                onTap: !isLocked ? () => widget.onLevelTap(levelId) : null,
                child: _LevelItem(
                  title: level['title'] ?? 'Untitled Level',
                  description: level['description'] ?? '',
                  isCompleted: isCompleted,
                  isInProgress: isInProgress,
                  isLocked: isLocked,
                  imageUrl: imageUrl,
                  journeyId: widget.journeyId,
                  levelId: levelId,
                  email: widget.email,
                ),
              );
            }).toList(),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text(
          'Error loading levels: $error',
          style: const TextStyle(color: Colors.white),
        ),
      ),
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Level content (behind)
        Padding(
          padding: const EdgeInsets.only(
            top: 15,
            bottom: 30,
            left: 8,
          ),
          child: Row(
            children: [
              // Left circular image
              LevelImage(
                imageUrl: imageUrl,
                status: isLocked ? 'locked' : isCompleted ? 'completed' : 'in_progress',
                isInProgress: isInProgress,
              ),
              // Right side content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
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
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                      if (!isLocked) ...[
                        const SizedBox(height: 12),
                        BlurContainer(
                          borderRadius: 50,
                          child: InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const JourneyScreen(),
                                ),
                              );
                            },
                            child: Container(
                              color: const Color.fromARGB(51, 255, 255, 255),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
    );
  }
} 