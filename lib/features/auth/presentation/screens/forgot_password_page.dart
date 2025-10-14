import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_provider.dart';
import '../widgets/index.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ForgotPasswordPageState createState() => ForgotPasswordPageState();
}

class ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isButtonDisabled = false;
  Timer? _timer;
  int _remainingSeconds = 90;

  @override
  void initState() {
    super.initState();
    _loadTimerState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _timer?.cancel();
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
              _buildEmailTextBox(),
              _buildSendEmailButton(),
              _buildLoginInsteadButton(context),
            ],
          ),
        ),
      ),
    );
  }

  // Widget methods
  Widget _buildDisplayHeading() {
    return const Padding(
      padding: EdgeInsets.all(18.0),
      child: SizedBox(
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            DisplayText(displayText: "Forgot Password?"),
            SubDisplayText(subDisplayText: "Don't worry!"),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailTextBox() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFromUser(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        labelText: "Email",
        hintText: "Enter email",
        obscureText: false,
        icon: Icons.email_outlined,
      ),
    );
  }

  Widget _buildSendEmailButton() {
    return ColoredButton(
      onPressed: _isButtonDisabled ? null : submitEmail,
      labelText: _isButtonDisabled
          ? 'Please wait $_remainingSeconds s'
          : 'Submit Email',
    );
  }

  void submitEmail() {
    final String email = _emailController.text.trim();

    if (email.isNotEmpty) {
      ref.read(authProvider.notifier).sendForgotPasswordLink(email);
      setState(() {
        _isButtonDisabled = true;
        _remainingSeconds = 90;
      });
      FocusScope.of(context).unfocus(); // Hide keyboard
      _startTimer();
      _saveTimerState();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Email sent! Please check your inbox and junk folder.',
            style: TextStyle(color: Colors.green),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please fill a valid email.',
            style: TextStyle(color: Colors.red),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
      );
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          _saveTimerState();
        } else {
          _isButtonDisabled = false;
          _timer?.cancel();
          _clearTimerState();
        }
      });
    });
  }

  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isButtonDisabled', _isButtonDisabled);
    await prefs.setInt('remainingSeconds', _remainingSeconds);
  }

  Future<void> _loadTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isButtonDisabled = prefs.getBool('isButtonDisabled') ?? false;
      _remainingSeconds = prefs.getInt('remainingSeconds') ?? 90;
      if (_isButtonDisabled) {
        _startTimer();
      }
    });
  }

  Future<void> _clearTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isButtonDisabled');
    await prefs.remove('remainingSeconds');
  }

  Widget _buildLoginInsteadButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Go back?"),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Text(
              " Login",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
