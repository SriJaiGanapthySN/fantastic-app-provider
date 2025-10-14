import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../discover/presentation/providers/discover_provider.dart'; // Import persona provider

// Helper function to safely convert dynamic values to int
int? _safeToInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    try {
      return int.parse(value);
    } catch (e) {
      return null;
    }
  }
  return null;
}

// --- SkillLevel Class (unchanged from your example) ---
class SkillLevel {
  final String id; // Firestore Document ID
  final String? contentUrl;
  final int? createdAt;
  final String? headline;
  final String? headlineImageUrl;
  final String objectId;
  final int? position;
  final String skillId;
  final String skillTrackId;
  final String? type;
  final int? updatedAt;
  final String? contentTitle;
  final String? contentReadingTime;

  SkillLevel({
    required this.id,
    this.contentUrl,
    this.createdAt,
    this.headline,
    this.headlineImageUrl,
    required this.objectId,
    this.position,
    required this.skillId,
    required this.skillTrackId,
    this.type,
    this.updatedAt,
    this.contentTitle,
    this.contentReadingTime,
  });

  // Factory from Firestore DocumentSnapshot
  factory SkillLevel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Missing data for SkillLevel doc ${doc.id}');
    }
    return SkillLevel(
      id: doc.id,
      contentUrl: data['contentUrl'] as String?,
      createdAt: _safeToInt(data['createdAt']),
      headline: data['headline'] as String?,
      headlineImageUrl: data['headlineImageUrl'] as String?,
      objectId: data['objectId'] as String? ?? '',
      position: _safeToInt(data['position']),
      skillId: data['skillId'] as String? ?? '',
      skillTrackId: data['skillTrackId'] as String? ?? '',
      type: data['type'] as String?,
      updatedAt: _safeToInt(data['updatedAt']),
      contentTitle: data['contentTitle'] as String?,
      contentReadingTime: data['contentReadingTime'] as String?,
    );
  }

  // To JSON (doesn't include id)
  Map<String, dynamic> toJson() {
    return {
      'contentUrl': contentUrl,
      'createdAt': createdAt,
      'headline': headline,
      'headlineImageUrl': headlineImageUrl,
      'objectId': objectId,
      'position': position,
      'skillId': skillId,
      'skillTrackId': skillTrackId,
      'type': type,
      'updatedAt': updatedAt,
      'contentTitle': contentTitle,
      'contentReadingTime': contentReadingTime,
    };
  }
}

// --- Modified Skill Class ---
class Skill {
  final String id; // <<< Added Firestore Document ID
  final String color;
  final int createdAt;
  final String goalId;
  final String iconUrl;
  final String iosIconUrl;
  final String objectId;
  final int position;
  final String skillTrackId; // The field we query by
  final String title;
  final int updatedAt;

  Skill({
    required this.id, // <<< Added id to constructor
    required this.color,
    required this.createdAt,
    required this.goalId,
    required this.iconUrl,
    required this.iosIconUrl,
    required this.objectId,
    required this.position,
    required this.skillTrackId,
    required this.title,
    required this.updatedAt,
  });

