import 'package:flutter/material.dart';

class AlarmsScreen extends StatefulWidget {
  const AlarmsScreen({Key? key}) : super(key: key);

  @override
  State<AlarmsScreen> createState() => _AlarmsScreenState();
}

class _AlarmsScreenState extends State<AlarmsScreen> {
  bool bedtimeEnabled = true;
  bool wakeupEnabled = true;
  bool reminderEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFDEEBFF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Text(
                'Alarmas',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Configura tus alarmas\npara que te recordemos\nhidratarte',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF3B82F6),
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildAlarmCard(
                        'Me acuesto',
                        Icons.access_time,
                        '00:00 h',
                        bedtimeEnabled,
                        (value) => setState(() => bedtimeEnabled = value),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildAlarmCard(
                        'Me levanto',
                        Icons.access_time,
                        '00:00 h',
                        wakeupEnabled,
                        (value) => setState(() => wakeupEnabled = value),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildAlarmCard(
                        'Recordatorio cada',
                        Icons.notifications,
                        '1 h 30 min',
                        reminderEnabled,
                        (value) => setState(() => reminderEnabled = value),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlarmCard(
    String title,
    IconData icon,
    String time,
    bool enabled,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1E3A8A),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: const Color(0xFF9CA3AF),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    time,
                    style: const TextStyle(
                      color: Color(0xFF374151),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Switch(
                value: enabled,
                onChanged: onChanged,
                activeColor: const Color(0xFF60A5FA),
              ),
            ],
          ),
        ],
      ),
    );
  }
}