import 'package:fantastic_app_riverpod/providers/journey_provider.dart';
import 'package:fantastic_app_riverpod/screens/journey_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
// import '../screens/journey_screen.dart'; // Assuming not used directly here
import '../utils/blur_container.dart';
// import '../providers/journey_levels_provider.dart'; // Assuming not used directly here
// import '../widgets/premium_button.dart'; // Assuming not used directly here
import '../screens/journey_reveal/journeyscreenrevealtype1.dart';
import '../screens/journey_reveal/journeyscreenrevealtype2.dart';
import '../screens/journey_reveal/journeyscreenrevealtype3.dart';
import '../models/skill.dart';
import '../models/skillTrack.dart';
import '../services/journey_service.dart' as js;

// Helper function for robust date parsing
DateTime _parseJourneyDate(dynamic dateValue, DateTime defaultValue) {
  if (dateValue == null) return defaultValue;
  if (dateValue is String) {
    try {
      // Try parsing as ISO 8601 string
      return DateTime.parse(dateValue);
    } catch (e) {
      // Try parsing as int (millisecondsSinceEpoch) if string parse fails
      final intTimestamp = int.tryParse(dateValue);
      if (intTimestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(intTimestamp);
      }
      return defaultValue;
    }
  }
  if (dateValue is int) {
    return DateTime.fromMillisecondsSinceEpoch(dateValue);
  }
  if (dateValue is double) {
    return DateTime.fromMillisecondsSinceEpoch(dateValue.toInt());
  }
  // Add other type handling if necessary, e.g., Firebase Timestamp
  // if (dateValue is Timestamp) { return dateValue.toDate(); }
  return defaultValue;
}

class LevelImage extends StatelessWidget {
  final String imageUrl;
  final String status;
  final bool isInProgress;
  final double size;
  final double animationSize;