  // Factory from Firestore DocumentSnapshot
  factory Skill.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Missing data for Skill doc ${doc.id}');
    }
    return Skill(
      id: doc.id, // <<< Assign doc id
      color: data['color'] as String? ?? '#FFFFFF', // Provide default if needed
      createdAt: _safeToInt(data['createdAt']) ?? 0,
      goalId: data['goalId'] as String? ?? '',
      iconUrl: data['iconUrl'] as String? ?? '',
      iosIconUrl: data['iosIconUrl'] as String? ?? '',
      objectId: data['objectId'] as String? ?? '',
      position: _safeToInt(data['position']) ?? 0,
      skillTrackId: data['skillTrackId'] as String? ?? '', // Crucial field
      title: data['title'] as String? ?? '',
      updatedAt: _safeToInt(data['updatedAt']) ?? 0,
    );
  }

  // Original fromJson factory (can be kept for other uses if needed)
  factory Skill.fromJson(Map<String, dynamic> json) {
    // Note: This doesn't set the Firestore 'id'. Use fromFirestore for that.
    return Skill(
      id: json['id'] ??
          '', // Allow setting id if passed in JSON, but fromFirestore is preferred
      color: json['color'] as String,
      createdAt: _safeToInt(json['createdAt']) ?? 0,
      goalId: json['goalId'] as String,
      iconUrl: json['iconUrl'] as String,
      iosIconUrl: json['iosIconUrl'] as String,
      objectId: json['objectId'] as String,
      position: _safeToInt(json['position']) ?? 0,
      skillTrackId: json['skillTrackId'] as String,
      title: json['title'] as String,
      updatedAt: _safeToInt(json['updatedAt']) ?? 0,
    );
  }

  // To JSON (doesn't include id)
  Map<String, dynamic> toJson() {
    return {
      'color': color,
      'createdAt': createdAt,
      'goalId': goalId,
      'iconUrl': iconUrl,
      'iosIconUrl': iosIconUrl,
      'objectId': objectId,
      'position': position,
      'skillTrackId': skillTrackId,
      'title': title,
      'updatedAt': updatedAt,
    };
  }
}

// --- Modified SkillGoal Class ---
class SkillGoal {
  final String id; // <<< Added Firestore Document ID
  final int createdAt;
  final String description;
  final List<String> habitIds;
  final String objectId;
  final bool removePreviousGoalHabits;
  final String ritualType;
  final String skillTrackId; // The field we query by
  final String title;
  final String type;
  final int updatedAt;
  final int value;

  SkillGoal({
    required this.id, // <<< Added id to constructor
    required this.createdAt,
    required this.description,
    required this.habitIds,
    required this.objectId,
    required this.removePreviousGoalHabits,
    required this.ritualType,
    required this.skillTrackId,
    required this.title,
    required this.type,
    required this.updatedAt,
    required this.value,
  });

  // Factory from Firestore DocumentSnapshot
  factory SkillGoal.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('Missing data for SkillGoal doc ${doc.id}');
    }
    return SkillGoal(
      id: doc.id, // <<< Assign doc id
      createdAt: _safeToInt(data['createdAt']) ?? 0,
      description: data['description'] as String? ?? '',
      // Safely handle list conversion, default to empty list if null or wrong type
      habitIds: List<String>.from(
          (data['habitIds'] as List<dynamic>?)?.map((e) => e.toString()) ?? []),
      objectId: data['objectId'] as String? ?? '',
      removePreviousGoalHabits:
          data['removePreviousGoalHabits'] as bool? ?? false,
      ritualType: data['ritualType'] as String? ?? '',
      skillTrackId: data['skillTrackId'] as String? ?? '', // Crucial field
      title: data['title'] as String? ?? '',
      type: data['type'] as String? ?? '',
      updatedAt: _safeToInt(data['updatedAt']) ?? 0,
      value: _safeToInt(data['value']) ?? 0,
    );
  }

  // Original fromJson factory (can be kept for other uses if needed)
  factory SkillGoal.fromJson(Map<String, dynamic> json) {
    // Note: This doesn't set the Firestore 'id'. Use fromFirestore for that.
    return SkillGoal(
      id: json['id'] ??
          '', // Allow setting id if passed in JSON, but fromFirestore is preferred
      createdAt: _safeToInt(json['createdAt']) ?? 0,
      description: json['description'] as String,
      habitIds: List<String>.from(json['habitIds'] ?? []),
      objectId: json['objectId'] as String,
      removePreviousGoalHabits: json['removePreviousGoalHabits'] as bool,
      ritualType: json['ritualType'] as String,
      skillTrackId: json['skillTrackId'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      updatedAt: _safeToInt(json['updatedAt']) ?? 0,
      value: _safeToInt(json['value']) ?? 0,
    );
  }

  // To JSON (doesn't include id)
  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt,
      'description': description,
      'habitIds': habitIds,
      'objectId': objectId,
      'removePreviousGoalHabits': removePreviousGoalHabits,
      'ritualType': ritualType,
      'skillTrackId': skillTrackId,
      'title': title,
      'type': type,
      'updatedAt': updatedAt,
      'value': value,
    };
  }
}

