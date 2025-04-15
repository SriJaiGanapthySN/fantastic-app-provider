import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../States/StateNotifiers.dart';
import '../Widgets/imageCard.dart';
import '../Widgets/socialList.dart';
import 'onBoard32.dart';

class OnBoard31 extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final selectedItems = ref.watch(selectedSleepProvider);
    final List<SocialList> itemList = socialMediaList; // your list of items

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 43, 42, 88),
      body: Column(
        children: [
          // Top Section
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Almost there! Tell us what you're interested in",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24.0,
                            color: Colors.white),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        "Pick as many as you like.",
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                // Circle Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 8),
                  ),
                ),
              ],
            ),
          ),

          // Cards Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                padding: EdgeInsets.only(bottom: 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.8,
                ),
                itemCount: itemList.length,
                itemBuilder: (context, index) {
                  final item = itemList[index];
                  final isSelected = selectedItems.contains(item.text);

                  return GestureDetector(
                    onTap: () {
                      final notifier = ref.read(selectedSleepProvider.notifier);
                      if (isSelected) {
                        notifier.removeItem(item.text);
                      } else {
                        notifier.select(item.text);
                      }
                    },
                    child: ImageCard(
                      imageAdd: item.imageAdd,
                      text: item.text,
                      isSelected: isSelected,
                    ),
                  );
                },
              ),
            ),
          ),

          // Continue Button (only show if any item selected)
          if (selectedItems.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(255, 61, 60, 124),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OnBoard32(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Continue",
                        style: TextStyle(color: Colors.black),
                      ),
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
