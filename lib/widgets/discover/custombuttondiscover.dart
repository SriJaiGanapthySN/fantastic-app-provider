import 'package:flutter/material.dart';

class CustomButtonDiscover extends StatelessWidget {
  CustomButtonDiscover({
    super.key,
    required this.routineName,
    required this.handleButtonPress,
    required this.selectedButtonIndex,
    required this.a,
  });
  final int selectedButtonIndex;
  final Function handleButtonPress;
  final String routineName;
  final int a;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedButtonIndex == a;

    return Container(
      height: MediaQuery.of(context).size.width * 0.1,
      width: MediaQuery.of(context).size.width * 0.35,
      margin: EdgeInsets.only(bottom: 15, top: 10),
      child: TextButton(
        onPressed: () => handleButtonPress(a),
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: isSelected ? Colors.pinkAccent : Colors.black,
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          elevation: 5,
        ),
        child: Text(
          routineName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