// --- Fetch Function for SkillGoal ---

/// Fetches a single document from the 'skillGoal' collection
/// where the 'skillTrackId' field matches the provided value.
///
/// Returns the document data as a SkillGoal object (null if not found or error).
Future<SkillGoal?> getSkillGoalByTrackId(String skillTrackIdToFind,
    {bool isParentMode = false}) async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Dynamic collection name based on persona mode
    final collectionName = isParentMode ? 'parent-skillGoal' : 'skillGoal';

    print(' Searching for SkillGoal in collection: $collectionName');
    print(' Looking for skillTrackId: $skillTrackIdToFind');
    print(' Parent mode: $isParentMode');

    // Reference the 'skillGoal' collection with converter
    final CollectionReference<SkillGoal> skillGoalCollection =
        firestore.collection(collectionName).withConverter<SkillGoal>(
              fromFirestore: (snapshots, _) =>
                  SkillGoal.fromFirestore(snapshots), // Use the new factory
              toFirestore: (skillGoal, _) =>
                  skillGoal.toJson(), // Use existing toJson
            );

    // Create the query
    QuerySnapshot<SkillGoal> querySnapshot = await skillGoalCollection
        .where('skillTrackId', isEqualTo: skillTrackIdToFind)
        .limit(1) // Optimization
        .get();

    print(' Found ${querySnapshot.docs.length} SkillGoal documents');

    // Check if any documents were found
    if (querySnapshot.docs.isNotEmpty) {
      QueryDocumentSnapshot<SkillGoal> doc = querySnapshot.docs.first;
      print('Found SkillGoal: ${doc.data().title}');
      return doc.data(); // Directly returns SkillGoal
    } else {
      print(
          'No skill goal found for skillTrackId: $skillTrackIdToFind in collection: $collectionName');
      return null;
    }
  } catch (e) {
    print('Error fetching skill goal by track ID $skillTrackIdToFind: $e');
    return null;
  }
}

// --- Fetch Function for Skill ---

/// Fetches a single document from the 'skill' collection
/// where the 'skillTrackId' field matches the provided value.
///
/// Returns the document data as a Skill object (null if not found or error).
Future<Skill?> getSkillByTrackId(String skillTrackIdToFind,
    {bool isParentMode = false}) async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Dynamic collection name based on persona mode
    final collectionName = isParentMode ? 'parent-skill' : 'skill';
    // Dynamic field name based on persona mode
    final fieldName = isParentMode ? 'skillTrackId' : 'skillTrackId';

    print('Searching for Skill in collection: $collectionName');
    print('Looking for skillTrackId: $skillTrackIdToFind');
    print('Parent mode: $isParentMode');

    // Reference the 'skill' collection with converter
    final CollectionReference<Skill> skillCollection =
        firestore.collection(collectionName).withConverter<Skill>(
              fromFirestore: (snapshots, _) =>
                  Skill.fromFirestore(snapshots), // Use the new factory
              toFirestore: (skill, _) => skill.toJson(), // Use existing toJson
            );

    // Create the query
    QuerySnapshot<Skill> querySnapshot = await skillCollection
        .where(fieldName, isEqualTo: skillTrackIdToFind)
        .limit(1) // Optimization
        .get();

    print(' Found ${querySnapshot.docs.length} Skill documents');

    // Check if any documents were found
    if (querySnapshot.docs.isNotEmpty) {
      QueryDocumentSnapshot<Skill> doc = querySnapshot.docs.first;
      print('Found Skill: ${doc.data().title}');
      return doc.data(); // Directly returns Skill
    } else {
      print(
          'No skill found for skillTrackId: $skillTrackIdToFind in collection: $collectionName');
      return null;
    }
  } catch (e) {
    print('Error fetching skill by track ID $skillTrackIdToFind: $e');
    return null;
  }
}

