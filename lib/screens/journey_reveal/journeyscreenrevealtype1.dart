import 'package:fantastic_app_riverpod/models/skill.dart';
import 'package:fantastic_app_riverpod/models/skillTrack.dart';
import 'package:flutter/material.dart';
import 'package:fantastic_app_riverpod/screens/journey_path.dart';

class JourneyRevealType1 extends StatelessWidget {
  final Map letterData;
  final Skill skill;
  final String email;
  final skillTrack skilltrack;

  const JourneyRevealType1(
      {super.key,
      required this.letterData,
      required this.skill,
      required this.skilltrack,
      required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_right_rounded),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const JourneyRoadmapScreen(),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Container(
        margin: const EdgeInsets.only(top: 300, bottom: 30),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Journey Reveal Type 1'),
            Container(
              width: 300,
              height: 50,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 162, 36, 27),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Next',
                    style: TextStyle(color: Colors.white),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// import 'dart:convert';
// import 'package:fab/models/skill.dart';
// import 'package:fab/models/skillTrack.dart';
// import 'package:flutter/material.dart';

// class JourneyRevealType1 extends StatefulWidget {
//   final Map letterData;
//     final Skill skill;
//   final String email;
//   final skillTrack skilltrack;

//   const JourneyRevealType1({
//     super.key,
//     required this.letterData,
//     required this.skill,required this.skilltrack,required this.email
//   });

//   @override
//   _JourneyRevealType1State createState() => _JourneyRevealType1State();
// }

// class _JourneyRevealType1State extends State<JourneyRevealType1> {
//   late List pages;
//   late PageController _pageController;
//   int currentPage = 0;

//   @override
//   void initState() {
//     super.initState();
//     print("_______DWA_________");
//     print(widget.letterData);
//     final pagedContent = widget.letterData['pagedContent'];
//     pages = jsonDecode(pagedContent)['pages'];
//     print(pages);
//     _pageController = PageController();
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Journey Reveal'),
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(4.0),
//           child: LinearProgressIndicator(
//             value: (currentPage + 1) / pages.length,
//           ),
//         ),
//       ),
//       body: PageView.builder(
//         controller: _pageController,
//         onPageChanged: (index) {
//           setState(() {
//             currentPage = index;
//           });
//         },
//         itemCount: pages.length,
//         itemBuilder: (context, index) {
//           final page = pages[index];
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (page['type'] == 'textAndMedia') ...[
//                   Text(
//                     page['text'] ?? '',
//                     style: const TextStyle(fontSize: 18.0),
//                   ),
//                   if (page['media'] != null)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 16.0),
//                       child: Image.network(page['media']),
//                     ),
//                 ] else if (page['type'] == 'quote') ...[
//                   Text(
//                     page['text'] ?? '',
//                     style: const TextStyle(
//                       fontSize: 18.0,
//                       fontStyle: FontStyle.italic,
//                     ),
//                   ),
//                 ]
//               ],
//             ),
//           );
//         },
//       ),
//       bottomNavigationBar: BottomAppBar(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             IconButton(
//               icon: const Icon(Icons.arrow_back),
//               onPressed: currentPage > 0
//                   ? () {
//                       _pageController.previousPage(
//                         duration: const Duration(milliseconds: 300),
//                         curve: Curves.easeInOut,
//                       );
//                     }
//                   : null,
//             ),
//             Text(
//               'Page ${currentPage + 1} of ${pages.length}',
//               style: const TextStyle(fontSize: 16.0),
//             ),
//             IconButton(
//               icon: const Icon(Icons.arrow_forward),
//               onPressed: currentPage < pages.length - 1
//                   ? () {
//                       _pageController.nextPage(
//                         duration: const Duration(milliseconds: 300),
//                         curve: Curves.easeInOut,
//                       );
//                     }
//                   : null,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
