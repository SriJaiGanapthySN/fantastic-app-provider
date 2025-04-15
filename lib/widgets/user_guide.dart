import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserGuide extends StatefulWidget {
  final Widget child;
  final List<GuideStep> steps;
  final VoidCallback? onComplete;

  const UserGuide({
    super.key,
    required this.child,
    required this.steps,
    this.onComplete,
  });

  static Widget _buildPreviewCard({
    required String title,
    required String subtitle,
    required String iconPath,
    required Color iconColor,
  }) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            iconPath,
            height: 32,
            width: 32,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildNavPreview() {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SvgPicture.asset('assets/icons/chat.svg', color: Colors.white70, height: 24),
          SvgPicture.asset('assets/icons/route.svg', color: Colors.white70, height: 24),
          SvgPicture.asset('assets/icons/heart.svg', color: Colors.white70, height: 24),
          SvgPicture.asset('assets/icons/search.svg', color: Colors.white70, height: 24),
        ],
      ),
    );
  }

  static Future<void> showAppGuide(BuildContext context) async {
    await showIfFirstTime(
      context,
      [
        GuideStep(
          title: "Chat with Fabulous",
          description: "Get personalized guidance and support from your AI companion. Ask questions, share thoughts, and get motivation.",
          target: _buildPreviewCard(
            title: "AI Chat",
            subtitle: "Your personal AI companion",
            iconPath: 'assets/icons/chat.svg',
            iconColor: Colors.blue,
          ),
        ),
        GuideStep(
          title: "Your Daily Ritual",
          description: "Start your day right with a personalized morning routine. Track your habits and build a healthy lifestyle.",
          target: _buildPreviewCard(
            title: "Daily Ritual",
            subtitle: "Build your perfect morning routine",
            iconPath: 'assets/icons/route.svg',
            iconColor: Colors.amber,
          ),
        ),
        GuideStep(
          title: "Your Journey",
          description: "Track your progress and unlock new achievements. See how far you've come and where you're headed.",
          target: _buildPreviewCard(
            title: "Journey Map",
            subtitle: "Your path to success",
            iconPath: 'assets/icons/heart.svg',
            iconColor: Colors.green,
          ),
        ),
        GuideStep(
          title: "Discover More",
          description: "Explore new challenges, guided activities, and coaching series to enhance your journey.",
          target: _buildPreviewCard(
            title: "Discover",
            subtitle: "Find new challenges and activities",
            iconPath: 'assets/icons/search.svg',
            iconColor: Colors.purple,
          ),
        ),
        GuideStep(
          title: "Quick Navigation",
          description: "Switch between different sections of the app using this navigation bar.",
          target: _buildNavPreview(),
        ),
      ],
    );
  }

  static Future<void> showIfFirstTime(
    BuildContext context,
    List<GuideStep> steps,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenGuide = prefs.getBool('has_seen_guide') ?? false;
    
    if (!hasSeenGuide && context.mounted) {
      final overlay = Overlay.of(context);
      final overlayEntry = OverlayEntry(
        builder: (context) => UserGuide(
          child: const SizedBox.shrink(),
          steps: steps,
          onComplete: () async {
            await prefs.setBool('has_seen_guide', true);
          },
        ),
      );
      
      overlay.insert(overlayEntry);
    }
  }

  @override
  State<UserGuide> createState() => _UserGuideState();
}

class _UserGuideState extends State<UserGuide> {
  int currentStep = 0;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCurrentStep();
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showCurrentStep() {
    _removeOverlay();

    if (currentStep >= widget.steps.length) {
      widget.onComplete?.call();
      return;
    }

    final step = widget.steps[currentStep];
    final overlay = Overlay.of(context);
    final screenSize = MediaQuery.of(context).size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.8),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              top: screenSize.height * 0.3,
              child: step.target,
            ),
            if (currentStep < 4) Positioned(
              bottom: 120,
              left: (currentStep * (screenSize.width / 4)) + (screenSize.width / 8) - 15,
              child: Transform.rotate(
                angle: -3.14159,
                child: CustomPaint(
                  size: const Size(30, 40),
                  painter: ArrowPainter(),
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: screenSize.height * 0.2,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.emoji_objects, color: Colors.amber),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            step.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (currentStep > 0)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                currentStep--;
                                _showCurrentStep();
                              });
                            },
                            child: const Text('Previous'),
                          )
                        else
                          const SizedBox(),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              currentStep++;
                              _showCurrentStep();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            currentStep < widget.steps.length - 1 ? 'Next' : 'Got it!',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class GuideStep {
  final String title;
  final String description;
  final Widget target;

  const GuideStep({
    required this.title,
    required this.description,
    required this.target,
  });
}

class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height / 3)
      ..lineTo(size.width * 0.6, size.height / 3)
      ..lineTo(size.width * 0.6, size.height)
      ..lineTo(size.width * 0.4, size.height)
      ..lineTo(size.width * 0.4, size.height / 3)
      ..lineTo(0, size.height / 3)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HolePainter extends CustomPainter {
  final Rect targetRect;
  final double borderRadius;

  HolePainter({
    required this.targetRect,
    this.borderRadius = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.transparent;
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(
          targetRect.inflate(4),
          Radius.circular(borderRadius),
        ),
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(HolePainter oldDelegate) =>
      targetRect != oldDelegate.targetRect ||
      borderRadius != oldDelegate.borderRadius;
} 