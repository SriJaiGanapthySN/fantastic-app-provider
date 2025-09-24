import 'package:flutter/material.dart';

class DailyCoaching extends StatelessWidget {
  const DailyCoaching(
      {super.key,
      required this.text,
      required this.url,
      required this.caption});

  final String text;
  final String url;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          Container(
            constraints: BoxConstraints(
              minHeight: 310,
              maxHeight: 400, // Allow the card to grow if content is longer
            ),
            width: 290,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: AssetImage(url),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              left: 20,
            ),
            constraints: BoxConstraints(
              minHeight: 290,
              maxHeight: 380, // Allow inner container to grow
            ),
            width: 270,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                    overflow: TextOverflow.visible,
                    maxLines: 3,
                  ),
                  Text(
                    '15 Dec',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                    ),
                  ),
                  SizedBox(
                    height: 70,
                  ),
                  Text(
                    caption,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.visible,
                    maxLines: 4,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.headphones),
                        label: Text("Listen")),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
