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
      // 'subtitle':
      //     journey['subtitle'] ?? 'Build habits to help you sleep soundly',
      // 'title': journey['title'] ?? 'A Fabulous Night',
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

final journeyStatsProvider = StreamProvider.family<Map<String, dynamic>, String>((ref, userEmail) async* {
  final journeyService = JourneyService();
  final journeys = await journeyService.fetchUserJourneys(userEmail);
  
  int totalLevels = 0;
  int completedLevels = 0;
  int totalSkills = 0;
  int completedSkills = 0;
  int eventsCompleted = 0;

  for (final journey in journeys) {
    final journeyLevels = (journey['skillLevelCount'] as num?)?.toInt() ?? 0;
    final completedJourneyLevels = (journey['levelsCompleted'] as num?)?.toInt() ?? 0;
    final journeySkills = (journey['skillCount'] as num?)?.toInt() ?? 0;
    final completedJourneySkills = (journey['skillsCompleted'] as num?)?.toInt() ?? 0;
    final journeyEvents = (journey['eventsCompleted'] as num?)?.toInt() ?? 0;

    totalLevels += journeyLevels;
    completedLevels += completedJourneyLevels;
    totalSkills += journeySkills;
    completedSkills += completedJourneySkills;
    eventsCompleted += journeyEvents;
  }

  final levelCompletion = totalLevels > 0 
      ? '${((completedLevels / totalLevels) * 100).toStringAsFixed(0)}%'
      : '0%';
      
  final skillCompletion = totalSkills > 0
      ? '${((completedSkills / totalSkills) * 100).toStringAsFixed(0)}%'
      : '0%';

  yield {
    'levelCompletion': levelCompletion,
    'skillCompletion': skillCompletion,
    'eventsCompleted': eventsCompleted.toString(),
    'totalLevels': totalLevels,
    'completedLevels': completedLevels,
    'totalSkills': totalSkills,
    'completedSkills': completedSkills,
    'lastUpdated': DateTime.now().toIso8601String(),
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

// Enhanced skills provider that includes the journey type from skillTrack model
final skillsWithTypeProvider =
    FutureProvider.family<List<Map<String, dynamic>>, SkillsRequest>(
        (ref, request) async {
  final journeyService = ref.watch(journeyServiceProvider);
  
  // Get journey type from the skillTrack
  final journeyData = await journeyService.getJourneyType(request.skillTrackId, request.email);
  final journeyType = journeyData['type'] ?? '';
  
  // Get skills
  final skills = await journeyService.fetchJourneyLevels(request.skillTrackId);
  
  // Add journey type to each skill
  return skills.map((skill) => {
    ...skill,
    'journeyType': journeyType
  }).toList();
});

// Original skills provider (keep for compatibility)
final skillsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, SkillsRequest>(
        (ref, request) async {
  final journeyService = ref.watch(journeyServiceProvider);
  final skills = await journeyService.fetchJourneyLevels(request.skillTrackId);
  return skills;
});
