import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'discover_provider.dart'; // Import to get persona provider

final journeyLevelsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, journeyId) async {
  final journeyService = ref.watch(journeyServiceProvider);
  return journeyService.fetchJourneyLevels(journeyId);
});

final currentLevelProvider =
    FutureProvider.family<int, String>((ref, journeyId) async {
  final journeyService = ref.watch(journeyServiceProvider);
  return journeyService.getCurrentLevel(journeyId);
});
