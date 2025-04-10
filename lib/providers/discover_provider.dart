import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fantastic_app_riverpod/services/challenges_service.dart';
import 'package:fantastic_app_riverpod/services/coaching_service.dart';
import 'package:fantastic_app_riverpod/services/guided_activities.dart';
import 'package:fantastic_app_riverpod/services/journey_service.dart';

// State classes for different data types
class JourneysState {
  final List<Map<String, dynamic>> journeys;
  final bool isLoading;
  final String? error;

  JourneysState({required this.journeys, required this.isLoading, this.error});

  JourneysState copyWith({
    List<Map<String, dynamic>>? journeys,
    bool? isLoading,
    String? error,
  }) {
    return JourneysState(
      journeys: journeys ?? this.journeys,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class CoachingState {
  final List<Map<String, dynamic>> coaching;
  final bool isLoading;
  final String? error;

  CoachingState({required this.coaching, required this.isLoading, this.error});

  CoachingState copyWith({
    List<Map<String, dynamic>>? coaching,
    bool? isLoading,
    String? error,
  }) {
    return CoachingState(
      coaching: coaching ?? this.coaching,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ActivitiesState {
  final List<Map<String, dynamic>> categories;
  final bool isLoading;
  final String? error;

  ActivitiesState(
      {required this.categories, required this.isLoading, this.error});

  ActivitiesState copyWith({
    List<Map<String, dynamic>>? categories,
    bool? isLoading,
    String? error,
  }) {
    return ActivitiesState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ChallengesState {
  final List<Map<String, dynamic>> challenges;
  final bool isLoading;
  final String? error;

  ChallengesState(
      {required this.challenges, required this.isLoading, this.error});

  ChallengesState copyWith({
    List<Map<String, dynamic>>? challenges,
    bool? isLoading,
    String? error,
  }) {
    return ChallengesState(
      challenges: challenges ?? this.challenges,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// UI State for selected tab and image
class DiscoverUIState {
  final int selectedButtonIndex;
  final String currentImage;

  DiscoverUIState(
      {required this.selectedButtonIndex, required this.currentImage});

  DiscoverUIState copyWith({
    int? selectedButtonIndex,
    String? currentImage,
  }) {
    return DiscoverUIState(
      selectedButtonIndex: selectedButtonIndex ?? this.selectedButtonIndex,
      currentImage: currentImage ?? this.currentImage,
    );
  }
}

// Define images for each button
final List<String> buttonImages = [
  "assets/images/image (5).png", // Journeys image
  "assets/images/image (3).png", // Guided Coaching image
  "assets/images/image (4).png", // Guided Activities image
  "assets/images/image (2).png", // Challenges image
];

// Providers for services
final journeyServiceProvider =
    Provider<JourneyService>((ref) => JourneyService());
final coachingServiceProvider =
    Provider<CoachingService>((ref) => CoachingService());
final activitiesServiceProvider =
    Provider<GuidedActivities>((ref) => GuidedActivities());
final challengesServiceProvider =
    Provider<ChallengesService>((ref) => ChallengesService());

// UI state provider
final discoverUIStateProvider =
    StateNotifierProvider<DiscoverUINotifier, DiscoverUIState>((ref) {
  return DiscoverUINotifier();
});

class DiscoverUINotifier extends StateNotifier<DiscoverUIState> {
  DiscoverUINotifier()
      : super(DiscoverUIState(
            selectedButtonIndex: 0, currentImage: buttonImages[0]));

  void selectButton(int index) {
    state = state.copyWith(
      selectedButtonIndex: index,
      currentImage: buttonImages[index],
    );
  }
}

// Journeys provider
final journeysProvider =
    StateNotifierProvider<JourneysNotifier, JourneysState>((ref) {
  final journeyService = ref.watch(journeyServiceProvider);
  return JourneysNotifier(journeyService);
});

class JourneysNotifier extends StateNotifier<JourneysState> {
  final JourneyService _journeyService;

  JourneysNotifier(this._journeyService)
      : super(JourneysState(journeys: [], isLoading: true));

  Future<void> fetchJourneys() async {
    try {
      state = state.copyWith(isLoading: true);
      final journeys = await _journeyService.fetchJourneys();
      state = state.copyWith(journeys: journeys, isLoading: false);
    } catch (e) {
      state = state.copyWith(
          error: 'Error fetching journeys: $e', isLoading: false);
    }
  }
}

// Coaching provider
final coachingProvider =
    StateNotifierProvider<CoachingNotifier, CoachingState>((ref) {
  final coachingService = ref.watch(coachingServiceProvider);
  return CoachingNotifier(coachingService);
});

class CoachingNotifier extends StateNotifier<CoachingState> {
  final CoachingService _coachingService;

  CoachingNotifier(this._coachingService)
      : super(CoachingState(coaching: [], isLoading: true));

  Future<void> fetchCoaching() async {
    try {
      state = state.copyWith(isLoading: true);
      final coaching = await _coachingService.getMainCoachings();
      state = state.copyWith(coaching: coaching, isLoading: false);
    } catch (e) {
      state = state.copyWith(
          error: 'Error fetching coaching: $e', isLoading: false);
    }
  }
}

// Activities provider
final activitiesProvider =
    StateNotifierProvider<ActivitiesNotifier, ActivitiesState>((ref) {
  final activitiesService = ref.watch(activitiesServiceProvider);
  return ActivitiesNotifier(activitiesService);
});

class ActivitiesNotifier extends StateNotifier<ActivitiesState> {
  final GuidedActivities _guidedActivities;

  ActivitiesNotifier(this._guidedActivities)
      : super(ActivitiesState(categories: [], isLoading: true));

  Future<void> fetchCategories() async {
    try {
      state = state.copyWith(isLoading: true);
      final categories = await _guidedActivities.fetchCategories();
      state = state.copyWith(categories: categories, isLoading: false);
    } catch (e) {
      state = state.copyWith(
          error: 'Error fetching categories: $e', isLoading: false);
    }
  }
}

// Challenges provider
final challengesProvider =
    StateNotifierProvider<ChallengesNotifier, ChallengesState>((ref) {
  final challengesService = ref.watch(challengesServiceProvider);
  return ChallengesNotifier(challengesService);
});

class ChallengesNotifier extends StateNotifier<ChallengesState> {
  final ChallengesService _challengesService;

  ChallengesNotifier(this._challengesService)
      : super(ChallengesState(challenges: [], isLoading: true));

  Future<void> fetchChallenges() async {
    try {
      state = state.copyWith(isLoading: true);
      final challenges = await _challengesService.fetchChallenges();
      state = state.copyWith(challenges: challenges, isLoading: false);
    } catch (e) {
      state = state.copyWith(
          error: 'Error fetching challenges: $e', isLoading: false);
    }
  }
}

// Current data provider based on selected button
final currentDataProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final selectedIndex = ref.watch(discoverUIStateProvider).selectedButtonIndex;

  switch (selectedIndex) {
    case 1:
      return ref.watch(coachingProvider).coaching;
    case 2:
      return ref.watch(activitiesProvider).categories;
    case 3:
      return ref.watch(challengesProvider).challenges;
    default:
      return ref.watch(journeysProvider).journeys;
  }
});
