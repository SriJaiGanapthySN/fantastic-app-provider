import 'package:fantastic_app_riverpod/profile/profileWholeMenu.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final DraggableScrollableController _controller =
  DraggableScrollableController();

  @override
  Widget build(BuildContext context) {
    // Show bottom sheet as soon as screen loads
    Future.delayed(Duration.zero, () => _showBottomSheet(context));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Text('')), // Empty body
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _DraggableSheetWithClose(controller: _controller);
      },
    );
  }
}

class _DraggableSheetWithClose extends StatefulWidget {
  final DraggableScrollableController controller;

  const _DraggableSheetWithClose({required this.controller});

  @override
  State<_DraggableSheetWithClose> createState() =>
      _DraggableSheetWithCloseState();
}

class _DraggableSheetWithCloseState extends State<_DraggableSheetWithClose> {
  @override
  void initState() {
    super.initState();

    widget.controller.addListener(() {
      if (widget.controller.size < 0.26) {
        if (mounted) {
          Navigator.of(context).pop(); // Close bottom sheet first
          Future.delayed(Duration(milliseconds: 200), () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => CustomScreen()),
            );
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: widget.controller,
      initialChildSize: 0.75,
      minChildSize: 0.25,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Follow Icon at Top-Right
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(Icons.person_add_alt_1_outlined),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => FollowScreen()),
                        );
                      },
                    ),
                  ),

                  /// Profile Row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage:
                        NetworkImage('https://via.placeholder.com/150'),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Display Name',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  /// Additional Texts
                  Text(
                    'Some more text goes here.\nYou can add more info here below the profile section.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class FollowScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Follow Page"),
      ),
      body: Center(child: Text("This is the follow page")),
    );
  }
}
