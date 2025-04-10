import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:async';

import 'package:fantastic_app_riverpod/models/addCoaching.dart';
import 'package:fantastic_app_riverpod/models/task.dart';

class TaskServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getTasks() {
    return _firestore.collection('predefinedTasks').snapshots();
  }

//   Future <List<Map<String, dynamic>?>> getHabits() async {
//   try {
//     // One-time fetch of documents where isHidden == false
//     QuerySnapshot snapshot = await _firestore
//         .collection('habits')
//         .where('isHidden', isEqualTo: false)
//         .get();

//     // Convert the snapshot to a Map
//     Map<String, dynamic> habits = {};
//     for (var doc in snapshot.docs) {
//       habits[doc.id] = doc.data();
//     }

//     return habits;
//   } catch (e) {
//     print('Error fetching habits: $e');
//     return null;
//   }
// }

  Future<List<Map<String, dynamic>>> getHabits() async {
    try {
      // One-time fetch of documents where isHidden == false
      QuerySnapshot snapshot = await _firestore
          .collection('habits')
          .where('isHidden', isEqualTo: false)
          .get();

      // Convert the snapshot to a List of Maps
      List<Map<String, dynamic>> habits = [];
      for (var doc in snapshot.docs) {
        habits.add(doc.data() as Map<String, dynamic>);
      }

      return habits;
    } catch (e) {
      print('Error fetching habits: $e');
      return []; // Returning an empty list in case of an error
    }
  }

  // Stream<QuerySnapshot> getUserHabits(String email) {
  //   return _firestore.collection('testers').doc(email).collection('habits').snapshots();
  // }

  Future<List<Map<String, dynamic>>> getUserHabits(String email) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('testers')
          .doc(email)
          .collection('habits')
          .get();

      // Convert the snapshot to a List of Maps
      List<Map<String, dynamic>> habits = [];
      for (var doc in snapshot.docs) {
        habits.add(doc.data() as Map<String, dynamic>);
      }

      return habits;
    } catch (e) {
      print('Error fetching user habits: $e');
      return []; // Return an empty list in case of an error
    }
  }

  Future<void> addHabits(String email, String id) async {
    try {
      // Reference to the document path '/skillGoal/{id}'
      final skillDocRef = _firestore.collection('habits').doc(id);
      // await skillDocRef.update({'isReleased': false});
      // Fetch the document snapshot
      final docSnapshot = await skillDocRef.get();

      // Check if the document exists
      if (docSnapshot.exists) {
        // Get the document data
        final skillData = docSnapshot.data() as Map<String, dynamic>;

        // Reference to the target path '/testers/{email}/skillGoal/{id}'
        final userSkillLevelPath =
            _firestore.collection('testers').doc(email).collection('habits');

        // Add the document data to the target path

        final updatedSkillData = {
          ...skillData,
          'isCompleted': false,
        };
        await userSkillLevelPath.doc(id).set(updatedSkillData);

        print('Document $id added to /testers/$email/habit');
      } else {
        print('Document with id $id does not exist in /habit.');
      }
    } catch (e) {
      print('Error fetching and adding skills: $e');
    }
  }

  Future<void> removeHabit(String id, String userEmail) async {
    await _firestore
        .collection('testers')
        .doc(userEmail)
        .collection('habits')
        .where('objectId', isEqualTo: id)
        .get()
        .then((value) {
      for (var element in value.docs) {
        element.reference.delete();
      }
    });
  }

  Future<void> updateHabitStatus(
      bool iscompleted, String id, String userEmail) async {
    await FirebaseFirestore.instance
        .collection('testers')
        .doc(userEmail)
        .collection('habits')
        .where('objectId', isEqualTo: id)
        .get()
        .then((value) {
      for (var element in value.docs) {
        element.reference.update({'isCompleted': iscompleted});
      }
    });
  }

  Stream<List<DocumentSnapshot>> getAddTasks(String userEmail) async* {
    print(userEmail);
    // Fetch tester tasks stream
    var testerTasksStream = _firestore
        .collection('testers')
        .doc(userEmail)
        .collection('tasks')
        .snapshots();

    // Fetch predefined tasks stream
    var predefinedTasksStream =
        _firestore.collection('predefinedTasks').snapshots();

    // Listen to the streams
    await for (var testerSnapshot in testerTasksStream) {
      // Get predefined tasks when tester tasks data is available
      var predefinedSnapshot = await predefinedTasksStream.first;

      // Create lists to store tasks
      List<DocumentSnapshot> combinedTasks = [];
      List<DocumentSnapshot> testerTasks = testerSnapshot.docs;
      List<DocumentSnapshot> predefinedTasks = predefinedSnapshot.docs;

      // Add all tester tasks to the combined list
      combinedTasks.addAll(testerTasks);
      print(combinedTasks);
      print(testerTasks);
      print(predefinedTasks);
      // Filter out predefined tasks that are already in tester tasks based on objectID
      for (var predefinedTask in predefinedTasks) {
        print(predefinedTask['objectID']);
        print(predefinedTask['isdailyroutine']);
        if (!testerTasks
            .any((task) => task['objectID'] == predefinedTask['objectID'])) {
          print("IN");
          print(predefinedTask['objectID']);
          print(predefinedTask['isdailyroutine']);
          combinedTasks.add(predefinedTask);
        }
        print("OUT");
      }

      print("Combined Tasks:");
      combinedTasks.forEach((task) {
        print(task['objectID']); // Print objectID of combined tasks
        print(task['isdailyroutine']);
      });

      // Yield the combined list of tasks as a stream
      yield combinedTasks;
    }
  }

  Future<void> addTask(
      String userEmail,
      String name,
      String descriptionHtml,
      String objectID,
      String animationLink,
      String audioLink,
      String backgroundLink,
      String iconLink,
      bool isdailyroutine,
      bool iscompleted,
      String category) async {
    Task newtask = Task(
        name: name,
        descriptionHtml: descriptionHtml,
        objectID: objectID,
        animationLink: animationLink,
        audioLink: audioLink,
        backgroundLink: backgroundLink,
        iconLink: iconLink,
        isdailyroutine: isdailyroutine,
        iscompleted: iscompleted,
        category: category);

    await _firestore
        .collection('testers')
        .doc(userEmail)
        .collection('tasks')
        .add(newtask.toMap());
  }

  Future<void> addCoaching(
    String userEmail,
    QueryDocumentSnapshot document,
  ) async {
    // Parse the document data into a CoachingDetail object
    CoachingDetail newTask =
        CoachingDetail.fromMap(document.data() as Map<String, dynamic>);
    newTask.isDailyRoutine = true;

    // Add the task to the Firestore collection
    await _firestore
        .collection('testers')
        .doc(userEmail)
        .collection('tasks')
        .add(newTask.toMap());
    print("_______HERE_______");
  }

  Future<void> deleteTask(String id, String userEmail) async {
    await _firestore
        .collection('testers')
        .doc(userEmail)
        .collection('tasks')
        .where('objectID', isEqualTo: id)
        .get()
        .then((value) {
      for (var element in value.docs) {
        element.reference.delete();
      }
    });
  }

  Future<bool> updateTasks(bool isadded, String id, String userEmail) async {
    await FirebaseFirestore.instance
        .collection('predefinedTasks')
        // .collection('testers').doc(userEmail).collection('tasks')
        .where('objectID', isEqualTo: id)
        .get()
        .then((value) {
      for (var element in value.docs) {
        element.reference.update({'isdailyroutine': isadded});
      }
    });
    return true;
  }

  Stream<QuerySnapshot> getdailyTasks(String userEmail) {
    return _firestore
        .collection('testers')
        .doc(userEmail)
        .collection('tasks')
        .snapshots();
  }