Future<SkillLevel?> getSkillLevelByTrackId(String skillTrackIdToFind,
    {bool isParentMode = false}) async {
  try {
    // 1. Get a reference to the Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Dynamic collection name based on persona mode
    final collectionName = isParentMode ? 'parent-skillLevel' : 'skillLevel';
    // Dynamic field name based on persona mode
    final fieldName = isParentMode ? 'skillTrackId' : 'skillTrackId';

    print(' Searching for SkillLevel in collection: $collectionName');
    print(' Looking for skillTrackId: $skillTrackIdToFind');
    print(' Parent mode: $isParentMode');

    // 2. Reference the 'skillLevel' collection
    //    Use .withConverter for better type safety
    final CollectionReference<SkillLevel> skillLevelCollection =
        firestore.collection(collectionName).withConverter<SkillLevel>(
              fromFirestore: (snapshots, _) =>
                  SkillLevel.fromFirestore(snapshots), // Use your factory
              toFirestore: (skillLevel, _) =>
                  skillLevel.toJson(), // Use your toJson
            );

    // 3. Create the query
    QuerySnapshot<SkillLevel> querySnapshot = await skillLevelCollection
        .where(fieldName, isEqualTo: skillTrackIdToFind)
        .limit(1) // Optimization: stop searching after finding the first match
        .get();

    print(' Found ${querySnapshot.docs.length} SkillLevel documents');

    // 4. Check if any documents were found
    if (querySnapshot.docs.isNotEmpty) {
      // 5. Get the first document found
      QueryDocumentSnapshot<SkillLevel> doc = querySnapshot.docs.first;
      print('Found SkillLevel: ${doc.data().headline ?? 'No headline'}');
      return doc.data(); // Directly returns SkillLevel
    } else {
      // No document found with that skillTrackId
      print(
          'No skill level found for skillTrackId: $skillTrackIdToFind in collection: $collectionName');
      return null;
    }
  } catch (e) {
    // Handle potential errors
    print('Error fetching skill level by track ID $skillTrackIdToFind: $e');
    return null;
  }
}

// Example Usage (assuming you have initialized Firebase):
/*

  String targetTrackId = "some_existing_skill_track_id";
  bool isParentMode = true; // or false based on persona toggle

  SkillLevel? skillLevel = await getSkillLevelByTrackId(targetTrackId, isParentMode: isParentMode);
  if (skillLevel != null) {
    print("Found Skill Level: ${skillLevel.headline}");
  }

  SkillGoal? skillGoal = await getSkillGoalByTrackId(targetTrackId, isParentMode: isParentMode);
  if (skillGoal != null) {
    print("Found Skill Goal: ${skillGoal.title}");
  }

  Skill? skill = await getSkillByTrackId(targetTrackId, isParentMode: isParentMode);
  if (skill != null) {
    print("Found Skill: ${skill.title}");
  }
}
*/

