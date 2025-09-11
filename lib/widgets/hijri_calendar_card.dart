import 'package:flutter/material.dart';
import 'package:hijri_calendar/hijri_calendar.dart' as hijri_cal;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:edu_sync/providers/school_provider.dart'; // Import SchoolProvider
import 'package:edu_sync/screens/admin/admin_panel_constants.dart'; // Import new constants file

class HijriCalendarCard extends StatelessWidget {
  const HijriCalendarCard({super.key});

  @override
  Widget build(BuildContext context) {
    final schoolProvider = Provider.of<SchoolProvider>(context);
    final int hijriDayAdjustment = schoolProvider.currentSchool?.hijriDayAdjustment ?? 0;

    final todayGregorian = DateTime.now(); // Get unadjusted Gregorian date
    final todayHijri = hijri_cal.HijriCalendarConfig.fromGregorian(todayGregorian); // Convert to Hijri

    if (hijriDayAdjustment != 0) {
      // Calculate JDN for todayGregorian to apply adjustment
      int jdn = (todayGregorian.millisecondsSinceEpoch / 86400000).floor() + 2440588;
      todayHijri.setAdjustments({jdn: hijriDayAdjustment}); // Apply adjustment
    }
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
                  todayHijri.toFormat("dd MMMM yyyy"), // Corrected to use todayHijri
                  style: textTheme.titleLarge?.copyWith(color: textDarkGrey, fontWeight: FontWeight.bold),
                ),
                 const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, dd MMMM yyyy').format(todayGregorian), // Corrected to use todayGregorian
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
