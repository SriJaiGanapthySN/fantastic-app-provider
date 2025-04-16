import 'package:flutter/material.dart';

class WhiteBox extends StatelessWidget {
  final String text;
  const WhiteBox({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;

    return Container(
      width: double.infinity, // make it full width or adjust as needed
      padding: EdgeInsets.symmetric(
        vertical: height * 0.035, // dynamic padding based on screen height
        horizontal: height * 0.03,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: TextStyle(
          color: Colors.deepPurple,
          fontSize: height * 0.02, // dynamic text size
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
