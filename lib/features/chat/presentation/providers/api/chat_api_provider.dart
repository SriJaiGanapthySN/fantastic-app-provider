import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/api/chat_api_service.dart';
import '../../../data/services/token/token_service.dart';
import '../../../data/model/chat_message.dart';

final chatApiServiceProvider = Provider<ChatApiService>((ref) {
  return ChatApiService();
});

// Provider to track authentication status using token service
final authStatusProvider = FutureProvider<bool>((ref) async {
  return await TokenService.isAuthenticated();
});

// Provider for loading states
final chatLoadingProvider = StateProvider<bool>((ref) => false);

// Provider for API messages
final apiMessagesProvider = StateProvider<List<ChatMessage>>((ref) => []);

// Provider for authentication errors
final authErrorProvider = StateProvider<String?>((ref) => null);
