import 'package:flutter/material.dart';

class SummaryItemData {
  final String title;
  final String count;
  final IconData icon;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final Color iconColor;

  SummaryItemData({
    required this.title,
    required this.count,
    required this.icon,
    required this.backgroundColor,
    required this.iconBackgroundColor,
    required this.iconColor,
  });
}

class ActivityLogItem {
  final IconData icon;
  final String message;
  final String timestamp;

  ActivityLogItem({required this.icon, required this.message, required this.timestamp});
}

class StarStudentItem {
  final String name;
  final String id;
  final String marks;
  final String? avatarUrl;

  StarStudentItem({required this.name, required this.id, required this.marks, this.avatarUrl});
}
