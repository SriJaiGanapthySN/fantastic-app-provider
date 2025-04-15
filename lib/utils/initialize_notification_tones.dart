import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> initializeNotificationTones() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference tones = firestore.collection('notification_tones');

  final List<Map<String, dynamic>> defaultTones = [
    {
      'name': 'A New Day',
      'category': '',
      'audioPath': 'assets/audio/a_new_day.mp3',
      'isSelected': false,
    },
    {
      'name': 'Wake up in Style',
      'category': '',
      'audioPath': 'assets/audio/wake_up_in_style.mp3',
      'isSelected': false,
    },
    {
      'name': "Ocean's Goodnight",
      'category': '',
      'audioPath': 'assets/audio/oceans_goodnight.mp3',
      'isSelected': false,
    },
    {
      'name': 'Reflection',
      'category': '',
      'audioPath': 'assets/audio/reflection.mp3',
      'isSelected': false,
    },
    {
      'name': 'Night Falls',
      'category': '',
      'audioPath': 'assets/audio/night_falls.mp3',
      'isSelected': false,
    },
    {
      'name': 'Morning Chorus',
      'category': '',
      'audioPath': 'assets/audio/morning_chorus.mp3',
      'isSelected': false,
    },
    {
      'name': 'Serene Sunrise',
      'category': '',
      'audioPath': 'assets/audio/serene_sunrise.mp3',
      'isSelected': false,
    },
    {
      'name': 'Music Box 2',
      'category': '',
      'audioPath': 'assets/audio/music_box_2.mp3',
      'isSelected': false,
    },
    {
      'name': 'Hall Mountain',
      'category': '',
      'audioPath': 'assets/audio/hall_mountain.mp3',
      'isSelected': false,
    },
    {
      'name': 'Ring Ding',
      'category': '',
      'audioPath': 'assets/audio/ring_ding.mp3',
      'isSelected': false,
    },
    {
      'name': 'Contemplation Waves',
      'category': '',
      'audioPath': 'assets/audio/contemplation_waves.mp3',
      'isSelected': false,
    },
    {
      'name': "It's Time",
      'category': '',
      'audioPath': 'assets/audio/its_time.mp3',
      'isSelected': false,
    },
    {
      'name': 'Sanctuary',
      'category': '',
      'audioPath': 'assets/audio/sanctuary.mp3',
      'isSelected': false,
    },
    {
      'name': 'Reflection Rain',
      'category': '',
      'audioPath': 'assets/audio/reflection_rain.mp3',
      'isSelected': false,
    },
    {
      'name': "What's Awaiting Me?",
      'category': '',
      'audioPath': 'assets/audio/whats_awaiting_me.mp3',
      'isSelected': false,
    },
    {
      'name': 'Music Box',
      'category': '',
      'audioPath': 'assets/audio/music_box.mp3',
      'isSelected': false,
    },
    {
      'name': 'Meditation Fountain',
      'category': '',
      'audioPath': 'assets/audio/meditation_fountain.mp3',
      'isSelected': false,
    },
    {
      'name': 'Silent',
      'category': 'Fabulous',
      'audioPath': 'assets/audio/silent.mp3',
      'isSelected': false,
    },
    {
      'name': 'Fabulous Beep',
      'category': 'Fabulous',
      'audioPath': 'assets/audio/fabulous_beep.mp3',
      'isSelected': true,
    },
    {
      'name': 'Simple Beep',
      'category': 'Fabulous',
      'audioPath': 'assets/audio/simple_beep.mp3',
      'isSelected': false,
    },
    {
      'name': 'Rise & Shine',
      'category': 'Fabulous',
      'audioPath': 'assets/audio/rise_and_shine.mp3',
      'isSelected': false,
    },
    {
      'name': 'Afternoon Stroll',
      'category': 'Fabulous',
      'audioPath': 'assets/audio/afternoon_stroll.mp3',
      'isSelected': false,
    },
    {
      'name': 'Calming Night',
      'category': 'Fabulous',
      'audioPath': 'assets/audio/calming_night.mp3',
      'isSelected': false,
    },
    {
      'name': 'The Fabulous',
      'category': 'Fabulous',
      'audioPath': 'assets/audio/the_fabulous.mp3',
      'isSelected': false,
    },
    {
      'name': 'Evolve',
      'category': 'Fabulous',
      'audioPath': 'assets/audio/evolve.mp3',
      'isSelected': false,
    },
  ];

  // Add all tones to Firestore
  for (final tone in defaultTones) {
    await tones.add(tone);
  }
} 