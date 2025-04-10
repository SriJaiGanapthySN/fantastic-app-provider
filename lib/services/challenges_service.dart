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
      final userSkillGoalPath =
          _firestore.collection('testers').doc(email).collection('skillGoal');
      final skillGoalCollection = _firestore.collection('skillGoal');

      int addedCount = 0;

      for (String goalId in goalIds) {
        final docSnapshot = await skillGoalCollection.doc(goalId).get();

        if (docSnapshot.exists) {
          final goalData = docSnapshot.data() as Map<String, dynamic>;
          await userSkillGoalPath.doc(goalId).set({
            ...goalData,
            'isCompleted': false,
          });
          addedCount++;
        } else {
          print('Goal $goalId not found in skillGoal collection');
        }
      }

      print('Added $addedCount challenge goals for user $email');
    } catch (e) {
      print('Error adding challenge goals: $e');
    }
  }

  // Update completion status for a challenge skill level
  Future<bool> updateChallengeSkillLevel(String userEmail, String skillLevelId,
      String skillId, String challengeId) async {
    try {
      // Update the skill level document
      await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillLevel')
          .doc(skillLevelId)
          .update({'isCompleted': true});

      // Increment the completed levels counter in the skill document
      await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skill')
          .doc(skillId)
          .update({'skillLevelCompleted': FieldValue.increment(1)});

      // Increment the total completed levels in the challenge document
      await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillTrack')
          .doc(challengeId)
          .update({'levelsCompleted': FieldValue.increment(1)});

      return true;
    } catch (e) {
      print('Error updating challenge skill level: $e');
      return false;
    }
  }

  // Update completion status for a challenge goal
  Future<bool> updateChallengeGoal(String userEmail, String goalId,
      String skillLevelId, String skillId, String challengeId) async {
    try {
      // Update the goal document
      await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillGoal')
          .doc(goalId)
          .update({'isCompleted': true});

      // Update the associated skill level
      await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillLevel')
          .doc(skillLevelId)
          .update({'isCompleted': true});

      // Increment skill level completed count
      await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skill')
          .doc(skillId)
          .update({'skillLevelCompleted': FieldValue.increment(1)});

      // Increment challenge completed levels
      await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillTrack')
          .doc(challengeId)
          .update({'levelsCompleted': FieldValue.increment(1)});

      return true;
    } catch (e) {
      print('Error updating challenge goal: $e');
      return false;
    }
  }
}
