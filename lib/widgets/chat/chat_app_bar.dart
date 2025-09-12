import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fantastic_app_riverpod/providers/nav_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../screens/main_screen.dart';

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
              child: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.more_horiz,
                      color: Colors.white, size: 22),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (context) {
                        final providerContainer =
                            ProviderScope.containerOf(context, listen: false);
                        final pageController =
                            providerContainer.read(pageControllerProvider);
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: SvgPicture.asset(
                                  'assets/icons/heart.svg',
                                  color: Colors.black),
                              title: const Text('Rituals'),
                              onTap: () {
                                Navigator.pop(context);
                                providerContainer
                                    .read(selectedTabProvider.notifier)
                                    .state = 1;
                                pageController.jumpToPage(1);
                              },
                            ),
                            ListTile(
                              leading: SvgPicture.asset(
                                  'assets/icons/route.svg',
                                  color: Colors.black),
                              title: const Text('Journey'),
                              onTap: () {
                                Navigator.pop(context);
                                providerContainer
                                    .read(selectedTabProvider.notifier)
                                    .state = 2;
                                pageController.jumpToPage(2);
                              },
                            ),
                            ListTile(
                              leading: SvgPicture.asset(
                                  'assets/icons/search.svg',
                                  color: Colors.black),
                              title: const Text('Discover'),
                              onTap: () {
                                Navigator.pop(context);
                                providerContainer
                                    .read(selectedTabProvider.notifier)
                                    .state = 3;
                                pageController.jumpToPage(3);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
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
