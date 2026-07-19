import 'package:flutter/material.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('משימות')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 112),
          children: const <Widget>[
            SearchBar(
              hintText: 'חיפוש משימות',
              leading: Icon(Icons.search_rounded),
            ),
            SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(Icons.radio_button_unchecked_rounded),
                title: Text('לנקות את המטבח'),
                subtitle: Text('היום · דני ונועה'),
                trailing: Chip(label: Text('גבוה')),
              ),
            ),
            SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: Icon(Icons.lock_outline_rounded),
                title: Text('להכין מצגת'),
                subtitle: Text('פרטי · מחר'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
