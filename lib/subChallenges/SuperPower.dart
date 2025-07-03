import 'package:fantastic_app_riverpod/subChallenges/MediatatingPage.dart';
import 'package:fantastic_app_riverpod/subChallenges/SuperPowerList.dart';
import 'package:flutter/material.dart';
import '../OnBoarding/Widgets/imageCard1.dart';

class SuperPowerScreen extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String objectId;
  const SuperPowerScreen({super.key, required this.imageUrl, required this.title, required this.objectId});

  @override
  _SuperPowerScreenState createState() => _SuperPowerScreenState();
}

class _SuperPowerScreenState extends State<SuperPowerScreen> {
  final List<Superpowerlist> itemList = habitList;
  final Set<String> selectedItems = {};

  void toggleSelection(String text) {
    setState(() {
      if (selectedItems.contains(text)) {
        selectedItems.remove(text);
      } else {
        selectedItems.add(text);
      }
    });
  }

  // --- DIALOG 1: The initial challenge popup, now fully generic. ---
  void _showSuperpowerDialog(BuildContext context, Superpowerlist item) {
    final Color dialogBackgroundColor = Color(int.parse(item.colorHex.replaceAll('#', '0xFF')));
    final Color nextButtonColor = Colors.white.withOpacity(0.3);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Container(
              color: dialogBackgroundColor, // DYNAMIC
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        Image.asset(
                          item.imageAdd, // DYNAMIC
                          height: 100,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.star_rounded, size: 100, color: Colors.white38),
                        ),
                        const SizedBox(height: 25.0),
                        Text(
                          item.text, // DYNAMIC
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.3),
                        ),
                        const SizedBox(height: 15.0),
                        Text(
                          item.Content, // DYNAMIC
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                        ),
                        const SizedBox(height: 30.0),
                        FloatingActionButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(); // Close this dialog...
                            _showSuperpowerDetailDialog(context, item); // ...and open the next one.
                          },
                          backgroundColor: nextButtonColor,
                          foregroundColor: Colors.white,
                          elevation: 2.0,
                          child: const Icon(Icons.arrow_forward), // Always a forward arrow
                        ),
                        const SizedBox(height: 10.0),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8, left: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      color: Colors.white70,
                      iconSize: 28,
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- DIALOG 2: The "how-to" popup, now fully generic. ---
  void _showSuperpowerDetailDialog(BuildContext context, Superpowerlist item) {
    const Color dialogBackgroundColor = Colors.white;
    const Color primaryTextColor = Color(0xFF333333);
    const Color secondaryTextColor = Color(0xFF555555);
    final Color primaryButtonColor = Color(int.parse(item.colorHex.replaceAll('#', '0xFF')));
    const Color secondaryButtonTextColor = Color(0xFF757575);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: dialogBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  item.popup2_title, // DYNAMIC
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: primaryTextColor, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                Text(
                  item.popup2_content, // DYNAMIC
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: secondaryTextColor, fontSize: 15.5, height: 1.4),
                ),
                const SizedBox(height: 24.0),
                Image.asset(
                  item.popup2_imageAdd, // DYNAMIC
                  height: 100,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.extension, size: 80, color: Colors.grey),
                ),
                const SizedBox(height: 28.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryButtonColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(item.popup2_primaryActionText), // DYNAMIC
                ),
                const SizedBox(height: 12.0),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    item.popup2_secondaryActionText, // DYNAMIC
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: secondaryButtonTextColor, fontSize: 13, fontWeight: FontWeight.w500, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 43, 42, 88),
      body: Column(
        children: [
          const SizedBox(height: 25,),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          const SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Pick Your Super Powers", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0, color: Colors.white)),
                      SizedBox(height: 8.0),
                      Text("Last Step! increase your chances of success.\nWe suggest Picking 3 super powers. It is not required, but highly recommended if you're serious about achieving your goals.", style: TextStyle(fontSize: 16.0, color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 8)),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 8.0, mainAxisSpacing: 8.0, childAspectRatio: 0.8),
                itemCount: itemList.length,
                itemBuilder: (context, index) {
                  final item = itemList[index];
                  final isSelected = selectedItems.contains(item.text);

                  // --- SIMPLIFIED GestureDetector ---
                  // It now calls the same function for every item, creating a consistent two-step flow.
                  return GestureDetector(
                    onTap: () {
                      toggleSelection(item.text);
                      _showSuperpowerDialog(context, item);
                    },
                    child: ImageCard1(
                      imageAdd: item.imageAdd,
                      text: item.text,
                      isSelected: isSelected,
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(255, 61, 60, 124),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> MeditationActionScreen(imageUrl: widget.imageUrl,objectId:widget.objectId,)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Continue", style: TextStyle(color: Colors.black)),
                    SizedBox(width: 8.0),
                    Icon(Icons.arrow_forward, color: Colors.black),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}