  const LevelImage({
    Key? key,
    required this.imageUrl,
    required this.status,
    required this.isInProgress,
    this.size = 104,
    this.animationSize = 240,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        if (status == 'completed' || status == 'in_progress')
          Positioned(
            left: -(animationSize - size) / 1.44,
            top: -(animationSize - size) / 2,
            child: Lottie.asset(
              'assets/animations/circular anti-clockwise/data.json',
              width: animationSize,
              height: animationSize,
              fit: BoxFit.cover,
              frameRate: FrameRate.max,
              repeat: true,
            ),
          ),
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (status == 'locked')
                ColorFiltered(
                  colorFilter: const ColorFilter.matrix([
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0,
                    0,
                    0,
                    1,
                    0,
                  ]),
                  child: ClipOval(
                    child: Image.network(
                      imageUrl,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: size,
                          height: size,
                          color: Colors.transparent,
                          child: const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: size,
                        height: size,
                        color: Colors.transparent,
                        child: const Center(
                          child:
                              Icon(Icons.lock, color: Colors.white, size: 40),
                        ),
                      ),
                    ),
                  ),
                )
              else
                ClipOval(
                  child: Image.network(
                    imageUrl,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: size,
                        height: size,
                        color: Colors.transparent,
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: size,
                      height: size,
                      color: Colors.transparent,
                      child: Center(
                        child: Icon(
                          isInProgress ? Icons.nightlight : null,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class ConnectingAnimation extends StatelessWidget {
  final bool isTransitionOdd;
  final bool shouldShow;
  final int index;

  const ConnectingAnimation({
    Key? key,
    required this.isTransitionOdd,
    required this.shouldShow,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!shouldShow) return const SizedBox.shrink();

    final delay =
        Duration(milliseconds: (index * 300) + (isTransitionOdd ? 200 : 0));
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return FutureBuilder(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SizedBox(
              width: screenWidth * 0.4,
              height: screenHeight * 0.25); // Placeholder size
        }
        return Lottie.asset(
          isTransitionOdd
              ? 'assets/animations/3/data.json'
              : 'assets/animations/1/data.json',
          width: screenWidth * 0.4,
          height: screenHeight * 0.25,
          fit: BoxFit.contain,
          frameRate: FrameRate.max,
          repeat: true,
        );
      },
    );
  }
}

class JourneyLevelsList extends ConsumerStatefulWidget {
  final String journeyId;
  final String email;
  final String skillTrackId;
  final Map<String, dynamic>? tile;
  final Function(String) onLevelTap;

  const JourneyLevelsList({
    Key? key,
    required this.journeyId,
    required this.email,
    required this.skillTrackId,
    this.tile,
    required this.onLevelTap,
  }) : super(key: key);

  @override
  ConsumerState<JourneyLevelsList> createState() => _JourneyLevelsListState();
}

class _JourneyLevelsListState extends ConsumerState<JourneyLevelsList>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  // Other state variables like _visibleAnimations, _animationControllers remain as they are UI related

  @override
  void initState() {
    super.initState();
    // _scrollController.addListener(_onScroll); // Assuming UI related
  }

  @override
  void dispose() {
    // _scrollController.removeListener(_onScroll); // Assuming UI related
    _scrollController.dispose();
    // Dispose animation controllers if any
    super.dispose();
  }

  // _onScroll method not modified.

  @override
  Widget build(BuildContext context) {
    final journeyService = ref.watch(journeyServiceProvider);

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: journeyService.addSkills(widget.skillTrackId, widget.email).then(
          (skills) => skills.map((skill) => skill.toMap()).toList()
            ..sort(
                (a, b) => (a['position'] ?? 0).compareTo(b['position'] ?? 0))),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading skills: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }
        final skills = snapshot.data ?? [];
        if (skills.isEmpty) {
          return const Center(
            child: Text(
              'No skills available',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return FutureBuilder<Map<String, dynamic>>(
            future: journeyService.getJourneyType(
                widget.skillTrackId, widget.email),
            builder: (context, journeySnapshot) {
              final String overallJourneyTrackType =
                  journeySnapshot.data?['type'] ?? widget.tile?['type'] ?? '';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  ...skills.map((skillMap) {
                    return _LevelItem(
                      title: skillMap['title'] ?? 'Untitled Skill',
                      description: skillMap['description'] ?? '',
                      isCompleted: skillMap['isCompleted'] ?? false,
                      isInProgress: skillMap['isInProgress'] ?? false,
                      isLocked: skillMap['isLocked'] ?? false,
                      imageUrl: skillMap['iosIconUrl'] ?? '',
                      journeyId: widget.journeyId,
                      levelId: skillMap['objectId'] ?? '',
                      email: widget.email,
                      index: skills.indexOf(skillMap),
                      isLastItem: skills.indexOf(skillMap) == skills.length - 1,
                      overallJourneyTrackType: overallJourneyTrackType,
                      skill: skillMap,
                      journeyTile: widget.tile,
                    );
                  }).toList(),
                ],
              );
            });
      },
    );
  }
}

class _LevelItem extends StatelessWidget {
  final String title;
  final String description;
  final bool isCompleted;
  final bool isInProgress;
  final bool isLocked;
  final String imageUrl;
  final String journeyId;
  final String levelId;
  final String email;
  final int index;
  final bool isLastItem;
  final String overallJourneyTrackType;
  final Map<String, dynamic> skill;
  final Map<String, dynamic>? journeyTile;

  const _LevelItem({
    Key? key,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.isInProgress,
    required this.isLocked,
    required this.imageUrl,
    required this.journeyId,
    required this.levelId,
    required this.email,
    required this.index,
    required this.isLastItem,
    required this.overallJourneyTrackType,
    required this.skill,
    this.journeyTile,
  }) : super(key: key);

  void _navigateToJourneyReveal(BuildContext context) {
    _getSkillTypeAndNavigate(context);
  }

