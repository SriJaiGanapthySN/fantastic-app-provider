import 'package:fantastic_app_riverpod/setting/settingPage.dart';
import 'package:flutter/material.dart';
import 'DayEndScreen.dart';

class AdvancedSettingsPage extends StatefulWidget {
  final String selectedTime;
  const AdvancedSettingsPage({Key? key, this.selectedTime = '2am (next day)'}) : super(key: key);

  @override
  State<AdvancedSettingsPage> createState() => _AdvancedSettingsPageState();
}

class _AdvancedSettingsPageState extends State<AdvancedSettingsPage> {
  late String selectedTime;

  @override
  void initState() {
    super.initState();
    selectedTime = widget.selectedTime;
  }
  void _showCustomPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.0),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top illustration (replace with your asset if needed)
              Container(
                width: double.infinity,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFF1CCFCF), // teal-ish background
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.change_history, color: Colors.greenAccent, size: 32), // Triangle
                      SizedBox(width: 12),
                      Icon(Icons.circle, color: Colors.pinkAccent, size: 32), // Circle
                      SizedBox(width: 12),
                      Icon(Icons.door_front_door, color: Colors.pink, size: 32), // Door
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                child: Column(
                  children: [
                    const Text(
                      'Signing out?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'If you sign out, your journey progress won’t back up.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdvancedSettingsPage()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Stay Signed In',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdvancedSettingsPage()));
                          // Show the same popup again
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF9E6E6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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
          onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SettingsPage())),
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
          'Advanced Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Day ends at'),
            trailing: Text(
              selectedTime,
              style: const TextStyle(color: Colors.grey),
            ),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DayEndsAtPage(selectedOption: selectedTime),
                ),
              );

              if (result != null && result is String) {
                setState(() {
                  selectedTime = result;
                });
              }
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: Row(
              children: [
                Icon(Icons.restart_alt_rounded),
                Text('Redownload everything'),
              ],
            ),
            trailing: Icon(Icons.navigate_next),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            title: Row(
              children: [
                Icon(Icons.power_settings_new_rounded),
                const Text('Restart the Journey'),
              ],
            ),
            trailing: Icon(Icons.navigate_next),
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Restart the Journey',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'This will re-start the current journey from Day One. Your habits and stats won’t be affected.\n\nAre you sure you want to re-start?',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Add your restart logic here
                                _showCustomPopup();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[700],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text(
                                'Restart',
                                style: TextStyle(fontSize: 18,color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },

          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
