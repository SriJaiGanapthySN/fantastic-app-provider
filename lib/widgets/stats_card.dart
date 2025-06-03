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
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progress Stats',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Level Completion', completionValue),
              _buildStatItem('Events Achieved', eventsValue),
              if (skillCompletionValue != null)
                _buildStatItem('Skill Completion', skillCompletionValue!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
} 