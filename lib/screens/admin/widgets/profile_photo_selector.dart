import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:edu_sync/l10n/app_localizations.dart';
import 'package:edu_sync/theme/app_theme.dart';

class ProfilePhotoSelector extends StatelessWidget {
  final File? profilePhotoFile;
  final String? currentProfilePhotoUrl;
  final Function() onPickProfilePhoto;
  final Color contextualAccentColor;

  const ProfilePhotoSelector({
    super.key,
    required this.profilePhotoFile,
    required this.currentProfilePhotoUrl,
    required this.onPickProfilePhoto,
    required this.contextualAccentColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.profilePhotoLabel, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: Container(
                  height: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: theme.inputDecorationTheme.fillColor ??
                          cardBackgroundColor.withAlpha(200),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                          color: theme.inputDecorationTheme.enabledBorder
                                  ?.borderSide.color ??
                              textLightGrey.withOpacity(0.5))),
                  child: profilePhotoFile != null
                      ? Image.file(profilePhotoFile!,
                          height: 90, fit: BoxFit.contain)
                      : (currentProfilePhotoUrl != null &&
                              currentProfilePhotoUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: currentProfilePhotoUrl!,
                              height: 90,
                              fit: BoxFit.contain,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => Text(
                                  l10n.couldNotLoadImage,
                                  style: theme.textTheme.bodySmall),
                            )
                          : Text(l10n.noProfilePhoto,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: textLightGrey))),
                )),
                const SizedBox(width: 16),
                TextButton.icon(
                  style: TextButton.styleFrom(
                      foregroundColor: contextualAccentColor),
                  icon: const Icon(Icons.image),
                  label: Text(l10n.selectPhotoButton),
                  onPressed: onPickProfilePhoto,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
