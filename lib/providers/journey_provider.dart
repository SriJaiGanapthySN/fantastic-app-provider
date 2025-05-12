import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/journey_service.dart';
import '../models/skillTrack.dart';

final journeyServiceProvider = Provider<JourneyService>((ref) {
  return JourneyService();
});

final currentJourneyProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, email) async {
  final journeyService = ref.watch(journeyServiceProvider);
  final journey = await journeyService.fetchUnreleaseJourney(email);

  if (journey != null) {
    return {
      ...journey,
      'imageUrl': journey['imageUrl'] ??
          journey['bigImageUrl'] ??
          '', // Use imageUrl or bigImageUrl from server
      'subtitle':
          journey['subtitle'] ?? 'Build habits to help you sleep soundly',
      'title': journey['title'] ?? 'A Fabulous Night',
    };
  }
  return null;
});

final allJourneysProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, email) async {
  final journeyService = ref.watch(journeyServiceProvider);
  return journeyService.fetchUserJourneys(email);
});

final journeyStatsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, email) async {
  final journeyService = ref.watch(journeyServiceProvider);
  final journeys = await journeyService.fetchUserJourneys(email);

  final totalLevels = journeys.fold<int>(
      0, (sum, journey) => sum + ((journey['skillLevelCount'] ?? 0) as int));

  final completedLevels = journeys.fold<int>(
      0, (sum, journey) => sum + ((journey['levelsCompleted'] ?? 0) as int));

  final completion = totalLevels > 0
      ? (completedLevels / totalLevels * 100).toStringAsFixed(0)
      : '0';

  return {
    'completion': '$completion%',
    'totalLevels': totalLevels,
    'completedLevels': completedLevels,
    'eventsAchieved': '$completedLevels/$totalLevels'
  };
});

class SkillsRequest {
  final String skillTrackId;
  final String email;

  SkillsRequest({required this.skillTrackId, required this.email});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillsRequest &&
          skillTrackId == other.skillTrackId &&
          email == other.email;

  @override
  int get hashCode => skillTrackId.hashCode ^ email.hashCode;
}

final skillsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, SkillsRequest>(
        (ref, request) async {
  final journeyService = ref.watch(journeyServiceProvider);
  final skills = await journeyService.fetchJourneyLevels(request.skillTrackId);
  return skills;
});
