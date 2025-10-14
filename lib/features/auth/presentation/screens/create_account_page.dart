// ignore_for_file: use_build_context_synchronously

import 'package:email_otp_auth/email_otp_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/index.dart';
import '../../../chat/data/services/api/chat_api_service.dart';
import '../../../chat/data/services/token/token_service.dart';
import '../../../../main_screen.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key, required this.togglePages});
  final void Function()? togglePages;

  @override
  CreateAccountPageState createState() => CreateAccountPageState();
}

class CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String _selectedGender = 'Male';
  bool _passwordVisible = true;
  bool _isOtpVerified = false;
  bool _isRegistering = false; // Add loading state
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _otpController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDisplayHeading(),
              _buildNameTextBox(),
              _buildAgeTextBox(),
              _buildGenderDropdown(),
              _buildLocationTextBox(),
              _buildEmailTextBox(),
              _buildOtpTextBox(),
              _buildPasswordTextBox(),
              _buildCreateAccountButton(),
              const Text('or'),
              buildLoginWithGoogleButton(),
              buildLoginWithAppleButton(),
              _buildLoginInsteadButton(context),
            ],
          ),
        ),
      ),
    );
  }

  // Widget methods
  Widget _buildLocationTextBox() {
    return _buildTextBox(
      controller: _locationController,
      labelText: "Location",
      hintText: "Enter your location",
      icon: Icons.location_on,
      obscureText: false,
    );
  }

  Widget _buildDisplayHeading() {
    return const Padding(
      padding: EdgeInsets.all(18.0),
      child: SizedBox(
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            DisplayText(displayText: "Welcome!"),
            SubDisplayText(subDisplayText: "Create an account"),
          ],
        ),
      ),
    );
  }

  Widget _buildNameTextBox() {
    return _buildTextBox(
      controller: _nameController,
      labelText: "Name",
      hintText: "Enter name",
      icon: Icons.person_outlined,
      obscureText: false,
    );
  }

  Widget _buildAgeTextBox() {
    return _buildTextBox(
      controller: _ageController,
      labelText: "Age",
      hintText: "Enter age",
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

  Widget _buildEmailTextBox() {
    return _buildTextBox(
      controller: _emailController,
      labelText: "Email",
      hintText: "Enter email",
      icon: Icons.email_outlined,
      obscureText: false,
      suffix: ButtonInsideTF(
        onPressed: _sendOTP,
        text: "Send OTP",
      ),
    );
  }

  Widget _buildOtpTextBox() {
    return _buildTextBox(
      controller: _otpController,
      labelText: "OTP",
      hintText: "Enter OTP",
      icon: Icons.password_outlined,
      obscureText: false,
      suffix: ButtonInsideTF(
        onPressed: _verifyOTP,
        text: "Verify OTP",
      ),
    );
  }

  Widget _buildPasswordTextBox() {
    return _buildTextBox(
      controller: _passwordController,
      labelText: "Password",
      hintText: "Enter Password",
      icon: Icons.key_outlined,
      obscureText: _passwordVisible,
      suffixIcon: IconButton(
        icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
        onPressed: () {
          setState(() {
            _passwordVisible = !_passwordVisible;
          });
        },
      ),
    );
  }

  Widget _buildTextBox({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    required bool obscureText,
    Widget? suffix,
    Widget? suffixIcon,
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
        suffix: suffix,
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildCreateAccountButton() {
    return Consumer(
      builder: (context, ref, child) {
        return ColoredButton(
          onPressed: _isRegistering
              ? null
              : () {
                  print('🔘 Create Account button pressed');
                  _register(ref);
                },
          labelText: "Create Account",
        );
      },
    );
  }

  Widget _buildLoginInsteadButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account?"),
        GestureDetector(
          onTap: widget.togglePages,
          child: const Text(
            " Login",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // Helper methods
  void _sendOTP() async {
    if (!_isEmailValid(_emailController.text)) {
      showSnackBar(context, "Enter a valid email", Colors.red);
      return;
    }

    try {
      showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      if (kDebugMode) {
        print("Attempting to send OTP...");
      }
      var res = await EmailOtpAuth.sendOTP(email: _emailController.text)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        return {"message": "Timeout"};
      });

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (kDebugMode) {
        print("Response: $res");
      }

      if (res["message"] == "Email Send" && context.mounted) {
        showSnackBar(context, "OTP has been sent", Colors.green);
      } else if (res["message"] == "Timeout" && context.mounted) {
        showSnackBar(
            context, "Request timed out. Please try again.", Colors.red);
      } else {
        showSnackBar(context, "Invalid E-Mail Address ", Colors.red);
      }
    } catch (error) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      if (kDebugMode) {
        print("Error: $error");
      }
      showSnackBar(context, "Something went wrong", Colors.red);
    }
  }

  void _verifyOTP() async {
    try {
      showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      var res = await EmailOtpAuth.verifyOtp(otp: _otpController.text);

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (res["message"] == "OTP Verified" && context.mounted) {
        setState(() {
          _isOtpVerified = true;
        });
        showSnackBar(context, "OTP verified ", Colors.green);
      } else if (res["data"] == "Invalid OTP" && context.mounted) {
        showSnackBar(context, "Invalid OTP ", Colors.red);
      } else if (res["data"] == "OTP Expired" && context.mounted) {
        showSnackBar(context, "OTP Expired ", Colors.red);
      } else {
        return;
      }
    } catch (error) {
      throw error.toString();
    }
  }

  void _register(WidgetRef ref) async {
    print('_register method called');

    // Set loading state
    setState(() {
      _isRegistering = true;
    });

    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String age = _ageController.text.trim();
    final String gender = _selectedGender;
    final String location = _locationController.text.trim();

    print(
        '📋 Registration data: name=$name, email=$email, age=$age, gender=$gender, location=$location');
    print('OTP verified: $_isOtpVerified');

    if (!_isOtpVerified) {
      setState(() {
        _isRegistering = false;
      });
      if (!mounted) return;
      print(' OTP not verified');
      showSnackBar(context, 'Please verify the OTP first', Colors.red);
      return;
    }

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        age.isEmpty ||
        gender.isEmpty ||
        location.isEmpty) {
      setState(() {
        _isRegistering = false;
      });
      if (!mounted) return;
      print(' Missing fields');
      showSnackBar(context, 'Please fill in all the fields', Colors.red);
      return;
    }

    try {
      print('Starting API registration');
      final apiService = ChatApiService();
      final registrationData = {
        'name': name,
        'email': email,
        'password': password,
        'age': age,
        'gender': gender,
        'location': location,
      };
      final apiResult = await apiService.register(registrationData);
      print('📡 API registration result: $apiResult');

      if (apiResult == null) {
        print(' API registration failed');
        setState(() {
          _isRegistering = false;
        });
        if (!mounted) return;
        showSnackBar(
            context, 'Registration failed. Please try again.', Colors.red);
        return;
      }

      print(' API registration successful');

      // Now authenticate to get token
      print('� Getting authentication token');
      final apiToken = await apiService.authenticate(email, password);

      if (apiToken != null) {
        // Store token and user details
        await TokenService.storeToken(apiToken);
        await TokenService.storeUserDetails(email: email, name: name);

        print('💾 Token and user details stored');

        setState(() {
          _isRegistering = false;
        });

        if (!mounted) return;
        showSnackBar(context, 'Account created successfully!', Colors.green);

        // Navigate directly to main screen
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        }
      } else {
        print(' Failed to get authentication token');
        setState(() {
          _isRegistering = false;
        });
        if (!mounted) return;
        showSnackBar(
            context,
            'Registration successful but login failed. Please try logging in.',
            Colors.orange);

        // Navigate to login page
        await Future.delayed(const Duration(seconds: 1));
        if (mounted && widget.togglePages != null) {
          widget.togglePages!();
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isRegistering = false;
      });
      if (!mounted) return;
      print(' Firebase error: ${e.code} - ${e.message}');
      if (e.code == 'weak-password') {
        showSnackBar(
            context, 'Weak password! Choose a stronger one.', Colors.red);
      } else {
        showSnackBar(context, e.message ?? 'Registration failed', Colors.red);
      }
    } catch (e) {
      setState(() {
        _isRegistering = false;
      });
      print('Unexpected error during registration: $e');
      if (!mounted) return;
      showSnackBar(context, 'Registration failed: $e', Colors.red);
    }
  }

  bool _isEmailValid(String email) {
    return RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$")
        .hasMatch(email);
  }
}
