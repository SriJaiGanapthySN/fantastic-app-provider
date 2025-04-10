import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fantastic_app_riverpod/models/skill.dart';
import 'package:fantastic_app_riverpod/models/skillTrack.dart';

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

  // Future<void> addSkillTrack(String id, String email) async {
  //   try {
  //     // Reference to the document path '/skillGoal/{id}'
  //     final skillDocRef = _firestore.collection('skillTrack').doc(id);
  //     await skillDocRef.update({'isReleased': false});
  //     // Fetch the document snapshot
  //     final docSnapshot = await skillDocRef.get();

  //     // Check if the document exists
  //     if (docSnapshot.exists) {
  //       // Get the document data
  //       final skillData = docSnapshot.data() as Map<String, dynamic>;

  //       // Reference to the target path '/testers/{email}/skillGoal/{id}'
  //       final userSkillLevelPath = _firestore
  //           .collection('testers')
  //           .doc(email)
  //           .collection('skillTrack');

  //       // Add the document data to the target path
  //       await userSkillLevelPath.doc(id).set(skillData);

  //       print('Document $id added to /testers/$email/skillTrack');
  //     } else {
  //       print('Document with id $id does not exist in /skillTrack.');
  //     }
  //   } catch (e) {
  //     print('Error fetching and adding skills: $e');
  //   }
  // }

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

  Future<bool> updateGoalCompletion(String userEmail, String id,
      String skillLevelId, String skillId, String skillTrackId) async {
    try {
      // Perform the Firestore update for the specific user email and skill level ID
      await FirebaseFirestore.instance
          .collection('testers')
          .doc(userEmail)
          .collection('skillGoal')
          .doc(id) // Assuming 'id' is the document ID for the skill level
          .update({'isCompleted': true});

      await FirebaseFirestore.instance
          .collection('testers')
          .doc(userEmail)
          .collection('skillLevel')
          .doc(
              skillLevelId) // Assuming 'id' is the document ID for the skill level
          .update({'isCompleted': true});

      await FirebaseFirestore.instance
          .collection('testers')
          .doc(userEmail)
          .collection('skill')
          .doc(skillId) // Assuming 'skillId' is the document ID for the skill
          .update({'skillLevelCompleted': FieldValue.increment(1)});

      await FirebaseFirestore.instance
          .collection('testers')
          .doc(userEmail)
          .collection('skillTrack')
          .doc(
              skillTrackId) // Assuming 'skillId' is the document ID for the skill
          .update({'levelsCompleted': FieldValue.increment(1)});

      return true;
    } catch (e) {
      print("Error updating task: $e");
      return false;
    }
  }

  Future<bool> updateOneTime(bool isAdded, String id, String userEmail,
      String skillId, String skillTrackId) async {
    try {
      // Perform the Firestore update for the specific user email and skill level ID
      await FirebaseFirestore.instance
          .collection('testers')
          .doc(userEmail)
          .collection('skillLevel')
          .doc(id) // Assuming 'id' is the document ID for the skill level
          .update({'isCompleted': true});

      await FirebaseFirestore.instance
          .collection('testers')
          .doc(userEmail)
          .collection('skill')
          .doc(skillId) // Assuming 'skillId' is the document ID for the skill
          .update({'skillLevelCompleted': FieldValue.increment(1)});

      await FirebaseFirestore.instance
          .collection('testers')
          .doc(userEmail)
          .collection('skillTrack')
          .doc(
              skillTrackId) // Assuming 'skillId' is the document ID for the skill
          .update({'levelsCompleted': FieldValue.increment(1)});

      return true;
    } catch (e) {
      print("Error updating task: $e");
      return false;
    }
  }

  Future<bool> updateGoal(int rate, String userEmail, String id) async {
    try {
      // Perform the Firestore update for the specific user email and skill level ID
      print(id);
      await FirebaseFirestore.instance
          .collection('testers')
          .doc(userEmail)
          .collection('skillGoal')
          .doc(id) // Assuming 'id' is the document ID for the skill level
          .update({'completionRateGoal': rate});

      return true;
    } catch (e) {
      print("Error updating task: $e");
      return false;
    }
  }

  Future<bool> updateMotivator(bool isAdded, String id, String userEmail,
      String skillId, String skillTrackId) async {
    try {
      // Perform the Firestore update for the specific user email and skill level ID

      final skillLevelDoc = await FirebaseFirestore.instance
          .collection('testers')
          .doc(userEmail)
          .collection('skillLevel')
          .doc(id) // Assuming 'id' is the document ID for the skill level
          .get();

// Check if the document exists and `isCompleted` is false
      if (skillLevelDoc.exists &&
          !(skillLevelDoc.data()?['isCompleted'] ?? true)) {
        // Update 'isCompleted' to true
        await FirebaseFirestore.instance
            .collection('testers')
            .doc(userEmail)
            .collection('skillLevel')
            .doc(id)
            .update({'isCompleted': true});

        // Increment 'skillLevelCompleted' in the skill document
        await FirebaseFirestore.instance
            .collection('testers')
            .doc(userEmail)
            .collection('skill')
            .doc(skillId) // Assuming 'skillId' is the document ID for the skill
            .update({'skillLevelCompleted': FieldValue.increment(1)});

        await FirebaseFirestore.instance
            .collection('testers')
            .doc(userEmail)
            .collection('skillTrack')
            .doc(
                skillTrackId) // Assuming 'skillId' is the document ID for the skill
            .update({'levelsCompleted': FieldValue.increment(1)});
      } else {
        print("Skill level is already completed or does not exist.");
      }

      return true;
    } catch (e) {
      print("Error updating task: $e");
      return false;
    }
  }
}
