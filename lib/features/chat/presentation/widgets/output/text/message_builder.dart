import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fantastic_app_riverpod/core/utils/blur_container.dart';
import 'package:fantastic_app_riverpod/features/journeys/presentation/widgets/journey_card.dart';
import 'package:fantastic_app_riverpod/features/chat/data/model/chat_message_data.dart';
import 'package:fantastic_app_riverpod/features/chat/data/factories/message_factory.dart';
import 'package:fantastic_app_riverpod/features/chat/presentation/providers/messages/chat_state_provider.dart';

class MessageBuilder extends ConsumerStatefulWidget {
  final ChatMessageData messageData;
  final TickerProvider tickerProvider;

  const MessageBuilder({
    Key? key,
    required this.messageData,
    required this.tickerProvider,
  }) : super(key: key);

  @override
  ConsumerState<MessageBuilder> createState() => _MessageBuilderState();
}

class _MessageBuilderState extends ConsumerState<MessageBuilder> {
  late MessageFactory messageFactory;
  bool _showJourneyPreview = false;
  bool _showHabitPreview = false;
  double _journeyOpacity = 0.0;
  double _habitOpacity = 0.0;
  Offset _journeyOffset = const Offset(0, 0.06);
  Offset _habitOffset = const Offset(0, 0.08);

  @override
  void initState() {
    super.initState();
    messageFactory = MessageFactory(widget.tickerProvider);
  }

