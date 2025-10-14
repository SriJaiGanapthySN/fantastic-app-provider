import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  const MyTextfield(
      {super.key,
      required this.hinttext,
      required this.obscure,
      required this.controller,
      this.focusNode});

  final String hinttext;
  final bool obscure;
  final TextEditingController controller;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: hinttext,
        ),
        obscureText: obscure,
      ),
    );
  }
}
