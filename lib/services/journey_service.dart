import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fantastic_app_riverpod/models/skill.dart';
import 'package:fantastic_app_riverpod/models/skillTrack.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JourneyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchJourneys() async {
    try {
      // Fetch all documents from the 'skillTrack' collection
      final querySnapshot = await _firestore.collection('skillTrack').get();

      // Filter out documents where 'type' contains 'challenge'
      final filteredDocs = querySnapshot.docs.where((doc) {
        final type = doc['type'] as String? ?? '';
        return !type
            .toLowerCase()
            .contains('challenge'); // Corrected spelling and case-insensitive
      }).toList();

      // Convert documents to a List of Maps
      return filteredDocs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching unreleased journey: $e');
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
      print('Error fetching unreleased journey: $e');
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
      print('Error fetching unreleased journey: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserJourneys(String email) async {
    try {
      // Fetch the collection snapshot for the given email
      final querySnapshot = await _firestore
          .collection('testers')
          .doc(email)
          .collection('skillTrack')
          .get();

      // Check if the collection has any documents
      if (querySnapshot.docs.isNotEmpty) {
        // Map each document to a Map<String, dynamic> and return as a list
        return querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      }

      // Return an empty list if no matching document is found
      return [];
    } catch (e) {
      print('Error fetching user journeys: $e');
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
          print('Document $docId updated to isReleased: ${!currentValue}');
        } else {
          print('Field "isReleased" does not exist in the document.');
        }
      } else {
        print('Document $docId does not exist.');
      }
    } catch (e) {
      print('Error updating isReleased: $e');
    }
  }

  Future<void> addSkillTrack(String id, String email) async {
    try {
      // Reference to the document path '/skillTrack/{id}'
      final skillDocRef = _firestore.collection('skillTrack').doc(id);

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

        print(
            'Document $id added to /testers/$email/skillTrack with levelsCompleted.');
      } else {
        print('Document with id $id does not exist in /skillTrack.');
      }
    } catch (e) {
      print('Error fetching and adding skills: $e');
    }
  }

  Future<List<Skill>> addSkills(String skillTrackId, String email) async {
    try {
      // Reference to the 'skill' collection
      final skillCollection = _firestore.collection('skill');

      // Query to fetch documents where skillTrackId matches
      final querySnapshot = await skillCollection
          .where('skillTrackId', isEqualTo: skillTrackId)
          .get();

      // Check if documents are found
      if (querySnapshot.docs.isEmpty) {
        print('No skills found for skillTrackId: $skillTrackId');
        return [];
      }

      // Map the documents into a list of Skill objects
      final List<Skill> skills = querySnapshot.docs
          .map((doc) => Skill.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Reference to the target path: /testers/{email}/skill
      final userSkillPath =
          _firestore.collection('testers').doc(email).collection('skill');

      // Check if the 'skill' collection already exists for the user
      final userSkillsSnapshot = await userSkillPath.get();
      if (userSkillsSnapshot.docs.isEmpty) {
        print('Skill collection for $email does not exist. Creating now.');
      }

      // Add each skill to the specified path with isComplete = false
      for (var skill in skills) {
        final totalLevels = await getTotalSkillLevels(skill
            .objectId); // Convert skill to a map and add 'isComplete': false
        final skillData = {
          ...skill.toMap(), // Existing skill data
          'isCompleted': false,
          'skillLevelCompleted': 0, // New field
          'totalLevels': totalLevels
        };

        // Add the updated skill data to the user's skill collection
        await userSkillPath.doc(skill.objectId).set(skillData);
      }

      print('${skills.length} skills added to /testers/$email/skill');
      return skills;
    } catch (e) {
      print('Error fetching and adding skills: $e');
      return [];
    }
  }

  Future<int> getTotalSkillLevels(String id) async {
    var _querysnapshot = await _firestore
        .collection('skillLevel')
        .where('skillId', isEqualTo: id)
        .get();
    return _querysnapshot.docs.length;
  }

  Future<List<String>> addSkillLevel(List<Skill> skills, String email) async {
    try {
      // List to store goalId values
      final List<String> goals = [];

      // Reference to the 'skillLevel' collection
      final skillCollection = _firestore.collection('skillLevel');

      // Iterate through each skill
      for (var skill in skills) {
        // Query to fetch documents where 'skillId' matches
        final querySnapshot = await skillCollection
            .where('skillId', isEqualTo: skill.objectId)
            .get();

        if (querySnapshot.docs.isEmpty) {
          print('No skill level found for skillID: ${skill.objectId}');
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

          print('Document ${doc.id} added to /testers/$email/skillLevel');
        }
      }

      // Print the collected goal IDs
      print('Collected goalIds: $goals');
      return goals;
    } catch (e) {
      print('Error fetching and adding skill levels: $e');
      return []; // Return an empty list if an error occurs
    }
  }

  Future<void> addSkillGoals(List<String> ids, String email) async {
    try {
      print('=== ADDING SKILL GOALS WITH ENRICHED DATA ===');
      print('Adding ${ids.length} goals for user: $email');
      
      // Reference to the target path: /testers/{email}/skillGoal
      final userSkillGoalPath =
          _firestore.collection('testers').doc(email).collection('skillGoal');
      
      // Reference to user's skillLevel collection to find related data
      final userSkillLevelPath = 
          _firestore.collection('testers').doc(email).collection('skillLevel');

      // Iterate through each ID in the list
      for (String id in ids) {
        // Reference to the document path: /skillGoal/{id}
        final skillDocRef = _firestore.collection('skillGoal').doc(id);

        // Fetch the document snapshot
        final docSnapshot = await skillDocRef.get();

        // Check if the document exists
        if (docSnapshot.exists) {
          // Get the document data
          final skillData = docSnapshot.data() as Map<String, dynamic>;
          
          // Find the corresponding skillLevel document that has this goalId
          final skillLevelQuery = await userSkillLevelPath
              .where('goalId', isEqualTo: id)
              .get();
          
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
            
            print('✅ Enriched goal $id with:');
            print('  - skillLevelId: ${skillLevelDoc.id}');
            print('  - skillId: ${skillLevelData['skillId']}');
            print('  - skillTrackId: ${skillLevelData['skillTrackId']}');
          } else {
            print('⚠️ No matching skillLevel found for goal $id - goal may not complete properly');
          }

          // Add the document data to the user's skillGoal collection
          await userSkillGoalPath.doc(id).set(updatedSkillData);
          print('✅ Goal $id added to /testers/$email/skillGoal');
        } else {
          print('❌ Goal $id does not exist in /skillGoal collection');
        }
      }

      print('=== SKILL GOALS ADDITION COMPLETED ===');
    } catch (e) {
      print('❌ Error adding skill goals: $e');
    }
  }

  Future<void> addSkillGoal(String id, String email) async {
    try {
      // Reference to the document path '/skillGoal/{id}'
      final skillDocRef = _firestore.collection('skillGoal').doc(id);

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

        print('Document $id added to /testers/$email/skillGoal');
      } else {
        print('Document with id $id does not exist in /skillGoal.');
      }
    } catch (e) {
      print('Error fetching and adding skills: $e');
    }
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
        print('No skills found for skillTrackId: $skillTrackId');
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
      print('Error fetching and adding skills: $e');
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
        print('No skills found with skillId: $skillId');
        return [];
      }

      // Map the documents into a list of Map<String, dynamic>
      List<Map<String, dynamic>> skillLevels = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      return skillLevels;
    } catch (e) {
      print('Error fetching skill levels: $e');
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
        print('No goal found with objectId: $goalId');
        return null;
      }

      // Since objectId should be unique, we expect one document
      final skillLevel =
          querySnapshot.docs.first.data() as Map<String, dynamic>;

      return skillLevel;
    } catch (e) {
      print('Error fetching skill levels: $e');
      return null;
    }
  }


  Future<Map<String, dynamic>?> getSkillLevel(
      String email, String goalId) async {
    try {
      // Reference to the user's skillGoal collection
      print("Currently searching for :$goalId");
      final userSkillLevelPath =
      _firestore.collection('skillLevel');

      // Query to get documents where 'objectId' matches the given goalId
      final querySnapshot =
      await userSkillLevelPath.where('skillId', isEqualTo: goalId).get();

      // Check if any documents are found
      if (querySnapshot.docs.isEmpty) {
        print('No level found with objectId: $goalId');
        return null;
      }else{
        print("Found the skillLevel :$goalId");
      }

      // Since objectId should be unique, we expect one document
      final skillLevel =
      querySnapshot.docs.first.data() as Map<String, dynamic>;

      return skillLevel;
    } catch (e) {
      print('Error fetching skill levels: $e');
      return null;
    }
  }

  Future<bool> updateGoalCompletion(String userEmail, String id,
      String skillLevelId, String skillId, String skillTrackId) async {
    try {
      print('=== UPDATING GOAL COMPLETION - IMMEDIATE FIX ===');
      print('User: $userEmail');
      print('Goal ID: $id');
      print('Skill Level ID: $skillLevelId');
      print('Skill ID: $skillId');
      print('Skill Track ID: $skillTrackId');

      // 1. Update skill level IMMEDIATELY
      print('Updating skill level document IMMEDIATELY...');
      await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillLevel')
          .doc(skillLevelId)
          .update({'isCompleted': true});
      print('✅ Skill level updated');

      // 2. Get current skill data and update immediately
      print('Updating skill document IMMEDIATELY...');
      final skillDoc = await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skill')
          .doc(skillId)
          .get();
      
      if (skillDoc.exists) {
        final currentCount = (skillDoc.data()?['skillLevelCompleted'] as num?)?.toInt() ?? 0;
        await _firestore
            .collection('testers')
            .doc(userEmail)
            .collection('skill')
            .doc(skillId)
            .update({'skillLevelCompleted': currentCount + 1});
        print('✅ Skill updated - new count: ${currentCount + 1}');
      } else {
        print('❌ Skill document not found: $skillId');
      }

      // 3. Get current track data and update immediately
      print('Updating skill track document IMMEDIATELY...');
      print('Skill track ID: $skillTrackId');
      
      try {
        final trackDoc = await _firestore
            .collection('testers')
            .doc(userEmail)
            .collection('skillTrack')
            .doc(skillTrackId)
            .get();
        
        if (trackDoc.exists) {
          final trackData = trackDoc.data();
          print('Track data found: $trackData');
          final currentCount = (trackData?['levelsCompleted'] as num?)?.toInt() ?? 0;
          print('Current track levels completed: $currentCount');
          
          await _firestore
              .collection('testers')
              .doc(userEmail)
              .collection('skillTrack')
              .doc(skillTrackId)
              .update({'levelsCompleted': currentCount + 1});
          print('✅ Skill track updated - new count: ${currentCount + 1}');
        } else {
          print('❌ Skill track document not found: $skillTrackId');
          return false;
        }
      } catch (trackError) {
        print('❌ Error updating skill track: $trackError');
        return false;
      }

      // 4. Update goal if it exists
      final skillLevelDoc = await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillLevel')
          .doc(skillLevelId)
          .get();
      
      if (skillLevelDoc.exists) {
        final skillLevelData = skillLevelDoc.data() as Map<String, dynamic>;
        final goalId = skillLevelData['goalId'] as String?;
        
        if (goalId != null) {
          print('Updating goal document IMMEDIATELY...');
          await _firestore
              .collection('testers')
              .doc(userEmail)
              .collection('skillGoal')
              .doc(goalId)
              .update({'isCompleted': true});
          print('✅ Goal updated');
        }
      }

      // 5. Add interaction log
      print('Logging interaction IMMEDIATELY...');
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
      print('✅ Interaction logged');

      print('=== ALL UPDATES COMPLETED SUCCESSFULLY ===');
      return true;
    } catch (e) {
      print('❌ ERROR updating goal completion: $e');
      return false;
    }
  }

  Future<bool> updateOneTime(bool isAdded, String id, String userEmail,
      String skillId, String skillTrackId) async {
    try {
      print('=== UPDATING ONE TIME - IMMEDIATE FIX ===');
      print('User: $userEmail, Skill Level ID: $id, Skill ID: $skillId, Track ID: $skillTrackId');

      // Check if already completed to avoid duplicate updates
      final skillLevelDoc = await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillLevel')
          .doc(id)
          .get();

      if (!skillLevelDoc.exists) {
        print("❌ Skill level document does not exist.");
        return false;
      }

      final isAlreadyCompleted = skillLevelDoc.data()?['isCompleted'] as bool? ?? false;
      
      if (isAlreadyCompleted) {
        print('⚠️ Skill level already completed, skipping update');
        return true;
      }

      // 1. Update skill level IMMEDIATELY
      print('Updating skill level document IMMEDIATELY...');
      await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillLevel')
          .doc(id)
          .update({'isCompleted': true});
      print('✅ Skill level updated');

      // 2. Update skill completion count IMMEDIATELY
      print('Updating skill document IMMEDIATELY...');
      final skillDoc = await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skill')
          .doc(skillId)
          .get();
      
      if (skillDoc.exists) {
        final currentCount = (skillDoc.data()?['skillLevelCompleted'] as num?)?.toInt() ?? 0;
        await _firestore
            .collection('testers')
            .doc(userEmail)
            .collection('skill')
            .doc(skillId)
            .update({'skillLevelCompleted': currentCount + 1});
        print('✅ Skill updated - new count: ${currentCount + 1}');
      } else {
        print('❌ Skill document not found: $skillId');
      }

      // 3. Update journey track completion IMMEDIATELY
      print('Updating skill track document IMMEDIATELY...');
      print('Skill track ID: $skillTrackId');
      
      try {
        final trackDoc = await _firestore
            .collection('testers')
            .doc(userEmail)
            .collection('skillTrack')
            .doc(skillTrackId)
            .get();
        
        if (trackDoc.exists) {
          final trackData = trackDoc.data();
          print('Track data found: $trackData');
          final currentCount = (trackData?['levelsCompleted'] as num?)?.toInt() ?? 0;
          print('Current track levels completed: $currentCount');
          
          await _firestore
              .collection('testers')
              .doc(userEmail)
              .collection('skillTrack')
              .doc(skillTrackId)
              .update({'levelsCompleted': currentCount + 1});
          print('✅ Skill track updated - new count: ${currentCount + 1}');
        } else {
          print('❌ Skill track document not found: $skillTrackId');
          print('Trying to check if document exists...');
          
          // Try to check if the document exists in the collection
          final allTracks = await _firestore
              .collection('testers')
              .doc(userEmail)
              .collection('skillTrack')
              .get();
          
          print('Available skill tracks:');
          for (var doc in allTracks.docs) {
            print('  - ${doc.id}');
          }
          
          return false;
        }
      } catch (trackError) {
        print('❌ Error updating skill track: $trackError');
        return false;
      }

      // 4. Log user interaction IMMEDIATELY
      print('Logging interaction IMMEDIATELY...');
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
      print('✅ Interaction logged');

      print('=== ONE TIME UPDATE COMPLETED SUCCESSFULLY ===');
      return true;
    } catch (e) {
      print("❌ ERROR updating one time: $e");
      return false;
    }
  }

  Future<bool> updateGoal(int rate, String userEmail, String id) async {
    try {
      print('=== UPDATING GOAL WITH COMPLETION CHECK ===');
      print('User: $userEmail, Goal ID: $id, New Rate: $rate');
      
      // Get the goal document first to check its current state and target value
      final goalRef = FirebaseFirestore.instance
          .collection('testers')
          .doc(userEmail)
          .collection('skillGoal')
          .doc(id);
      
      final goalDoc = await goalRef.get();
      if (!goalDoc.exists) {
        print('❌ Goal document not found: $id');
        return false;
      }
      
      final goalData = goalDoc.data() as Map<String, dynamic>;
      final targetValue = (goalData['value'] as num?)?.toInt() ?? 0;
      final currentRate = (goalData['completionRateGoal'] as num?)?.toInt() ?? 0;
      final isAlreadyCompleted = goalData['isCompleted'] as bool? ?? false;
      
      print('=== DETAILED GOAL ANALYSIS ===');
      print('Goal target: $targetValue, Current rate in DB: $currentRate, New rate requested: $rate, Already completed: $isAlreadyCompleted');
      print('Rate change calculation: $rate - $currentRate = ${rate - currentRate}');
      print('Will update journey progress? ${rate > currentRate ? "YES" : "NO"} (rate > currentRate: $rate > $currentRate)');
      
      // Always update the completion rate
      await goalRef.update({'completionRateGoal': rate});
      print('✅ Goal rate updated from $currentRate to: $rate');
      
      // Get skill level information from the goal data for journey tracking
      final skillLevelId = goalData['skillLevelId'] as String?;
      final skillId = goalData['skillId'] as String?;
      final skillTrackId = goalData['skillTrackId'] as String?;
      
      print('Skill Level ID: $skillLevelId, Skill ID: $skillId, Track ID: $skillTrackId');
      
      // Update journey progress on EVERY rate increase (not just goal completion)
      if (rate > currentRate && skillTrackId != null) {
        final rateDifference = rate - currentRate;
        print('🚀 Rate increased by $rateDifference - updating journey progress...');
        
        // Update journey track completion for each rate increase
        final trackDoc = await _firestore
            .collection('testers')
            .doc(userEmail)
            .collection('skillTrack')
            .doc(skillTrackId)
            .get();
        
        if (trackDoc.exists) {
          final trackData = trackDoc.data();
          final currentCount = (trackData?['levelsCompleted'] as num?)?.toInt() ?? 0;
          final newCount = currentCount + rateDifference;
          await _firestore
              .collection('testers')
              .doc(userEmail)
              .collection('skillTrack')
              .doc(skillTrackId)
              .update({'levelsCompleted': newCount});
          print('✅ Journey track updated - levels completed: $currentCount → $newCount (+$rateDifference)');
        } else {
          print('❌ Journey track document not found: $skillTrackId');
        }
        
        // Also update skill completion count
        if (skillId != null) {
          print('Updating skill completion count...');
          final skillDoc = await _firestore
              .collection('testers')
              .doc(userEmail)
              .collection('skill')
              .doc(skillId)
              .get();
          
          if (skillDoc.exists) {
            final currentSkillCount = (skillDoc.data()?['skillLevelCompleted'] as num?)?.toInt() ?? 0;
            final newSkillCount = currentSkillCount + rateDifference;
            await _firestore
                .collection('testers')
                .doc(userEmail)
                .collection('skill')
                .doc(skillId)
                .update({'skillLevelCompleted': newSkillCount});
            print('✅ Skill updated - completion count: $currentSkillCount → $newSkillCount (+$rateDifference)');
          }
        }
      } else if (rate <= currentRate) {
        print('⚠️ No rate increase detected ($currentRate → $rate) - skipping journey progress update');
        print('   Reason: rate ($rate) <= currentRate ($currentRate)');
      } else if (skillTrackId == null) {
        print('⚠️ Missing skillTrackId - cannot update journey progress');
      }
      
      // If this goal has reached or exceeded its target and isn't already completed
      if (rate >= targetValue && targetValue > 0 && !isAlreadyCompleted) {
        print('🎯 Goal has reached target! Marking as completed...');
        
        // Mark goal as completed
        await goalRef.update({'isCompleted': true});
        print('✅ Goal marked as completed');
        
        if (skillLevelId != null) {
          // Mark the associated skill level as completed
          print('Updating skill level document...');
          await _firestore
              .collection('testers')
              .doc(userEmail)
              .collection('skillLevel')
              .doc(skillLevelId)
              .update({'isCompleted': true});
          print('✅ Skill level marked as completed');
        }
        
        // Log full goal completion interaction
        print('Logging goal completion interaction...');
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
        print('✅ Goal completion interaction logged');
        
        print('🎉 GOAL FULL COMPLETION SEQUENCE COMPLETED');
      } else {
        // Log daily progress interaction
        print('Logging daily progress interaction...');
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
        print('✅ Daily progress interaction logged');
      }

      print('=== GOAL UPDATE COMPLETED SUCCESSFULLY ===');
      return true;
    } catch (e) {
      print("❌ ERROR updating goal: $e");
      return false;
    }
  }

  Future<bool> updateMotivator(bool isAdded, String id, String userEmail,
      String skillId, String skillTrackId) async {
    try {
      print('=== UPDATING MOTIVATOR - IMMEDIATE FIX ===');
      print('User: $userEmail, Skill Level ID: $id, Skill ID: $skillId, Track ID: $skillTrackId');

      // Check if already completed
      final skillLevelDoc = await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillLevel')
          .doc(id)
          .get();

      if (skillLevelDoc.exists) {
        final isAlreadyCompleted = skillLevelDoc.data()?['isCompleted'] as bool? ?? false;
        
        if (isAlreadyCompleted) {
          print('⚠️ Skill level already completed, skipping update');
          return true;
        }

        // 1. Update skill level IMMEDIATELY
        print('Updating skill level document IMMEDIATELY...');
        await _firestore
            .collection('testers')
            .doc(userEmail)
            .collection('skillLevel')
            .doc(id)
            .update({'isCompleted': true});
        print('✅ Skill level updated');

        // 2. Update skill completion count IMMEDIATELY
        print('Updating skill document IMMEDIATELY...');
        final skillDoc = await _firestore
            .collection('testers')
            .doc(userEmail)
            .collection('skill')
            .doc(skillId)
            .get();
        
        if (skillDoc.exists) {
          final currentCount = (skillDoc.data()?['skillLevelCompleted'] as num?)?.toInt() ?? 0;
          await _firestore
              .collection('testers')
              .doc(userEmail)
              .collection('skill')
              .doc(skillId)
              .update({'skillLevelCompleted': currentCount + 1});
          print('✅ Skill updated - new count: ${currentCount + 1}');
        } else {
          print('❌ Skill document not found: $skillId');
        }

        // 3. Update journey track completion IMMEDIATELY
        print('Updating skill track document IMMEDIATELY...');
        print('Skill track ID: $skillTrackId');
        
        try {
          final trackDoc = await _firestore
              .collection('testers')
              .doc(userEmail)
              .collection('skillTrack')
              .doc(skillTrackId)
              .get();
          
          if (trackDoc.exists) {
            final trackData = trackDoc.data();
            print('Track data found: $trackData');
            final currentCount = (trackData?['levelsCompleted'] as num?)?.toInt() ?? 0;
            print('Current track levels completed: $currentCount');
            
            await _firestore
                .collection('testers')
                .doc(userEmail)
                .collection('skillTrack')
                .doc(skillTrackId)
                .update({'levelsCompleted': currentCount + 1});
            print('✅ Skill track updated - new count: ${currentCount + 1}');
          } else {
            print('❌ Skill track document not found: $skillTrackId');
            return false;
          }
        } catch (trackError) {
          print('❌ Error updating skill track: $trackError');
          return false;
        }

        // 4. Log user interaction IMMEDIATELY
        print('Logging interaction IMMEDIATELY...');
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
        print('✅ Interaction logged');

        print('=== MOTIVATOR UPDATE COMPLETED SUCCESSFULLY ===');
      } else {
        print("❌ Skill level document does not exist.");
        return false;
      }

      return true;
    } catch (e) {
      print("❌ ERROR updating motivator: $e");
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
      print('Error fetching journey levels: $e');
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
      print('Error getting current level: $e');
      return 1;
    }
  }

  Future<List<Map<String, dynamic>>> fetchSkillsByTrackId(
      String skillTrackId) async {
    try {
      final skillCollection = _firestore.collection('skill');
      final querySnapshot = await skillCollection
          .where('skillTrackId', isEqualTo: skillTrackId)
          .orderBy('position') // Add this if you want to maintain order
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No skills found for skillTrackId: $skillTrackId');
        return [];
      }

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          ...data,
          'objectId': doc.id,
          'isCompleted': false,
          'isInProgress': false,
          'isLocked': true,
        };
      }).toList();
    } catch (e) {
      print('Error fetching skills by track ID: $e');
      return [];
    }
  }

  // Add this new method to get journey type information
  Future<Map<String, dynamic>> getJourneyType(String skillTrackId, String email) async {
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
      
      // If not found in user's collection, try the main skillTrack collection
      final journeyRef = _firestore.collection('skillTrack').doc(skillTrackId);
      final journeySnapshot = await journeyRef.get();
      
      if (journeySnapshot.exists) {
        return journeySnapshot.data() ?? {'type': ''};
      }
      
      return {'type': ''};
    } catch (e) {
      print('Error fetching journey type: $e');
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
    } catch (e) {
      print("Error logging journey screen interaction: $e");
    }
  }

  Future<Map<String, dynamic>> testCompletionFlow(String userEmail, String skillTrackId) async {
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
        'skillLevelCompleted': updatedSkillLevel.data()?['isCompleted'] ?? false,
        'skillLevelId': skillLevelId,
        'skillId': skillId,
      };
    } catch (e) {
      print('Error in test completion flow: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  Future<void> forceStatsRefresh(String userEmail) async {
    try {
      print('=== FORCING STATS REFRESH ===');
      
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
      
      print('✅ Stats refresh triggered');
    } catch (e) {
      print('❌ Error forcing stats refresh: $e');
    }
  }

  // Auto-initialize missing journey with default skills and levels
  Future<bool> initializeJourney(String userEmail, String journeyId, Map<String, dynamic>? journeyData) async {
    try {
      print('🚀 INITIALIZING JOURNEY FROM EXISTING DATA: $journeyId');
      
      // 1. Get the existing journey from main skillTrack collection
      final mainJourneyDoc = await _firestore
          .collection('skillTrack')
          .doc(journeyId)
          .get();
      
      if (!mainJourneyDoc.exists) {
        print('❌ Journey $journeyId not found in main skillTrack collection');
        return false;
      }
      
      final mainJourneyData = mainJourneyDoc.data()!;
      print('✅ Found main journey: ${mainJourneyData['title']}');
      
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
      print('✅ Journey copied to user collection');
      
      // 3. Get and copy all skills for this journey
      final skillsQuery = await _firestore
          .collection('skill')
          .where('skillTrackId', isEqualTo: journeyId)
          .get();
      
      print('Found ${skillsQuery.docs.length} skills for journey');
      
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
      print('✅ All skills copied to user collection');
      
      // 4. Get and copy all skill levels for this journey
      final skillLevelsQuery = await _firestore
          .collection('skillLevel')
          .where('skillTrackId', isEqualTo: journeyId)
          .get();
      
      print('Found ${skillLevelsQuery.docs.length} skill levels for journey');
      
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
      print('✅ All skill levels copied to user collection');
      
      // 5. Copy any associated goals
      final goalsQuery = await _firestore
          .collection('skillGoal')
          .where('skillTrackId', isEqualTo: journeyId)
          .get();
      
      if (goalsQuery.docs.isNotEmpty) {
        print('Found ${goalsQuery.docs.length} goals for journey');
        
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
        print('✅ All goals copied to user collection');
      }
      
      print('🎉 JOURNEY INITIALIZATION COMPLETE: ${mainJourneyData['title']}');
      return true;
    } catch (e) {
      print('❌ Failed to initialize journey: $e');
      return false;
    }
  }

  // Add method to reset goal for testing
  Future<bool> resetGoal(String userEmail, String goalId) async {
    try {
      print('=== RESETTING GOAL FOR TESTING ===');
      print('User: $userEmail, Goal ID: $goalId');
      
      final goalRef = FirebaseFirestore.instance
          .collection('testers')
          .doc(userEmail)
          .collection('skillGoal')
          .doc(goalId);
      
      await goalRef.update({
        'completionRateGoal': 0,
        'isCompleted': false,
      });
      
      print('✅ Goal reset to 0 completions');
      return true;
    } catch (e) {
      print('❌ Error resetting goal: $e');
      return false;
    }
  }
}

final journeyServiceProvider =
    Provider<JourneyService>((ref) => JourneyService());