  skillTrack _createSkillTrackForType(String specificScreenType) {
    return skillTrack(
      ctaColor: journeyTile?['ctaColor']?.toString() ?? '',
      bigImageUrl: journeyTile?['bigImageUrl']?.toString() ?? '',
      imageUrl: journeyTile?['imageUrl']?.toString() ?? '',
      includeInTotalProgress:
          journeyTile?['includeInTotalProgress'] as bool? ?? false,
      type: specificScreenType,
      isReleased: journeyTile?['isReleased'] as bool? ?? false,
      color: journeyTile?['color']?.toString() ?? '',
      skillLevelCount: (journeyTile?['skillLevelCount'] as num?)?.toInt() ?? 0,
      updatedAt: _parseJourneyDate(journeyTile?['updatedAt'], DateTime.now()),
      endTextBis: journeyTile?['endTextBis']?.toString() ?? '',
      endText: journeyTile?['endText']?.toString() ?? '',
      topDecoImageUrl: journeyTile?['topDecoImageUrl']?.toString() ?? '',
      chapterDescription: journeyTile?['chapterDescription']?.toString() ?? '',
      subtitle: journeyTile?['subtitle']?.toString() ?? '',
      infoText: journeyTile?['infoText']?.toString() ?? '',
      createdAt: _parseJourneyDate(journeyTile?['createdAt'], DateTime.now()),
      title: journeyTile?['title']?.toString() ??
          skill['skillTrackTitle']?.toString() ??
          'Journey',
      skillCount: (journeyTile?['skillCount'] as num?)?.toInt() ?? 0,
      objectId: journeyId,
    );
  }

  Future<void> _getSkillTypeAndNavigate(BuildContext context) async {
    try {
      final journeyService = js.JourneyService();

      final skillObj = Skill(
        color: skill['color']?.toString() ?? '',
        createdAt: (skill['createdAt'] as num?)?.toInt() ?? 0,
        goalId: skill['goalId']?.toString() ?? '',
        iconUrl: skill['iconUrl']?.toString() ?? '',
        iosIconUrl: skill['iosIconUrl']?.toString() ?? '',
        objectId: skill['objectId']?.toString() ??
            levelId, // levelId is skill's objectId
        position: (skill['position'] as num?)?.toInt() ?? 0,
        skillTrackId: skill['skillTrackId']?.toString() ??
            journeyId, // journeyId is skillTrackId
        title: skill['title']?.toString() ?? '',
        updatedAt: (skill['updatedAt'] as num?)?.toInt() ?? 0,
      );

      // Check for Type 2 (Goal)
      if (skillObj.goalId.isNotEmpty) {
        final goalDataResponse =
            await journeyService.getSkillGoal(email, skillObj.goalId);
        if (goalDataResponse != null) {
          final goalData = {
            'goalId': goalDataResponse['goalId']?.toString() ?? skillObj.goalId,
            'title': goalDataResponse['title']?.toString() ?? skillObj.title,
            'objectId':
                goalDataResponse['objectId']?.toString() ?? skillObj.goalId,
            'description': goalDataResponse['description']?.toString() ?? '',
          };
          if (Navigator.canPop(context)) Navigator.pop(context);
          print("Navigating to Goal screen (Type 2)");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Journeyscreenrevealtype2(
                goalData: goalData,
                skill: skillObj,
                email: email,
                skilltrack: _createSkillTrackForType('goal'),
              ),
            ),
          );
          return;
        }
      }

      final level =
          await journeyService.getSkillLevel(email, skillObj.objectId);
      print("Type : $level");
      print("Type : ${level?['type']}");

