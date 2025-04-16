import 'package:flutter/material.dart';
import 'onBoard2.dart';
import 'package:lottie/lottie.dart';

class Onboard1 extends StatefulWidget {
  const Onboard1({super.key});

  @override
  _Onboard1State createState() => _Onboard1State();
}

class _Onboard1State extends State<Onboard1> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnBoard2()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Lottie.asset('assets/your_animation.json', height: 300),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 160.0,left: 40,right: 40),
            child: Text(
              'Enter the Fabulous world , where you will turn your intentions into into reality',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}


