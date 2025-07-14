import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hijri_calendar/hijri_calendar.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/l10n/app_localizations.dart';

class DateDisplayWidget extends StatelessWidget {
  const DateDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final schoolProvider = Provider.of<SchoolProvider>(context);
    final int dayAdjustment = schoolProvider.currentSchool?.hijriDayAdjustment ?? 0;

    final now = DateTime.now();
    final gregorianDate = DateFormat.yMMMMd(l10n.localeName).format(now);

    // Calculate Hijri date with adjustment
    final hijriCalendar = HijriCalendarConfig.now();
    final jdn = (now.millisecondsSinceEpoch / 86400000).floor() + 2440588;
    hijriCalendar.setAdjustments({jdn: dayAdjustment});
    final hijriDateFormatted = hijriCalendar.toFormat("dd MMMM yyyy");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          gregorianDate,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        Text(
          "($hijriDateFormatted)",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
