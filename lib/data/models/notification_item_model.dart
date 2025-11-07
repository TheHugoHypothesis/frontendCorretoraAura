import 'package:flutter/material.dart';

class NotificationItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String time;

  NotificationItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.time,
  });
}
