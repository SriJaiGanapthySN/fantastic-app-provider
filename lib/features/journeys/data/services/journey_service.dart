// ignore_for_file: unnecessary_cast, empty_catches

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fantastic_app_riverpod/features/coaching/data/models/skill.dart';
import 'package:fantastic_app_riverpod/features/journeys/data/models/skillTrack.dart';

class JourneyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchJourneys(
      {bool isParentMode = false}) async {
    try {
      final collectionName =
          isParentMode ? 'parent-skillTrack' : 'skillTrack-new';

      print('🚀 JourneyService: Fetching from collection: $collectionName');
      print('🚀 JourneyService: Parent mode: $isParentMode');

      // Enhanced debug: Check if collection exists by attempting to fetch
      final collectionRef = _firestore.collection(collectionName);
      print('🔍 JourneyService: Checking collection existence...');

      // Fetch all documents from the appropriate collection
      final querySnapshot = await collectionRef.get();

      print(
          '🔍 JourneyService: Total documents in $collectionName: ${querySnapshot.docs.length}');

      if (querySnapshot.docs.isEmpty) {
        print('⚠️ JourneyService: Collection $collectionName is empty!');

        // If parent mode collection is empty, try falling back to regular collection
        if (isParentMode) {
          print('🔄 JourneyService: Falling back to regular collection...');
          final fallbackSnapshot =
              await _firestore.collection('skillTrack-new').get();
          print(
              '🔍 JourneyService: Fallback collection has ${fallbackSnapshot.docs.length} documents');

          if (fallbackSnapshot.docs.isNotEmpty) {
            final fallbackDocs = fallbackSnapshot.docs.where((doc) {
              final type = doc['type'] as String? ?? '';
              return !type.toLowerCase().contains('challenge');
            }).toList();

            print(
                '🔄 JourneyService: Using fallback data with ${fallbackDocs.length} journeys');
            return fallbackDocs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
          }
        }

        return [];
      }

      // Filter out documents where 'type' contains 'challenge'
      final filteredDocs = querySnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final type = data['type'] as String? ?? '';
        print('🔍 JourneyService: Document ${doc.id} has type: "$type"');
        return !type.toLowerCase().contains('challenge');
      }).toList();

      print(
          '🚀 JourneyService: Found ${filteredDocs.length} journeys after filtering');

      // Log the journeyIds that were found
      if (filteredDocs.isNotEmpty) {
        print('🚀 JourneyService: Sample journey IDs:');
        for (int i = 0; i < filteredDocs.length && i < 5; i++) {
          final journey = filteredDocs[i];
          final data = journey.data() as Map<String, dynamic>;
          final id = data['objectId'] ?? data['id'] ?? journey.id;
          final title = data['title'] ?? 'NO_TITLE';
          final type = data['type'] ?? 'NO_TYPE';
          print('   - $id (title: $title, type: $type)');
        }
      } else {
        print('⚠️ JourneyService: No journeys found after filtering!');
      }

      // Convert documents to a List of Maps
      return filteredDocs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('💥 JourneyService: Error fetching journeys: $e');
      print('💥 JourneyService: Stack trace: ${StackTrace.current}');
      return []; // Return an empty list instead of null
    }
  }

  /// Fetch a single journey where `isReleased` is false
  Future<skillTrack?> fetchUnreleasedJourney(String email) async {
    try {
      // Reference to the specific collection for the given email
      final collectionRef =
          _firestore.collection('testers').doc(email).collection('skillTrack');

      // Query to get the first document where `isReleased` is false
      final querySnapshot = await collectionRef
          .where('isReleased', isEqualTo: false)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Convert the first document into a skillTrack object
        return skillTrack
            .fromMap(querySnapshot.docs.first.data() as Map<String, dynamic>);
      }

      // Return null if no matching document is found
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchUnreleaseJourney(String email) async {
    try {
      // Reference to the specific collection for the given email
      final collectionRef =
          _firestore.collection('testers').doc(email).collection('skillTrack');

      // Query to get the first document where `isReleased` is false
      final querySnapshot =
          await collectionRef.where('isReleased', isEqualTo: false).get();

      if (querySnapshot.docs.isNotEmpty) {
        // Return the first document's data as Map
        return querySnapshot.docs.first.data() as Map<String, dynamic>;
      }

      // Return null if no matching document is found
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserJourneys(String email,
      {bool isParentMode = false}) async {
    try {
      print('🚀 fetchUserJourneys: Fetching for email: $email');
      print('🚀 fetchUserJourneys: Parent mode: $isParentMode');

      // Fetch the collection snapshot for the given email
      final querySnapshot = await _firestore
          .collection('testers')
          .doc(email)
          .collection('skillTrack')
          .get();

      print(
          '🚀 fetchUserJourneys: Found ${querySnapshot.docs.length} user journeys');

      // Check if the collection has any documents
      if (querySnapshot.docs.isNotEmpty) {
        final journeys = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            ...data,
            'docId': doc.id, // Add document ID if missing
          };
        }).toList();

        print('🚀 fetchUserJourneys: Sample user journeys:');
        for (int i = 0; i < journeys.length && i < 3; i++) {
          final journey = journeys[i];
          final id = journey['objectId'] ?? journey['id'] ?? journey['docId'];
          final title = journey['title'] ?? 'NO_TITLE';
          print('   - $id ($title)');
        }

        return journeys;
      }

      print(
          '⚠️ fetchUserJourneys: No user journeys found, checking main collections');

      // If no user journeys found, fetch from main collections as fallback
      final mainJourneys = await fetchJourneys(isParentMode: isParentMode);
      print(
          '🔄 fetchUserJourneys: Using ${mainJourneys.length} journeys from main collection as fallback');

      return mainJourneys;
    } catch (e) {
      print('💥 fetchUserJourneys: Error: $e');
      return [];
    }
  }

  Future<void> updateIsReleased(String email, String docId) async {
    try {
      final docRef = _firestore
          .collection('testers')
          .doc(email)
          .collection('skillTrack')
          .doc(docId);

      // Fetch the current value of isReleased
      final snapshot = await docRef.get();

      if (snapshot.exists) {
        final currentValue = snapshot.data()?['isReleased'] as bool?;

        // Reverse the value if it exists
        if (currentValue != null) {
          await docRef.update({'isReleased': !currentValue});
        } else {}
      } else {}
    } catch (e) {}
  }

  Future<void> addSkillTrack(String id, String email,
      {bool isParentMode = false}) async {
    try {
      final collectionName =
          isParentMode ? 'parent-skillTrack' : 'skillTrack-new';

      // Reference to the document path '/{collectionName}/{id}'
      final skillDocRef = _firestore.collection(collectionName).doc(id);

      // Ensure 'isReleased' is set to false
      await skillDocRef.update({'isReleased': false});

      // Fetch the document snapshot
      final docSnapshot = await skillDocRef.get();

      // Check if the document exists
      if (docSnapshot.exists) {
        // Get the document data
        final skillData = docSnapshot.data() as Map<String, dynamic>;

        // Check if 'levelsCompleted' is not present and add it with a default value of 0
        if (!skillData.containsKey('levelsCompleted')) {
          skillData['levelsCompleted'] = 0;
        }

        // Reference to the target path '/testers/{email}/skillTrack/{id}'
        final userSkillLevelPath = _firestore
            .collection('testers')
            .doc(email)
            .collection('skillTrack');

        // Add the document data to the target path
        await userSkillLevelPath.doc(id).set(skillData);
      } else {}
    } catch (e) {}
  }

  Future<List<Skill>> addSkills(String skillTrackId, String email,
      {bool isParentMode = false}) async {
    try {
      final collectionName = isParentMode ? 'parent-skill' : 'skill-new';

      print('🔍 addSkills Debug Info:');
      print('  - skillTrackId: $skillTrackId');
      print('  - email: $email');
      print('  - isParentMode: $isParentMode');
      print('  - collectionName: $collectionName');

      // Reference to the appropriate skill collection
      final skillCollection = _firestore.collection(collectionName);

      // Query to fetch documents where skillTrackId matches
      final querySnapshot = await skillCollection
          .where('skillTrackId', isEqualTo: skillTrackId)
          .get();

      print('🔍 Query result: ${querySnapshot.docs.length} documents found');

      // Check if documents are found
      if (querySnapshot.docs.isEmpty) {
        print(
            '❌ No skills found in collection $collectionName for skillTrackId: $skillTrackId');
        return [];
      }

      // Map the documents into a list of Skill objects
      final List<Skill> skills = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print('🔍 Found skill: ${data['title']} (ID: ${doc.id})');
        return Skill.fromMap(data);
      }).toList();

      print('🔍 Successfully mapped ${skills.length} skills');

      // Reference to the target path: /testers/{email}/skill
      final userSkillPath =
          _firestore.collection('testers').doc(email).collection('skill');

      // Check if the 'skill' collection already exists for the user
      final userSkillsSnapshot = await userSkillPath.get();
      if (userSkillsSnapshot.docs.isEmpty) {
        print('🔍 User skill collection is empty, will create new entries');
      } else {
        print('🔍 User already has ${userSkillsSnapshot.docs.length} skills');
      }

      // Add each skill to the specified path with isComplete = false
      for (var skill in skills) {
        final totalLevels = await getTotalSkillLevels(skill.objectId,
            isParentMode:
                isParentMode); // Convert skill to a map and add 'isComplete': false
        final skillData = {
          ...skill.toMap(), // Existing skill data
          'isCompleted': false,
          'skillLevelCompleted': 0, // New field
          'totalLevels': totalLevels
        };

        // Add the updated skill data to the user's skill collection
        await userSkillPath.doc(skill.objectId).set(skillData);
        print('🔍 Added skill to user collection: ${skill.title}');
      }

      print('✅ addSkills completed successfully with ${skills.length} skills');
      return skills;
    } catch (e) {
      print('❌ Error in addSkills: $e');
      return [];
    }
  }

  // Debug method to check what skills exist in the collections
  Future<void> debugSkillCollections(String skillTrackId) async {
    try {
      print(
          '🔍 DEBUG: Checking skill collections for skillTrackId: $skillTrackId');

      // Check skill-new collection
      final skillNewQuery = await _firestore
          .collection('skill-new')
          .where('skillTrackId', isEqualTo: skillTrackId)
          .get();

      print(
          '🔍 skill-new collection: ${skillNewQuery.docs.length} skills found');
      for (var doc in skillNewQuery.docs.take(3)) {
        final data = doc.data();
        print('  - ${data['title']} (${doc.id})');
      }

      // Check parent-skill collection
      final parentSkillQuery = await _firestore
          .collection('parent-skill')
          .where('skillTrackId', isEqualTo: skillTrackId)
          .get();

      print(
          '🔍 parent-skill collection: ${parentSkillQuery.docs.length} skills found');
      for (var doc in parentSkillQuery.docs.take(3)) {
        final data = doc.data();
        print('  - ${data['title']} (${doc.id})');
      }

      // Also check if skillTrackId exists in skillTrack collections
      final skillTrackNewDoc =
          await _firestore.collection('skillTrack-new').doc(skillTrackId).get();

      print('🔍 skillTrack-new exists: ${skillTrackNewDoc.exists}');
      if (skillTrackNewDoc.exists) {
        print('  - title: ${skillTrackNewDoc.data()?['title']}');
      }

      final parentSkillTrackDoc = await _firestore
          .collection('parent-skillTrack')
          .doc(skillTrackId)
          .get();

      print('🔍 parent-skillTrack exists: ${parentSkillTrackDoc.exists}');
      if (parentSkillTrackDoc.exists) {
        print('  - title: ${parentSkillTrackDoc.data()?['title']}');
      }

      // Let's also check if there are ANY skills in these collections at all
      print('🔍 Checking if collections have any data...');

      final allSkillsNew =
          await _firestore.collection('skill-new').limit(3).get();
      print(
          '🔍 skill-new total documents: ${allSkillsNew.docs.length} (showing first 3)');
      for (var doc in allSkillsNew.docs) {
        final data = doc.data();
        print('  - ${data['title']} (skillTrackId: ${data['skillTrackId']})');
      }

      final allParentSkills =
          await _firestore.collection('parent-skill').limit(3).get();
      print(
          '🔍 parent-skill total documents: ${allParentSkills.docs.length} (showing first 3)');
      for (var doc in allParentSkills.docs) {
        final data = doc.data();
        print('  - ${data['title']} (skillTrackId: ${data['skillTrackId']})');
      }

      // Show all unique skillTrackIds for debugging
      final allSkillTrackIds = <String>{};
      for (var doc in allSkillsNew.docs) {
        final skillTrackId = doc.data()['skillTrackId'] as String?;
        if (skillTrackId != null) allSkillTrackIds.add(skillTrackId);
      }
      for (var doc in allParentSkills.docs) {
        final skillTrackId = doc.data()['skillTrackId'] as String?;
        if (skillTrackId != null) allSkillTrackIds.add(skillTrackId);
      }
      print('🔍 Available skillTrackIds in database: $allSkillTrackIds');
      print('🔍 Current search skillTrackId: $skillTrackId');

      if (!allSkillTrackIds.contains(skillTrackId)) {
        print('❌ Current skillTrackId ($skillTrackId) not found in database!');
        print('✅ Try using one of these instead: $allSkillTrackIds');
      }
    } catch (e) {
      print('❌ Error in debugSkillCollections: $e');
    }
  }

  Future<int> getTotalSkillLevels(String id,
      {bool isParentMode = false}) async {
    final collectionName =
        isParentMode ? 'parent-skillLevel' : 'skillLevel-new';
    var querysnapshot = await _firestore
        .collection(collectionName)
        .where('skillId', isEqualTo: id)
        .get();
    return querysnapshot.docs.length;
  }

  Future<List<String>> addSkillLevel(List<Skill> skills, String email,
      {bool isParentMode = false}) async {
    try {
      // List to store goalId values
      final List<String> goals = [];

      final collectionName =
          isParentMode ? 'parent-skillLevel' : 'skillLevel-new';

      // Reference to the appropriate skillLevel collection
      final skillCollection = _firestore.collection(collectionName);

      // Iterate through each skill
      for (var skill in skills) {
        // Query to fetch documents where 'skillId' matches
        final querySnapshot = await skillCollection
            .where('skillId', isEqualTo: skill.objectId)
            .get();

        if (querySnapshot.docs.isEmpty) {
          continue; // Move to the next skill
        }

        // Reference to the target path: /testers/{email}/skillLevel
        final userSkillLevelPath = _firestore
            .collection('testers')
            .doc(email)
            .collection('skillLevel');

        // Add each document to the specified path
        for (var doc in querySnapshot.docs) {
          final skillData = doc.data() as Map<String, dynamic>;

          // Check if 'goalId' exists and add it to the goals list
          if (skillData.containsKey('goalId')) {
            final goalId = skillData['goalId'];
            if (goalId != null && goalId is String) {
              goals.add(goalId); // Only add the ID
            }
          }

          // Add 'isCompleted' field with a default value of false
          final updatedSkillData = {
            ...skillData,
            'isCompleted': false,
          };

          // Upload the updated data
          await userSkillLevelPath.doc(doc.id).set(updatedSkillData);
        }
      }

      // Print the collected goal IDs
      return goals;
    } catch (e) {
      return []; // Return an empty list if an error occurs
    }
  }

  Future<void> addSkillGoals(List<String> ids, String email,
      {bool isParentMode = false}) async {
    try {
      // Reference to the target path: /testers/{email}/skillGoal
      final userSkillGoalPath =
          _firestore.collection('testers').doc(email).collection('skillGoal');

      // Reference to user's skillLevel collection to find related data
      final userSkillLevelPath =
          _firestore.collection('testers').doc(email).collection('skillLevel');

      final collectionName =
          isParentMode ? 'parent-skillGoal' : 'skillGoal-new';

      // Iterate through each ID in the list
      for (String id in ids) {
        // Reference to the document path: /{collectionName}/{id}
        final skillDocRef = _firestore.collection(collectionName).doc(id);

        // Fetch the document snapshot
        final docSnapshot = await skillDocRef.get();

        // Check if the document exists
        if (docSnapshot.exists) {
          // Get the document data
          final skillData = docSnapshot.data() as Map<String, dynamic>;

          // Find the corresponding skillLevel document that has this goalId
          final skillLevelQuery =
              await userSkillLevelPath.where('goalId', isEqualTo: id).get();

          // Initialize the updated data with existing data
          final updatedSkillData = {
            ...skillData, // Existing data
            'isCompleted': false, // New field
          };

          // If we found a matching skillLevel, add the required fields
          if (skillLevelQuery.docs.isNotEmpty) {
            final skillLevelDoc = skillLevelQuery.docs.first;
            final skillLevelData = skillLevelDoc.data();

            // Add the fields needed for goal completion
            updatedSkillData['skillLevelId'] = skillLevelDoc.id;
            updatedSkillData['skillId'] = skillLevelData['skillId'];
            updatedSkillData['skillTrackId'] = skillLevelData['skillTrackId'];
          } else {}

          // Add the document data to the user's skillGoal collection
          await userSkillGoalPath.doc(id).set(updatedSkillData);
        } else {}
      }
    } catch (e) {}
  }

  Future<void> addSkillGoal(String id, String email,
      {bool isParentMode = false}) async {
    try {
      final collectionName =
          isParentMode ? 'parent-skillGoal' : 'skillGoal-new';

      // Reference to the document path '/{collectionName}/{id}'
      final skillDocRef = _firestore.collection(collectionName).doc(id);

      // Fetch the document snapshot
      final docSnapshot = await skillDocRef.get();

      // Check if the document exists
      if (docSnapshot.exists) {
        // Get the document data
        final skillData = docSnapshot.data() as Map<String, dynamic>;

        // Reference to the target path '/testers/{email}/skillGoal/{id}'
        final userSkillLevelPath =
            _firestore.collection('testers').doc(email).collection('skillGoal');

        // Add the document data to the target path
        await userSkillLevelPath.doc(id).set(skillData);
      } else {}
    } catch (e) {}
  }

  Future<List<Skill>> getSkills(String skillTrackId, String email) async {
    try {
      // Reference to the 'skill' collection for the specific user
      final skillCollection =
          _firestore.collection('testers').doc(email).collection('skill');

      // Query to fetch documents where skillTrackId matches
      final querySnapshot = await skillCollection
          .where('skillTrackId', isEqualTo: skillTrackId)
          .get();

      // Check if documents are found
      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      // Map the documents into a list of Skill objects
      final List<Skill> skills = querySnapshot.docs
          .map((doc) => Skill.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Sort skills based on the 'position' field
      skills.sort((a, b) => a.position.compareTo(b.position));

      // Return the sorted list of skills
      return skills;
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSkillLevels(
      String email, String skillId) async {
    try {
      // Reference to the user's skillLevel collection
      final userSkillLevelPath =
          _firestore.collection('testers').doc(email).collection('skillLevel');

      // Query to get documents where 'skillId' is equal to the given 'skillId'
      final querySnapshot =
          await userSkillLevelPath.where('skillId', isEqualTo: skillId).get();

      // Check if any documents are found
      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      // Map the documents into a list of Map<String, dynamic>
      List<Map<String, dynamic>> skillLevels = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      return skillLevels;
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getSkillGoal(
      String email, String goalId) async {
    try {
      // Reference to the user's skillGoal collection
      final userSkillLevelPath =
          _firestore.collection('testers').doc(email).collection('skillGoal');

      // Query to get documents where 'objectId' matches the given goalId
      final querySnapshot =
          await userSkillLevelPath.where('objectId', isEqualTo: goalId).get();

      // Check if any documents are found
      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      // Since objectId should be unique, we expect one document
      final skillLevel =
          querySnapshot.docs.first.data() as Map<String, dynamic>;

      return skillLevel;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getSkillLevel(
      String email, String goalId) async {
    try {
      // Reference to the user's skillGoal collection
      final userSkillLevelPath = _firestore.collection('skillLevel');

      // Query to get documents where 'objectId' matches the given goalId
      final querySnapshot =
          await userSkillLevelPath.where('skillId', isEqualTo: goalId).get();

      // Check if any documents are found
      if (querySnapshot.docs.isEmpty) {
        return null;
      } else {}

      // Since objectId should be unique, we expect one document
      final skillLevel =
          querySnapshot.docs.first.data() as Map<String, dynamic>;

      return skillLevel;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateGoalCompletion(String userEmail, String id,
      String skillLevelId, String skillId, String skillTrackId) async {
    try {
      // 1. SKILL LEVEL
      final skillLevelRef = _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillLevel')
          .doc(skillLevelId);
      final skillLevelDoc = await skillLevelRef.get();
      if (!skillLevelDoc.exists) {
        // Fetch master skillLevel doc for all required fields
        final masterSkillLevelDoc =
            await _firestore.collection('skillLevel').doc(skillLevelId).get();
        final masterData = masterSkillLevelDoc.data() ?? {};
        // Compose new doc with all master fields, plus required user fields
        await skillLevelRef.set({
          ...masterData,
          'isCompleted': true,
          'goalId': id,
          'skillId': skillId,
          'skillTrackId': skillTrackId,
          'objectId': skillLevelId,
        });
      } else {
        await skillLevelRef.update({'isCompleted': true});
      }

      // 2. SKILL
      final skillRef = _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skill')
          .doc(skillId);
      final skillDoc = await skillRef.get();
      if (!skillDoc.exists) {
        // Fetch master skill doc for all required fields
        final masterSkillDoc =
            await _firestore.collection('skill').doc(skillId).get();
        final masterData = masterSkillDoc.data() ?? {};
        // Ensure totalLevels is present
        final totalLevels = masterData['totalLevels'] ?? 0;
        await skillRef.set({
          ...masterData,
          'objectId': skillId,
          'skillTrackId': skillTrackId,
          'skillLevelCompleted': 1,
          'totalLevels': totalLevels,
        });
      } else {
        final currentCount =
            (skillDoc.data()?['skillLevelCompleted'] as num?)?.toInt() ?? 0;
        await skillRef.update({'skillLevelCompleted': currentCount + 1});
      }

      // 3. SKILL TRACK
      final trackRef = _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillTrack')
          .doc(skillTrackId);
      final trackDoc = await trackRef.get();
      if (!trackDoc.exists) {
        // Fetch master skillTrack doc for all required fields
        final masterTrackDoc =
            await _firestore.collection('skillTrack').doc(skillTrackId).get();
        final masterData = masterTrackDoc.data() ?? {};
        // Ensure totalLevels is present
        final totalLevels = masterData['totalLevels'] ?? 0;
        await trackRef.set({
          ...masterData,
          'objectId': skillTrackId,
          'levelsCompleted': 1,
          'totalLevels': totalLevels,
        });
      } else {
        final trackData = trackDoc.data();
        final currentCount =
            (trackData?['levelsCompleted'] as num?)?.toInt() ?? 0;
        await trackRef.update({'levelsCompleted': currentCount + 1});
      }

      // 4. Update goal if it exists
      final skillLevelDoc2 = await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillLevel')
          .doc(skillLevelId)
          .get();
      if (skillLevelDoc2.exists) {
        final skillLevelData = skillLevelDoc2.data() as Map<String, dynamic>;
        final goalId = skillLevelData['goalId'] as String?;
        if (goalId != null) {
          final userGoalRef = _firestore
              .collection('testers')
              .doc(userEmail)
              .collection('skillGoal')
              .doc(goalId);
          final userGoalDoc = await userGoalRef.get();
          if (userGoalDoc.exists) {
            await userGoalRef.update({'isCompleted': true});
          } else {
            // Optionally: copy from master goal if you want to create it
            final masterGoalDoc =
                await _firestore.collection('skillGoal').doc(goalId).get();
            if (masterGoalDoc.exists) {
              await userGoalRef.set({
                ...?masterGoalDoc.data(),
                'isCompleted': true,
              });
            } else {}
          }
        }
      }

      // 5. Add interaction log
      await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('userInteractions')
          .add({
        'type': 'goal_completion',
        'goalId': id,
        'skillLevelId': skillLevelId,
        'skillId': skillId,
        'skillTrackId': skillTrackId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateOneTime(bool isAdded, String id, String userEmail,
      String skillId, String skillTrackId) async {
    try {
      // Check if already completed to avoid duplicate updates
      final skillLevelDoc = await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillLevel')
          .doc(id)
          .get();

      if (!skillLevelDoc.exists) {
        return false;
      }

      final isAlreadyCompleted =
          skillLevelDoc.data()?['isCompleted'] as bool? ?? false;

      if (isAlreadyCompleted) {
        return true;
      }

      // 1. Update skill level IMMEDIATELY
      await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillLevel')
          .doc(id)
          .update({'isCompleted': true});

      // 2. Update skill completion count IMMEDIATELY
      final skillDoc = await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skill')
          .doc(skillId)
          .get();

      if (skillDoc.exists) {
        final currentCount =
            (skillDoc.data()?['skillLevelCompleted'] as num?)?.toInt() ?? 0;
        await _firestore
            .collection('testers')
            .doc(userEmail)
            .collection('skill')
            .doc(skillId)
            .update({'skillLevelCompleted': currentCount + 1});
      } else {}

      // 3. Update journey track completion IMMEDIATELY

      try {
        final trackDoc = await _firestore
            .collection('testers')
            .doc(userEmail)
            .collection('skillTrack')
            .doc(skillTrackId)
            .get();

        if (trackDoc.exists) {
          final trackData = trackDoc.data();
          final currentCount =
              (trackData?['levelsCompleted'] as num?)?.toInt() ?? 0;

          await _firestore
              .collection('testers')
              .doc(userEmail)
              .collection('skillTrack')
              .doc(skillTrackId)
              .update({'levelsCompleted': currentCount + 1});
        } else {
          // Try to check if the document exists in the collection
          final allTracks = await _firestore
              .collection('testers')
              .doc(userEmail)
              .collection('skillTrack')
              .get();

          for (var doc in allTracks.docs) {}

          return false;
        }
      } catch (trackError) {
        return false;
      }

      // 4. Log user interaction IMMEDIATELY
      await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('userInteractions')
          .add({
        'type': 'one_time_completion',
        'skillLevelId': id,
        'skillId': skillId,
        'skillTrackId': skillTrackId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateGoal(int rate, String userEmail, String id) async {
    try {
      // Get the goal document first to check its current state and target value
      final goalRef = FirebaseFirestore.instance
          .collection('testers')
          .doc(userEmail)
          .collection('skillGoal')
          .doc(id);

      final goalDoc = await goalRef.get();
      if (!goalDoc.exists) {
        return false;
      }

      final goalData = goalDoc.data() as Map<String, dynamic>;
      final targetValue = (goalData['value'] as num?)?.toInt() ?? 0;
      final currentRate =
          (goalData['completionRateGoal'] as num?)?.toInt() ?? 0;
      final isAlreadyCompleted = goalData['isCompleted'] as bool? ?? false;

      // Always update the completion rate
      await goalRef.update({'completionRateGoal': rate});

      // Get skill level information from the goal data for journey tracking
      final skillLevelId = goalData['skillLevelId'] as String?;
      final skillId = goalData['skillId'] as String?;
      final skillTrackId = goalData['skillTrackId'] as String?;

      // Update journey progress on EVERY rate increase (not just goal completion)
      if (rate > currentRate && skillTrackId != null) {
        final rateDifference = rate - currentRate;

        // Update journey track completion for each rate increase
        final trackDoc = await _firestore
            .collection('testers')
            .doc(userEmail)
            .collection('skillTrack')
            .doc(skillTrackId)
            .get();

        if (trackDoc.exists) {
          final trackData = trackDoc.data();
          final currentCount =
              (trackData?['levelsCompleted'] as num?)?.toInt() ?? 0;
          final newCount = currentCount + rateDifference;
          await _firestore
              .collection('testers')
              .doc(userEmail)
              .collection('skillTrack')
              .doc(skillTrackId)
              .update({'levelsCompleted': newCount});
        } else {}

        // Also update skill completion count
        if (skillId != null) {
          final skillDoc = await _firestore
              .collection('testers')
              .doc(userEmail)
              .collection('skill')
              .doc(skillId)
              .get();

          if (skillDoc.exists) {
            final currentSkillCount =
                (skillDoc.data()?['skillLevelCompleted'] as num?)?.toInt() ?? 0;
            final newSkillCount = currentSkillCount + rateDifference;
            await _firestore
                .collection('testers')
                .doc(userEmail)
                .collection('skill')
                .doc(skillId)
                .update({'skillLevelCompleted': newSkillCount});
          }
        }
      } else if (rate <= currentRate) {
      } else if (skillTrackId == null) {}

      // If this goal has reached or exceeded its target and isn't already completed
      if (rate >= targetValue && targetValue > 0 && !isAlreadyCompleted) {
        // Mark goal as completed
        await goalRef.update({'isCompleted': true});

        if (skillLevelId != null) {
          // Mark the associated skill level as completed
          await _firestore
              .collection('testers')
              .doc(userEmail)
              .collection('skillLevel')
              .doc(skillLevelId)
              .update({'isCompleted': true});
        }

        // Log full goal completion interaction
        await _firestore
            .collection('testers')
            .doc(userEmail)
            .collection('userInteractions')
            .add({
          'type': 'goal_full_completion',
          'goalId': id,
          'skillLevelId': skillLevelId,
          'skillId': skillId,
          'skillTrackId': skillTrackId,
          'completionRate': rate,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        // Log daily progress interaction
        await _firestore
            .collection('testers')
            .doc(userEmail)
            .collection('userInteractions')
            .add({
          'type': 'goal_daily_progress',
          'goalId': id,
          'skillLevelId': skillLevelId,
          'skillId': skillId,
          'skillTrackId': skillTrackId,
          'completionRate': rate,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateMotivator(bool isAdded, String id, String userEmail,
      String skillId, String skillTrackId) async {
    try {
      // Check if already completed
      final skillLevelDoc = await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillLevel')
          .doc(id)
          .get();

      if (skillLevelDoc.exists) {
        final isAlreadyCompleted =
            skillLevelDoc.data()?['isCompleted'] as bool? ?? false;

        if (isAlreadyCompleted) {
          return true;
        }

        // 1. Update skill level IMMEDIATELY
        await _firestore
            .collection('testers')
            .doc(userEmail)
            .collection('skillLevel')
            .doc(id)
            .update({'isCompleted': true});

        // 2. Update skill completion count IMMEDIATELY
        final skillDoc = await _firestore
            .collection('testers')
            .doc(userEmail)
            .collection('skill')
            .doc(skillId)
            .get();

        if (skillDoc.exists) {
          final currentCount =
              (skillDoc.data()?['skillLevelCompleted'] as num?)?.toInt() ?? 0;
          await _firestore
              .collection('testers')
              .doc(userEmail)
              .collection('skill')
              .doc(skillId)
              .update({'skillLevelCompleted': currentCount + 1});
        } else {}

        // 3. Update journey track completion IMMEDIATELY

        try {
          final trackDoc = await _firestore
              .collection('testers')
              .doc(userEmail)
              .collection('skillTrack')
              .doc(skillTrackId)
              .get();

          if (trackDoc.exists) {
            final trackData = trackDoc.data();
            final currentCount =
                (trackData?['levelsCompleted'] as num?)?.toInt() ?? 0;

            await _firestore
                .collection('testers')
                .doc(userEmail)
                .collection('skillTrack')
                .doc(skillTrackId)
                .update({'levelsCompleted': currentCount + 1});
          } else {
            return false;
          }
        } catch (trackError) {
          return false;
        }

        // 4. Log user interaction IMMEDIATELY
        await _firestore
            .collection('testers')
            .doc(userEmail)
            .collection('userInteractions')
            .add({
          'type': 'motivator_completion',
          'skillLevelId': id,
          'skillId': skillId,
          'skillTrackId': skillTrackId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchJourneyLevels(
      String journeyId) async {
    try {
      final querySnapshot = await _firestore
          .collection('skillTrack')
          .doc(journeyId)
          .collection('levels')
          .orderBy('order')
          .get();

      return querySnapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> getCurrentLevel(String journeyId) async {
    try {
      final doc =
          await _firestore.collection('skillTrack').doc(journeyId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return (data['currentLevel'] as int?) ?? 1;
      }
      return 1;
    } catch (e) {
      return 1;
    }
  }

  Future<List<Map<String, dynamic>>> fetchSkillsByTrackId(String skillTrackId,
      {bool isParentMode = false}) async {
    try {
      final collectionName = isParentMode ? 'parent-skill' : 'skill-new';

      print('🔍 fetchSkillsByTrackId Debug Info:');
      print('  - skillTrackId: $skillTrackId');
      print('  - isParentMode: $isParentMode');
      print('  - collectionName: $collectionName');

      final skillCollection = _firestore.collection(collectionName);
      QuerySnapshot querySnapshot;

      try {
        // Try the ordered query first
        querySnapshot = await skillCollection
            .where('skillTrackId', isEqualTo: skillTrackId)
            .orderBy('position')
            .get();
        print('✅ Ordered query succeeded');
      } catch (indexError) {
        print(
            '⚠️ Ordered query failed (missing index), trying fallback query: $indexError');
        // Fallback: query without ordering and sort manually
        querySnapshot = await skillCollection
            .where('skillTrackId', isEqualTo: skillTrackId)
            .get();
        print('✅ Fallback query succeeded');
      }

      print(
          '🔍 fetchSkillsByTrackId query result: ${querySnapshot.docs.length} documents found');

      if (querySnapshot.docs.isEmpty) {
        print(
            '❌ No skills found in collection $collectionName for skillTrackId: $skillTrackId');

        // If parent mode collection is empty, try falling back to regular collection
        if (isParentMode) {
          print(
              '🔄 fetchSkillsByTrackId: Falling back to regular collection...');
          final fallbackCollectionName = 'skill-new';
          final fallbackCollection =
              _firestore.collection(fallbackCollectionName);

          QuerySnapshot fallbackSnapshot;
          try {
            fallbackSnapshot = await fallbackCollection
                .where('skillTrackId', isEqualTo: skillTrackId)
                .orderBy('position')
                .get();
          } catch (indexError) {
            fallbackSnapshot = await fallbackCollection
                .where('skillTrackId', isEqualTo: skillTrackId)
                .get();
          }

          print(
              '🔍 fetchSkillsByTrackId fallback result: ${fallbackSnapshot.docs.length} documents found');

          if (fallbackSnapshot.docs.isNotEmpty) {
            final skills = fallbackSnapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              print(
                  '🔍 Found fallback skill: ${data['title']} (ID: ${doc.id}, position: ${data['position']})');
              return {
                ...data,
                'objectId': doc.id,
                'isCompleted': false,
                'isInProgress': false,
                'isLocked': false,
              };
            }).toList();

            skills.sort(
                (a, b) => (a['position'] ?? 0).compareTo(b['position'] ?? 0));
            print(
                '✅ fetchSkillsByTrackId fallback completed successfully with ${skills.length} skills');
            return skills;
          }
        }

        return [];
      }

      final skills = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print(
            '🔍 Found skill: ${data['title']} (ID: ${doc.id}, position: ${data['position']})');
        return {
          ...data,
          'objectId': doc.id,
          'isCompleted': false,
          'isInProgress': false,
          'isLocked': false, // Change to false so they're not locked by default
        };
      }).toList();

      // Sort manually by position if we used the fallback query
      skills.sort((a, b) => (a['position'] ?? 0).compareTo(b['position'] ?? 0));

      print(
          '✅ fetchSkillsByTrackId completed successfully with ${skills.length} skills');
      return skills;
    } catch (e) {
      print('❌ Error in fetchSkillsByTrackId: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Add this new method to get journey type information
  Future<Map<String, dynamic>> getJourneyType(String skillTrackId, String email,
      {bool isParentMode = false}) async {
    try {
      // Try to get the journey from the user's collection first
      final userJourneyRef = _firestore
          .collection('testers')
          .doc(email)
          .collection('skillTrack')
          .doc(skillTrackId);

      final userJourneySnapshot = await userJourneyRef.get();

      if (userJourneySnapshot.exists) {
        return userJourneySnapshot.data() ?? {'type': ''};
      }

      // If not found in user's collection, try the appropriate main skillTrack collection
      final collectionName =
          isParentMode ? 'parent-skillTrack' : 'skillTrack-new';
      final journeyRef =
          _firestore.collection(collectionName).doc(skillTrackId);
      final journeySnapshot = await journeyRef.get();

      if (journeySnapshot.exists) {
        return journeySnapshot.data() ?? {'type': ''};
      }

      return {'type': ''};
    } catch (e) {
      return {'type': ''};
    }
  }

  // Add new method to track journey screen interactions
  Future<void> logJourneyScreenInteraction(
    String userEmail,
    String journeyId,
    String action, {
    Map<String, Object>? additionalData,
  }) async {
    try {
      final data = <String, Object>{
        'journeyId': journeyId,
        'action': action,
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (additionalData != null) {
        data.addAll(additionalData);
      }

      await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('journeyInteractions')
          .add(data);
    } catch (e) {}
  }

  // Add method to debug collection availability
  Future<void> debugCollectionAvailability() async {
    try {
      print('🔍 === COLLECTION AVAILABILITY DEBUG ===');

      final collections = [
        'skillTrack-new',
        'parent-skillTrack',
        'skill-new',
        'parent-skill',
        'skillTrack',
        'skill'
      ];

      for (final collectionName in collections) {
        try {
          final snapshot =
              await _firestore.collection(collectionName).limit(1).get();
          print(
              '✅ Collection "$collectionName": ${snapshot.docs.length > 0 ? 'EXISTS with data' : 'EXISTS but empty'}');

          if (snapshot.docs.isNotEmpty) {
            final firstDoc = snapshot.docs.first.data();
            final keys = firstDoc.keys.take(5).join(', ');
            print('   Sample fields: $keys');
          }
        } catch (e) {
          print('❌ Collection "$collectionName": ERROR - $e');
        }
      }

      print('🔍 === END COLLECTION DEBUG ===');
    } catch (e) {
      print('💥 Error in debugCollectionAvailability: $e');
    }
  }

  Future<Map<String, dynamic>> testCompletionFlow(
      String userEmail, String skillTrackId) async {
    try {
      // 1. Get initial state
      final initialTrack = await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillTrack')
          .doc(skillTrackId)
          .get();

      final initialStats = {
        'levelsCompleted': initialTrack.data()?['levelsCompleted'] ?? 0,
        'skillLevelCount': initialTrack.data()?['skillLevelCount'] ?? 0,
        'skillCount': initialTrack.data()?['skillCount'] ?? 0,
      };

      // 2. Get a skill level to complete
      final skillLevels = await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillLevel')
          .where('skillTrackId', isEqualTo: skillTrackId)
          .where('isCompleted', isEqualTo: false)
          .limit(1)
          .get();

      if (skillLevels.docs.isEmpty) {
        return {
          'success': false,
          'message': 'No incomplete skill levels found',
          'initialStats': initialStats,
        };
      }

      final skillLevel = skillLevels.docs.first;
      final skillLevelId = skillLevel.id;
      final skillId = skillLevel.data()['skillId'];

      // 3. Update completion
      final batch = _firestore.batch();

      // Update skill level
      final skillLevelRef = _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillLevel')
          .doc(skillLevelId);
      batch.update(skillLevelRef, {'isCompleted': true});

      // Update skill
      final skillRef = _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skill')
          .doc(skillId);
      batch.update(skillRef, {'skillLevelCompleted': FieldValue.increment(1)});

      // Update skill track
      final skillTrackRef = _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillTrack')
          .doc(skillTrackId);
      batch.update(skillTrackRef, {'levelsCompleted': FieldValue.increment(1)});

      await batch.commit();

      // 4. Get final state
      final finalTrack = await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillTrack')
          .doc(skillTrackId)
          .get();

      final finalStats = {
        'levelsCompleted': finalTrack.data()?['levelsCompleted'] ?? 0,
        'skillLevelCount': finalTrack.data()?['skillLevelCount'] ?? 0,
        'skillCount': finalTrack.data()?['skillCount'] ?? 0,
      };

      // 5. Verify the skill level was marked as completed
      final updatedSkillLevel = await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillLevel')
          .doc(skillLevelId)
          .get();

      return {
        'success': true,
        'message': 'Test completed successfully',
        'initialStats': initialStats,
        'finalStats': finalStats,
        'skillLevelCompleted':
            updatedSkillLevel.data()?['isCompleted'] ?? false,
        'skillLevelId': skillLevelId,
        'skillId': skillId,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  Future<void> forceStatsRefresh(String userEmail) async {
    try {
      // Add a dummy interaction to trigger provider refresh
      await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('userInteractions')
          .add({
        'type': 'stats_refresh',
        'timestamp': FieldValue.serverTimestamp(),
        'forced': true,
      });
    } catch (e) {}
  }

  // Auto-initialize missing journey with default skills and levels
  Future<bool> initializeJourney(
      String userEmail, String journeyId, Map<String, dynamic>? journeyData,
      {bool isParentMode = false}) async {
    try {
      final collectionName =
          isParentMode ? 'parent-skillTrack' : 'skillTrack-new';

      // 1. Get the existing journey from main skillTrack collection
      final mainJourneyDoc =
          await _firestore.collection(collectionName).doc(journeyId).get();

      if (!mainJourneyDoc.exists) {
        return false;
      }

      final mainJourneyData = mainJourneyDoc.data()!;

      // 2. Copy journey to user's collection with completion tracking
      await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillTrack')
          .doc(journeyId)
          .set({
        ...mainJourneyData,
        'levelsCompleted': 0,
        'isReleased': true,
        'userInitialized': true,
        'initializedAt': FieldValue.serverTimestamp(),
      });

      // 3. Get and copy all skills for this journey
      final skillCollectionName = isParentMode ? 'parent-skill' : 'skill-new';
      final skillsQuery = await _firestore
          .collection(skillCollectionName)
          .where('skillTrackId', isEqualTo: journeyId)
          .get();

      for (var skillDoc in skillsQuery.docs) {
        final skillData = skillDoc.data();

        // Copy skill to user's collection with completion tracking
        await _firestore
            .collection('testers')
            .doc(userEmail)
            .collection('skill')
            .doc(skillDoc.id)
            .set({
          ...skillData,
          'isCompleted': false,
          'skillLevelCompleted': 0,
          'userInitialized': true,
        });
      }

      // 4. Get and copy all skill levels for this journey
      final skillLevelCollectionName =
          isParentMode ? 'parent-skillLevel' : 'skillLevel-new';
      final skillLevelsQuery = await _firestore
          .collection(skillLevelCollectionName)
          .where('skillTrackId', isEqualTo: journeyId)
          .get();

      for (var levelDoc in skillLevelsQuery.docs) {
        final levelData = levelDoc.data();

        // Copy skill level to user's collection with completion tracking
        await _firestore
            .collection('testers')
            .doc(userEmail)
            .collection('skillLevel')
            .doc(levelDoc.id)
            .set({
          ...levelData,
          'isCompleted': false,
          'userInitialized': true,
        });
      }

      // 5. Copy any associated goals
      final goalCollectionName =
          isParentMode ? 'parent-skillGoal' : 'skillGoal-new';
      final goalsQuery = await _firestore
          .collection(goalCollectionName)
          .where('skillTrackId', isEqualTo: journeyId)
          .get();

      if (goalsQuery.docs.isNotEmpty) {
        for (var goalDoc in goalsQuery.docs) {
          final goalData = goalDoc.data();

          await _firestore
              .collection('testers')
              .doc(userEmail)
              .collection('skillGoal')
              .doc(goalDoc.id)
              .set({
            ...goalData,
            'isCompleted': false,
            'userInitialized': true,
          });
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Add method to reset goal for testing
  Future<bool> resetGoal(String userEmail, String goalId) async {
    try {
      final goalRef = FirebaseFirestore.instance
          .collection('testers')
          .doc(userEmail)
          .collection('skillGoal')
          .doc(goalId);

      await goalRef.update({
        'completionRateGoal': 0,
        'isCompleted': false,
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isSkillLevelCompleted(String email, String skillLevelId) async {
    final doc = await _firestore
        .collection('testers')
        .doc(email)
        .collection('skillLevel')
        .doc(skillLevelId)
        .get();
    return doc.exists && (doc.data()?['isCompleted'] == true);
  }

  /// Get journey by objectId from skillTrack-new collection
  Future<Map<String, dynamic>?> getJourneyById(String objectId) async {
    try {
      print('🔍 JourneyService: Searching for journey with ID: $objectId');

      // First try skillTrack-new collection
      final docSnapshot =
          await _firestore.collection('skillTrack-new').doc(objectId).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        // Filter out challenges from journeys
        final type = data['type'] as String? ?? '';
        if (!type.toLowerCase().contains('challenge')) {
          print(
              '✅ JourneyService: Found journey: ${data['title'] ?? 'Unnamed'}');
          return {
            ...data,
            'objectId': docSnapshot.id,
          };
        }
      }

      // If not found, try parent-skillTrack collection
      final parentDocSnapshot =
          await _firestore.collection('parent-skillTrack').doc(objectId).get();

      if (parentDocSnapshot.exists) {
        final data = parentDocSnapshot.data() as Map<String, dynamic>;
        final type = data['type'] as String? ?? '';
        if (!type.toLowerCase().contains('challenge')) {
          print(
              '✅ JourneyService: Found journey in parent collection: ${data['title'] ?? 'Unnamed'}');
          return {
            ...data,
            'objectId': parentDocSnapshot.id,
          };
        }
      }

      print('❌ JourneyService: Journey not found with ID: $objectId');
      return null;
    } catch (e) {
      print('❌ JourneyService: Error getting journey by ID: $e');
      return null;
    }
  }
}
