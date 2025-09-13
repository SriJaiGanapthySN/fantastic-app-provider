import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fantastic_app_riverpod/models/skill.dart';

class ChallengesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all challenges from the skillTrack collection
  Future<List<Map<String, dynamic>>> fetchChallenges() async {
    try {
      // Fetch documents from the 'skillTrack' collection where type contains 'challenge'
      final querySnapshot = await _firestore
          .collection('Parent-skillTrack')
          .where('type', isGreaterThanOrEqualTo: 'FREE_CHALLENGE')
          // Efficient string prefix query
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
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
        } else {}
      } else {}
    } catch (e) {}
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
      } else {}
    } catch (e) {}
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
        return [];
      }

      final List<Skill> skills = querySnapshot.docs
          .map((doc) => Skill.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Sort skills by position
      skills.sort((a, b) => a.position.compareTo(b.position));
      return skills;
    } catch (e) {
      return [];
    }
  }

  // Add skills for a challenge
  Future<List<Skill>> addChallengeSkills(
      String challengeId, String email) async {
    try {
      // Reference to the 'skill' collection
      final skillCollection = _firestore.collection('Parent-skill');

      // Query to fetch skills associated with this challenge
      final querySnapshot = await skillCollection
          .where('skillTrackId', isEqualTo: challengeId)
          .get();

      if (querySnapshot.docs.isEmpty) {
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

      return skills;
    } catch (e) {
      return [];
    }
  }

  // Get total number of skill levels for a skill
  Future<int> getTotalSkillLevels(String skillId) async {
    try {
      var querySnapshot = await _firestore
          .collection('Parent-skillLevel')
          .where('skillId', isEqualTo: skillId)
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // Add skill levels for a challenge
  Future<List<String>> addChallengeSkillLevels(
      List<Skill> skills, String email) async {
    try {
      final List<String> goals = [];
      final skillLevelCollection = _firestore.collection('Parent-skillLevel');
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

      return goals;
    } catch (e) {
      return [];
    }
  }

  // Add skill goals for a challenge
  Future<void> addChallengeGoals(List<String> goalIds, String email) async {
    try {
      final userSkillGoalPath =
          _firestore.collection('testers').doc(email).collection('skillGoal');
      final skillGoalCollection = _firestore.collection('Parent-skillGoal');

      // Reference to user's skillLevel collection to find related data
      final userSkillLevelPath =
          _firestore.collection('testers').doc(email).collection('skillLevel');

      int addedCount = 0;

      for (String goalId in goalIds) {
        final docSnapshot = await skillGoalCollection.doc(goalId).get();

        if (docSnapshot.exists) {
          final goalData = docSnapshot.data() as Map<String, dynamic>;

          // Find the corresponding skillLevel document that has this goalId
          final skillLevelQuery =
              await userSkillLevelPath.where('goalId', isEqualTo: goalId).get();

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
          } else {}

          await userSkillGoalPath.doc(goalId).set(updatedGoalData);
          addedCount++;
        } else {}
      }
    } catch (e) {}
  }

  // Update completion status for a challenge skill level
  Future<bool> updateChallengeSkillLevel(String userEmail, String skillLevelId,
      String skillId, String challengeId) async {
    try {
      // Check if already completed to avoid duplicate updates
      final skillLevelDoc = await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillLevel')
          .doc(skillLevelId)
          .get();

      if (!skillLevelDoc.exists) {
        return false;
      }

      final isAlreadyCompleted =
          skillLevelDoc.data()?['isCompleted'] as bool? ?? false;

      if (isAlreadyCompleted) {
        return true;
      }

      // 1. Update the skill level document IMMEDIATELY
      await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillLevel')
          .doc(skillLevelId)
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

      // 3. Update challenge completion count IMMEDIATELY
      final challengeDoc = await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillTrack')
          .doc(challengeId)
          .get();

      if (challengeDoc.exists) {
        final currentCount =
            (challengeDoc.data()?['levelsCompleted'] as num?)?.toInt() ?? 0;
        await _firestore
            .collection('testers')
            .doc(userEmail)
            .collection('skillTrack')
            .doc(challengeId)
            .update({'levelsCompleted': currentCount + 1});
      } else {}

      // 4. Log interaction
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

      return true;
    } catch (e) {
      return false;
    }
  }

  // Update completion status for a challenge goal
  Future<bool> updateChallengeGoal(String userEmail, String goalId,
      String skillLevelId, String skillId, String challengeId) async {
    try {
      // Check if goal already completed to avoid duplicate updates
      final goalDoc = await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillGoal')
          .doc(goalId)
          .get();

      if (!goalDoc.exists) {
        return false;
      }

      final isGoalCompleted = goalDoc.data()?['isCompleted'] as bool? ?? false;

      if (isGoalCompleted) {
        return true;
      }

      // 1. Update the goal document IMMEDIATELY
      await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillGoal')
          .doc(goalId)
          .update({'isCompleted': true});

      // 2. Update the associated skill level IMMEDIATELY
      final skillLevelDoc = await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillLevel')
          .doc(skillLevelId)
          .get();

      if (skillLevelDoc.exists) {
        final isLevelCompleted =
            skillLevelDoc.data()?['isCompleted'] as bool? ?? false;

        if (!isLevelCompleted) {
          await _firestore
              .collection('testers')
              .doc(userEmail)
              .collection('skillLevel')
              .doc(skillLevelId)
              .update({'isCompleted': true});
        } else {}
      } else {}

      // 3. Update skill completion count IMMEDIATELY
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

      // 4. Update challenge completion count IMMEDIATELY
      final challengeDoc = await _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillTrack')
          .doc(challengeId)
          .get();

      if (challengeDoc.exists) {
        final currentCount =
            (challengeDoc.data()?['levelsCompleted'] as num?)?.toInt() ?? 0;
        await _firestore
            .collection('testers')
            .doc(userEmail)
            .collection('skillTrack')
            .doc(challengeId)
            .update({'levelsCompleted': currentCount + 1});
      } else {}

      // 5. Log interaction
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

      return true;
    } catch (e) {
      return false;
    }
  }
}
