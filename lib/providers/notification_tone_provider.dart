import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_tone.dart';

// Sample notification tones for testing
final List<NotificationTone> sampleNotificationTones = [
  NotificationTone(
    id: 'sample_1',
    name: 'Chime',
    category: 'Classic',
    audioPath: 'assets/audio/chime.mp3',
    isSelected: false,
  ),
  NotificationTone(
    id: 'sample_2',
    name: 'Bell',
    category: 'Classic',
    audioPath: 'assets/audio/bell.mp3',
    isSelected: false,
  ),
  NotificationTone(
    id: 'sample_3',
    name: 'Digital',
    category: 'Modern',
    audioPath: 'assets/audio/digital.mp3',
    isSelected: false,
  ),
  NotificationTone(
    id: 'sample_4',
    name: 'Melody',
    category: 'Modern',
    audioPath: 'assets/audio/melody.mp3',
    isSelected: false,
  ),
  NotificationTone(
    id: 'sample_5',
    name: 'Nature',
    category: 'Ambient',
    audioPath: 'assets/audio/nature.mp3',
    isSelected: false,
  ),
  NotificationTone(
    id: 'sample_6',
    name: 'Ocean',
    category: 'Ambient',
    audioPath: 'assets/audio/ocean.mp3',
    isSelected: false,
  ),
];

// Provider to toggle between real and sample data
final useSampleDataProvider = StateProvider<bool>((ref) => false);

// Modified provider that can use either real or sample data
final notificationTonesProvider = StateNotifierProvider<NotificationTonesNotifier, AsyncValue<List<NotificationTone>>>((ref) {
  return NotificationTonesNotifier(ref);
});

class NotificationTonesNotifier extends StateNotifier<AsyncValue<List<NotificationTone>>> {
  final Ref ref;
  
  NotificationTonesNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadNotificationTones();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> loadNotificationTones() async {
    try {
      state = const AsyncValue.loading();
      
      // Check if we should use sample data
      final useSampleData = ref.read(useSampleDataProvider);
      
      if (useSampleData) {
        // Use sample data
        state = AsyncValue.data(sampleNotificationTones);
        return;
      }
      
      // Use real data from Firestore
      final snapshot = await _firestore.collection('notification_tones').get();
      final tones = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return NotificationTone.fromJson(data);
      }).toList();

      state = AsyncValue.data(tones);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateSelectedTone(String toneId) async {
    try {
      state.whenData((tones) async {
        final updatedTones = tones.map((tone) {
          return tone.copyWith(isSelected: tone.id == toneId);
        }).toList();

        state = AsyncValue.data(updatedTones);

        // Only update Firestore if not using sample data
        final useSampleData = ref.read(useSampleDataProvider);
        if (!useSampleData) {
          await _firestore.collection('users').doc('current_user_id').update({
            'selectedNotificationTone': toneId,
          });
        }
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  List<String> getCategories() {
    return state.whenData((tones) {
      return tones.map((tone) => tone.category).toSet().toList();
    }).value ?? [];
  }

  List<NotificationTone> getTonesByCategory(String category) {
    return state.whenData((tones) {
      return tones.where((tone) => tone.category == category).toList();
    }).value ?? [];
  }
} 