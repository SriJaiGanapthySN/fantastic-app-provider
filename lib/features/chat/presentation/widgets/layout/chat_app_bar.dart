import 'dart:ui';
import 'package:flutter/material.dart';

class ChatAppBar extends StatelessWidget {
  final bool isThresholdReached;
  final VoidCallback? onMenuPressed;

  const ChatAppBar(
      {super.key, required this.isThresholdReached, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 8,
        right: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Leading button
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isThresholdReached
                        ? Colors.white.withOpacity(0.2)
                        : Colors.white.withOpacity(0.1),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.more_horiz,
                        color: Colors.white, size: 22),
                    onPressed: () {
                      print('🔥 Button tapped in ChatAppBar');
                      onMenuPressed?.call();
                    },
                  ),
                ),
              ),
            ),
          ),
          // Actions button
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isThresholdReached
                        ? Colors.white.withOpacity(0.2)
                        : Colors.white.withOpacity(0.1),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.stacked_bar_chart,
                        color: Colors.white, size: 22),
                    onPressed: () {
                      print('🔥 Stats button tapped');
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
