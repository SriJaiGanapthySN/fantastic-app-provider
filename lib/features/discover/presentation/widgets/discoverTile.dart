
import 'package:flutter/material.dart';

class discoverTile extends StatelessWidget {
  const discoverTile({
    super.key,
    required this.url,
    required this.title,
    this.onTap,
  });

  final String url;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // Connected onTap
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(url),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            alignment: Alignment.topLeft,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 29,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}