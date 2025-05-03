import 'package:cloud_firestore/cloud_firestore.dart';

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
      createdAt: data['createdAt'] as int?,
      headline: data['headline'] as String?,
      headlineImageUrl: data['headlineImageUrl'] as String?,
      objectId: data['objectId'] as String? ?? '',
      position: data['position'] as int?,
      skillId: data['skillId'] as String? ?? '',
      skillTrackId: data['skillTrackId'] as String? ?? '',
      type: data['type'] as String?,
      updatedAt: data['updatedAt'] as int?,
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
      createdAt: data['createdAt'] as int? ?? 0,
      goalId: data['goalId'] as String? ?? '',
      iconUrl: data['iconUrl'] as String? ?? '',
      iosIconUrl: data['iosIconUrl'] as String? ?? '',
      objectId: data['objectId'] as String? ?? '',
      position: data['position'] as int? ?? 0,
      skillTrackId: data['skillTrackId'] as String? ?? '', // Crucial field
      title: data['title'] as String? ?? '',
      updatedAt: data['updatedAt'] as int? ?? 0,
    );
  }

  // Original fromJson factory (can be kept for other uses if needed)
  factory Skill.fromJson(Map<String, dynamic> json) {
    // Note: This doesn't set the Firestore 'id'. Use fromFirestore for that.
    return Skill(
      id: json['id'] ?? '', // Allow setting id if passed in JSON, but fromFirestore is preferred
      color: json['color'] as String,
      createdAt: json['createdAt'] as int,
      goalId: json['goalId'] as String,
      iconUrl: json['iconUrl'] as String,
      iosIconUrl: json['iosIconUrl'] as String,
      objectId: json['objectId'] as String,
      position: json['position'] as int,
      skillTrackId: json['skillTrackId'] as String,
      title: json['title'] as String,
      updatedAt: json['updatedAt'] as int,
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
      createdAt: data['createdAt'] as int? ?? 0,
      description: data['description'] as String? ?? '',
      // Safely handle list conversion, default to empty list if null or wrong type
      habitIds: List<String>.from((data['habitIds'] as List<dynamic>?)?.map((e) => e.toString()) ?? []),
      objectId: data['objectId'] as String? ?? '',
      removePreviousGoalHabits: data['removePreviousGoalHabits'] as bool? ?? false,
      ritualType: data['ritualType'] as String? ?? '',
      skillTrackId: data['skillTrackId'] as String? ?? '', // Crucial field
      title: data['title'] as String? ?? '',
      type: data['type'] as String? ?? '',
      updatedAt: data['updatedAt'] as int? ?? 0,
      value: data['value'] as int? ?? 0,
    );
  }

  // Original fromJson factory (can be kept for other uses if needed)
  factory SkillGoal.fromJson(Map<String, dynamic> json) {
    // Note: This doesn't set the Firestore 'id'. Use fromFirestore for that.
    return SkillGoal(
      id: json['id'] ?? '', // Allow setting id if passed in JSON, but fromFirestore is preferred
      createdAt: json['createdAt'] as int,
      description: json['description'] as String,
      habitIds: List<String>.from(json['habitIds'] ?? []),
      objectId: json['objectId'] as String,
      removePreviousGoalHabits: json['removePreviousGoalHabits'] as bool,
      ritualType: json['ritualType'] as String,
      skillTrackId: json['skillTrackId'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      updatedAt: json['updatedAt'] as int,
      value: json['value'] as int,
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
Future<SkillGoal?> getSkillGoalByTrackId(String skillTrackIdToFind) async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Reference the 'skillGoal' collection with converter
    final CollectionReference<SkillGoal> skillGoalCollection =
    firestore.collection('skillGoal').withConverter<SkillGoal>(
      fromFirestore: (snapshots, _) => SkillGoal.fromFirestore(snapshots), // Use the new factory
      toFirestore: (skillGoal, _) => skillGoal.toJson(), // Use existing toJson
    );

    // Create the query
    QuerySnapshot<SkillGoal> querySnapshot = await skillGoalCollection
        .where('skillTrackId', isEqualTo: skillTrackIdToFind)
        .limit(1) // Optimization
        .get();

    // Check if any documents were found
    if (querySnapshot.docs.isNotEmpty) {
      QueryDocumentSnapshot<SkillGoal> doc = querySnapshot.docs.first;
      return doc.data(); // Directly returns SkillGoal
    } else {
      print('No skill goal found for skillTrackId: $skillTrackIdToFind');
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
Future<Skill?> getSkillByTrackId(String skillTrackIdToFind) async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Reference the 'skill' collection with converter
    final CollectionReference<Skill> skillCollection =
    firestore.collection('skill').withConverter<Skill>(
      fromFirestore: (snapshots, _) => Skill.fromFirestore(snapshots), // Use the new factory
      toFirestore: (skill, _) => skill.toJson(), // Use existing toJson
    );

    // Create the query
    QuerySnapshot<Skill> querySnapshot = await skillCollection
        .where('skillTrackId', isEqualTo: skillTrackIdToFind)
        .limit(1) // Optimization
        .get();

    // Check if any documents were found
    if (querySnapshot.docs.isNotEmpty) {
      QueryDocumentSnapshot<Skill> doc = querySnapshot.docs.first;
      return doc.data(); // Directly returns Skill
    } else {
      print('No skill found for skillTrackId: $skillTrackIdToFind');
      return null;
    }
  } catch (e) {
    print('Error fetching skill by track ID $skillTrackIdToFind: $e');
    return null;
  }
}

Future<SkillLevel?> getSkillLevelByTrackId(String skillTrackIdToFind) async {
  try {
    // 1. Get a reference to the Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // 2. Reference the 'skillLevel' collection
    //    Use .withConverter for better type safety
    final CollectionReference<SkillLevel> skillLevelCollection =
    firestore.collection('skillLevel').withConverter<SkillLevel>(
      fromFirestore: (snapshots, _) => SkillLevel.fromFirestore(snapshots), // Use your factory
      toFirestore: (skillLevel, _) => skillLevel.toJson(), // Use your toJson
    );

    // 3. Create the query
    QuerySnapshot<SkillLevel> querySnapshot = await skillLevelCollection
        .where('skillTrackId', isEqualTo: skillTrackIdToFind)
        .limit(1) // Optimization: stop searching after finding the first match
        .get();

    // 4. Check if any documents were found
    if (querySnapshot.docs.isNotEmpty) {
      // 5. Get the first document found
      QueryDocumentSnapshot<SkillLevel> doc = querySnapshot.docs.first;
      return doc.data(); // Directly returns SkillLevel
    } else {
      // No document found with that skillTrackId
      print('No skill level found for skillTrackId: $skillTrackIdToFind');
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

  SkillLevel? skillLevel = await getSkillLevelByTrackId(targetTrackId);
  if (skillLevel != null) {
    print("Found Skill Level: ${skillLevel.headline}");
  }

  SkillGoal? skillGoal = await getSkillGoalByTrackId(targetTrackId);
  if (skillGoal != null) {
    print("Found Skill Goal: ${skillGoal.title}");
  }

  Skill? skill = await getSkillByTrackId(targetTrackId);
  if (skill != null) {
    print("Found Skill: ${skill.title}");
  }
}
*/