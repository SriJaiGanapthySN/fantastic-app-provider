import 'package:fantastic_app_riverpod/screens/ChallengeScreen.dart';
import 'package:fantastic_app_riverpod/screens/chatScreen.dart';
import 'package:fantastic_app_riverpod/screens/discoverscreen.dart';
import 'package:fantastic_app_riverpod/screens/journey_path.dart';
import 'package:fantastic_app_riverpod/screens/journey_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/bottom_nav_bar.dart';
import '../providers/auth_provider.dart' as auth;
import '../widgets/user_guide.dart';
import '../models/feedback.dart';
import 'feedback/feed_back.dart';

import 'ritual_screen.dart';
import 'notification_tone_screen.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.pink),
        title: const Text('Fantastic App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationToneScreen(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.pink,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fantastic App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    userEmail ?? 'Guest User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.fitness_center, color: Colors.pink),
              title: Text('Challenges'),
              onTap: () {
                // Replace this with actual navigation to challenges screen when created
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChallengeScreen(
                      cardData: [],
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.feedback, color: Colors.pink),
              title: Text('Feedback'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                final feedbackQuestions =
                    FeedbackManager.getAppFeedbackQuestions();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeedbackScreen(
                      allQuestions: feedbackQuestions,
                    ),
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.notifications_none, color: Colors.pink),
              title: Text('Notification Tone'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationToneScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.pink),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Settings coming soon!')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.help_outline, color: Colors.pink),
              title: Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Help & Support coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
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
