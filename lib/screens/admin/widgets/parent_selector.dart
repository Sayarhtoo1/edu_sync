import 'package:flutter/material.dart';
import 'package:edu_sync/models/user.dart' as app_user;
import 'package:edu_sync/l10n/gen/app_localizations.dart';

class ParentSelector extends StatelessWidget {
  final bool isLoadingParents;
  final List<app_user.User> availableParents;
  final List<String> linkedParentIds;
  final Function(String, bool?) onParentChanged;
  final Color contextualAccentColor;

  const ParentSelector({
    super.key,
    required this.isLoadingParents,
    required this.availableParents,
    required this.linkedParentIds,
    required this.onParentChanged,
    required this.contextualAccentColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return const SizedBox.shrink(); // Or a placeholder widget
    }
    final theme = Theme.of(context);

    if (isLoadingParents) {
      return Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)));
    }
    if (availableParents.isEmpty) {
      return Text(l10n.noParentsAvailableToLink ?? 'No parents available to link',
          style: theme.textTheme.bodyMedium);
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(l10n.linkParentsTitle ?? 'Link Parents',
                  style: theme.textTheme.titleLarge),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: availableParents.length,
              itemBuilder: (context, index) {
                final parent = availableParents[index];
                return CheckboxListTile(
                  title: Text(parent.fullName ?? l10n.unnamedParent ?? 'Unnamed Parent',
                      style: theme.textTheme.bodyLarge),
                  value: linkedParentIds.contains(parent.id),
                  activeColor: contextualAccentColor,
                  onChanged: (bool? selected) {
                    onParentChanged(parent.id, selected);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
