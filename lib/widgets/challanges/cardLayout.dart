import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui'; // Important: for the frosted glass effect
import '../../subChallenges/SubChallengePage.dart';
import 'customCard.dart';

class CardLayout extends StatefulWidget {
  final List<Map<String, dynamic>> cardData;

  const CardLayout({Key? key, required this.cardData}) : super(key: key);

  @override
  State<CardLayout> createState() => _CardLayoutState();
}

class _CardLayoutState extends State<CardLayout> with TickerProviderStateMixin {
  late List<Map<String, dynamic>> _cards;
  Offset _dragOffset = Offset.zero;
  final double _swipeThreshold = 100.0;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _undoAnimationController;
  late Animation<Offset> _undoSlideAnimation;
  late Animation<double> _undoFadeAnimation;
  bool _isDragging = false;
  bool _isUndoing = false;
  double _opacity = 1.0;

  Map<String, dynamic>? _lastSwipedCard;

  @override
  void initState() {
    super.initState();
    _cards = List.from(widget.cardData);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = _animationController.drive(
      Tween<Offset>(
        begin: Offset.zero,
        end: Offset.zero,
      ),
    );

    _undoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _undoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _undoAnimationController,
      curve: Curves.easeOut,
    ));

    _undoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _undoAnimationController,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _undoAnimationController.dispose();
    super.dispose();
  }

  void _onDragEnd() {
    if (_dragOffset.dx.abs() > _swipeThreshold) {
      final isRight = _dragOffset.dx > 0;
      final endOffset = Offset(isRight ? 2.0 : -2.0, 0);

      _slideAnimation = Tween<Offset>(
        begin: _dragOffset,
        end: endOffset * 400,
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      );

      _animationController.forward().then((_) {
        setState(() {
          _lastSwipedCard = _cards.removeAt(0);
          _dragOffset = Offset.zero;
          _opacity = 1.0;
          _animationController.reset();
        });
      });
    } else {
      _slideAnimation = Tween<Offset>(
        begin: _dragOffset,
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
      );

      _animationController.forward().then((_) {
        setState(() {
          _dragOffset = Offset.zero;
          _opacity = 1.0;
          _animationController.reset();
        });
      });
    }
    _isDragging = false;
  }

  void _undoSwipe() {
    if (_lastSwipedCard != null) {
      setState(() {
        _isUndoing = true;
        _cards.insert(0, _lastSwipedCard!);
      });
      _undoAnimationController.forward(from: 0).then((_) {
        setState(() {
          _isUndoing = false;
          _lastSwipedCard = null;
        });
      });
    }
  }
  void _onCardTap(Map<String, dynamic> cardData) {
    // Prevent navigation if a swipe or undo animation is in progress
    if ( _isUndoing || _isDragging || _animationController.isAnimating || _undoAnimationController.isAnimating) {
      print("Navigation prevented: Animation/Drag in progress.");
      return;
    }
    print("Card tapped: ${cardData['title']}"); // Debugging
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChallengeDetailScreen(challengeData: cardData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final parentWidth = constraints.maxWidth;
        final parentHeight = constraints.maxHeight;

        final visibleCards = _cards.take(4).toList();

        return Column(
          children: [
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ===== Cards =====
                  ...visibleCards.reversed.toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final card = entry.value;
                    final relativeIndex = visibleCards.length - 1 - index;
                    final isTop = relativeIndex == 0;

                    double scale = 1.0 - (relativeIndex * 0.05);
                    double topOffset = relativeIndex * -10.0;
                    double sideOffset = relativeIndex * 10.0;

                    Widget cardWidget = _buildCard(parentWidth, parentHeight, card);

                    if (isTop && _isUndoing) {
                      cardWidget = SlideTransition(
                        position: _undoSlideAnimation,
                        child: FadeTransition(
                          opacity: _undoFadeAnimation,
                          child: cardWidget,
                        ),
                      );
                    } else if (isTop) {
                      cardWidget = GestureDetector(
                        onTap: () => _onCardTap(card),
                        onPanStart: (_) {
                          _isDragging = true;
                        },
                        onPanUpdate: (details) {
                          setState(() {
                            _dragOffset += details.delta;
                            _opacity = (1.0 - (_dragOffset.dx.abs() / 300)).clamp(0.0, 1.0);
                          });
                        },
                        onPanEnd: (_) => _onDragEnd(),
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            final offset = _animationController.isAnimating
                                ? _slideAnimation.value
                                : _dragOffset;

                            double rotationAngle = (offset.dx / parentWidth) * 0.3;

                            return Opacity(
                              opacity: _opacity,
                              child: Transform.translate(
                                offset: Offset(offset.dx, offset.dy),
                                child: Transform.rotate(
                                  angle: rotationAngle,
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: cardWidget,
                        ),
                      );
                    }

                    return AnimatedPositioned(
                      duration: _isDragging ? Duration.zero : const Duration(milliseconds: 300),
                      top: topOffset,
                      left: sideOffset,
                      right: sideOffset,
                      child: AnimatedScale(
                        scale: scale,
                        duration: _isDragging ? Duration.zero : const Duration(milliseconds: 300),
                        child: cardWidget,
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            _buildUndoButton(),
          ],
        );
      },
    );
  }

  Widget _buildUndoButton() {
    return ElevatedButton(
      onPressed: _lastSwipedCard != null ? _undoSwipe : null,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(18),
        backgroundColor: Colors.white,
        shadowColor: Colors.black,
        elevation: 8,
      ),
      child: const Icon(
        Icons.restore,
        color: Colors.black,
        size: 30,
      ),
    );
  }

  Widget _buildCard(double width, double height, Map<String, dynamic> card) {
    final String imageUrl = card['imageUrl'] ?? 'assets/default_image.png';
    final String title = card['title'] ?? '';
    return Container(
      width: width,
      height: height * 0.56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ClipRect( // <- important for the blur to not overflow
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              border: Border.all(
                width: 1.5,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: CustomCard(
                imageAdd: imageUrl,
                text: title,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
