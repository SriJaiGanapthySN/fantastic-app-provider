import 'package:fantastic_app_riverpod/widgets/glowing_card.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AllJourney extends StatefulWidget {
  const AllJourney({super.key});

  @override
  State<AllJourney> createState() => _AllJourneyState();
}

class _AllJourneyState extends State<AllJourney> {
  @override
  Widget build(BuildContext context) {
    print(allJourney);

    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Center(
              child: IconButton.filled(
                  onPressed: () {}, icon: Icon(Icons.chevron_left_rounded)),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Text(
              "Manufacture Your Best Night's Sleep",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            // GlowingCard(),
            Expanded(
              child: ListView.builder(
              itemCount: allJourney.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return Column(
                children: [
                  if (index == 0)
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  GlowingCard(
                  title: allJourney[index].title,
                  subtitle: allJourney[index].description,
                  isCompleted: allJourney[index].isCompleted,
                  progress: "${index + 1}/${allJourney.length}",
                  ),
                ],
                );
              },
              ),
            ),
            // Container(
            //   // height: MediaQuery.of(context).size.height * 0.15,
            //   width: MediaQuery.of(context).size.width * 0.9,
            //   margin:
            //       const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(16.0),
            //     gradient: const LinearGradient(
            //       colors: [
            //         Color(0xff9747FF),
            //         Color(0xffFF6B6B),
            //       ],
            //       begin: Alignment.topLeft,
            //       end: Alignment.bottomRight,
            //     ),
            //     // boxShadow: [
            //     //   BoxShadow(
            //     //     color: Colors.purple.withOpacity(0.6),
            //     //     blurRadius: 20.0,
            //     //     spreadRadius: 5.0,
            //     //   ),
            //     // ],
            //   ),
            //   child: Card(
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(16.0),
            //     ),
            //     color: Color(0xff0E0E0E),
            //     child: Padding(
            //       padding: const EdgeInsets.all(10.0),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Text(
            //             "Journey Title",
            //             style: TextStyle(
            //               fontSize: 18,
            //               fontWeight: FontWeight.bold,
            //               color: Colors.white,
            //             ),
            //           ),
            //           SizedBox(height: 8.0),
            //           Text(
            //             "This is a description of the journey.",
            //             style: TextStyle(
            //               fontSize: 14,
            //               color: Colors.grey[400],
            //             ),
            //           ),
            //           SizedBox(height: 8.0),
            //           Row(
            //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //             children: [
            //               Text(
            //                 "ID: 0",
            //                 style: TextStyle(
            //                   fontSize: 12,
            //                   color: Colors.grey[500],
            //                 ),
            //               ),
            //               Icon(
            //                 Icons.check_circle,
            //                 color: Colors.green,
            //                 size: 16.0,
            //               ),
            //             ],
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // )
          ],
        ));

    // return Lottie.asset("assets/lottie/card.lottie");
  }
}

class data {
  final int id;
  final String title;
  final String description;
  final bool isCompleted;

  data({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
  });

  @override
  String toString() {
    return 'data{id: $id, title: $title, description: $description, isCompleted: $isCompleted}\n';
  }
}

List<data> raw = [
  data(
    id: 1,
    title: 'Journey 1',
    description: 'Description of Journey 1',
    isCompleted: false,
  ),
  data(
    id: 2,
    title: 'Journey 2',
    description: 'Description of Journey 2',
    isCompleted: true,
  ),
  data(
    id: 3,
    title: 'Journey 3',
    description: 'Description of Journey 3',
    isCompleted: false,
  ),
  data(
    id: 4,
    title: 'Journey 4',
    description: 'Description of Journey 4',
    isCompleted: true,
  ),
  data(
    id: 5,
    title: 'Journey 5',
    description: 'Description of Journey 5',
    isCompleted: false,
  ),
  data(
    id: 6,
    title: 'Journey 6',
    description: 'Description of Journey 6',
    isCompleted: true,
  ),
  data(
    id: 7,
    title: 'Journey 7',
    description: 'Description of Journey 7',
    isCompleted: false,
  ),
];
List<data> allJourney = [
  ...raw.where((journey) => journey.isCompleted),
  ...raw.where((journey) => !journey.isCompleted),
];
