import 'package:cloud_firestore/cloud_firestore.dart';

class CoachingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getMainCoachings() async {
    try {
      // One-time fetch of documents where hidden == false
      QuerySnapshot snapshot = await _firestore
          .collection('coachingSeries')
          .where('hidden', isEqualTo: false)
          .get();

      // Convert the snapshot to a List of Maps
      List<Map<String, dynamic>> mainCoachings = [];
      for (var doc in snapshot.docs) {
        mainCoachings.add(doc.data() as Map<String, dynamic>);
      }

      // Sort the list by the 'position' field
      mainCoachings.sort((a, b) {
        // Assuming 'position' is a numeric field
        return (a['position'] as int).compareTo(b['position'] as int);
      });

      return mainCoachings;
    } catch (e) {
      print('Error fetching habits: $e');
      return []; // Returning an empty list in case of an error
    }
  }

  Future<List<Map<String, dynamic>>> getCoachings(String id) async {
    try {
      // One-time fetch of documents where hidden == false
      QuerySnapshot snapshot = await _firestore
          .collection('coachingSeriesEntry')
          .where('coachingSeriesId', isEqualTo: id)
          .get();

      // Convert the snapshot to a List of Maps
      List<Map<String, dynamic>> Coachings = [];
      for (var doc in snapshot.docs) {
        Coachings.add(doc.data() as Map<String, dynamic>);
      }

      // Sort the list by the 'position' field
      Coachings.sort((a, b) {
        // Assuming 'position' is a numeric field
        return (a['position'] as int).compareTo(b['position'] as int);
      });

      return Coachings;
    } catch (e) {
      print('Error fetching habits: $e');
      return []; // Returning an empty list in case of an error
    }
  }

  Future<Map<String, dynamic>> getHabitCoaching(
      String type, int dayOfWeek) async {
    try {
      // Fetch the documents where 'type' matches and 'dayOfWeek' matches
      print("___________________-");
      print(type);
      QuerySnapshot snapshot = await _firestore
          .collection('coaching')
          .where('type', isEqualTo: type)
          .where('dayOfWeek', isEqualTo: dayOfWeek)
          .get();

      // Convert the snapshot to a List of Maps
      List<Map<String, dynamic>> Coachings = [];
      for (var doc in snapshot.docs) {
        Coachings.add(doc.data() as Map<String, dynamic>);
      }
      print("HERE");
      print(Coachings);
      // Sort the list first by 'position' field, then by 'updated' field
      Coachings.sort((a, b) {
        // Compare by 'position' first
        int positionComparison =
            (a['position'] as int).compareTo(b['position'] as int);
        if (positionComparison != 0) {
          return positionComparison;
        }

        // If 'position' values are equal, compare by 'updated' field
        // DateTime aUpdated = DateTime.parse(a['updatedAt']);
        // DateTime bUpdated = DateTime.parse(b['updatedAt']);

        int aUpdated = (a['updatedAt']
            as int); // Assuming 'updatedAt' is a timestamp stored as an integer (milliseconds)
        int bUpdated = (b['updatedAt'] as int); // Same assumption
        return aUpdated.compareTo(bUpdated);
      });

      // Check if there's any coaching entry
      if (Coachings.isNotEmpty) {
        // Update the 'updated' field of the first coaching entry with the current time
        Coachings.first['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

        // Update the corresponding document in Firestore with the new 'updated' field
        await _firestore
            .collection('coaching')
            .doc(snapshot.docs[0]
                .id) // Assuming the first document corresponds to the coaching entry
            .update({
          'updatedAt': Coachings.first[
              'updatedAt'], // Set the 'updated' field to the current time
        });

        // Return the first coaching entry
        print(Coachings.first);
        return Coachings.first;
      } else {
        return {}; // Returning an empty map if no data
      }
    } catch (e) {
      print('Error fetching and updating habit: $e');
      return {}; // Returning an empty map in case of an error
    }
  }
}
