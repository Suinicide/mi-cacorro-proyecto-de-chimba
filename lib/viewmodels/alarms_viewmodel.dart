import 'package:flutter/material.dart';
import '../models/alarm_model.dart';

class AlarmsViewModel extends ChangeNotifier {
  List<AlarmModel> _alarms = [
    AlarmModel(
      id: '1',
      title: 'Me acuesto',
      time: '00:00 h',
      enabled: true,
    ),
    AlarmModel(
      id: '2',
      title: 'Me levanto',
      time: '00:00 h',
      enabled: true,
    ),
    AlarmModel(
      id: '3',
      title: 'Recordatorio cada',
      time: '1 h 30 min',
      enabled: true,
    ),
  ];

  List<AlarmModel> get alarms => _alarms;

  void toggleAlarm(String id, bool enabled) {
    final index = _alarms.indexWhere((alarm) => alarm.id == id);
    if (index != -1) {
      _alarms[index] = _alarms[index].copyWith(enabled: enabled);
      notifyListeners();
    }
  }

  void updateAlarmTime(String id, String newTime) {
    final index = _alarms.indexWhere((alarm) => alarm.id == id);
    if (index != -1) {
      _alarms[index] = _alarms[index].copyWith(time: newTime);
      notifyListeners();
    }
  }
}