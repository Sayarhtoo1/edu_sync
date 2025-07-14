import 'package:flutter/material.dart';
import 'package:hijri_calendar/hijri_calendar.dart';
import 'package:intl/intl.dart';

// --- Color Palette (Dribbble Inspired) ---
const Color appBackgroundColor = Color(0xFFF5F0FF); // Very light pastel purple
const Color cardBackgroundColor = Colors.white;
const Color textDarkGrey = Color(0xFF2C2C2C);
const Color textLightGrey = Color(0xFF8C8C8C);

// Accent colors for summary items
const Color accentStudents = Color(0xFFE0C7FF); // Pastel Purple
const Color iconBgStudents = Color(0xFFD4D0FB); // Slightly darker purple for icon bg
const Color iconColorStudents = Color(0xFF7A6FF0); // Icon color


class HijriCalendarCard extends StatelessWidget {
  const HijriCalendarCard({super.key});

  @override
  Widget build(BuildContext context) {
    final today = HijriCalendarConfig.now();
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: accentStudents,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Hijri Calendar',
                  style: textTheme.bodySmall?.copyWith(color: textDarkGrey.withAlpha((0.7 * 255).round())),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Text(
                  today.toFormat("dd MMMM yyyy"),
                  style: textTheme.titleLarge?.copyWith(color: textDarkGrey, fontWeight: FontWeight.bold),
                ),
                 const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()),
                  style: textTheme.bodyMedium?.copyWith(color: textLightGrey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundColor: iconBgStudents,
            child: Icon(Icons.calendar_today, color: iconColorStudents, size: 20),
          ),
        ],
      ),
    );
  }
}
