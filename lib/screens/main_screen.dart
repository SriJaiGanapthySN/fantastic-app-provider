import 'package:fantastic_app_riverpod/screens/chatScreen.dart';
import 'package:fantastic_app_riverpod/screens/discoverscreen.dart';
import 'package:fantastic_app_riverpod/screens/journey_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/bottom_nav_bar.dart';
import '../providers/auth_provider.dart' as auth;
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
    final userEmail = ref.watch(auth.userEmailProvider);

    ref.listen<int>(selectedTabProvider, (_, index) {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          ref.read(selectedTabProvider.notifier).state = index;
        },
        children: [
          ChatScreen(email: userEmail),
          const RitualScreen(),
          const JourneyRoadmapScreen(),
          Discoverscreen(email: userEmail),
        ],
      ),
      floatingActionButton: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: BottomNavBar(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