  @override
  Widget build(BuildContext context) {
    final messageData = widget.messageData;
    final shouldAnimate =
        !messageData.hasAnimated; // Only animate if not already animated

    print('📱 Building message of type: ${messageData.type}');
    print('📱 Audio URL: ${messageData.audioUrl}');
    print('📱 Should animate: $shouldAnimate');

    Widget messageWidget;

    switch (messageData.type) {
      case ChatMessageType.userMessage:
        messageWidget = messageFactory.createUserMessage(
          messageText: messageData.text,
          shouldAnimate: shouldAnimate,
          onAnimationComplete: () {
            if (shouldAnimate && mounted) {
              // Mark as animated only if it was animating and widget is still mounted
              try {
                ref
                    .read(chatProvider.notifier)
                    .markMessageAsAnimated(messageData.id);
              } catch (e) {
                print('Error marking message as animated: $e');
              }
            }
          },
        );
        break;

      case ChatMessageType.cardMessage:
        messageWidget = messageFactory.createCardMessage(
          id: messageData.id,
          isQuestion: messageData.isQuestion,
          apiResponse: messageData.text,
          shouldAnimate: shouldAnimate,
          onAnimationComplete: () {
            if (shouldAnimate && mounted) {
              // Mark as animated only if it was animating and widget is still mounted
              try {
                ref
                    .read(chatProvider.notifier)
                    .markMessageAsAnimated(messageData.id);

                // Turn off background animation when bot message animation completes
                if (!messageData.isUser) {
                  ref.read(chatProvider.notifier).setThresholdReached(false);
                }
              } catch (e) {
                print('Error in card animation complete callback: $e');
              }
            }
          },
        );
        break;

      case ChatMessageType.animatedObjectCard:
        messageWidget = messageFactory.createAnimatedObjectCardMessage(
          id: messageData.id,
          shouldAnimate: shouldAnimate,
          onAnimationComplete: () {
            if (shouldAnimate && mounted) {
              try {
                ref
                    .read(chatProvider.notifier)
                    .markMessageAsAnimated(messageData.id);
                if (!messageData.isUser) {
                  ref.read(chatProvider.notifier).setThresholdReached(false);
                }
              } catch (e) {
                print('Error in object card animation callback: $e');
              }
            }
            // Reveal previews with smooth staggered fade + slide
            if (mounted) {
              setState(() {
                _showJourneyPreview = true;
                _journeyOpacity = 0.0;
                _journeyOffset = const Offset(0, 0.06);
              });
            }
            Future.delayed(const Duration(milliseconds: 16), () {
              if (!mounted) return;
              try {
                setState(() {
                  _journeyOpacity = 1.0;
                  _journeyOffset = Offset.zero;
                });
              } catch (e) {
                print('Error updating journey preview state: $e');
              }
            });

            Future.delayed(const Duration(milliseconds: 120), () {
              if (!mounted) return;
              try {
                setState(() {
                  _showHabitPreview = true;
                  _habitOpacity = 0.0;
                  _habitOffset = const Offset(0, 0.08);
                });
              } catch (e) {
                print('Error showing habit preview: $e');
              }

              Future.delayed(const Duration(milliseconds: 16), () {
                if (!mounted) return;
                try {
                  setState(() {
                    _habitOpacity = 1.0;
                    _habitOffset = Offset.zero;
                  });
                } catch (e) {
                  print('Error updating habit preview state: $e');
                }
              });
            });
          },
        );
        break;

      case ChatMessageType.audioMessage:
        messageWidget = messageFactory.createAudioMessage(
          id: messageData.id,
          messageText: messageData.text,
          audioUrl: messageData.audioUrl ?? '',
          isUser: messageData.isUser,
          shouldAnimate: shouldAnimate,
          onAnimationComplete: () {
            if (shouldAnimate && mounted) {
              // Mark as animated only if it was animating and widget is still mounted
              try {
                ref
                    .read(chatProvider.notifier)
                    .markMessageAsAnimated(messageData.id);

                // Turn off background animation when bot message animation completes
                if (!messageData.isUser) {
                  ref.read(chatProvider.notifier).setThresholdReached(false);
                }
              } catch (e) {
                print('Error in audio animation complete callback: $e');
              }
            }
          },
        );
        break;

      case ChatMessageType.contentCard:
        messageWidget = messageFactory.createContentCardMessage(
          objectId: messageData.objectId ?? '',
          type: messageData.contentType ?? '',
          onAnimationComplete: () {
            if (shouldAnimate && mounted) {
              // Mark as animated only if it was animating and widget is still mounted
              try {
                ref
                    .read(chatProvider.notifier)
                    .markMessageAsAnimated(messageData.id);

                // Turn off background animation when bot message animation completes
                if (!messageData.isUser) {
                  ref.read(chatProvider.notifier).setThresholdReached(false);
                }
              } catch (e) {
                print('Error in content card animation callback: $e');
              }
            }
          },
        );
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        messageWidget,
        if (messageData.type == ChatMessageType.cardMessage &&
            _showJourneyPreview) ...[
          const SizedBox(height: 8),
          AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            offset: _journeyOffset,
            child: AnimatedOpacity(
              opacity: _journeyOpacity,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: _ChatJourneyPreview(),
              ),
            ),
          ),
        ],
        if (messageData.type == ChatMessageType.cardMessage &&
            _showHabitPreview) ...[
          const SizedBox(height: 8),
          AnimatedSlide(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            offset: _habitOffset,
            child: AnimatedOpacity(
              opacity: _habitOpacity,
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOut,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: _ChatHabitPreview(),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ChatJourneyPreview extends StatelessWidget {
  const _ChatJourneyPreview();

  static const String _journeyId = '0fCYCubptS'; // sample id provided

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('skillTrack')
          .doc(_journeyId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _SkeletonBox(heightFactor: 0.20);
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }
        final data = snapshot.data!.data() ?? {};
        final String title = (data['title'] as String?) ?? 'Journey';
        final String subtitle = (data['subtitle'] as String?) ?? '';
        final String? imageUrl = (data['imageUrl'] as String?);

        // Progress will be static for now
        return JourneyCard(
          title: title,
          subtitle: subtitle,
          progress: '0%',
          imageUrl: imageUrl,
        );
      },
    );
  }
}

class _ChatHabitPreview extends StatelessWidget {
  const _ChatHabitPreview();

  static const String _habitId = '24juUJAqxV'; // sample id provided

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('habits-new')
          .doc(_habitId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _SkeletonRow();
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }
        final data = snapshot.data!.data() ?? {};
        final String title = (data['name'] as String?) ?? 'Habit';
        final String iconUrl = (data['iconUrl'] as String?) ?? '';

        return BlurContainer(
          blur: 35.87,
          borderRadius: 13.04,
          color: Colors.black.withOpacity(0.22),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Row(
              children: [
                if (iconUrl.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0, right: 8.0),
                    child: SvgPicture.network(
                      iconUrl,
                      height: 16,
                      width: 16,
                    ),
                  ),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double heightFactor;
  const _SkeletonBox({this.heightFactor = 0.12});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height * heightFactor,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
