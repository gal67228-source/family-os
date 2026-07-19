import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('עוד')),
        body: ListView(
          children: const <Widget>[
            ListTile(
              leading: Icon(Icons.calendar_month_rounded),
              title: Text('יומן משפחתי'),
            ),
            ListTile(
              leading: Icon(Icons.timeline_rounded),
              title: Text('Timeline'),
            ),
            ListTile(
              leading: Icon(Icons.description_rounded),
              title: Text('מסמכים'),
            ),
            ListTile(
              leading: Icon(Icons.settings_rounded),
              title: Text('הגדרות'),
            ),
          ],
        ),
      ),
    );
  }
}
