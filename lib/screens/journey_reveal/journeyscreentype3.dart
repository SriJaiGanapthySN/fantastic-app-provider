import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import '../journey_screen.dart';
import '../../models/skill.dart';
import '../../models/skillTrack.dart';
import '../../services/journey_service.dart';

class Journeyscreentype3 extends StatefulWidget {
  final Map motivatorData;
  final Skill skill;
  final String email;
  final skillTrack skilltrack;

  const Journeyscreentype3({
    super.key,
    required this.motivatorData,
    required this.skill,
    required this.email,
    required this.skilltrack,
  });

  @override
  State<Journeyscreentype3> createState() => _Journeyscreentype3State();
}

class _Journeyscreentype3State extends State<Journeyscreentype3> {
  final JourneyService _journeyService = JourneyService();
  String? content;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchContent();
  }

  Future<void> fetchContent() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await http.get(Uri.parse(widget.motivatorData['contentUrl']));
      
      setState(() {
        isLoading = false;
        if (response.statusCode == 200) {
          content = response.body;
        } else {
          errorMessage = 'Failed to load content: ${response.statusCode}';
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading content: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.motivatorData['title'] ?? 'Motivator'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.motivatorData['headlineImageUrl'] != null)
                  Image.network(
                    widget.motivatorData['headlineImageUrl'],
                    fit: BoxFit.cover,
                    height: screenHeight * 0.25,
                    width: screenWidth,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: screenHeight * 0.25,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      );
                    },
                  ),
                SizedBox(height: screenHeight * 0.02),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Text(
                    widget.motivatorData['contentTitle'] ?? 'Content Title',
                    style: TextStyle(
                      fontSize: screenWidth * 0.07,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (errorMessage != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    child: Html(
                      data: content ?? '<p>No content available</p>',
                      style: {
                        "html": Style(
                          fontSize: FontSize(screenWidth * 0.045),
                          lineHeight: LineHeight(1.6),
                          color: Colors.black87,
                        ),
                        "p": Style(
                          fontSize: FontSize(screenWidth * 0.045),
                          color: Colors.black87,
                          textAlign: TextAlign.justify,
                        ),
                        "ul": Style(
                          padding: HtmlPaddings.only(left: screenWidth * 0.04),
                        ),
                        "li": Style(
                          fontSize: FontSize(screenWidth * 0.045),
                          color: Colors.black87,
                        ),
                      },
                    ),
                  ),
                SizedBox(height: screenHeight * 0.1),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Material(
              elevation: 10,
              shadowColor: Colors.black.withOpacity(0.6),
              child: Container(
                color: Colors.grey.shade300,
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                  horizontal: screenWidth * 0.04,
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            try {
                              setState(() {
                                isLoading = true;
                                errorMessage = null;
                              });

                              await _journeyService.updateMotivator(
                                true,
                                widget.motivatorData['objectId'],
                                widget.email,
                                widget.skill.objectId,
                                widget.skilltrack.objectId,
                              );

                              setState(() {
                                isLoading = false;
                              });

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const JourneyScreen(),
                                ),
                              );
                            } catch (e) {
                              setState(() {
                                isLoading = false;
                                errorMessage = 'Error updating motivator: $e';
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 13, 173, 32),
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 10,
                      shadowColor: Colors.black.withOpacity(0.8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: screenWidth * 0.06,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          'Done! What Next',
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
