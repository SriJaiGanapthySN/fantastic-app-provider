import 'package:flutter/material.dart';

class DayEndsAtPage extends StatefulWidget {
  final String selectedOption;
  const DayEndsAtPage({Key? key, required this.selectedOption}) : super(key: key);

  @override
  State<DayEndsAtPage> createState() => _DayEndsAtPageState();
}

class _DayEndsAtPageState extends State<DayEndsAtPage> {
  late String selectedOption;

  @override
  void initState() {
    super.initState();
    selectedOption = widget.selectedOption;
  }

  void _goBack() {
    Navigator.pop(context, selectedOption);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: _goBack,
          child: Row(
            children: const [
              SizedBox(width: 12),
              Icon(Icons.arrow_back_ios, size: 18, color: Colors.red),
              Text(
                'Back',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Day ends at',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          buildOption('Midnight'),
          buildOption(
            '2am (next day)',
            subtitle: 'Habits completed before 2am will count for the previous day',
          ),
        ],
      ),
    );
  }

  Widget buildOption(String title, {String? subtitle}) {
    final isSelected = selectedOption == title;
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
        subtitle,
        style: const TextStyle(color: Colors.grey),
      )
          : null,
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.red, size: 20)
          : null,
      onTap: () {
        setState(() {
          selectedOption = title;
        });
        _goBack(); // Immediately return selection on tap
      },
    );
  }
}
