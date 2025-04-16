import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

class SelectedSleepNotifier extends StateNotifier<List<String>> {
  SelectedSleepNotifier() : super([]);

  // Separate list for personal details
  final List<String> _personalDetails = [];

  // Existing method
  void select(String value) {
    state = [...state, value];
    debugPrint('Selected list: $state');
  }

  void clear() {
    state = [];
  }

  void addItem(String value) {
    if (!state.contains(value)) {
      state = [...state, value];
    }
  }

  void removeItem(String value) {
    state = state.where((element) => element != value).toList();
  }

  bool isSelected(String value) {
    return state.contains(value);
  }

  // ✅ Method to add personal details
  void addPersonalDetails(String value) {
    _personalDetails.add(value);
    debugPrint('Personal Detail Added: $value');
    debugPrint('Current Personal Details List: $_personalDetails');
  }

  // ✅ NEW: Method to remove personal details
  void removePersonalDetails(String value) {
    _personalDetails.remove(value);
    debugPrint('Personal Detail Removed: $value');
    debugPrint('Current Personal Details List: $_personalDetails');
  }

  // Getter for personal details list
  List<String> get personalDetails => _personalDetails;

  // ✅ NEW: Method to save image to a file
  Future<String> saveImageToFile(XFile image) async {
    // Get the app's document directory
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;

    // Create a new file path
    final imageFile = File('$path/${DateTime.now().millisecondsSinceEpoch}.jpg');

    // Write the image to the file
    await imageFile.writeAsBytes(await image.readAsBytes());

    // Return the file path
    return imageFile.path;
  }
}

final selectedSleepProvider =
StateNotifierProvider<SelectedSleepNotifier, List<String>>((ref) {
  return SelectedSleepNotifier();
});
