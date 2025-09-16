import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/nav_provider.dart';
import 'chat_screen.dart';
import 'discoverscreen.dart';
import 'journey_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import 'package:fantastic_app_riverpod/providers/auth_provider.dart' as auth;
import '../widgets/user_guide.dart';

import 'ritual_screen.dart';

final pageControllerProvider = Provider<PageController>((ref) {
  final controller = PageController(initialPage: 1);
  ref.onDispose(() => controller.dispose());
  return controller;
});

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UserGuide.showAppGuide(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageController = ref.watch(pageControllerProvider);
    // Use the utility function to get the current user email
    final userEmail = auth.getCurrentUserEmail(ref);

    // Log the email being used
    print('MainScreen: Using email: $userEmail for all screens');

    final selectedTab = ref.watch(selectedTabProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          // This ensures the tab updates if page changes by other means
          if (ref.read(selectedTabProvider) != index) {
            ref.read(selectedTabProvider.notifier).state = index;
          }
        },
        children: [
          ChatScreen(email: userEmail), // Pass email to ChatScreen
          RitualScreen(
              currentUserEmail: userEmail), // Pass email to RitualScreen
          JourneyScreen(userEmail: userEmail),
          Discoverscreen(email: userEmail),
          // Pass email to DiscoverScreen
        ],
      ),
      floatingActionButton: selectedTab == 0
          ? null
          : const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: BottomNavBar(),
            ),
      floatingActionButtonLocation:
          selectedTab == 0 ? null : FloatingActionButtonLocation.centerFloat,
    );
  }
}
