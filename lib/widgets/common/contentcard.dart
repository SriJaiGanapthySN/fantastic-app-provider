import 'package:flutter/material.dart';

class ContentCard extends StatefulWidget {
  final Map<String, dynamic> coaching;
  final Map<String, dynamic> coachingSeries;
  // final String title;
  // final String duration;
  // final String type;
  const ContentCard({
    super.key,
    // required this.title,
    // required this.duration,
    // required this.type,
    required this.coaching,
    required this.coachingSeries,
  });

  @override
  State<ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard> {
//   late final VideoPlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
// // ignore: deprecated_member_use
//     _controller = VideoPlayerController.asset("assets/videos/chatBg.mp4")
//       ..initialize().then((_) {
//         setState(() {});
//       });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _controller.dispose();
//   }

  Color colorFromString(String colorString) {
    // Remove the '#' if it's there and parse the hex color code
    String hexColor = colorString.replaceAll('#', '');

    // Ensure the string has the correct length (6 digits)
    if (hexColor.length == 6) {
      // Parse the color string to an integer and return it as a Color
      return Color(
          int.parse('0xFF$hexColor')); // Adding 0xFF to indicate full opacity
    } else {
      throw FormatException('Invalid color string format');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorFromString(widget.coachingSeries["color"]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ListTile(
                    //   leading: _controller.value.isInitialized
                    //       ? Container(
                    //           width: 100.0,
                    //           height: 56.0,
                    //           child: VideoPlayer(_controller),
                    //         )
                    //       : CircularProgressIndicator(),
                    //   // title: Text(widget.video.file.path.split('/').last),
                    //   onTap: () {
                    //     // Navigator.push(
                    //     //   context,
                    //     //   MaterialPageRoute(
                    //     //     builder: (context) =>
                    //     //         VideoPlayerPage(videoUrl: widget.video.file.path),
                    //     //   ),
                    //     // );
                    //   },
                    // ),
                    Text(
                      widget.coaching['subtitle'],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              "${(widget.coaching["duration"] / 60).round()} min",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Row(
                          children: [
                            const Icon(Icons.folder,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              widget.coaching["videoOrientation"] == "UNKNOWN"
                                  ? "Audio"
                                  : "Video",
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Divider(color: Colors.white),
        ],
      ),
    );
  }
}