//   Stream<QuerySnapshot> getdailyTasks(String userEmail) {
//   return _firestore
//       .collection('testers')
//       .doc(userEmail)
//       .collection('tasks')
//       .where('taskPlaceholder', isNull: true) // Exclude docs with 'placeholder' field
//       .snapshots();
// }

  Future<void> updateTaskStatus(
      bool iscompleted, String id, String userEmail) async {
    await FirebaseFirestore.instance
        .collection('testers')
        .doc(userEmail)
        .collection('tasks')
        .where('objectID', isEqualTo: id)
        .get()
        .then((value) {
      for (var element in value.docs) {
        element.reference.update({'iscompleted': iscompleted});
      }
    });
  }

  Future<void> updateTaskNotes({
    required String id,
    required String mail,
    required String title,
    required String items,
    required String timestamp,
  }) async {
    // Reference to the collection where tasks are stored
    CollectionReference tasksCollection = FirebaseFirestore.instance
        .collection('testers')
        .doc(mail)
        .collection('tasks');

    // Query to find documents with a specific objectID
    QuerySnapshot querySnapshot =
        await tasksCollection.where('objectID', isEqualTo: id).get();

    if (querySnapshot.docs.isNotEmpty) {
      // Process the first document (assuming only one document with the given objectID)
      DocumentSnapshot docSnapshot = querySnapshot.docs.first;

      // Convert the string timestamp into Firestore Timestamp
      Timestamp firestoreTimestamp =
          Timestamp.fromDate(DateTime.parse(timestamp));

      // Cast the document data to a Map<String, dynamic>
      Map<String, dynamic> docData = docSnapshot.data() as Map<String, dynamic>;

      // Check if 'notes' exists; if so, update it, otherwise create it
      var notes = docData["notes"] ?? {};

      // Update the note
      notes = {
        'title': title,
        'items': items,
        'timestamp': firestoreTimestamp, // Store as Timestamp instead of String
      };

      // Update the document with the new 'notes' field
      await docSnapshot.reference.update({
        'notes': notes,
      });
    } else {
      // If document doesn't exist with the given objectID, create a new one
      Timestamp firestoreTimestamp =
          Timestamp.fromDate(DateTime.parse(timestamp));

      await tasksCollection.add({
        'objectID': id,
        'notes': {
          'title': title,
          'items': items,
          'timestamp':
              firestoreTimestamp, // Store as Timestamp instead of String
        },
      });
    }
  }

  Future<void> deleteTaskNote({
    required String taskID,
    required String mail,
  }) async {
    CollectionReference tasksCollection = FirebaseFirestore.instance
        .collection('testers')
        .doc(mail)
        .collection('tasks');

    // Query to find the task document by taskID
    QuerySnapshot querySnapshot =
        await tasksCollection.where('objectID', isEqualTo: taskID).get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot docSnapshot = querySnapshot.docs.first;

      // Remove the 'notes' field or set it to an empty map
      await docSnapshot.reference.update({
        'notes': {}, // Clear the notes
      });
    }
  }

  Future<int> getTotalUserTasks(String userEmail) async {
    var _querysnapshot = await _firestore
        .collection('testers')
        .doc(userEmail)
        .collection('tasks')
        .get();
    return _querysnapshot.docs.length;
  }

  Future<int> getTotalUserHabits(String userEmail) async {
    var _querysnapshot = await _firestore
        .collection('testers')
        .doc(userEmail)
        .collection('habits')
        .get();
    return _querysnapshot.docs.length;
  }
}