      if(level!=null && level['type']=="GOAL"){
        final goalDataResponse =
        await journeyService.getSkillGoal(email, level['goalId']);
        final goalData = {
          'goalId': goalDataResponse?['goalId']?.toString() ?? skillObj.goalId,
          'title': goalDataResponse?['title']?.toString() ?? skillObj.title,
          'objectId':
          goalDataResponse?['objectId']?.toString() ?? skillObj.goalId,
          'description': goalDataResponse?['description']?.toString() ?? '',
        };

        //if (Navigator.canPop(context)) Navigator.pop(context);
        print("Navigating to Goal screen (Type 2)");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Journeyscreenrevealtype2(
              goalData: goalData,
              skill: skillObj,
              email: email,
              skilltrack: _createSkillTrackForType('goal'),
            ),
          ),
        );
        return;
      }

      if (level != null &&
          (level['type'] == "MOTIVATOR" ||
              level['type'] == "ONE_TIME_REMINDER")) {
        print("Type 3 MOTIVATOR or ONE_TIME_REMINDER");
        final motivatorData = {
          'contentUrl': level['contentUrl']?.toString() ?? '',
          'headline': level['headline']?.toString() ?? skillObj.title,
          'headlineImageUrl': level['headlineImageUrl']?.toString() ?? '',
          'contentTitle': level['contentTitle']?.toString() ?? skillObj.title,
          'contentReadingTime': level['contentReadingTime']?.toString() ?? '',
          'objectId': level['objectId']?.toString() ?? skillObj.objectId,
          'createdAt': (level['createdAt'] as num?)?.toInt(),
          'updatedAt': (level['updatedAt'] as num?)?.toInt(),
          'type': level['type']?.toString() ?? "MOTIVATOR",
          'skillId': level['skillId']?.toString() ?? skillObj.objectId,
          'skillTrackId':
              level['skillTrackId']?.toString() ?? skillObj.skillTrackId,
          'position': (level['position'] as num?)?.toInt(),
          'goalId':
              level['goalId']?.toString() ?? '', // Include goalId if present
        };
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Journeyscreentype3(
              motivatorData: motivatorData,
            ),
          ),
        );
        return;
      } else if (level != null && level['type'] == "CONTENT") {
        print("Type 1 Content ");
        final letterData = {
          'contentUrl': level['contentUrl']?.toString() ?? '',
          'headline': level['headline']?.toString() ?? skillObj.title,
          'headlineImageUrl': level['headlineImageUrl']?.toString() ?? '',
          'contentTitle': level['contentTitle']?.toString() ?? skillObj.title,
          'contentReadingTime': level['contentReadingTime']?.toString() ?? '',
          'objectId': level['objectId']?.toString() ?? skillObj.objectId,
          'createdAt': (level['createdAt'] as num?)?.toInt(),
          'updatedAt': (level['updatedAt'] as num?)?.toInt(),
          'type': level['type']?.toString() ?? "CONTENT",
          'skillId': level['skillId']?.toString() ?? skillObj.objectId,
          'skillTrackId':
              level['skillTrackId']?.toString() ?? skillObj.skillTrackId,
          'position': (level['position'] as num?)?.toInt(),
          'goalId':
              level['goalId']?.toString() ?? '', // Include goalId if present
        };
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JourneyRevealType1(
              letterData: letterData,
              skill: skillObj,
              email: email,
              skilltrack: _createSkillTrackForType('letter'), // Or 'content'
            ),
          ),
        );
        return;
      }

      // Fetch skillLevels for Motivator (Type 3) or Content/Letter (Type 1)
      // final skillLevels = await journeyService.getSkillLevels(email, skillObj.objectId);
      //
      // // Check for Type 3 (Motivator)
      // for (final level in skillLevels) {
      //   if (level.containsKey('type') && level['type'] == "MOTIVATOR") {
      //     final String motivatorItemObjectId = level['objectId'] as String? ?? skillObj.objectId;
      //     final motivatorData = {
      //       'title': level['title']?.toString() ?? skillObj.title,
      //       'contentUrl': level["ContentUrl"]?.toString() ?? level["contentUrl"]?.toString() ?? '',
      //       'objectId': motivatorItemObjectId,
      //       'contentTitle': level["contentTitle"]?.toString() ?? '',
      //       'headline' : level["headline"]?.toString() ?? '',
      //       'headlineImageUrl': level["headlineImageUrl"]?.toString() ?? "https://storage-cache.thefab.co/thefabulousco/content/assets/920be0211e66da7c90d65e9aa808e27c_img_journey_celebrating_healthy_eating_motivator_header.jpg",
      //     };
      //
      //     if (Navigator.canPop(context)) Navigator.pop(context);
      //     print("Navigating to Motivator screen (Type 3 - identified by type: MOTIVATOR)");
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => Journeyscreentype3(
      //           motivatorData: motivatorData,
      //         ),
      //       ),
      //     );
      //     return;
      //   }
      // }
      //
      // // Check for Type 1 (Letter/Content from skillLevel)
      // Map<String, dynamic>? contentLevelData;
      // for (final level in skillLevels) {
      //   if (level.containsKey('type') && level['type'] == "CONTENT") {
      //     contentLevelData = level; // Take the first "CONTENT" type found
      //     break;
      //   }
      // }
      //
      // if (contentLevelData != null) {
      //   final letterData = {
      //     'contentUrl': contentLevelData['contentUrl']?.toString() ?? '',
      //     'headline': contentLevelData['headline']?.toString() ?? skillObj.title,
      //     'headlineImageUrl': contentLevelData['headlineImageUrl']?.toString() ?? '',
      //     'contentTitle': contentLevelData['contentTitle']?.toString() ?? skillObj.title,
      //     'contentReadingTime': contentLevelData['contentReadingTime']?.toString() ?? '',
      //     'objectId': contentLevelData['objectId']?.toString() ?? skillObj.objectId,
      //     'createdAt': (contentLevelData['createdAt'] as num?)?.toInt(),
      //     'updatedAt': (contentLevelData['updatedAt'] as num?)?.toInt(),
      //     'type': contentLevelData['type']?.toString() ?? "CONTENT",
      //     'skillId': contentLevelData['skillId']?.toString() ?? skillObj.objectId,
      //     'skillTrackId': contentLevelData['skillTrackId']?.toString() ?? skillObj.skillTrackId,
      //     'position': (contentLevelData['position'] as num?)?.toInt(),
      //     'goalId': contentLevelData['goalId']?.toString() ?? '', // Include goalId if present
      //   };
      //
      //   if (Navigator.canPop(context)) Navigator.pop(context);
      //   print("Navigating to Letter screen (Type 1 - CONTENT skill level)");
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => JourneyRevealType1(
      //         letterData: letterData,
      //         skill: skillObj,
      //         email: email,
      //         skilltrack: _createSkillTrackForType('letter'), // Or 'content'
      //       ),
      //     ),
      //   );
      //   return;
      // }

      // Fallback: Default Type 1 (Letter using pagedContent from skill itself if no CONTENT level)
      // final fallbackLetterData = {
      //   'pagedContent': skill['pagedContent']?.toString() ?? '{"pages":[{"type":"textAndMedia","text":"Welcome to your journey (fallback content).","media":""}]}',
      //   'headline': skillObj.title,
      //   'contentTitle': skillObj.title,
      //   'objectId': skillObj.objectId, // Ensure objectId is present
      // };

      // if (Navigator.canPop(context)) Navigator.pop(context);
      // print("Navigating to Letter screen (Type 1 - Fallback/pagedContent from skill)");
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => JourneyRevealType1(
      //       letterData: fallbackLetterData,
      //       skill: skillObj,
      //       email: email,
      //       skilltrack: _createSkillTrackForType('letter'),
      //     ),
      //   ),
      // );
    } catch (e, s) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      print("Error in _getSkillTypeAndNavigate: $e\n$s");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Navigation Error'),
          content: Text(
              'Error: $e\n\nThis skill might be misconfigured. Try debug navigation:'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _tryNavigateToType1(context);
                },
                child: const Text('Try Type 1')),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _tryNavigateToType2(context);
                },
                child: const Text('Try Type 2')),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _tryNavigateToType3(context);
                },
                child: const Text('Try Type 3')),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
          ],
        ),
      );
    }
  }

  Future<void> _tryNavigateToType1(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));
    try {
      final skillObj = Skill(
        color: skill['color']?.toString() ?? '',
        createdAt: (skill['createdAt'] as num?)?.toInt() ?? 0,
        goalId: skill['goalId']?.toString() ?? '',
        iconUrl: skill['iconUrl']?.toString() ?? '',
        iosIconUrl: skill['iosIconUrl']?.toString() ?? '',
        objectId: skill['objectId']?.toString() ?? levelId,
        position: (skill['position'] as num?)?.toInt() ?? 0,
        skillTrackId: skill['skillTrackId']?.toString() ?? journeyId,
        title: skill['title']?.toString() ?? '',
        updatedAt: (skill['updatedAt'] as num?)?.toInt() ?? 0,
      );
      final defaultSkillTrack = _createSkillTrackForType('letter');

      final journeyService = js.JourneyService();
      final skillLevels =
          await journeyService.getSkillLevels(email, skillObj.objectId);
      Map<String, dynamic>? contentLevelData;
      for (final level in skillLevels) {
        if (level.containsKey('type') && level['type'] == "CONTENT") {
          contentLevelData = level;
          break;
        }
      }

      Map<String, dynamic> letterDataForScreen;
      if (contentLevelData != null) {
        print("Debug Type 1: Found CONTENT skill level.");
        letterDataForScreen = {
          'contentUrl': contentLevelData['contentUrl']?.toString() ?? '',
          'headline':
              contentLevelData['headline']?.toString() ?? skillObj.title,
          'headlineImageUrl':
              contentLevelData['headlineImageUrl']?.toString() ?? '',
          'contentTitle':
              contentLevelData['contentTitle']?.toString() ?? skillObj.title,
          'contentReadingTime':
              contentLevelData['contentReadingTime']?.toString() ?? '',
          'objectId':
              contentLevelData['objectId']?.toString() ?? skillObj.objectId,
          // Add other fields from your DB structure as needed
        };
      } else {
        print(
            "Debug Type 1: No CONTENT skill level found. Using fallback pagedContent.");
        letterDataForScreen = {
          'pagedContent': skill['pagedContent']?.toString() ??
              '{"pages":[{"type":"textAndMedia","text":"Manually trying Type 1 (No specific CONTENT level found).","media":""}]}',
          'headline': skillObj.title,
          'contentTitle': skillObj.title,
          'objectId': skillObj.objectId,
        };
      }

      if (Navigator.canPop(context)) Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => JourneyRevealType1(
                letterData: letterDataForScreen,
                skill: skillObj,
                email: email,
                skilltrack: defaultSkillTrack)),
      );
    } catch (e, s) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      print("Error in _tryNavigateToType1: $e\n$s");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error trying Type 1: $e")));
    }
  }

  void _tryNavigateToType2(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));
    try {
      final skillObj = Skill(
        color: skill['color']?.toString() ?? '',
        createdAt: (skill['createdAt'] as num?)?.toInt() ?? 0,
        goalId: skill['goalId']?.toString() ?? '',
        iconUrl: skill['iconUrl']?.toString() ?? '',
        iosIconUrl: skill['iosIconUrl']?.toString() ?? '',
        objectId: skill['objectId']?.toString() ?? levelId,
        position: (skill['position'] as num?)?.toInt() ?? 0,
        skillTrackId: skill['skillTrackId']?.toString() ?? journeyId,
        title: skill['title']?.toString() ?? '',
        updatedAt: (skill['updatedAt'] as num?)?.toInt() ?? 0,
      );
      final defaultSkillTrack = _createSkillTrackForType('goal');
      final Map<String, dynamic> goalData = {
        'goalId': skill['goalId']?.toString() ?? 'debug_goal_id',
        'title': skill['title']?.toString() ?? 'Debug Goal Title',
        'objectId': skill['goalId']?.toString() ??
            skill['objectId']?.toString() ??
            'debug_obj_id',
        'description':
            skill['description']?.toString() ?? 'Debug goal description.',
      };

      //if (Navigator.canPop(context)) Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Journeyscreenrevealtype2(
                goalData: goalData,
                skill: skillObj,
                email: email,
                skilltrack: defaultSkillTrack)),
      );
    } catch (e, s) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      print("Error in _tryNavigateToType2: $e\n$s");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error trying Type 2: $e")));
    }
  }

  Future<void> _tryNavigateToType3(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final skillObj = Skill(
        color: skill['color']?.toString() ?? '',
        createdAt: (skill['createdAt'] as num?)?.toInt() ?? 0,
        goalId: skill['goalId']?.toString() ?? '',
        iconUrl: skill['iconUrl']?.toString() ?? '',
        iosIconUrl: skill['iosIconUrl']?.toString() ?? '',
        objectId: skill['objectId']?.toString() ?? levelId,
        position: (skill['position'] as num?)?.toInt() ?? 0,
        skillTrackId: skill['skillTrackId']?.toString() ?? journeyId,
        title: skill['title']?.toString() ?? '',
        updatedAt: (skill['updatedAt'] as num?)?.toInt() ?? 0,
      );

      final journeyService = js.JourneyService();
      final skillLevels =
          await journeyService.getSkillLevels(email, skillObj.objectId);

      Map<String, dynamic>? foundMotivatorLevel;
      for (final levelData in skillLevels) {
        if (levelData.containsKey('type') && levelData['type'] == "MOTIVATOR") {
          foundMotivatorLevel = levelData;
          break;
        }
      }

      if (Navigator.canPop(context)) Navigator.pop(context);

      if (foundMotivatorLevel != null) {
        final String motivatorItemObjectId =
            foundMotivatorLevel['objectId'] as String? ?? skillObj.objectId;
        final Map<String, dynamic> motivatorData = {
          'title': foundMotivatorLevel['title']?.toString() ?? skillObj.title,
          'contentUrl': foundMotivatorLevel['ContentUrl']?.toString() ??
              foundMotivatorLevel['contentUrl']?.toString() ??
              'debug_content_url',
          'objectId': motivatorItemObjectId,
          'contentTitle': foundMotivatorLevel['contentTitle']?.toString() ??
              'Debug Content Title',
          'headline':
              foundMotivatorLevel['headline']?.toString() ?? 'Debug Headline',
          'headlineImageUrl': foundMotivatorLevel['headlineImageUrl']
                  ?.toString() ??
              "https://storage-cache.thefab.co/thefabulousco/content/assets/920be0211e66da7c90d65e9aa808e27c_img_journey_celebrating_healthy_eating_motivator_header.jpg",
        };

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Journeyscreentype3(
              motivatorData: motivatorData,
            ),
          ),
        );
      } else {
        print(
            "Error in _tryNavigateToType3: No MOTIVATOR type level found for skill ${skillObj.objectId}.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Debug Type 3: Motivator data not found for this skill.')),
        );
      }
    } catch (e, s) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      print("Error in _tryNavigateToType3: $e\n$s");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error trying Type 3 navigation: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEven = index % 2 == 0;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            if (!isLastItem)
              Positioned(
                left: isEven ? screenWidth * 0.25 : null,
                right: !isEven ? screenWidth * 0.25 : null,
                bottom: -screenHeight * 0.1,
                child: ConnectingAnimation(
                  isTransitionOdd: !isEven,
                  shouldShow: true,
                  index: index,
                ),
              ),
            Padding(
              padding: EdgeInsets.only(
                top: 15,
                bottom: 50,
                left: isEven ? 8 : 16,
                right: isEven ? 10 : 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: LevelImage(
                      imageUrl: imageUrl,
                      status: isLocked
                          ? 'locked'
                          : (isCompleted ? 'completed' : 'in_progress'),
                      isInProgress: isInProgress,
                    ),
                  ),
                  if (!isLocked)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Center(
                        child: BlurContainer(
                          borderRadius: 50,
                          child: InkWell(
                            onTap: () => _navigateToJourneyReveal(context),
                            child: Container(
                              color: const Color.fromARGB(51, 255, 255, 255),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 3),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('View',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14)),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_ios,
                                      color: Colors.white, size: 12),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
