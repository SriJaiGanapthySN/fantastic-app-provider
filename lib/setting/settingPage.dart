import 'package:flutter/material.dart';

import 'AdvancedSetting.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String selectedTab = 'General';

  bool notificationSound = true;
  bool alarmSound = true;
  bool soundEffects = true;
  bool backgroundMusic = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Settings', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Done', style: TextStyle(color: Colors.red)),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = 'General';
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: selectedTab == 'General' ? Colors.red : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            'General',
                            style: TextStyle(
                              color: selectedTab == 'General' ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = 'Premium';
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: selectedTab == 'Premium' ? Colors.red : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            'Premium',
                            style: TextStyle(
                              color: selectedTab == 'Premium' ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: const Text('Rate The Fabulous!'),
                  onTap: () {},
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text('GENERAL SETTINGS', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  title: Row(
                    children: [
                      const Text('Display Name'),
                    ],
                  ),
                  subtitle: const Text('Sarah'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text('NOTIFICATION SETTINGS', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                SwitchListTile(
                  title: const Text('Notification Sound'),
                  value: notificationSound,
                  onChanged: (val) {
                    setState(() {
                      notificationSound = val;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Alarm Sound'),
                  value: alarmSound,
                  onChanged: (val) {
                    setState(() {
                      alarmSound = val;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Sound Effects'),
                  value: soundEffects,
                  onChanged: (val) {
                    setState(() {
                      soundEffects = val;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Background Music'),
                  subtitle: const Text('Soothing background music will play during the routine'),
                  value: backgroundMusic,
                  onChanged: (val) {
                    setState(() {
                      backgroundMusic = val;
                    });
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Advanced Settings'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdvancedSettingsPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.group),
                  title: const Text('Join the Private Community'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.purple),
                  title: const Text('Follow us on Instagram'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('NEW', style: TextStyle(fontSize: 10)),
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.facebook, color: Colors.blue),
                  title: const Text('Like us on Facebook'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.alternate_email, color: Colors.lightBlue),
                  title: const Text('Follow us on X (Twitter)'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text('ACCOUNT', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.black),
                  title: const Text('Sign Out'),
                  subtitle: const Text('kt8wxg7hv8@privaterelay.appleid.com'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Sign out logic here
                  },
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text('PRIVACY', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text(
                    'Delete Your Account',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    // Delete account logic here
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
