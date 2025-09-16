import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../widgets/index.dart';
import 'forgot_password_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key, required this.togglePages});
  final void Function()? togglePages;

  @override
  SignInPageState createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  bool passwordVisible = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
              _buildPasswordTextBox(),
              _buildForgotPasswordButton(),
              _buildLoginButton(),
              const Text('or'),
              buildLoginWithGoogleButton(),
              buildLoginWithAppleButton(),
              _buildCreateAccountButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget methods
  Widget _buildDisplayHeading() {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: SizedBox(
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            DisplayText(displayText: "Welcome back!"),
            SubDisplayText(subDisplayText: "Login to continue"),
          ],
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
    );
  }

  Widget _buildPasswordTextBox() {
    return _buildTextBox(
      controller: _passwordController,
      labelText: "Password",
      hintText: "Enter Password",
      icon: Icons.key_outlined,
      obscureText: passwordVisible,
      suffixIcon: IconButton(
        icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
        onPressed: () {
          setState(() {
            passwordVisible = !passwordVisible;
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
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFromUser(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        labelText: labelText,
        hintText: hintText,
        obscureText: obscureText,
        icon: icon,
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: SizedBox(
        width: 340,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: _navigateToForgotPasswordPage,
              child: const Text("Forgot password?"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> login(WidgetRef ref) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      await ref.read(authProvider.notifier).login(email, password);
      final authState = ref.read(authProvider);
      if (authState.user != null) {
        Navigator.pushReplacementNamed(context, '/habitPlay', arguments: {
          'email': authState.user!.email,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authState.error ?? 'Login failed',
              style: const TextStyle(color: Colors.red),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Email and password are required',
            style: TextStyle(color: Colors.red),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
      );
    }
  }

  Widget _buildLoginButton() {
    return Consumer(
      builder: (context, ref, _) {
        return ColoredButton(
          onPressed: () => login(ref),
          labelText: 'Login',
        );
      },
    );
  }

  Widget _buildCreateAccountButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Are you a new user?"),
        GestureDetector(
          onTap: widget.togglePages,
          child: const Text(
            " Register",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // Navigation methods
  void _navigateToForgotPasswordPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ForgotPasswordPage(),
      ),
    );
  }
}
