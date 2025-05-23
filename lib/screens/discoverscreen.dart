// ignore_for_file: deprecated_member_use

import 'package:fantastic_app_riverpod/OnBoarding/Screens/onBoard1.dart';
import 'package:fantastic_app_riverpod/profile/profile.dart';
import 'package:fantastic_app_riverpod/providers/auth_provider.dart';
import 'package:fantastic_app_riverpod/providers/discover_provider.dart';
import 'package:fantastic_app_riverpod/setting/settingPage.dart';
import 'package:fantastic_app_riverpod/subChallenges/SubChallengeScreen.dart';
import 'package:fantastic_app_riverpod/widgets/discover/buttonimage.dart';
import 'package:fantastic_app_riverpod/widgets/discover/discoverbuttons.dart';
import 'package:fantastic_app_riverpod/widgets/discover/discoverstrip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import 'ChallengeScreen.dart';
import '../OnBoarding/Screens/onBoard36.dart';
import 'notification_tone_screen.dart';

class Discoverscreen extends ConsumerStatefulWidget {
  final String email;
  const Discoverscreen({super.key, required this.email});

  @override
  ConsumerState<Discoverscreen> createState() => _DiscoverscreenState();
}

class _DiscoverscreenState extends ConsumerState<Discoverscreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _dataDiscoveryController;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller with a longer duration to slow down the animation
    _dataDiscoveryController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // Start the animation and make it repeat
    _dataDiscoveryController.repeat();

    // Load initial data (journeys) when the screen first loads
    Future.microtask(() => ref.read(journeysProvider.notifier).fetchJourneys());
  }

  // Handle button press using the provider
  Future<void> _handleButtonPress(int index) async {
    if (index == 0) {
      ref.read(discoverUIStateProvider.notifier).selectButton(index);
      if (ref.read(journeysProvider).journeys.isEmpty) {
        ref.read(journeysProvider.notifier).fetchJourneys();
      }
    } else if (index == 1) {
      ref.read(discoverUIStateProvider.notifier).selectButton(index);
      if (ref.read(coachingProvider).coaching.isEmpty) {
        ref.read(coachingProvider.notifier).fetchCoaching();
      }
    } else if (index == 2) {
      ref.read(discoverUIStateProvider.notifier).selectButton(index);
      if (ref.read(activitiesProvider).categories.isEmpty) {
        ref.read(activitiesProvider.notifier).fetchCategories();
      }
    } else if (index == 3) {
      final challenges = ref.read(challengesProvider).challenges;

      if (challenges.isEmpty) {
        await ref.read(challengesProvider.notifier).fetchChallenges();
        final updatedChallenges = ref.read(challengesProvider).challenges;
        ref.read(journeysProvider.notifier).fetchJourneys();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChallengeScreen(
                cardData:
                    updatedChallenges), //ChallengeScreen(cardData: updatedChallenges)
          ),
        );
        ref.read(discoverUIStateProvider.notifier).selectButton(0);
        if (ref.read(journeysProvider).journeys.isEmpty) {
          ref.read(journeysProvider.notifier).fetchJourneys();
        }
      } else {
        ref.read(journeysProvider.notifier).fetchJourneys();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChallengeScreen(cardData: challenges),
          ),
        );
        ref.read(discoverUIStateProvider.notifier).selectButton(0);
      }
      if (ref.read(journeysProvider).journeys.isEmpty) {
        ref.read(journeysProvider.notifier).fetchJourneys();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _dataDiscoveryController.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Watch the UI state and current data from providers
    final uiState = ref.watch(discoverUIStateProvider);
    final currentData = ref.watch(currentDataProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Extra screen in drawer',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 21, 21, 21),
            ),
          ),
          centerTitle: true,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.indigo,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.indigo,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      widget.email,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Welcome!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.dashboard_customize, color: Colors.indigo),
                title: Text('Onboarding'),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Onboard1()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.person, color: Colors.indigo),
                title: Text('Profile'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()));
                  // Navigate to profile screen
                },
              ),
              ListTile(
                leading: Icon(Icons.settings, color: Colors.indigo),
                title: Text('Settings'),
                onTap: () {
                  // Navigate to settings screen
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SettingsPage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.notifications, color: Colors.indigo),
                title: Text('Notifications'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationToneScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app, color: Colors.indigo),
                title: Text('Logout'),
                onTap: () async {
                  // Clear all user-specific data
                  await ref.read(authProvider.notifier).logout();

                  // Force a refresh of providers that may cache user data
                  ref.invalidate(userEmailProvider);
                  ref.invalidate(currentEmailProvider);
                  ref.invalidate(emailStorageProvider);

                  // Reset any other user-specific providers
                  ref.invalidate(journeysProvider);
                  ref.invalidate(coachingProvider);
                  ref.invalidate(activitiesProvider);
                  ref.invalidate(challengesProvider);

                  // Close the drawer and navigate to login screen
                  Navigator.pop(context);
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/', // Replace with your login route
                    (route) => false,
                  );
                },
              ),
              Divider(),
            ],
          ),
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bgdiscover.jpeg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.transparent,
                    BlendMode.dst,
                  ),
                ),
              ),
            ),
            Buttonimage(currentImage: uiState.currentImage),
            // Temporarily removed Lottie animation to debug red screen issue
            Column(
              children: [
                Discoverbuttons(
                    handleButtonPress: _handleButtonPress,
                    selectedButtonIndex: uiState.selectedButtonIndex == 3
                        ? 0
                        : uiState.selectedButtonIndex),
                SizedBox(height: screenHeight * 0.09),
                Discoverstrip(currentData: currentData, email: widget.email)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
