import 'package:flutter/material.dart';

class GlowingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String progress;
  final bool isCompleted;

  const GlowingCard({super.key, required this.title, required this.subtitle, required this.progress, required this.isCompleted});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          // Outer glow effect using a blurred shadow
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withAlpha(76), // Glowing effect
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),

          // Main card with gradient border
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Container(
               decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    // Gradient background
                    gradient: LinearGradient(
                      colors: [Colors.white.withAlpha(50), Colors.transparent],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                ),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    // Gradient background
                    gradient: LinearGradient(
                      colors: [Colors.white.withAlpha(50), Colors.transparent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                ),
                 
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      width: 1.5,
                      color: Colors.white.withOpacity(0.2), // Thin white border
                    ),
                  
                    color: Color(0xff0E0E0E).withAlpha(200), // Dark background
                  ),
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 12),
                
                      // Buttons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          isCompleted?
                          // Completed button (Outlined)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueAccent, width: 1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Completed",
                              style: TextStyle(color: Colors.blueAccent, fontSize: 12),
                            ),
                          )
                          :
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Not Completed",
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                
                          // Progress counter button (Filled)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              progress,
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
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
