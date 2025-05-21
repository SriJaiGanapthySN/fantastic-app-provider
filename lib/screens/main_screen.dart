import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/nav_provider.dart';
import 'ChallengeScreen.dart';
import 'chatScreen.dart';
import 'discoverscreen.dart';
import 'journey_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../providers/auth_provider.dart' as auth;
import '../widgets/user_guide.dart';
import '../models/feedback.dart';
import 'feedback/feed_back.dart';
import 'ritual_screen.dart';
import 'notification_tone_screen.dart';
import 'extras_screen.dart';

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
          ChatScreen(email: "test03@gmail.com"),
          const RitualScreen(),
          Discoverscreen(email: "test03@gmail.com"),
        ],
      ),
      floatingActionButton: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: BottomNavBar(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
