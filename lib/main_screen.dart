import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/common/providers/nav_provider.dart';
import 'features/chat/presentation/providers/token/token_provider.dart';
import 'features/chat/data/services/token/token_service.dart';
import 'features/chat/presentation/screens/chat_screen.dart';
import 'features/discover/presentation/screens/discoverscreen.dart';
import 'features/journeys/presentation/screens/normal/journey_screen.dart';
import 'core/common/widgets/bottom_nav_bar.dart';
import 'features/extras/presentation/widgets/user_guide.dart';

import 'features/ritual/presentation/screens/ritual_screen.dart';

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
      body: Consumer(
        builder: (context, ref, child) {
          // Watch the token validation status
          final tokenValidationAsync = ref.watch(tokenValidationProvider);

          return tokenValidationAsync.when(
            data: (isTokenValid) {
              if (!isTokenValid) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.security, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Authentication required',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Please log in to access the app',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              // Token is valid, get user data and show main content
              return FutureBuilder<String?>(
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
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) {
              print('Token validation error: $error');
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Authentication Error',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please restart the app and try again',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
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
