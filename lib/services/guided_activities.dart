import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fantastic_app_riverpod/models/skill.dart';
import 'package:fantastic_app_riverpod/models/skillTrack.dart' show skillTrack;

class GuidedActivities {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      // Fetch documents sorted by the 'position' field in ascending order
      final querySnapshot = await _firestore
          .collection('trainingCategory')
          .orderBy('position') // Ascending order (default)
          .get();

      // Convert documents to a List of Maps
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching categories: $e');
      return []; // Return an empty list in case of error
    }
  }

  Future<List<Map<String, dynamic>>> fetchTrainings(List<String> ids) async {
    try {
      // Check if the ID list is empty to avoid unnecessary queries
      if (ids.isEmpty) return [];

      // Firestore 'whereIn' supports up to 10 items per query
      List<Map<String, dynamic>> allResults = [];

      // Split the IDs list into batches of 10 (Firestore limit)
      for (int i = 0; i < ids.length; i += 10) {
        // Create a batch of up to 10 IDs
        final batchIds =
            ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10);

        // Fetch documents where the document ID is in the batch
        final querySnapshot = await _firestore
            .collection('training')
            .where(FieldPath.documentId, whereIn: batchIds)
            .get();

        // Add fetched data to the overall results list
        allResults.addAll(querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());
      }

      // Sort all fetched documents by the 'position' field
      allResults.sort((a, b) {
        int posA = a['position'] ?? 0;
        int posB = b['position'] ?? 0;
        return posA.compareTo(posB); // Ascending order
      });

      return allResults;
    } catch (e) {
      print('Error fetching trainings: $e');
      return []; // Return an empty list in case of error
    }
  }

  Future<List<Map<String, dynamic>>> fetchSteps(String id) async {
    if (id.isEmpty) {
      return []; // Return empty list if ID is invalid
    }

    try {
      // Fetch steps related to the given training ID, ordered by 'position'
      final querySnapshot = await _firestore
          .collection("trainingStep")
          .where("trainingId", isEqualTo: id)
          .get();

      // Convert documents to a List of Maps
      List<Map<String, dynamic>> data = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // No need to sort again, but if required:
      data.sort((a, b) {
        int posA = a['position'] ?? 0;
        int posB = b['position'] ?? 0;
        return posA.compareTo(posB); // Ascending order
      });

      return data;
    } catch (e) {
      print("Error fetching steps: $e");
      return []; // Return an empty list in case of error
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
      final querySnapshot = await collectionRef
          .where('isReleased', isEqualTo: false)
          .limit(1)
          .get();

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

  Future<void> updateIsReleased(String email, String docId) async {
    try {
      final docRef = _firestore
          .collection('testers')
          .doc(email)
          .collection('skillTrack')
          .doc(docId);

      await docRef.update({'isReleased': true});
      print('Document $docId updated to isReleased: true');
    } catch (e) {
      print('Error updating isReleased: $e');
    }
  }

  Future<void> addSkillTrack(String id, String email) async {
    try {
      // Reference to the document path '/skillGoal/{id}'
      final skillDocRef = _firestore.collection('skillTrack').doc(id);
      await skillDocRef.update({'isReleased': false});
      // Fetch the document snapshot
      final docSnapshot = await skillDocRef.get();

      // Check if the document exists
      if (docSnapshot.exists) {
        // Get the document data
        final skillData = docSnapshot.data() as Map<String, dynamic>;

        // Reference to the target path '/testers/{email}/skillGoal/{id}'
        final userSkillLevelPath = _firestore
            .collection('testers')
            .doc(email)
            .collection('skillTrack');

        // Add the document data to the target path
        await userSkillLevelPath.doc(id).set(skillData);

        print('Document $id added to /testers/$email/skillTrack');
      } else {
        print('Document with id $id does not exist in /skillTrack.');
      }
    } catch (e) {
      print('Error fetching and adding skills: $e');
    }
  }

// Future<List<Skill>> addSkills(String skillTrackId, String email) async {
//   try {
//     // Reference to the 'skill' collection
//     final skillCollection = _firestore.collection('skill');

//     // Query to fetch documents where skillTrackId matches
//     final querySnapshot = await skillCollection
//         .where('skillTrackId', isEqualTo: skillTrackId)
//         .get();

//     // Check if documents are found
//     if (querySnapshot.docs.isEmpty) {
//       print('No skills found for skillTrackId: $skillTrackId');
//       return [];
//     }

//     // Map the documents into a list of Skill objects
//     final List<Skill> skills = querySnapshot.docs
//         .map((doc) => Skill.fromMap(doc.data() as Map<String, dynamic>))
//         .toList();

//     // Reference to the target path: /testers/{email}/skill
//     final userSkillPath = _firestore.collection('testers').doc(email).collection('skill');

//     // Check if the 'skill' collection already exists for the user
//     final userSkillsSnapshot = await userSkillPath.get();
//     if (userSkillsSnapshot.docs.isEmpty) {
//       // If no skills exist, print a message (optional)
//       print('Skill collection for $email does not exist. Creating now.');
//     }

//     // Add each skill to the specified path
//     for (var skill in skills) {
//       // Add the skill to the user's skill collection
//       await userSkillPath.doc(skill.objectId).set(skill.toMap());
//     }

//     print('${skills.length} skills added to /testers/$email/skill');
//     return skills;
//   } catch (e) {
//     print('Error fetching and adding skills: $e');
//     return [];
//   }
// }

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
        // Convert skill to a map and add 'isComplete': false
        final skillData = {
          ...skill.toMap(), // Existing skill data
          'isCompleted': false, // New field
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
      // Reference to the target path: /testers/{email}/skillGoal
      final userSkillGoalPath =
          _firestore.collection('testers').doc(email).collection('skillGoal');

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
          final updatedSkillData = {
            ...skillData, // Existing data
            'isCompleted': false, // New field
          };

          // Add the document data to the user's skillGoal collection
          await userSkillGoalPath.doc(id).set(updatedSkillData);

          print('Document $id added to /testers/$email/skillGoal');
        } else {
          print('Document with id $id does not exist in /skillGoal.');
        }
      }

      print('All provided skill goals have been added successfully.');
    } catch (e) {
      print('Error fetching and adding skill goals: $e');
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

  Future<bool> updateGoalCompletion(
      String userEmail, String id, String skillLevelId) async {
    try {
      // Create a batch write to ensure all updates are atomic
      final batch = _firestore.batch();
      
      // Get the goal document first to check if it's already completed
      final goalRef = _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillGoal')
          .doc(id);
      final goalDoc = await goalRef.get();
      
      if (!goalDoc.exists) {
        print("Goal document does not exist");
        return false;
      }
      
      if (goalDoc.data()?['isCompleted'] == true) {
        print("Goal is already completed");
        return true;
      }

      // Get the skill level document to find associated skill and skill track IDs
      final skillLevelRef = _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillLevel')
          .doc(skillLevelId);
      final skillLevelDoc = await skillLevelRef.get();
      
      if (!skillLevelDoc.exists) {
        print("Skill level document does not exist");
        return false;
      }

      // Only update goal if it's not completed
      batch.update(goalRef, {'isCompleted': true});

      // Only update skill level if it's not completed
      if (skillLevelDoc.data()?['isCompleted'] != true) {
        batch.update(skillLevelRef, {'isCompleted': true});

        final skillLevelData = skillLevelDoc.data() as Map<String, dynamic>;
        final skillId = skillLevelData['skillId'];
        final skillTrackId = skillLevelData['skillTrackId'];

        if (skillId != null) {
          // Get the skill document to check current completion count
          final skillRef = _firestore
              .collection('testers')
              .doc(userEmail)
              .collection('skill')
              .doc(skillId);
          final skillDoc = await skillRef.get();
          
          if (skillDoc.exists) {
            final currentCount = skillDoc.data()?['skillLevelCompleted'] ?? 0;
            batch.update(skillRef, {'skillLevelCompleted': currentCount + 1});
          }
        }

        if (skillTrackId != null) {
          // Get the skill track document to check current completion count
          final skillTrackRef = _firestore
              .collection('testers')
              .doc(userEmail)
              .collection('skillTrack')
              .doc(skillTrackId);
          final skillTrackDoc = await skillTrackRef.get();
          
          if (skillTrackDoc.exists) {
            final currentCount = skillTrackDoc.data()?['levelsCompleted'] ?? 0;
            batch.update(skillTrackRef, {'levelsCompleted': currentCount + 1});
          }
        }
      }

      // Commit all updates
      await batch.commit();
      return true;
    } catch (e) {
      print("Error updating task: $e");
      return false;
    }
  }

  Future<bool> updateOneTime(bool isAdded, String id, String userEmail) async {
    try {
      // Create a batch write to ensure all updates are atomic
      final batch = _firestore.batch();
      
      // Get the skill level document first to check if it's already completed
      final skillLevelRef = _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillLevel')
          .doc(id);
      final skillLevelDoc = await skillLevelRef.get();
      
      if (!skillLevelDoc.exists) {
        print("Skill level document does not exist");
        return false;
      }

      if (skillLevelDoc.data()?['isCompleted'] == true) {
        print("Skill level is already completed");
        return true;
      }

      // Only update skill level if it's not completed
      batch.update(skillLevelRef, {'isCompleted': true});

      final skillLevelData = skillLevelDoc.data() as Map<String, dynamic>;
      final skillId = skillLevelData['skillId'];
      final skillTrackId = skillLevelData['skillTrackId'];

      if (skillId != null) {
        // Get the skill document to check current completion count
        final skillRef = _firestore
            .collection('testers')
            .doc(userEmail)
            .collection('skill')
            .doc(skillId);
        final skillDoc = await skillRef.get();
        
        if (skillDoc.exists) {
          final currentCount = skillDoc.data()?['skillLevelCompleted'] ?? 0;
          batch.update(skillRef, {'skillLevelCompleted': currentCount + 1});
        }
      }

      if (skillTrackId != null) {
        // Get the skill track document to check current completion count
        final skillTrackRef = _firestore
            .collection('testers')
            .doc(userEmail)
            .collection('skillTrack')
            .doc(skillTrackId);
        final skillTrackDoc = await skillTrackRef.get();
        
        if (skillTrackDoc.exists) {
          final currentCount = skillTrackDoc.data()?['levelsCompleted'] ?? 0;
          batch.update(skillTrackRef, {'levelsCompleted': currentCount + 1});
        }
      }

      // Commit all updates
      await batch.commit();
      return true;
    } catch (e) {
      print("Error updating task: $e");
      return false;
    }
  }

  Future<bool> updateMotivator(
      bool isAdded, String id, String userEmail) async {
    try {
      // Create a batch write to ensure all updates are atomic
      final batch = _firestore.batch();

      // Get the skill level document first to check if it's already completed
      final skillLevelRef = _firestore
          .collection('testers')
          .doc(userEmail)
          .collection('skillLevel')
          .doc(id);
      final skillLevelDoc = await skillLevelRef.get();
      
      if (!skillLevelDoc.exists) {
        print("Skill level document does not exist");
        return false;
      }

      if (skillLevelDoc.data()?['isCompleted'] == true) {
        print("Skill level is already completed");
        return true;
      }

      // Only update skill level if it's not completed
      batch.update(skillLevelRef, {'isCompleted': true});

      final skillLevelData = skillLevelDoc.data() as Map<String, dynamic>;
      final skillId = skillLevelData['skillId'];
      final skillTrackId = skillLevelData['skillTrackId'];

      if (skillId != null) {
        // Get the skill document to check current completion count
        final skillRef = _firestore
            .collection('testers')
            .doc(userEmail)
            .collection('skill')
            .doc(skillId);
        final skillDoc = await skillRef.get();
        
        if (skillDoc.exists) {
          final currentCount = skillDoc.data()?['skillLevelCompleted'] ?? 0;
          batch.update(skillRef, {'skillLevelCompleted': currentCount + 1});
        }
      }

      if (skillTrackId != null) {
        // Get the skill track document to check current completion count
        final skillTrackRef = _firestore
            .collection('testers')
            .doc(userEmail)
            .collection('skillTrack')
            .doc(skillTrackId);
        final skillTrackDoc = await skillTrackRef.get();
        
        if (skillTrackDoc.exists) {
          final currentCount = skillTrackDoc.data()?['levelsCompleted'] ?? 0;
          batch.update(skillTrackRef, {'levelsCompleted': currentCount + 1});
        }
      }

      // Commit all updates
      await batch.commit();
      return true;
    } catch (e) {
      print("Error updating task: $e");
      return false;
    }
  }
}
