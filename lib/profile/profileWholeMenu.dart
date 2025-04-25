import 'package:fantastic_app_riverpod/profile/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Image with blend
                  Stack(
                    children: [
                      Container(
                        height: screenHeight * 0.3,
                        width: double.infinity,
                        child: Image.asset(
                          'assets/picture1.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        height: screenHeight * 0.3,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey[300]!,
                              Colors.transparent,
                              Colors.grey[300]!,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Image Card with text
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.015,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Image.asset(
                            'assets/picture1.jpg',
                            width: double.infinity,
                            height: screenHeight * 0.20,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            left: 16,
                            bottom: 20,
                            child: Text(
                              'A Fabulous Night',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    blurRadius: 6.0,
                                    color: Colors.black45,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            bottom: 10,
                            child: Text(
                              'Build habits to help you sleep silently',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    blurRadius: 6.0,
                                    color: Colors.black45,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            top: 16,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 16, left: 16, bottom: 6, right: 6),
                                child: Text(
                                  'Your Current Journey',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.03,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 6.0,
                                        color: Colors.black45,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Menu Items
                  Column(
                    children: [
                      menuRow(context, Icons.map_rounded, 'All Journeys',
                          DummyPage(title: 'All Journeys')),
                      SizedBox(
                        height: 8,
                      ),
                      menuRow(context, Icons.people, 'Invite Your friends',
                          DummyPage(title: 'Invite Your friends')),
                      menuRow(
                          context,
                          Icons.app_blocking,
                          'Discover Fabulous Apps',
                          DummyPage(title: 'Discover Fabulous Apps')),
                      SizedBox(
                        height: 8,
                      ),
                      menuRow(context, Icons.sort_by_alpha, 'Sarah',
                          ProfileScreen()),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: 40,// Sets the background to white
                        child: SizedBox(
                          height: 20,
                          child: Center(
                            child: Text(
                              "Create Profile",
                              style: TextStyle(
                                color: Color(0xFF00008B),
                                fontSize: screenWidth * 0.045,// Deep blue color
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      menuRow(context, Icons.help, 'Help',
                          DummyPage(title: 'Help')),
                      menuRow(context, Icons.message, 'Contact us',
                          DummyPage(title: 'Contact us')),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget menuRow(BuildContext context, IconData icon, String title,
      Widget destinationPage) {
    final screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destinationPage),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: screenWidth * 0.04),
            Icon(icon, size: 24, color: Colors.black87),
            SizedBox(width: screenWidth * 0.05),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.black45),
            SizedBox(width: screenWidth * 0.04),
          ],
        ),
      ),
    );
  }
}

class DummyPage extends StatelessWidget {
  final String title;
  const DummyPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Welcome to $title')),
    );
  }
}
