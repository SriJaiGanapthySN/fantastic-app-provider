import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../utils/blur_container.dart';
import '../providers/journey_levels_provider.dart';
import '../widgets/premium_button.dart';

// Mock data for debugging
final List<Map<String, dynamic>> mockLevels = [
  {
    'order': 3,
    'title': 'Sleep Foundation Basics',
    'description': 'Completed',
    'progress': 1.0,
    'status': 'completed',
    'imageUrl': 'https://picsum.photos/202', // Different placeholder image
  },
  {
    'order': 4,
    'title': 'Advanced Sleep Techniques',
    'description': 'Completed',
    'progress': 1.0,
    'status': 'completed',
    'imageUrl': 'https://picsum.photos/203', // Different placeholder image
  },
  {
    'order': 1,
    'title': 'Manufacture Your Best Night\'s Sleep',
    'description': '1/6 achieved',
    'progress': 0.17,
    'status': 'in_progress',
    'imageUrl': 'https://picsum.photos/200', // Placeholder image
  },
  {
    'order': 2,
    'title': 'Create Your Bedtime Routine',
    'description': 'Not yet unlocked',
    'progress': 0.0,
    'status': 'locked',
    'imageUrl': 'https://picsum.photos/201', // Different placeholder image
  },
];

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
    // return Padding(
    //   padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
        
      
    //   child: Lottie.asset(
    //     isOddToEven 
    //         ? 'assets/animations/3/data.json'
    //         : 'assets/animations/1/data.json',
    //     width: 120,
    //     height: 120,
    //     fit: BoxFit.contain,
    //     frameRate: FrameRate.max,
    //     repeat: true,
    //   ),
    // Add a delay based on whether it's odd or even
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

  const JourneyLevelsList({
    Key? key,
    required this.journeyId,
  }) : super(key: key);

  @override
  ConsumerState<JourneyLevelsList> createState() => _JourneyLevelsListState();
}

class _JourneyLevelsListState extends ConsumerState<JourneyLevelsList> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final Map<int, bool> _visibleAnimations = {};
  final Map<int, AnimationController> _animationControllers = {};
  
  // Mock data for debugging
  final List<Map<String, dynamic>> sortedMockLevels = [
    {
      'id': '1',
      'title': 'Introduction to Sleep',
      'description': 'Learn the basics of sleep and its importance for health.',
      'imageUrl': 'https://images.unsplash.com/photo-1511295742362-92c96b1cf484?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
      'status': 'completed',
      'order': 1,
    },
    {
      'id': '2',
      'title': 'Sleep Cycles',
      'description': 'Understand the different stages of sleep and their functions.',
      'imageUrl': 'https://images.unsplash.com/photo-1511295742362-92c96b1cf484?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
      'status': 'completed',
      'order': 2,
    },
    {
      'id': '3',
      'title': 'Sleep Hygiene',
      'description': 'Learn practices for better sleep quality and duration.',
      'imageUrl': 'https://images.unsplash.com/photo-1511295742362-92c96b1cf484?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
      'status': 'in_progress',
      'order': 3,
    },
    {
      'id': '4',
      'title': 'Sleep Disorders',
      'description': 'Identify common sleep disorders and their treatments.',
      'imageUrl': 'https://images.unsplash.com/photo-1511295742362-92c96b1cf484?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
      'status': 'in_progress',
      'order': 4,
    },
    {
      'id': '5',
      'title': 'Advanced Sleep Techniques',
      'description': 'Master advanced techniques for optimal sleep quality.',
      'imageUrl': 'https://images.unsplash.com/photo-1511295742362-92c96b1cf484?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
      'status': 'locked',
      'order': 5,
    },
  ];

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
    // Check which animations should be visible based on scroll position
    final scrollPosition = _scrollController.position.pixels;
    final viewportHeight = _scrollController.position.viewportDimension;
    
    // Calculate which items are in or near the viewport
    for (int i = 0; i < sortedMockLevels.length - 1; i++) {
      // Approximate position of each item (this is a simplification)
      final itemPosition = i * 200.0; // Approximate height of each item
      
      // Check if item is in or near viewport
      final isVisible = (itemPosition - scrollPosition).abs() < viewportHeight * 1.5;
      
      if (isVisible != _visibleAnimations[i]) {
        setState(() {
          _visibleAnimations[i] = isVisible;
          
          // Create or dispose animation controller as needed
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
  }

  @override
  Widget build(BuildContext context) {
    // For debugging, we'll use mock data instead of the actual provider
    // Comment out the actual provider calls
    // final journeyLevels = ref.watch(journeyLevelsProvider(widget.journeyId));
    // final currentLevel = ref.watch(currentLevelProvider(widget.journeyId));

    // Return the widget with sorted mock data
    return ListView.builder(
      controller: _scrollController,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedMockLevels.length,
      itemBuilder: (context, index) {
        final level = sortedMockLevels[index];
        final isInProgress = level['status'] == 'in_progress';
        final showButton = level['status'] == 'completed' || level['status'] == 'in_progress';
        final nextLevel = index < sortedMockLevels.length - 1 ? sortedMockLevels[index + 1] : null;
        final showAnimation = (level['status'] == 'completed' || level['status'] == 'in_progress') &&
                             (nextLevel != null && (nextLevel['status'] == 'completed' || nextLevel['status'] == 'in_progress'));
        
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Level content (behind)
            Padding(
              padding: EdgeInsets.only(
                top: 15,
                bottom: 30,
                left: index.isOdd ? 120 : 8,
              ),
              child: Row(
                children: [
                  // Left circular image
                  LevelImage(
                    imageUrl: level['imageUrl'] as String,
                    status: level['status'] as String,
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
                            level['title'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            level['description'] as String,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                          if (showButton) ...[
                            const SizedBox(height: 12),
                            BlurContainer(
                              borderRadius: 50,
                              child: InkWell(
                                onTap: () {
                                  // Handle view button tap
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
            // Connecting animation (in front)
            if (index < sortedMockLevels.length - 1 && showAnimation)
              Positioned(
                left: 45,
                top: 110,
                child: ConnectingAnimation(
                  isTransitionOdd: index.isOdd,
                  shouldShow: true,
                ),
              ),
          ],
        );
      },
    );
  }
} 