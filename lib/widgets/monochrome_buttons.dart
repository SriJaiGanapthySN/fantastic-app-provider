import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

class ColoredButton extends StatelessWidget {
  final String labelText;
  final ImageProvider? image;
  final VoidCallback? onPressed;

  const ColoredButton({
    super.key,
    required this.labelText,
    this.image,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 50,
        width: 350,
        child: MaterialButton(
          onPressed: onPressed,
          color: Theme.of(context).colorScheme.inverseSurface,
          elevation: 2,
          padding: const EdgeInsets.all(1),
          textColor: Theme.of(context).colorScheme.inversePrimary,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (image != null)
                Image(
                  image: image!,
                  height: 20,
                  width: 20,
                ),
              Text(
                labelText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.brightness == Brightness.light
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ButtonInsideTF extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;

  const ButtonInsideTF({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  State<ButtonInsideTF> createState() => _ButtonInsideTFState();
}

class _ButtonInsideTFState extends State<ButtonInsideTF> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextButton(
        onPressed: widget.onPressed,
        style: TextButton.styleFrom(
          elevation: 1,
          backgroundColor: Theme.of(context).colorScheme.primary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
        child: Text(
          widget.text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
      ),
    );
  }
}

Widget buildLoginWithGoogleButton() {
  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: Consumer(
      builder: (context, ref, _) {
        return ColoredButton(
          onPressed: () => ref.read(authProvider.notifier).signInWithGoogle(),
          labelText: "  Login with Google",
          image: AssetImage('assets/icons/google.png'),
        );
      },
    ),
  );
}

Widget buildLoginWithAppleButton() {
  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: Consumer(
      builder: (context, ref, _) {
        return ColoredButton(
          onPressed: () => ref.read(authProvider.notifier).signInWithApple(),
          labelText: "  Login with Apple",
          image: AssetImage(Theme.of(context).brightness == Brightness.light
              ? 'assets/icons/apple_light.png'
              : 'assets/icons/apple_dark.png'),
        );
      },
    ),
  );
}
