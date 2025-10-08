# In-App Notification Pop-up Mechanism and Background Notification Handling Design

## Part 1: Design In-App Notification Pop-up Mechanism

The goal is to display a pop-up notification on the user dashboard (Admin, Teacher, Parent) when a new announcement is received while the app is in the foreground.

### Proposed Design:

1.  **Notification Stream in `NotificationService`:**
    *   Add a `StreamController<Announcement>` to `NotificationService` (e.g., `_inAppAnnouncementController`).
    *   Expose a `Stream<Announcement>` (e.g., `inAppAnnouncements`) from `NotificationService` that dashboard screens can subscribe to.
    *   When a new announcement is received via Supabase Realtime in `subscribeToAnnouncements`, in addition to triggering a local notification, add the `Announcement` object to this stream if the app is in the foreground.

2.  **In-App Notification Widget:**
    *   Create a new, reusable Flutter widget (e.g., `InAppNotificationPopup`) that takes an `Announcement` object as input.
    *   This widget should display the announcement title and a brief content preview in a visually distinct pop-up (e.g., a `SnackBar`, `OverlayEntry`, or a custom dialog).
    *   It should have a dismiss button and, optionally, a "View" button that navigates to the `AnnouncementsScreen`.

3.  **Integration with Dashboard Screens:**
    *   In `AdminPanelScreen`, `TeacherDashboardScreen`, and `ParentDashboardScreen`:
        *   Subscribe to `NotificationService.inAppAnnouncements` in the `initState` method.
        *   When a new announcement is received from the stream, display the `InAppNotificationPopup` widget.
        *   Ensure the subscription is disposed of in `dispose`.

## Part 2: Verify Background Phone Notifications

The existing `NotificationService` already triggers local notifications. The goal is to confirm they work reliably in the background.

### Verification Plan:

1.  **Review `NotificationService.showNotification()`:**
    *   Confirm that the `showNotification` method is called regardless of the app's foreground/background state when a new announcement is received via Supabase Realtime. The current implementation within `subscribeToAnnouncements` should handle this.
    *   Ensure `AndroidNotificationDetails` and `DarwinNotificationDetails` are configured with appropriate `importance`, `priority`, and `presentAlert/presentSound/presentBadge` settings to ensure visibility. (This was addressed in the previous implementation step).

2.  **Testing Strategy (for later implementation phase):**
    *   Test by sending new announcements while the app is in the background and terminated to confirm local notifications appear on the device's notification tray.