import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.black,
              ),
              onPressed: () {},
            ),
          ),
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(
                Icons.auto_graph,
                color: Colors.black,
              ),
              onPressed: () {},
            ),
          ),
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(
                Icons.favorite_border,
                color: Colors.black,
              ),
              onPressed: () {},
            ),
          ),
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(
                Icons.search,
                color: Colors.black,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
