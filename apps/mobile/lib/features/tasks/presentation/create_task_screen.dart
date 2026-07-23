import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../families/application/family_controller.dart';
import '../../families/domain/family_member.dart';
import '../application/task_controller.dart';
import '../domain/family_task.dart';

String _formatDate(DateTime date) {
  final String day = date.day.toString().padLeft(2, '0');
  final String month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final TextEditingController _title = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  DateTime _dueDate = DateTime.now();
  String _assignee = '';

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final family = ref.watch(familyControllerProvider).activeFamily;
    if (family == null) {
      return const Scaffold(body: Center(child: Text('אין משפחה פעילה')));
    }
    final List<FamilyMember> members = family.members;
    if (_assignee.isEmpty && members.isNotEmpty) {
      _assignee = members.first.name;
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('משימה חדשה')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            AppCard(
              child: Column(
                children: <Widget>[
                  AppTextField(
                    controller: _title,
                    label: 'כותרת המשימה',
                    icon: Icons.task_alt_rounded,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _assignee.isEmpty ? null : _assignee,
                    decoration: const InputDecoration(labelText: 'אחראי/ת'),
                    items: members
                        .map((FamilyMember m) => DropdownMenuItem<String>(
                              value: m.name,
                              child: Text(m.name),
                            ))
                        .toList(),
                    onChanged: (String? value) =>
                        setState(() => _assignee = value ?? ''),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<TaskPriority>(
                    initialValue: _priority,
                    decoration: const InputDecoration(labelText: 'עדיפות'),
                    items: TaskPriority.values
                        .map((TaskPriority p) => DropdownMenuItem<TaskPriority>(
                              value: p,
                              child: Text(p.label),
                            ))
                        .toList(),
                    onChanged: (TaskPriority? value) {
                      if (value != null) setState(() => _priority = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_month_rounded),
                    title: const Text('תאריך יעד'),
                    subtitle: Text(_formatDate(_dueDate)),
                    onTap: () async {
                      final DateTime? value = await showDatePicker(
                        context: context,
                        initialDate: _dueDate,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate:
                            DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (value != null) setState(() => _dueDate = value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppPrimaryButton(
              label: 'שמור משימה',
              onPressed: () async {
                final bool ok =
                    await ref.read(taskControllerProvider.notifier).addTask(
                          familyId: family.id,
                          title: _title.text,
                          assigneeName: _assignee,
                          priority: _priority,
                          dueDate: _dueDate,
                        );
                if (ok && context.mounted) context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
