import 'package:flutter/material.dart';

import '../../../core/design/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../application/notification_service.dart';
import '../domain/notification_settings.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  NotificationSettings? _settings;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final NotificationSettings settings =
        await NotificationService.instance.loadSettings();

    if (mounted) {
      setState(() => _settings = settings);
    }
  }

  Future<void> _update(NotificationSettings settings) async {
    setState(() {
      _settings = settings;
      _saving = true;
    });

    await NotificationService.instance.saveSettings(settings);

    if (mounted) {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final NotificationSettings? settings = _settings;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.softBlue,
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              SizedBox(width: 10),
              Text('הגדרות התראות'),
            ],
          ),
        ),
        body: settings == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  AppCard(
                    child: Column(
                      children: <Widget>[
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('הפעלת התראות'),
                          subtitle: const Text(
                            'אירועים, משימות וקניות',
                          ),
                          secondary: const Icon(
                            Icons.notifications_rounded,
                          ),
                          value: settings.enabled,
                          onChanged: (bool value) {
                            _update(
                              settings.copyWith(enabled: value),
                            );
                          },
                        ),
                        const Divider(),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('תזכורות לאירועים'),
                          secondary: const Icon(Icons.event_rounded),
                          value: settings.eventReminders,
                          onChanged: settings.enabled
                              ? (bool value) {
                                  _update(
                                    settings.copyWith(
                                      eventReminders: value,
                                    ),
                                  );
                                }
                              : null,
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('תזכורות למשימות'),
                          secondary: const Icon(Icons.task_alt_rounded),
                          value: settings.taskReminders,
                          onChanged: settings.enabled
                              ? (bool value) {
                                  _update(
                                    settings.copyWith(
                                      taskReminders: value,
                                    ),
                                  );
                                }
                              : null,
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('תזכורות לקניות קבועות'),
                          secondary: const Icon(
                            Icons.shopping_cart_rounded,
                          ),
                          value: settings.shoppingReminders,
                          onChanged: settings.enabled
                              ? (bool value) {
                                  _update(
                                    settings.copyWith(
                                      shoppingReminders: value,
                                    ),
                                  );
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppCard(
                    child: Column(
                      children: <Widget>[
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('סיכום יומי'),
                          subtitle: const Text(
                            'אירועים, משימות ופריטים לקנייה',
                          ),
                          secondary: const Icon(Icons.wb_sunny_rounded),
                          value: settings.dailySummary,
                          onChanged: settings.enabled
                              ? (bool value) {
                                  _update(
                                    settings.copyWith(
                                      dailySummary: value,
                                    ),
                                  );
                                }
                              : null,
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          enabled: settings.enabled && settings.dailySummary,
                          leading: const Icon(Icons.schedule_rounded),
                          title: const Text('שעת הסיכום'),
                          subtitle: Text(
                            '${settings.dailySummaryHour.toString().padLeft(2, '0')}:'
                            '${settings.dailySummaryMinute.toString().padLeft(2, '0')}',
                          ),
                          onTap: () async {
                            final TimeOfDay? value = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                hour: settings.dailySummaryHour,
                                minute: settings.dailySummaryMinute,
                              ),
                            );

                            if (value != null) {
                              await _update(
                                settings.copyWith(
                                  dailySummaryHour: value.hour,
                                  dailySummaryMinute: value.minute,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () async {
                      final bool granted = await NotificationService.instance
                          .requestPermissions();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              granted
                                  ? 'הרשאת ההתראות פעילה'
                                  : 'הרשאת ההתראות לא אושרה',
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.security_rounded),
                    label: const Text('בדיקת הרשאה'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await NotificationService.instance.showTestNotification();
                    },
                    icon: const Icon(Icons.notifications_active_rounded),
                    label: const Text('שלח התראת בדיקה'),
                  ),
                  if (_saving) ...<Widget>[
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(),
                  ],
                ],
              ),
      ),
    );
  }
}
