import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<Box> openBox() async {
    return Hive.openBox('settings');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Box>(
      future: openBox(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          var box = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Settings'),
            ),
            body: ListView(
              children: <Widget>[
                Switch(
                    value: box.get("hello") ?? false,
                    onChanged: (value) {
                      box.put("hello", value);
                      setState(() {});
                    }),
              ],
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Settings'),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
