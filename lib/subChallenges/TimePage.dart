import 'package:fantastic_app_riverpod/subChallenges/ChallengeName.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting time

// Enum to represent the different time choices
enum TimeOption { recommended, evening, late, other }

class ChallengeTimeScreen extends StatefulWidget {
  final String imageUrl;
  const ChallengeTimeScreen({super.key, required this.imageUrl});


  @override
  State<ChallengeTimeScreen> createState() => _ChallengeTimeScreenState();
}

class _ChallengeTimeScreenState extends State<ChallengeTimeScreen> {
  // State variable to hold the currently selected option
  TimeOption _selectedOption = TimeOption.recommended; // Default to recommended

  // State variable to hold a custom time if selected via "Other time"
  TimeOfDay? _customTime;


  // Predefined times mapping
  final Map<TimeOption, TimeOfDay?> _predefinedTimes = {
    TimeOption.recommended: const TimeOfDay(hour: 8, minute: 0),
    TimeOption.evening: const TimeOfDay(hour: 18, minute: 0),
    TimeOption.late: const TimeOfDay(hour: 22, minute: 30),
    TimeOption.other: null, // Placeholder for custom time
  };

  // Helper to format TimeOfDay as HH:mm (24-hour format)
  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat('HH:mm'); // Explicitly 24-hour format
    return format.format(dt);
  }

  // Function to show the time picker dialog
  Future<void> _selectOtherTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _customTime ?? const TimeOfDay(hour: 9, minute: 0), // Start with custom or default
      builder: (BuildContext context, Widget? child) {
        // Apply custom theme to the time picker
        return Theme(
          data: ThemeData.light().copyWith(
            // Adjust primaryColor and accentColor/colorScheme for picker theme
            primaryColor: const Color(0xFF00695C), // Darker Teal for header bg
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00695C), // Header background, selected numbers
              onPrimary: Colors.white,    // Header text
              surface: Colors.white,    // Dialog background
              onSurface: Colors.black,    // Clock face numbers, main text
            ),
            buttonTheme: const ButtonThemeData(
                textTheme: ButtonTextTheme.primary,
                colorScheme: ColorScheme.light(
                  primary: Color(0xFF00796B), // Teal for button text
                )
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF00796B), // Teal for button text
              ),
            ),
            timePickerTheme: const TimePickerThemeData(
              // Customize further if needed
              // dialHandColor: Colors.red,
            ),
            // Deprecated but sometimes needed for older picker styles
            // accentColor: const Color(0xFF00796B),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _customTime = pickedTime;
        _selectedOption = TimeOption.other; // Automatically select "Other" after picking
      });
    }
  }

  // Helper method to build each time option row
  // Helper method to build each time option row
  Widget _buildTimeOptionWidget(TimeOption option) {
    bool isSelected = _selectedOption == option;
    TimeOfDay? timeToShow = (option == TimeOption.other)
        ? _customTime
        : _predefinedTimes[option];
    String displayString;
    bool isRecommendedOption = option == TimeOption.recommended; // Check if it's the recommended *option*

    // Determine the text to display
    if (option == TimeOption.other) {
      displayString = _customTime != null ? _formatTime(_customTime!) : "Other time";
    } else {
      displayString = _formatTime(timeToShow!);
    }

    // Define styles based on selection state
    Color backgroundColor;
    Color textColor;
    Color? recommendedLabelColor; // Color for the "Recommended" label
    FontWeight fontWeight;
    double fontSize;

    if (isSelected) {
      // --- SELECTED STYLE ---
      backgroundColor = const Color(0xFF00796B); // Teal background
      textColor = Colors.white;
      fontWeight = FontWeight.bold;
      fontSize = 26; // Prominent size for selected time
      if (isRecommendedOption) {
        // Only show "Recommended" label if this specific option is selected
        recommendedLabelColor = Colors.white70;
      }
    } else {
      // --- NON-SELECTED STYLE ---
      backgroundColor = Colors.transparent; // No background fill
      textColor = const Color(0xFF333333); // Dark text
      fontWeight = FontWeight.w500;
      fontSize = 22; // Standard size for non-selected time
    }

    return GestureDetector(
      onTap: () {
        if (option == TimeOption.other) {
          _selectOtherTime(context);
        } else {
          setState(() {
            _selectedOption = option;
            // If a predefined time is selected explicitly, clear any custom time? Optional.
            // if (_customTime != null) {
            //   _customTime = null;
            // }
          });
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0), // Consistent padding
        margin: const EdgeInsets.only(bottom: 10.0), // Consistent margin
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.0),
          // Optional: add a subtle border for non-selected items if needed
          border: !isSelected ? Border.all(color: Colors.grey.shade300, width: 1.0) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Show "Recommended" label ONLY if this option IS recommended AND is selected
            if (isRecommendedOption && isSelected && recommendedLabelColor != null)
              Text(
                "Recommended",
                style: TextStyle(
                  color: recommendedLabelColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (isRecommendedOption && isSelected) const SizedBox(height: 4), // Spacing only if label shown

            // The Time/Text itself
            Text(
              displayString,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine the final time to be used by the Continue button
    TimeOfDay finalSelectedTime = (_selectedOption == TimeOption.other && _customTime != null)
        ? _customTime!
        : _predefinedTimes[_selectedOption]!; // Assumes non-other options always have a time

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F1), // Light beige background
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () {
            // Just close the dialog
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack( // Use Stack for background image and positioned button
        children: [
          // Background Image (Bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/meditation_fade_bg.png', // <<< YOUR FADE IMAGE
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height * 0.3, // Adjust height
              // Optional: Add color blend if needed
              // color: Colors.white.withOpacity(0.8),
              // colorBlendMode: BlendMode.dstATop,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(), // Hide if error
            ),
          ),

          // Main Content Area (Scrollable)
          Positioned.fill(
            bottom: 90, // Leave space for the button at the bottom
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "When do you want to take on your challenge?",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333), // Dark text
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Morning is an amazing time to meditate, because the effects will spillover into the rest of the day. However, if it's tough to fit in, evening works equally well, and will allow you to release the days tensions before you sleep.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF555555), // Slightly lighter dark text
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Time Options List
                  _buildTimeOptionWidget(TimeOption.recommended),
                  _buildTimeOptionWidget(TimeOption.evening),
                  _buildTimeOptionWidget(TimeOption.late),
                  _buildTimeOptionWidget(TimeOption.other),

                  const SizedBox(height: 20), // Extra space at the bottom before button area
                ],
              ),
            ),
          ),

          // Continue Button (Bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              // Optional: Add a slight gradient or solid color matching the scroll background if needed
              // color: const Color(0xFFF8F5F1),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00796B), // Teal background
                  foregroundColor: Colors.white, // White text
                  minimumSize: const Size(double.infinity, 50), // Full width, fixed height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NameChallengeScreen(imageUrl: widget.imageUrl,)));
                  // Example: Navigator.pop(context, finalSelectedTime);
                },
                child: const Text(
                  "CONTINUE",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
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