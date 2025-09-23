import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/journey_service.dart';
import 'discover_provider.dart'; // Import to get persona provider
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

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
      // 'title': journey['title'] ?? 'AFantastic  Night',
    };
  }
  return null;
});

final allJourneysProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, email) async {
  final journeyService = ref.watch(journeyServiceProvider);
  final isParentMode = ref.watch(personaProvider).isParentMode;

  print('🚀 allJourneysProvider: Fetching user journeys for $email');
  print('🚀 allJourneysProvider: Parent mode: $isParentMode');

  final journeys =
      await journeyService.fetchUserJourneys(email, isParentMode: isParentMode);

  print('🚀 allJourneysProvider: Found ${journeys.length} user journeys');
  if (journeys.isNotEmpty) {
    for (int i = 0; i < journeys.length && i < 3; i++) {
      final journey = journeys[i];
      final id = journey['objectId'] ?? journey['id'] ?? 'NO_ID';
      final title = journey['title'] ?? 'NO_TITLE';
      print('   - $id ($title)');
    }
  }

  return journeys;
});

class JourneyStatsRequest {
  final String userEmail;
  final String journeyId;

  JourneyStatsRequest({required this.userEmail, required this.journeyId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JourneyStatsRequest &&
          userEmail == other.userEmail &&
          journeyId == other.journeyId;

  @override
  int get hashCode => userEmail.hashCode ^ journeyId.hashCode;
}

// Track initialization attempts to prevent infinite loops
final Map<String, bool> _journeyInitializationAttempts = {};

final journeyStatsProvider =
    StreamProvider.family<Map<String, dynamic>, JourneyStatsRequest>(
        (ref, request) async* {
  final initKey = '${request.userEmail}_${request.journeyId}';

  // Function to calculate stats immediately from database for specific journey
  Future<Map<String, dynamic>> getStatsFromDatabase() async {
    try {
      int totalLevels = 0;
      int completedLevels = 0;
      int totalSkills = 0;
      int completedSkills = 0;
      int eventsCompleted = 0;

      // Get the specific journey

      final journeyDoc = await FirebaseFirestore.instance
          .collection('testers')
          .doc(request.userEmail)
          .collection('skillTrack')
          .doc(request.journeyId)
          .get();

      if (!journeyDoc.exists) {
        // Check if we've already tried to initialize this journey
        if (_journeyInitializationAttempts[initKey] == true) {
          return {
            'levelCompletion': '0%',
            'skillCompletion': '0%',
            'eventsCompleted': '0',
            'totalLevels': 0,
            'completedLevels': 0,
            'totalSkills': 0,
            'completedSkills': 0,
            'lastUpdated': DateTime.now().toIso8601String(),
            'error': 'Journey not found and initialization already attempted',
          };
        }

        _journeyInitializationAttempts[initKey] = true; // Mark as attempted

        // Get journey service for initialization
        final journeyService = JourneyService();
        final isParentMode = ref.read(personaProvider).isParentMode;

        // Initialize the journey
        final initSuccess = await journeyService.initializeJourney(
            request.userEmail,
            request.journeyId,
            null, // Let the service determine the journey data
            isParentMode: isParentMode);

        if (initSuccess) {
          // Reset the initialization flag on success
          _journeyInitializationAttempts.remove(initKey);

          // Recalculate stats after initialization
          return getStatsFromDatabase();
        } else {
          return {
            'levelCompletion': '0%',
            'skillCompletion': '0%',
            'eventsCompleted': '0',
            'totalLevels': 0,
            'completedLevels': 0,
            'totalSkills': 0,
            'completedSkills': 0,
            'lastUpdated': DateTime.now().toIso8601String(),
            'error': 'Failed to initialize journey',
          };
        }
      } else {
        // Reset initialization flag if journey exists
        _journeyInitializationAttempts.remove(initKey);

        final journeyData = journeyDoc.data()!;
        final journeyLevelsCompleted =
            (journeyData['levelsCompleted'] as num?)?.toInt() ?? 0;
        completedLevels = journeyLevelsCompleted;

        // Get skills for this specific journey
        final skillsSnapshot = await FirebaseFirestore.instance
            .collection('testers')
            .doc(request.userEmail)
            .collection('skill')
            .where('skillTrackId', isEqualTo: request.journeyId)
            .get();

        for (var skillDoc in skillsSnapshot.docs) {
          final skillData = skillDoc.data();
          final skillTotalLevels =
              (skillData['totalLevels'] as num?)?.toInt() ?? 0;
          final skillCompletedLevels =
              (skillData['skillLevelCompleted'] as num?)?.toInt() ?? 0;
          final isSkillCompleted = skillData['isCompleted'] as bool? ?? false;

          totalLevels += skillTotalLevels;
          totalSkills += 1;

          if (isSkillCompleted ||
              (skillCompletedLevels >= skillTotalLevels &&
                  skillTotalLevels > 0)) {
            completedSkills += 1;
          } else {}
        }

        // Count completed skill levels for this specific journey
        final completedLevelsSnapshot = await FirebaseFirestore.instance
            .collection('testers')
            .doc(request.userEmail)
            .collection('skillLevel')
            .where('skillTrackId', isEqualTo: request.journeyId)
            .where('isCompleted', isEqualTo: true)
            .get();

        eventsCompleted = completedLevelsSnapshot.docs.length;

        // Debug: Show some completed levels
        for (var levelDoc in completedLevelsSnapshot.docs.take(3)) {
          levelDoc.data();
        }
      }

      final levelCompletion = totalLevels > 0
          ? '${((completedLevels / totalLevels) * 100).round()}%'
          : '0%';

      final skillCompletion = totalSkills > 0
          ? '${((completedSkills / totalSkills) * 100).round()}%'
          : '0%';

      final result = {
        'levelCompletion': levelCompletion,
        'skillCompletion': skillCompletion,
        'eventsCompleted': eventsCompleted.toString(),
        'totalLevels': totalLevels,
        'completedLevels': completedLevels,
        'totalSkills': totalSkills,
        'completedSkills': completedSkills,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      return result;
    } catch (e) {
      return {
        'levelCompletion': '0%',
        'skillCompletion': '0%',
        'eventsCompleted': '0',
        'totalLevels': 0,
        'completedLevels': 0,
        'totalSkills': 0,
        'completedSkills': 0,
        'lastUpdated': DateTime.now().toIso8601String(),
        'error': e.toString(),
      };
    }
  }

  // TEMPORARILY DISABLE STREAMING - JUST RETURN INITIAL STATS

  // Yield initial stats
  final initialStats = await getStatsFromDatabase();
  yield initialStats;

  // Set up listeners for ALL collections that affect stats
  final skillGoalsStream = FirebaseFirestore.instance
      .collection('testers')
      .doc(request.userEmail)
      .collection('skillGoal')
      .snapshots();

  final skillLevelsStream = FirebaseFirestore.instance
      .collection('testers')
      .doc(request.userEmail)
      .collection('skillLevel')
      .where('skillTrackId', isEqualTo: request.journeyId)
      .snapshots();

  final skillsStream = FirebaseFirestore.instance
      .collection('testers')
      .doc(request.userEmail)
      .collection('skill')
      .where('skillTrackId', isEqualTo: request.journeyId)
      .snapshots();

  final journeyStream = FirebaseFirestore.instance
      .collection('testers')
      .doc(request.userEmail)
      .collection('skillTrack')
      .doc(request.journeyId)
      .snapshots();

  // Use a simple approach - listen to each stream individually
  final controller = StreamController<void>();

  skillGoalsStream.listen((snapshot) {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.modified) {
        change.doc.data();
      }
    }
    controller.add(null);
  });

  skillLevelsStream.listen((snapshot) {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.modified) {
        change.doc.data();
      }
    }
    controller.add(null);
  });

  skillsStream.listen((snapshot) {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.modified) {
        change.doc.data();
      }
    }
    controller.add(null);
  });

  journeyStream.listen((snapshot) {
    if (snapshot.exists) {
      snapshot.data();
    }
    controller.add(null);
  });

  // Listen for any updates and recalculate
  await for (final _ in controller.stream) {
    final newStats = await getStatsFromDatabase();
    yield newStats;
  }
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
  final isParentMode = ref.watch(personaProvider).isParentMode;

  // Get journey type from the skillTrack
  final journeyData = await journeyService.getJourneyType(
      request.skillTrackId, request.email,
      isParentMode: isParentMode);
  final journeyType = journeyData['type'] ?? '';

  // Get skills
  final skills = await journeyService.fetchJourneyLevels(request.skillTrackId);

  // Add journey type to each skill
  return skills.map((skill) => {...skill, 'journeyType': journeyType}).toList();
});

// Original skills provider (keep for compatibility)
final skillsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, SkillsRequest>(
        (ref, request) async {
  final journeyService = ref.watch(journeyServiceProvider);
  final skills = await journeyService.fetchJourneyLevels(request.skillTrackId);
  return skills;
});
