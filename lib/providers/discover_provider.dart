// ignore_for_file: unused_import

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

// Persona State for toggle between parent and regular mode
class PersonaState {
  final bool isParentMode;

  PersonaState({required this.isParentMode});

  PersonaState copyWith({bool? isParentMode}) {
    return PersonaState(
      isParentMode: isParentMode ?? this.isParentMode,
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

// Persona provider
final personaProvider =
    StateNotifierProvider<PersonaNotifier, PersonaState>((ref) {
  return PersonaNotifier();
});

class PersonaNotifier extends StateNotifier<PersonaState> {
  PersonaNotifier() : super(PersonaState(isParentMode: false));

  void togglePersona() {
    state = state.copyWith(isParentMode: !state.isParentMode);
  }

  void setParentMode(bool isParent) {
    state = state.copyWith(isParentMode: isParent);
  }
}

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

// Journeys provider with persona awareness
final journeysProvider =
    StateNotifierProvider<JourneysNotifier, JourneysState>((ref) {
  final journeyService = ref.watch(journeyServiceProvider);
  return JourneysNotifier(journeyService, ref);
});

class JourneysNotifier extends StateNotifier<JourneysState> {
  final JourneyService _journeyService;
  final Ref _ref;

  JourneysNotifier(this._journeyService, this._ref)
      : super(JourneysState(journeys: [], isLoading: true)) {
    // Listen to persona changes and refetch automatically
    _ref.listen<PersonaState>(personaProvider, (previous, next) {
      if (previous?.isParentMode != next.isParentMode) {
        print(
            '🔄 JourneysNotifier: Persona changed, refetching journeys. Parent mode: ${next.isParentMode}');
        fetchJourneys();
      }
    });

    // Initial fetch
    fetchJourneys();
  }

  Future<void> fetchJourneys() async {
    try {
      print('🚀 JourneysNotifier: Starting to fetch journeys...');
      state = state.copyWith(isLoading: true);
      final isParentMode = _ref.read(personaProvider).isParentMode;
      print('🚀 JourneysNotifier: Parent mode: $isParentMode');

      final journeys =
          await _journeyService.fetchJourneys(isParentMode: isParentMode);

      print('🚀 JourneysNotifier: Fetched ${journeys.length} journeys');

      if (journeys.isNotEmpty) {
        print('🚀 JourneysNotifier: Sample journeys:');
        for (int i = 0; i < journeys.length && i < 3; i++) {
          final journey = journeys[i];
          final id = journey['objectId'] ?? journey['id'] ?? 'NO_ID';
          final title = journey['title'] ?? 'NO_TITLE';
          print('   - $id ($title)');
        }
      } else {
        print('⚠️ JourneysNotifier: No journeys found!');
      }

      state = state.copyWith(journeys: journeys, isLoading: false);
    } catch (e) {
      print('💥 JourneysNotifier: Error fetching journeys: $e');
      state = state.copyWith(
          error: 'Error fetching journeys: $e', isLoading: false);
    }
  }

  // Manual refresh method
  Future<void> refreshJourneys() async {
    await fetchJourneys();
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
      print('🚀 CoachingNotifier: Starting to fetch coaching...');
      state = state.copyWith(isLoading: true);
      final coaching = await _coachingService.getMainCoachings();
      print('🚀 CoachingNotifier: Fetched ${coaching.length} coaching items');
      state = state.copyWith(coaching: coaching, isLoading: false);

      // Debug: Print first few items
      if (coaching.isNotEmpty) {
        print('🚀 CoachingNotifier: Sample coaching items:');
        for (int i = 0; i < coaching.length && i < 3; i++) {
          final item = coaching[i];
          print(
              '   - ${item['title'] ?? 'NO_TITLE'} (id: ${item['objectId'] ?? 'NO_ID'})');
        }
      } else {
        print('🚀 CoachingNotifier: No coaching items found!');
      }
    } catch (e) {
      print('💥 CoachingNotifier: Error fetching coaching: $e');
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
  return ChallengesNotifier(challengesService, ref);
});

class ChallengesNotifier extends StateNotifier<ChallengesState> {
  final ChallengesService _challengesService;
  final Ref _ref;

  ChallengesNotifier(this._challengesService, this._ref)
      : super(ChallengesState(challenges: [], isLoading: true)) {
    // Listen to persona changes and refetch automatically
    _ref.listen<PersonaState>(personaProvider, (previous, next) {
      if (previous?.isParentMode != next.isParentMode) {
        fetchChallenges();
      }
    });
  }

  Future<void> fetchChallenges() async {
    try {
      state = state.copyWith(isLoading: true);
      final isParentMode = _ref.read(personaProvider).isParentMode;
      final challenges =
          await _challengesService.fetchChallenges(isParentMode: isParentMode);
      state = state.copyWith(challenges: challenges, isLoading: false);
    } catch (e) {
      state = state.copyWith(
          error: 'Error fetching challenges: $e', isLoading: false);
    }
  }

  // Manual refresh method
  Future<void> refreshChallenges() async {
    await fetchChallenges();
  }

  // Fetch user-specific challenges
  Future<void> fetchUserChallenges(String email) async {
    try {
      state = state.copyWith(isLoading: true);
      final isParentMode = _ref.read(personaProvider).isParentMode;
      final challenges = await _challengesService.fetchUserChallenges(email,
          isParentMode: isParentMode);
      state = state.copyWith(challenges: challenges, isLoading: false);
    } catch (e) {
      state = state.copyWith(
          error: 'Error fetching user challenges: $e', isLoading: false);
    }
  }

  // Fetch unreleased challenge for user
  Future<void> fetchUnreleasedChallenge(String email) async {
    try {
      state = state.copyWith(isLoading: true);
      final isParentMode = _ref.read(personaProvider).isParentMode;
      final challenges = await _challengesService
          .fetchUnreleasedChallenge(email, isParentMode: isParentMode);
      state = state.copyWith(challenges: challenges, isLoading: false);
    } catch (e) {
      state = state.copyWith(
          error: 'Error fetching unreleased challenge: $e', isLoading: false);
    }
  }

  // Reset challenges state
  void resetChallenges() {
    state = ChallengesState(challenges: [], isLoading: false);
  }
}

// Current data provider based on selected button
final currentDataProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final selectedIndex = ref.watch(discoverUIStateProvider).selectedButtonIndex;
  print('🔄 currentDataProvider: selectedIndex=$selectedIndex');

  switch (selectedIndex) {
    case 1:
      final coachingData = ref.watch(coachingProvider).coaching;
      print(
          '🔄 currentDataProvider: coaching data length=${coachingData.length}');
      return coachingData;
    case 2:
      final activitiesData = ref.watch(activitiesProvider).categories;
      print(
          '🔄 currentDataProvider: activities data length=${activitiesData.length}');
      return activitiesData;
    case 3:
      final challengesData = ref.watch(challengesProvider).challenges;
      print(
          '🔄 currentDataProvider: challenges data length=${challengesData.length}');
      return challengesData;
    default:
      final journeysData = ref.watch(journeysProvider).journeys;
      print(
          '🔄 currentDataProvider: journeys data length=${journeysData.length}');
      return journeysData;
  }
});
