// ignore_for_file: deprecated_member_use

import 'package:fantastic_app_riverpod/providers/discover_provider.dart';
import 'package:fantastic_app_riverpod/widgets/discover/buttonimage.dart';
import 'package:fantastic_app_riverpod/widgets/discover/discoverbuttons.dart';
import 'package:fantastic_app_riverpod/widgets/discover/discoverstrip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

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
  void _handleButtonPress(int index) {
    // Update the UI state
    ref.read(discoverUIStateProvider.notifier).selectButton(index);

    // Fetch data for the selected category if it hasn't been loaded yet
    if (index == 0) {
      if (ref.read(journeysProvider).journeys.isEmpty) {
        ref.read(journeysProvider.notifier).fetchJourneys();
      }
    } else if (index == 1) {
      if (ref.read(coachingProvider).coaching.isEmpty) {
        ref.read(coachingProvider.notifier).fetchCoaching();
      }
    } else if (index == 2) {
      if (ref.read(activitiesProvider).categories.isEmpty) {
        ref.read(activitiesProvider.notifier).fetchCategories();
      }
    } else if (index == 3) {
      if (ref.read(challengesProvider).challenges.isEmpty) {
        ref.read(challengesProvider.notifier).fetchChallenges();
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

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bgdiscover.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Buttonimage(currentImage: uiState.currentImage),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Lottie.asset(
              "assets/animations/disbottom.json",
              controller: _dataDiscoveryController,
              repeat: false,
              animate: false,
              width: MediaQuery.of(context).size.width,
            ),
          ),
          Column(
            children: [
              Discoverbuttons(
                  handleButtonPress: _handleButtonPress,
                  selectedButtonIndex: uiState.selectedButtonIndex),
              SizedBox(height: screenHeight * 0.09),
              Discoverstrip(currentData: currentData, email: widget.email)
            ],
          ),
        ],
      ),
    );
  }
}
