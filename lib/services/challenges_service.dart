import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fantastic_app_riverpod/models/skill.dart';

class ChallengesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all challenges from the skillTrack collection
  Future<List<Map<String, dynamic>>> fetchChallenges() async {
    try {
      // Fetch documents from the 'skillTrack' collection where type contains 'challenge'
      final querySnapshot = await _firestore
          .collection('skillTrack')
          .where('type', isGreaterThanOrEqualTo: 'FREE_CHALLENGE')
          // Efficient string prefix query
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching challenges: $e');
      return [];
    }
  }

  // Fetch a single unreleased challenge for a specific user
  Future<List<Map<String, dynamic>>> fetchUnreleasedChallenge(
      String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('testers')
          .doc(email)
          .collection('skillTrack')
          .where('isReleased', isEqualTo: false)
          .where('type', isGreaterThanOrEqualTo: 'FREE_CHALLENGE')
          .limit(1)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching unreleased challenge: $e');
      return [];
    }
  }

  // Fetch all challenges for a specific user
  Future<List<Map<String, dynamic>>> fetchUserChallenges(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('testers')
          .doc(email)
          .collection('skillTrack')
          .where('type', isGreaterThanOrEqualTo: 'FREE_CHALLENGE')
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching user challenges: $e');
      return [];
    }
  }

  // Update the release status of a challenge
  Future<void> updateChallengeReleaseStatus(String email, String docId) async {
    try {
      final docRef = _firestore
          .collection('testers')
          .doc(email)
          .collection('skillTrack')
          .doc(docId);

      final snapshot = await docRef.get();

      if (snapshot.exists) {
        final currentValue = snapshot.data()?['isReleased'] as bool?;
        if (currentValue != null) {
          await docRef.update({'isReleased': !currentValue});
          print('Challenge $docId updated to isReleased: ${!currentValue}');
        } else {
          print('Field "isReleased" does not exist in the challenge document.');
        }
      } else {
        print('Challenge document $docId does not exist.');
      }
    } catch (e) {
      print('Error updating challenge release status: $e');
    }
  }

  // Add a challenge to a user's collection
  Future<void> addChallenge(String id, String email) async {
    try {
      // Reference to the document in skillTrack collection
      final challengeDocRef = _firestore.collection('skillTrack').doc(id);

      // Fetch the document snapshot
      final docSnapshot = await challengeDocRef.get();

      if (docSnapshot.exists) {
        // Get the document data and ensure required fields exist
        final challengeData = docSnapshot.data() as Map<String, dynamic>;

        // Add levelsCompleted if it doesn't exist
        if (!challengeData.containsKey('levelsCompleted')) {
          challengeData['levelsCompleted'] = 0;
        }

        // Ensure isReleased is false
        challengeData['isReleased'] = false;

        // Add to user's skillTrack collection
        await _firestore
            .collection('testers')
            .doc(email)
            .collection('skillTrack')
            .doc(id)
            .set(challengeData);

        print('Challenge $id added to user $email\'s collection');
      } else {
        print('Challenge with id $id does not exist in skillTrack collection.');
      }
    } catch (e) {
      print('Error adding challenge: $e');
    }
  }

  // Get skills associated with a specific challenge
  Future<List<Skill>> getChallengeSkills(
      String challengeId, String email) async {
    try {
      final skillCollection =
          _firestore.collection('testers').doc(email).collection('skill');

      final querySnapshot = await skillCollection
          .where('skillTrackId', isEqualTo: challengeId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No skills found for challenge: $challengeId');
        return [];
      }

      final List<Skill> skills = querySnapshot.docs
          .map((doc) => Skill.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Sort skills by position
      skills.sort((a, b) => a.position.compareTo(b.position));
      return skills;
    } catch (e) {
      print('Error fetching challenge skills: $e');
      return [];
    }
  }

  // Add skills for a challenge
  Future<List<Skill>> addChallengeSkills(
      String challengeId, String email) async {
    try {
      // Reference to the 'skill' collection
      final skillCollection = _firestore.collection('skill');

      // Query to fetch skills associated with this challenge
      final querySnapshot = await skillCollection
          .where('skillTrackId', isEqualTo: challengeId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No skills found for challenge ID: $challengeId');
        return [];
      }

      final List<Skill> skills = querySnapshot.docs
          .map((doc) => Skill.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Reference to the user's skill collection
      final userSkillPath =
          _firestore.collection('testers').doc(email).collection('skill');

      // Add each skill with proper metadata
      for (var skill in skills) {
        final totalLevels = await getTotalSkillLevels(skill.objectId);
        final skillData = {
          ...skill.toMap(),
          'isCompleted': false,
          'skillLevelCompleted': 0,
          'totalLevels': totalLevels
        };

        await userSkillPath.doc(skill.objectId).set(skillData);
      }

      print('${skills.length} challenge skills added for user $email');
      return skills;
    } catch (e) {
      print('Error adding challenge skills: $e');
      return [];
    }
  }

  // Get total number of skill levels for a skill
  Future<int> getTotalSkillLevels(String skillId) async {
    try {
      var querySnapshot = await _firestore
          .collection('skillLevel')
          .where('skillId', isEqualTo: skillId)
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      print('Error getting total skill levels: $e');
      return 0;
    }
  }

  // Add skill levels for a challenge
  Future<List<String>> addChallengeSkillLevels(
      List<Skill> skills, String email) async {
    try {
      final List<String> goals = [];
      final skillLevelCollection = _firestore.collection('skillLevel');
      final userSkillLevelPath =
          _firestore.collection('testers').doc(email).collection('skillLevel');

      for (var skill in skills) {
        final querySnapshot = await skillLevelCollection
            .where('skillId', isEqualTo: skill.objectId)
            .get();

        if (querySnapshot.docs.isEmpty) continue;

        // Process each skill level
        for (var doc in querySnapshot.docs) {
          final skillData = doc.data() as Map<String, dynamic>;

          // Collect goal IDs
          if (skillData.containsKey('goalId') &&
              skillData['goalId'] != null &&
              skillData['goalId'] is String) {
            goals.add(skillData['goalId']);
          }

          // Add isCompleted field
          final updatedData = {
            ...skillData,
            'isCompleted': false,
          };

          await userSkillLevelPath.doc(doc.id).set(updatedData);
        }
      }

      print(
          'Added skill levels for challenge with ${goals.length} associated goals');
      return goals;
    } catch (e) {
      print('Error adding challenge skill levels: $e');
      return [];
    }
  }

  // Add skill goals for a challenge
  Future<void> addChallengeGoals(List<String> goalIds, String email) async {
    try {
      print('=== ADDING CHALLENGE GOALS WITH ENRICHED DATA ===');
      print('Adding ${goalIds.length} goals for user: $email');
      
      final userSkillGoalPath =
          _firestore.collection('testers').doc(email).collection('skillGoal');
      final skillGoalCollection = _firestore.collection('skillGoal');
      
      // Reference to user's skillLevel collection to find related data
      final userSkillLevelPath = 
          _firestore.collection('testers').doc(email).collection('skillLevel');

      int addedCount = 0;

      for (String goalId in goalIds) {
        final docSnapshot = await skillGoalCollection.doc(goalId).get();

        if (docSnapshot.exists) {
          final goalData = docSnapshot.data() as Map<String, dynamic>;
          
          // Find the corresponding skillLevel document that has this goalId
          final skillLevelQuery = await userSkillLevelPath
              .where('goalId', isEqualTo: goalId)
              .get();
          
          // Initialize the updated data
          final updatedGoalData = {
            ...goalData,
            'isCompleted': false,
          };
          
          // If we found a matching skillLevel, add the required fields
          if (skillLevelQuery.docs.isNotEmpty) {
            final skillLevelDoc = skillLevelQuery.docs.first;
            final skillLevelData = skillLevelDoc.data();
            
            // Add the fields needed for goal completion
            updatedGoalData['skillLevelId'] = skillLevelDoc.id;
            updatedGoalData['skillId'] = skillLevelData['skillId'];
            updatedGoalData['skillTrackId'] = skillLevelData['skillTrackId'];
            
            print('✅ Enriched challenge goal $goalId with:');
            print('  - skillLevelId: ${skillLevelDoc.id}');
            print('  - skillId: ${skillLevelData['skillId']}');
            print('  - skillTrackId: ${skillLevelData['skillTrackId']}');
          } else {
            print('⚠️ No matching skillLevel found for goal $goalId - goal may not complete properly');
          }
          
          await userSkillGoalPath.doc(goalId).set(updatedGoalData);
          addedCount++;
          print('✅ Challenge goal $goalId added successfully');
        } else {
          print('❌ Goal $goalId not found in skillGoal collection');
        }
      }

      print('=== ADDED $addedCount CHALLENGE GOALS FOR USER $email ===');
    } catch (e) {
      print('❌ Error adding challenge goals: $e');
    }
  }

  // Update completion status for a challenge skill level
  Future<bool> updateChallengeSkillLevel(String userEmail, String skillLevelId,
      String skillId, String challengeId) async {
    try {
      print('=== UPDATING CHALLENGE SKILL LEVEL - IMMEDIATE FIX ===');
      print('User: $userEmail, Skill Level ID: $skillLevelId, Skill ID: $skillId, Challenge ID: $challengeId');

      // Check if already completed to avoid duplicate updates
      final skillLevelDoc = await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillLevel')
          .doc(skillLevelId)
          .get();

      if (!skillLevelDoc.exists) {
        print("❌ Skill level document does not exist");
        return false;
      }

      final isAlreadyCompleted = skillLevelDoc.data()?['isCompleted'] as bool? ?? false;
      
      if (isAlreadyCompleted) {
        print('⚠️ Skill level already completed, skipping update');
        return true;
      }

      // 1. Update the skill level document IMMEDIATELY
      print('Updating skill level document IMMEDIATELY...');
      await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillLevel')
          .doc(skillLevelId)
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

      // 3. Update challenge completion count IMMEDIATELY
      print('Updating challenge document IMMEDIATELY...');
      final challengeDoc = await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillTrack')
          .doc(challengeId)
          .get();
      
      if (challengeDoc.exists) {
        final currentCount = (challengeDoc.data()?['levelsCompleted'] as num?)?.toInt() ?? 0;
        await _firestore
            .collection('testers')
            .doc(userEmail)
            .collection('skillTrack')
            .doc(challengeId)
            .update({'levelsCompleted': currentCount + 1});
        print('✅ Challenge updated - new count: ${currentCount + 1}');
      } else {
        print('❌ Challenge document not found: $challengeId');
      }

      // 4. Log interaction
      print('Logging interaction IMMEDIATELY...');
      await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('userInteractions')
          .add({
        'type': 'challenge_skill_level_completion',
        'skillLevelId': skillLevelId,
        'skillId': skillId,
        'challengeId': challengeId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('✅ Interaction logged');

      print('=== CHALLENGE SKILL LEVEL UPDATE COMPLETED SUCCESSFULLY ===');
      return true;
    } catch (e) {
      print('❌ Error updating challenge skill level: $e');
      return false;
    }
  }

  // Update completion status for a challenge goal
  Future<bool> updateChallengeGoal(String userEmail, String goalId,
      String skillLevelId, String skillId, String challengeId) async {
    try {
      print('=== UPDATING CHALLENGE GOAL - IMMEDIATE FIX ===');
      print('User: $userEmail, Goal ID: $goalId, Skill Level ID: $skillLevelId, Skill ID: $skillId, Challenge ID: $challengeId');

      // Check if goal already completed to avoid duplicate updates
      final goalDoc = await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillGoal')
          .doc(goalId)
          .get();

      if (!goalDoc.exists) {
        print("❌ Goal document does not exist");
        return false;
      }

      final isGoalCompleted = goalDoc.data()?['isCompleted'] as bool? ?? false;
      
      if (isGoalCompleted) {
        print('⚠️ Goal already completed, skipping update');
        return true;
      }

      // 1. Update the goal document IMMEDIATELY
      print('Updating goal document IMMEDIATELY...');
      await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillGoal')
          .doc(goalId)
          .update({'isCompleted': true});
      print('✅ Goal updated');

      // 2. Update the associated skill level IMMEDIATELY
      print('Updating skill level document IMMEDIATELY...');
      final skillLevelDoc = await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillLevel')
          .doc(skillLevelId)
          .get();

      if (skillLevelDoc.exists) {
        final isLevelCompleted = skillLevelDoc.data()?['isCompleted'] as bool? ?? false;
        
        if (!isLevelCompleted) {
          await _firestore
              .collection('testers')
              .doc(userEmail)
              .collection('skillLevel')
              .doc(skillLevelId)
              .update({'isCompleted': true});
          print('✅ Skill level updated');
        } else {
          print('⚠️ Skill level already completed');
        }
      } else {
        print('❌ Skill level document not found: $skillLevelId');
      }

      // 3. Update skill completion count IMMEDIATELY
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

      // 4. Update challenge completion count IMMEDIATELY
      print('Updating challenge document IMMEDIATELY...');
      final challengeDoc = await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillTrack')
          .doc(challengeId)
          .get();
      
      if (challengeDoc.exists) {
        final currentCount = (challengeDoc.data()?['levelsCompleted'] as num?)?.toInt() ?? 0;
        await _firestore
            .collection('testers')
            .doc(userEmail)
            .collection('skillTrack')
            .doc(challengeId)
            .update({'levelsCompleted': currentCount + 1});
        print('✅ Challenge updated - new count: ${currentCount + 1}');
      } else {
        print('❌ Challenge document not found: $challengeId');
      }

      // 5. Log interaction
      print('Logging interaction IMMEDIATELY...');
      await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('userInteractions')
          .add({
        'type': 'challenge_goal_completion',
        'goalId': goalId,
        'skillLevelId': skillLevelId,
        'skillId': skillId,
        'challengeId': challengeId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('✅ Interaction logged');

      print('=== CHALLENGE GOAL UPDATE COMPLETED SUCCESSFULLY ===');
      return true;
    } catch (e) {
      print('❌ Error updating challenge goal: $e');
      return false;
    }
  }
}
