import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../States/StateNotifiers.dart';
import 'finalScreen.dart';

class OnBoard36 extends ConsumerStatefulWidget {
  const OnBoard36({Key? key}) : super(key: key);

  @override
  _OnBoard36State createState() => _OnBoard36State();
}

class _OnBoard36State extends ConsumerState<OnBoard36> {
  File? _image;
  bool _isImageSelected = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _selectImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select an option'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                final pickedFile = await _picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (pickedFile != null) {
                  setState(() {
                    _image = File(pickedFile.path);
                    _isImageSelected = true;
                  });

                  // Save the image to the file
                  final imagePath = await ref.read(selectedSleepProvider.notifier).saveImageToFile(pickedFile);
                  debugPrint('Image saved at: $imagePath');
                }
                Navigator.pop(context);
              },
              child: Text('Choose Photo'),
            ),
            TextButton(
              onPressed: () async {
                final pickedFile = await _picker.pickImage(
                  source: ImageSource.camera,
                );
                if (pickedFile != null) {
                  setState(() {
                    _image = File(pickedFile.path);
                    _isImageSelected = true;
                  });

                  // Save the image to the file
                  final imagePath = await ref.read(selectedSleepProvider.notifier).saveImageToFile(pickedFile);
                  debugPrint('Image saved at: $imagePath');
                }
                Navigator.pop(context);
              },
              child: Text('Take Photo'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Show us your best pic!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30),
            DottedBorder(
              color: Colors.white,
              strokeWidth: 2,
              borderType: BorderType.RRect,
              radius: Radius.circular(12),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: GestureDetector(
                    onTap: _selectImage,
                    child: _image == null
                        ? Icon(Icons.add_a_photo, color: Colors.white, size: 40)
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _image!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isImageSelected
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OnboardingCompletedScreen(),
                  ),
                );
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Done',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
