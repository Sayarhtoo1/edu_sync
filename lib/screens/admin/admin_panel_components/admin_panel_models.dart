import 'package:flutter/material.dart';

class SummaryItemData {
  final String title;
  final String count;
  final IconData icon;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final VoidCallback? onTap;

  SummaryItemData({
    required this.title,
    required this.count,
    required this.icon,
    required this.backgroundColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    this.onTap,
  });
}

class ActivityLogItem {
  final IconData icon;
  final String message;
  final String timestamp;

  ActivityLogItem({required this.icon, required this.message, required this.timestamp});
}