// --- Debug Function to Check Collections ---
Future<void> debugCollections(String skillTrackIdToFind) async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    print('🚀 === DEBUGGING COLLECTIONS ===');
    print(' Looking for skillTrackId: $skillTrackIdToFind');

    final collections = [
      'skillGoal',
      'parent-skillGoal',
      'skill',
      'parent-skill',
      'skillLevel',
      'parent-skillLevel'
    ];

    for (String collectionName in collections) {
      try {
        print('\n📂 Checking collection: $collectionName');

        // Get all documents in the collection (limit to 10 for debugging)
        QuerySnapshot snapshot =
            await firestore.collection(collectionName).limit(10).get();

        print('   📄 Total documents in collection: ${snapshot.docs.length}');

        if (snapshot.docs.isNotEmpty) {
          print('   📋 Sample document IDs and skillTrackIds:');
          for (var doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>?;
            final skillTrackId = data?['skillTrackId'] ?? 'NO_SKILL_TRACK_ID';
            final title = data?['title'] ?? data?['headline'] ?? 'NO_TITLE';
            print('      - ${doc.id}');
            print('        skillTrackId: $skillTrackId');
            print('        title/headline: $title');
          }

          // Now check if our specific skillTrackId exists
          QuerySnapshot targetQuery = await firestore
              .collection(collectionName)
              .where('skillTrackId', isEqualTo: skillTrackIdToFind)
              .get();

          print(
              '   🎯 Documents matching skillTrackId "$skillTrackIdToFind": ${targetQuery.docs.length}');

          if (targetQuery.docs.isNotEmpty) {
            print('   FOUND MATCHING DOCUMENTS:');
            for (var doc in targetQuery.docs) {
              final data = doc.data() as Map<String, dynamic>?;
              final title = data?['title'] ?? data?['headline'] ?? 'NO_TITLE';
              print('      - ${doc.id} (title: $title)');
            }
          }
        } else {
          print('   Collection is empty');
        }
      } catch (e) {
        print('   Error accessing collection $collectionName: $e');
      }
    }

    print('\n🚀 === END DEBUGGING ===\n');
  } catch (e) {
    print('Error in debug function: $e');
  }
}

// --- Advanced Debug Function for skillTrackId Analysis ---
Future<void> debugSkillTrackIds() async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    print('🚀 === ANALYZING ALL SKILL TRACK IDs ===');

    final collections = [
      'skillTrack',
      'parent-skillTrack',
      'skillGoal',
      'parent-skillGoal',
      'skill',
      'parent-skill',
      'skillLevel',
      'parent-skillLevel'
    ];

    Map<String, Set<String>> collectionSkillTrackIds = {};

    for (String collectionName in collections) {
      try {
        QuerySnapshot snapshot =
            await firestore.collection(collectionName).limit(20).get();

        Set<String> skillTrackIds = {};

        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          final skillTrackId = data?['skillTrackId'] as String?;
          if (skillTrackId != null && skillTrackId.isNotEmpty) {
            skillTrackIds.add(skillTrackId);
          }
        }

        collectionSkillTrackIds[collectionName] = skillTrackIds;

        print('\n📂 $collectionName:');
        print('   Total documents: ${snapshot.docs.length}');
        print('   Unique skillTrackIds: ${skillTrackIds.length}');
        print('   Sample skillTrackIds: ${skillTrackIds.take(5).join(', ')}');
      } catch (e) {
        print('Error accessing $collectionName: $e');
      }
    }

    // Compare regular vs parent collections
    print('\n === COMPARISON ANALYSIS ===');
    final comparisons = [
      ['skillTrack', 'parent-skillTrack'],
      ['skillGoal', 'parent-skillGoal'],
      ['skill', 'parent-skill'],
      ['skillLevel', 'parent-skillLevel'],
    ];

    for (var pair in comparisons) {
      final regular = pair[0];
      final parent = pair[1];

      final regularIds = collectionSkillTrackIds[regular] ?? {};
      final parentIds = collectionSkillTrackIds[parent] ?? {};

      print('\n📊 $regular vs $parent:');
      print('   Regular collection skillTrackIds: ${regularIds.length}');
      print('   Parent collection skillTrackIds: ${parentIds.length}');

      final commonIds = regularIds.intersection(parentIds);
      final onlyInRegular = regularIds.difference(parentIds);
      final onlyInParent = parentIds.difference(regularIds);

      print('   Common skillTrackIds: ${commonIds.length}');
      if (commonIds.isNotEmpty) {
        print('   Sample common: ${commonIds.take(3).join(', ')}');
      }

      print('   Only in regular: ${onlyInRegular.length}');
      if (onlyInRegular.isNotEmpty) {
        print('   Sample regular-only: ${onlyInRegular.take(3).join(', ')}');
      }

      print('   Only in parent: ${onlyInParent.length}');
      if (onlyInParent.isNotEmpty) {
        print('   Sample parent-only: ${onlyInParent.take(3).join(', ')}');
      }
    }

    print('\n🚀 === END ANALYSIS ===\n');
  } catch (e) {
    print('Error in skill track ID analysis: $e');
  }
}

