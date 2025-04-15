import 'package:flutter/material.dart';

class JourneyListItem extends StatelessWidget {
  final VoidCallback onTap;

  const JourneyListItem({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(130),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color.fromARGB(255, 255, 255, 255).withOpacity(0.05),
            const Color.fromARGB(255, 255, 255, 255).withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0),
          width: 1,
        ),
      ),
      child: Material(
        color: const Color.fromARGB(0, 255, 255, 255),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(130),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.map_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'All Journey',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.7),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 