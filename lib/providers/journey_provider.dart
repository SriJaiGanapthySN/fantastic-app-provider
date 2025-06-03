import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/journey_service.dart';
import '../models/skillTrack.dart';
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

final journeyStatsProvider = StreamProvider.family<Map<String, dynamic>, JourneyStatsRequest>((ref, request) async* {
  print('=== STATS PROVIDER STARTING FOR JOURNEY: ${request.journeyId} ===');
  print('User: ${request.userEmail}');
  
  final initKey = '${request.userEmail}_${request.journeyId}';
  
  // Function to calculate stats immediately from database for specific journey
  Future<Map<String, dynamic>> getStatsFromDatabase() async {
    print('=== GETTING FRESH STATS FROM DATABASE ===');
    print('User: ${request.userEmail}');
    print('Journey ID: ${request.journeyId}');
    print('Timestamp: ${DateTime.now()}');
    
    try {
      int totalLevels = 0;
      int completedLevels = 0;
      int totalSkills = 0;
      int completedSkills = 0;
      int eventsCompleted = 0;

      // Get the specific journey
      print('🔍 Looking for journey document at:');
      print('  Path: /testers/${request.userEmail}/skillTrack/${request.journeyId}');
      print('  Journey ID: ${request.journeyId}');
      
      final journeyDoc = await FirebaseFirestore.instance
          .collection('testers')
          .doc(request.userEmail)
          .collection('skillTrack')
          .doc(request.journeyId)
          .get();

      if (!journeyDoc.exists) {
        print('❌ Journey not found: ${request.journeyId}');
        
        // Check if we've already tried to initialize this journey
        if (_journeyInitializationAttempts[initKey] == true) {
          print('⚠️ Already attempted initialization for ${request.journeyId} - skipping to avoid loop');
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
        
        print('🚀 AUTO-INITIALIZING MISSING JOURNEY NOW!');
        _journeyInitializationAttempts[initKey] = true; // Mark as attempted
        
        // Get journey service for initialization
        final journeyService = JourneyService();
        
        // Initialize the journey
        final initSuccess = await journeyService.initializeJourney(
          request.userEmail, 
          request.journeyId, 
          null // Let the service determine the journey data
        );
        
        if (initSuccess) {
          print('✅ Journey initialized successfully - calculating stats...');
          
          // Reset the initialization flag on success
          _journeyInitializationAttempts.remove(initKey);
          
          // Recalculate stats after initialization
          return getStatsFromDatabase();
        } else {
          print('❌ Failed to initialize journey');
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
        final journeyLevelsCompleted = (journeyData['levelsCompleted'] as num?)?.toInt() ?? 0;
        completedLevels = journeyLevelsCompleted;
        
        print('Journey ${request.journeyId}: ${journeyLevelsCompleted} levels completed');

        // Get skills for this specific journey
        final skillsSnapshot = await FirebaseFirestore.instance
            .collection('testers')
            .doc(request.userEmail)
            .collection('skill')
            .where('skillTrackId', isEqualTo: request.journeyId)
            .get();

        print('Found ${skillsSnapshot.docs.length} skills for journey ${request.journeyId}');

        for (var skillDoc in skillsSnapshot.docs) {
          final skillData = skillDoc.data();
          final skillTotalLevels = (skillData['totalLevels'] as num?)?.toInt() ?? 0;
          final skillCompletedLevels = (skillData['skillLevelCompleted'] as num?)?.toInt() ?? 0;
          final isSkillCompleted = skillData['isCompleted'] as bool? ?? false;
          
          totalLevels += skillTotalLevels;
          totalSkills += 1;
          
          print('Skill ${skillDoc.id}: completed=${skillCompletedLevels}/${skillTotalLevels}, isCompleted=${isSkillCompleted}');
          
          if (isSkillCompleted || (skillCompletedLevels >= skillTotalLevels && skillTotalLevels > 0)) {
            completedSkills += 1;
            print('  ✅ Skill ${skillDoc.id} counts as completed');
          } else {
            print('  ❌ Skill ${skillDoc.id} not completed yet');
          }
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
        print('Journey ${request.journeyId}: ${completedLevelsSnapshot.docs.length} events completed');
        
        // Debug: Show some completed levels
        for (var levelDoc in completedLevelsSnapshot.docs.take(3)) {
          final levelData = levelDoc.data();
          print('  Completed level ${levelDoc.id}: type=${levelData['type']}, skillId=${levelData['skillId']}');
        }
      }

      final levelCompletion = totalLevels > 0 
          ? '${((completedLevels / totalLevels) * 100).round()}%'
          : '0%';
          
      final skillCompletion = totalSkills > 0
          ? '${((completedSkills / totalSkills) * 100).round()}%'
          : '0%';

      print('=== FINAL STATS FOR JOURNEY ${request.journeyId} ===');
      print('Level Completion: $levelCompletion ($completedLevels/$totalLevels)');
      print('Skill Completion: $skillCompletion ($completedSkills/$totalSkills)');
      print('Events Completed: $eventsCompleted');

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

      print('=== RETURNING STATS FOR JOURNEY ${request.journeyId} ===');
      print('Result: $result');
      
      return result;
    } catch (e) {
      print('❌ ERROR calculating stats for journey ${request.journeyId}: $e');
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
  print('✅ ENABLING REAL-TIME STATS - GOAL COMPLETION SHOULD UPDATE IMMEDIATELY');
  
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
  
  print('🔍 SETTING UP LISTENERS FOR JOURNEY: ${request.journeyId}');
  print('📡 Watching paths:');
  print('  - /testers/${request.userEmail}/skillGoal (all goals)');
  print('  - /testers/${request.userEmail}/skillLevel?skillTrackId=${request.journeyId}');
  print('  - /testers/${request.userEmail}/skill?skillTrackId=${request.journeyId}');
  print('  - /testers/${request.userEmail}/skillTrack/${request.journeyId}');
  
  skillGoalsStream.listen((snapshot) {
    print('🔥 SKILL GOALS CHANGED - RECALCULATING STATS');
    print('   Change count: ${snapshot.docChanges.length}');
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.modified) {
        final data = change.doc.data();
        print('   Modified goal: ${change.doc.id} | isCompleted: ${data?['isCompleted']}');
      }
    }
    controller.add(null);
  });
  
  skillLevelsStream.listen((snapshot) {
    print('🔥 SKILL LEVELS CHANGED FOR JOURNEY ${request.journeyId} - RECALCULATING STATS');
    print('   Change count: ${snapshot.docChanges.length}');
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.modified) {
        final data = change.doc.data();
        print('   Modified level: ${change.doc.id} | isCompleted: ${data?['isCompleted']}');
      }
    }
    controller.add(null);
  });
  
  skillsStream.listen((snapshot) {
    print('🔥 SKILLS CHANGED FOR JOURNEY ${request.journeyId} - RECALCULATING STATS');
    print('   Change count: ${snapshot.docChanges.length}');
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.modified) {
        final data = change.doc.data();
        print('   Modified skill: ${change.doc.id} | skillLevelCompleted: ${data?['skillLevelCompleted']}');
      }
    }
    controller.add(null);
  });
  
  journeyStream.listen((snapshot) {
    print('🔥 JOURNEY ${request.journeyId} CHANGED - RECALCULATING STATS');
    if (snapshot.exists) {
      final data = snapshot.data();
      print('   Journey levelsCompleted: ${data?['levelsCompleted']}');
    }
    controller.add(null);
  });
      
  // Listen for any updates and recalculate
  await for (final _ in controller.stream) {
    print('📊 RECALCULATING STATS DUE TO DATA CHANGE');
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
