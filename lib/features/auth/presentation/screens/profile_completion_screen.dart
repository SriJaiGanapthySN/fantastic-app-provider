// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/log/app_logger.dart';
import '../../data/models/app_user.dart';
import '../providers/auth_provider.dart';
import '../widgets/index.dart';
import '../../../onboarding/presentation/Screens/onBoard1.dart';
import '../../../chat/data/services/api/chat_api_service.dart';

class ProfileCompletionScreen extends ConsumerStatefulWidget {
  final AppUser user;

  const ProfileCompletionScreen({super.key, required this.user});

  @override
  ConsumerState<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState
    extends ConsumerState<ProfileCompletionScreen> {
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _stressLevelController = TextEditingController();
  String _selectedGender = 'Male';
  bool _isSaving = false;

  @override
  void dispose() {
    _ageController.dispose();
    _locationController.dispose();
    _stressLevelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        automaticallyImplyLeading: false, // Prevent going back
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Welcome, ${widget.user.name}!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Please complete your profile to continue',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                _buildAgeTextBox(),
                _buildGenderDropdown(),
                _buildLocationTextBox(),
                _buildStressLevelTextBox(),
                const SizedBox(height: 20),
                _buildSaveButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAgeTextBox() {
    return _buildTextBox(
      controller: _ageController,
      labelText: "Age",
      hintText: "Enter your age",
      icon: Icons.cake_outlined,
      obscureText: false,
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 350,
        child: DropdownButtonFormField<String>(
          value: _selectedGender,
          decoration: InputDecoration(
            labelText: "Gender",
            prefixIcon: const Icon(Icons.wc),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            fillColor: Theme.of(context).colorScheme.surface,
            filled: true,
          ),
          items: ["Male", "Female", "Other"].map((gender) {
            return DropdownMenuItem<String>(
              value: gender,
              child: Text(gender),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedGender = value ?? 'Male';
            });
          },
        ),
      ),
    );
  }

  Widget _buildLocationTextBox() {
    return _buildTextBox(
      controller: _locationController,
      labelText: "Location",
      hintText: "Enter your location",
      icon: Icons.location_on,
      obscureText: false,
    );
  }

  Widget _buildStressLevelTextBox() {
    return _buildTextBox(
      controller: _stressLevelController,
      labelText: "Stress Level",
      hintText: "Enter your stress level (1-10)",
      icon: Icons.psychology_outlined,
      obscureText: false,
    );
  }

  Widget _buildTextBox({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    required bool obscureText,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFromUser(
        controller: controller,
        keyboardType: TextInputType.text,
        labelText: labelText,
        hintText: hintText,
        obscureText: obscureText,
        icon: icon,
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: 350,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Complete Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final String age = _ageController.text.trim();
    final String gender = _selectedGender;
    final String location = _locationController.text.trim();
    final String stressLevel = _stressLevelController.text.trim();

    // Validate inputs
    if (age.isEmpty ||
        gender.isEmpty ||
        location.isEmpty ||
        stressLevel.isEmpty) {
      showSnackBar(context, 'Please fill in all the fields', Colors.red);
      return;
    }

    // Validate age is a number
    final ageInt = int.tryParse(age);
    if (ageInt == null || ageInt < 1 || ageInt > 120) {
      showSnackBar(context, 'Please enter a valid age (1-120)', Colors.red);
      return;
    }

    // Validate stress level
    final stressLevelInt = int.tryParse(stressLevel);
    if (stressLevelInt == null || stressLevelInt < 1 || stressLevelInt > 10) {
      showSnackBar(
          context, 'Please enter a valid stress level (1-10)', Colors.red);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      AppLogger.i('💾 Saving user profile data...');

      // Update Firestore with complete profile
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update({
        'age': age,
        'gender': gender,
        'location': location,
        'stressLevel': stressLevel,
        'profileComplete': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.i('✅ Firestore profile updated successfully');

      // Register with backend API
      try {
        final apiService = ChatApiService();
        final registrationData = {
          'name': widget.user.name,
          'email': widget.user.email,
          'password':
              'oauth_user_${DateTime.now().millisecondsSinceEpoch}', // Auto-generated password for OAuth users
          'age': age,
          'gender_identity': gender,
          'location': location,
        };

        AppLogger.i('📡 Registering user with backend API...');
        await apiService.register(registrationData);
        AppLogger.i('✅ Backend API registration successful');
      } catch (e) {
        AppLogger.w('⚠️ Backend registration failed (non-critical): $e');
        // Don't block the user - backend registration is optional
      }

      // Update the auth state with the complete user profile
      final updatedUser = widget.user.copyWith(
        age: age,
        gender: gender,
        location: location,
        stressLevel: stressLevel,
        profileComplete: true,
      );

      // Force refresh auth state
      await ref.read(authProvider.notifier).checkAuth();

      setState(() {
        _isSaving = false;
      });

      if (!mounted) return;
      showSnackBar(context, 'Profile completed successfully!', Colors.green);

      // Navigate to onboarding
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Onboard1()),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      AppLogger.e('💥 Error saving profile: $e');
      if (!mounted) return;
      showSnackBar(context, 'Failed to save profile: $e', Colors.red);
    }
  }
}
