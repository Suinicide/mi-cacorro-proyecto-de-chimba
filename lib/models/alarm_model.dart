class AlarmModel {
  final String id;
  final String title;
  final String time;
  final bool enabled;

  AlarmModel({
    required this.id,
    required this.title,
    required this.time,
    required this.enabled,
  });

  AlarmModel copyWith({
    String? id,
    String? title,
    String? time,
    bool? enabled,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      enabled: enabled ?? this.enabled,
    );
  }
}