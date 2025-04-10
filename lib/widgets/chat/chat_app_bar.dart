import 'dart:ui';
import 'package:flutter/material.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isThresholdReached;

  const ChatAppBar({super.key, required this.isThresholdReached});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left: 8, top: 10),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isThresholdReached
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
              ),
              child: IconButton(
                icon:
                    const Icon(Icons.more_horiz, color: Colors.white, size: 22),
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8, top: 10),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isThresholdReached
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                ),
                child: IconButton(
                  icon: const Icon(Icons.stacked_bar_chart,
                      color: Colors.white, size: 22),
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