// --- Challenge Data Service Class ---
class ChallengeDataService {
  /// Debug method to check what's in the collections
  Future<void> debugCollections(String skillTrackId) async {
    await debugCollections(skillTrackId);
  }

  /// Advanced debug to analyze all skillTrackIds across collections
  Future<void> debugSkillTrackIds() async {
    await debugSkillTrackIds();
  }

  /// Fetch skill goal by track ID with persona mode
  Future<SkillGoal?> getSkillGoal(String skillTrackId,
      {required bool isParentMode}) async {
    return await getSkillGoalByTrackId(skillTrackId,
        isParentMode: isParentMode);
  }

  /// Fetch skill by track ID with persona mode
  Future<Skill?> getSkill(String skillTrackId,
      {required bool isParentMode}) async {
    return await getSkillByTrackId(skillTrackId, isParentMode: isParentMode);
  }

  /// Fetch skill level by track ID with persona mode
  Future<SkillLevel?> getSkillLevel(String skillTrackId,
      {required bool isParentMode}) async {
    return await getSkillLevelByTrackId(skillTrackId,
        isParentMode: isParentMode);
  }

  /// Fetch all challenge-related data at once
  Future<Map<String, dynamic>> getChallengeData(String skillTrackId,
      {required bool isParentMode}) async {
    // Enhanced debug to see what's being requested
    print('� === CHALLENGE DATA REQUEST ===');
    print(' Requested skillTrackId: $skillTrackId');
    print(' Parent mode: $isParentMode');
    print(
        ' Will search in collections: ${isParentMode ? 'parent-*' : 'regular'}');

    // First run debug to see what's available
    print(' Running debug analysis...');
    await debugCollections(skillTrackId);

    // If parent mode and no data found, let's check what IDs exist in parent collections
    if (isParentMode) {
      print(' === PARENT MODE ANALYSIS ===');
      await _analyzeParentCollections();
    }

    final results = await Future.wait([
      getSkillGoal(skillTrackId, isParentMode: isParentMode),
      getSkill(skillTrackId, isParentMode: isParentMode),
      getSkillLevel(skillTrackId, isParentMode: isParentMode),
    ]);

    return {
      'skillGoal': results[0],
      'skill': results[1],
      'skillLevel': results[2],
    };
  }

  /// Analyze what's actually in parent collections
  Future<void> _analyzeParentCollections() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      final parentCollections = [
        'parent-skillGoal',
        'parent-skill',
        'parent-skillLevel'
      ];

      for (String collection in parentCollections) {
        print('\n📂 Analyzing $collection:');

        try {
          QuerySnapshot snapshot =
              await firestore.collection(collection).limit(10).get();

          if (snapshot.docs.isEmpty) {
            print('   Collection is EMPTY - This is likely the problem!');
          } else {
            print('   Found ${snapshot.docs.length} documents');
            print('   📋 Available skillTrackIds:');

            Set<String> uniqueIds = {};
            for (var doc in snapshot.docs) {
              final data = doc.data() as Map<String, dynamic>?;
              final skillTrackId = data?['skillTrackId'] as String?;
              if (skillTrackId != null) {
                uniqueIds.add(skillTrackId);
              }
            }

            if (uniqueIds.isEmpty) {
              print('      No documents have skillTrackId field!');
            } else {
              for (String id in uniqueIds.take(5)) {
                print('      - $id');
              }
              if (uniqueIds.length > 5) {
                print('      - ... and ${uniqueIds.length - 5} more');
              }
            }
          }
        } catch (e) {
          print('   Error accessing $collection: $e');
        }
      }
    } catch (e) {
      print('Error in parent collection analysis: $e');
    }
  }
}

