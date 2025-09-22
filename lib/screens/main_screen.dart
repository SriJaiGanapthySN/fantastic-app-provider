import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/nav_provider.dart';
import '../services/token_service.dart';
import 'chat_screen.dart';
import 'discoverscreen.dart';
import 'journey_screen.dart';
import '../widgets/bottom_nav_bar.dart';
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
    ref.listen<int>(selectedTabProvider, (previous, next) {
      if (pageController.hasClients && pageController.page?.round() != next) {
        pageController.jumpToPage(next);
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<String?>(
        future: TokenService.getUserEmail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final userEmail = snapshot.data ?? '';
          print('MainScreen: Using email: $userEmail for all screens');

          return PageView(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              // This is a failsafe, but the primary update mechanism is tapping the nav bar
              if (ref.read(selectedTabProvider) != index) {
                ref.read(selectedTabProvider.notifier).state = index;
              }
            },
            children: [
              ChatScreen(email: userEmail), // 0
              RitualScreen(currentUserEmail: userEmail), // 1
              JourneyScreen(userEmail: userEmail), // 2
              Discoverscreen(email: userEmail), // 3
            ],
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: BottomNavBar(pageController: pageController),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
