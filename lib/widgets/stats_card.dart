import 'package:flutter/material.dart';
import '../services/journey_service.dart';

class StatsCard extends StatelessWidget {
  final String completionValue;
  final String eventsValue;
  final String? skillCompletionValue;
  final JourneyService _journeyService = JourneyService();
  final String? userEmail;

  StatsCard({
    Key? key,
    required this.completionValue,
    required this.eventsValue,
    this.skillCompletionValue,
    this.userEmail,
  }) : super(key: key);

  void _logStatsView() {
    if (userEmail != null) {
      _journeyService.logJourneyScreenInteraction(
        userEmail!,
        'stats_view',
        'stats_card_view',
        additionalData: {
          'completionValue': completionValue,
          'eventsValue': eventsValue,
          if (skillCompletionValue != null) 'skillCompletionValue': skillCompletionValue!,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _logStatsView();
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Calculate dynamic dimensions
    final cardHeight = screenHeight * 0.09; // 12% of screen height
    final cardWidth = screenWidth - 32; // Full width minus padding
    final borderRadius = screenWidth * 0.07; // 7% of screen width
    final padding = screenWidth * 0.015; // 2.5% of screen width
    final valueFontSize = screenWidth * 0.06; // 8% of screen width
    final labelFontSize = screenWidth * 0.035; // 3.5% of screen width
    final dividerWidth = screenWidth * 0.001; // 0.1% of screen width
    final spacing = screenWidth * 0.01; // 2% of screen width

    return Container(
      width: cardWidth,
      height: cardHeight,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    completionValue,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: valueFontSize,
                      fontWeight: FontWeight.w400,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: spacing * 0.4),
                  Text(
                    'Level Completion',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: labelFontSize,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            VerticalDivider(
              color: Colors.white.withOpacity(0.2),
              width: dividerWidth,
              thickness: dividerWidth,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    eventsValue,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: valueFontSize,
                      fontWeight: FontWeight.w400,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: spacing * 0.4),
                  Text(
                    'Events Achieved',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: labelFontSize,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (skillCompletionValue != null) ...[
              VerticalDivider(
                color: Colors.white.withOpacity(0.2),
                width: dividerWidth,
                thickness: dividerWidth,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      skillCompletionValue!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: valueFontSize,
                        fontWeight: FontWeight.w400,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: spacing * 0.4),
                    Text(
                      'Skill Completion',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: labelFontSize,
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 