import 'package:flutter/material.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart';

class GreetingSection extends StatelessWidget {
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return const SizedBox.shrink(); // Or a placeholder widget
    }
    final textTheme = Theme.of(context).textTheme;
    const Color textDarkGrey = Color(0xFF2C2C2C);
    const Color textLightGrey = Color(0xFF8C8C8C);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.welcomeAdmin ?? 'Welcome, Admin!', // "Welcome, Admin!" or similar
          style: textTheme.bodyMedium?.copyWith(color: textLightGrey),
        ),
        const SizedBox(height: 4),
        Text(
          "Admin Dashboard", // As per Dribbble
          style: textTheme.headlineMedium?.copyWith(color: textDarkGrey, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}