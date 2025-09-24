import '../services/task_services.dart';
import '../services/journey_service.dart';
import '../services/coaching_service.dart';
import '../services/challenges_service.dart';

/// Service that routes content requests based on type and searches by objectId
class ContentCardService {
  static final TaskServices _taskServices = TaskServices();
  static final JourneyService _journeyService = JourneyService();
  static final CoachingService _coachingService = CoachingService();
  static final ChallengesService _challengesService = ChallengesService();

  /// Universal content model that all services return
  static Future<ContentCardData?> getContentById(
      String objectId, String type) async {
    try {
      print('🔍 ContentCardService: Searching for $type with ID: $objectId');

      switch (type.toUpperCase()) {
        case 'HABIT':
          return await _getHabitContent(objectId);
        case 'JOURNEY':
          return await _getJourneyContent(objectId);
        case 'COACHING':
          return await _getCoachingContent(objectId);
        case 'CHALLENGE':
          return await _getChallengeContent(objectId);
        default:
          print('❌ ContentCardService: Unknown type: $type');
          return null;
      }
    } catch (e) {
      print('❌ ContentCardService: Error getting content: $e');
      return null;
    }
  }

  static Future<ContentCardData?> _getHabitContent(String objectId) async {
    try {
      // Search in habits-new collection by document ID
      final habit = await _taskServices.getHabitById(objectId);
      if (habit != null) {
        return ContentCardData(
          objectId: objectId,
          type: 'HABIT',
          title: habit['name'] ?? habit['title'] ?? 'Habit',
          description: habit['descriptionHtml'] ?? habit['description'] ?? '',
          imageUrl: habit['iconUrl'] ?? habit['imageUrl'] ?? '',
          actionText: 'Start Habit',
          data: habit,
        );
      }
      return null;
    } catch (e) {
      print('❌ ContentCardService: Error getting habit: $e');
      return null;
    }
  }

  static Future<ContentCardData?> _getJourneyContent(String objectId) async {
    try {
      // Search in skillTrack-new collection by document ID
      final journey = await _journeyService.getJourneyById(objectId);
      if (journey != null) {
        return ContentCardData(
          objectId: objectId,
          type: 'JOURNEY',
          title: journey['title'] ?? 'Journey',
          description: journey['subtitle'] ?? journey['description'] ?? '',
          imageUrl: journey['imageUrl'] ?? journey['bigImageUrl'] ?? '',
          actionText: 'Start Journey',
          data: journey,
        );
      }
      return null;
    } catch (e) {
      print('❌ ContentCardService: Error getting journey: $e');
      return null;
    }
  }

  static Future<ContentCardData?> _getCoachingContent(String objectId) async {
    try {
      // Search in coachingSeries-new collection by document ID
      final coaching = await _coachingService.getCoachingById(objectId);
      if (coaching != null) {
        return ContentCardData(
          objectId: objectId,
          type: 'COACHING',
          title: coaching['title'] ?? 'Coaching',
          description: coaching['subtitle'] ?? coaching['description'] ?? '',
          imageUrl: coaching['imageUrl'] ?? coaching['iconUrl'] ?? '',
          actionText: 'Start Coaching',
          data: coaching,
        );
      }
      return null;
    } catch (e) {
      print('❌ ContentCardService: Error getting coaching: $e');
      return null;
    }
  }

  static Future<ContentCardData?> _getChallengeContent(String objectId) async {
    try {
      // Search in skillTrack-new collection for challenges
      final challenge = await _challengesService.getChallengeById(objectId);
      if (challenge != null) {
        return ContentCardData(
          objectId: objectId,
          type: 'CHALLENGE',
          title: challenge['title'] ?? 'Challenge',
          description: challenge['subtitle'] ?? challenge['description'] ?? '',
          imageUrl: challenge['imageUrl'] ?? challenge['bigImageUrl'] ?? '',
          actionText: 'Start Challenge',
          data: challenge,
        );
      }
      return null;
    } catch (e) {
      print('❌ ContentCardService: Error getting challenge: $e');
      return null;
    }
  }
}

/// Universal content data model
class ContentCardData {
  final String objectId;
  final String type;
  final String title;
  final String description;
  final String imageUrl;
  final String actionText;
  final Map<String, dynamic> data; // Raw data for type-specific operations

  ContentCardData({
    required this.objectId,
    required this.type,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.actionText,
    required this.data,
  });

  /// Get the appropriate navigation action based on type
  String get navigationRoute {
    switch (type.toUpperCase()) {
      case 'HABIT':
        return '/habit-detail';
      case 'JOURNEY':
        return '/journey-detail';
      case 'COACHING':
        return '/coaching-detail';
      case 'CHALLENGE':
        return '/challenge-detail';
      default:
        return '/content-detail';
    }
  }

  /// Get appropriate color scheme based on type
  Map<String, dynamic> get colorScheme {
    switch (type.toUpperCase()) {
      case 'HABIT':
        return {
          'primary': '0xFF00C89C', // Teal for habits
          'background': '0xFF1A4D3A',
        };
      case 'JOURNEY':
        return {
          'primary': '0xFF3498DB', // Blue for journeys
          'background': '0xFF1A2F4D',
        };
      case 'COACHING':
        return {
          'primary': '0xFFE74C3C', // Red for coaching
          'background': '0xFF4D1A1A',
        };
      case 'CHALLENGE':
        return {
          'primary': '0xFF9B59B6', // Purple for challenges
          'background': '0xFF3A1A4D',
        };
      default:
        return {
          'primary': '0xFF95A5A6', // Gray for unknown
          'background': '0xFF2C3E50',
        };
    }
  }

  @override
  String toString() {
    return 'ContentCardData{objectId: $objectId, type: $type, title: $title}';
  }
}