// --- Riverpod Providers for Persona-Aware Challenge Data ---

/// Service provider for challenge data
final challengeDataServiceProvider =
    Provider<ChallengeDataService>((ref) => ChallengeDataService());

/// Provider for accessing persona state from discover_provider.dart
/// This should be imported from discover_provider.dart in actual usage
// Note: This is a placeholder - import the actual personaProvider from discover_provider.dart

/// Skill Goal Provider - fetches skill goal by track ID with persona awareness
final skillGoalProvider =
    FutureProvider.family<SkillGoal?, String>((ref, skillTrackId) async {
  final service = ref.watch(challengeDataServiceProvider);
  final isParentMode = ref.watch(personaProvider).isParentMode;

  return await service.getSkillGoal(skillTrackId, isParentMode: isParentMode);
});

/// Skill Provider - fetches skill by track ID with persona awareness
final skillProvider =
    FutureProvider.family<Skill?, String>((ref, skillTrackId) async {
  final service = ref.watch(challengeDataServiceProvider);
  final isParentMode = ref.watch(personaProvider).isParentMode;

  return await service.getSkill(skillTrackId, isParentMode: isParentMode);
});

/// Skill Level Provider - fetches skill level by track ID with persona awareness
final skillLevelProvider =
    FutureProvider.family<SkillLevel?, String>((ref, skillTrackId) async {
  final service = ref.watch(challengeDataServiceProvider);
  final isParentMode = ref.watch(personaProvider).isParentMode;

  return await service.getSkillLevel(skillTrackId, isParentMode: isParentMode);
});

/// Combined Challenge Data Provider - fetches all related data for a challenge
final challengeDataProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
        (ref, skillTrackId) async {
  final service = ref.watch(challengeDataServiceProvider);
  final isParentMode = ref.watch(personaProvider).isParentMode;

  return await service.getChallengeData(skillTrackId,
      isParentMode: isParentMode);
});

/// Debug Provider - runs comprehensive skillTrackId analysis
final debugSkillTrackIdsProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(challengeDataServiceProvider);
  await service.debugSkillTrackIds();
});

/*
/// QUICK DEBUG SOLUTION - Add this to your discover screen temporarily
/// 
/// Add this FloatingActionButton to your discover screen:
/// 
/// floatingActionButton: FloatingActionButton(
///   onPressed: () async {
///     print('🚀 === MANUAL DEBUG STARTED ===');
///     
///     // Check what challenges are actually available
///     final challengesService = ChallengesService();
///     
///     print('\n📊 REGULAR MODE CHALLENGES:');
///     final regularChallenges = await challengesService.fetchChallenges(isParentMode: false);
///     print('Found ${regularChallenges.length} regular challenges');
///     for (int i = 0; i < regularChallenges.length && i < 3; i++) {
///       final challenge = regularChallenges[i];
///       final id = challenge['objectId'] ?? challenge['id'] ?? 'NO_ID';
///       final title = challenge['title'] ?? 'NO_TITLE';
///       print('  - $id ($title)');
///     }
///     
///     print('\n📊 PARENT MODE CHALLENGES:');
///     final parentChallenges = await challengesService.fetchChallenges(isParentMode: true);
///     print('Found ${parentChallenges.length} parent challenges');
///     for (int i = 0; i < parentChallenges.length && i < 3; i++) {
///       final challenge = parentChallenges[i];
///       final id = challenge['objectId'] ?? challenge['id'] ?? 'NO_ID';
///       final title = challenge['title'] ?? 'NO_TITLE';
///       print('  - $id ($title)');
///     }
///     
///     // Now check collections
///     final service = ChallengeDataService();
///     await service.debugSkillTrackIds();
///   },
///   child: Icon(Icons.bug_report),
/// ),
/// 
/// This will show you:
/// 1. What challenge IDs are available in regular vs parent mode
/// 2. What collections exist and what IDs they contain
/// 3. Whether the problem is missing challenges or missing skill data
*/
