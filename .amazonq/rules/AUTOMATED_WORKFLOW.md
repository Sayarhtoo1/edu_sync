# Automated Desktop Screen Implementation Workflow

## How to Use This Workflow

This workflow automates the implementation of desktop screens one by one in the order specified in `DESKTOP_SCREENS_IMPLEMENTATION_ORDER.md`.

---

## Step-by-Step Automated Process

### For Each Screen in Order:

Copy and paste this prompt template, replacing `[SCREEN_NUMBER]`, `[MOBILE_PATH]`, and `[DESKTOP_PATH]`:

```
AUTOMATED DESKTOP SCREEN IMPLEMENTATION

SCREEN NUMBER: [SCREEN_NUMBER] of 96
MOBILE SCREEN: [MOBILE_PATH]
DESKTOP SCREEN: [DESKTOP_PATH]

STEP 1 - CHECK FILE EXISTENCE:
List all files in the desktop directory for this screen.
Check if the desktop screen file already exists.

STEP 2A - IF FILE EXISTS:
Read the existing desktop screen file.
Analyze current implementation:
- Layout structure
- Features implemented
- Services used
- Components used
- Issues or missing features

Then enhance it following the Desktop UI/UX Enhancement Plan.
Use fsReplace to modify specific sections only.

STEP 2B - IF FILE DOES NOT EXIST:
Read the mobile screen file.
Analyze:
- Features and functionality
- Data displayed
- User interactions
- Services used
- Models used

Design desktop layout with:
- Multi-column layout (2-3 columns)
- Enhanced data tables
- Desktop-specific interactions
- Proper spacing (24-32px)

Create the desktop screen file using:
- DesktopScaffold wrapper
- Existing services from lib/services/
- Existing components from lib/widgets/
- Color system: #3498DB, #2ECC71, #E74C3C, #F39C12
- Spacing: 24-32px between sections

STEP 3 - VERIFY IMPLEMENTATION:
Check:
- Code compiles without errors
- Follows design system
- Has loading states
- Has error states
- Has empty states
- Responsive layout
- No breaking changes to mobile

STEP 4 - MARK COMPLETE:
Confirm screen is complete and ready for next screen.

RULES TO FOLLOW:
- Use existing services (no duplication)
- Use existing components
- Follow Desktop Development Rules
- Make minimal changes if modifying
- Never delete and recreate
- Don't break mobile screens
```

---

## Quick Start Commands

### Phase 0: Foundation & Authentication

#### Screen 1: Splash Screen
```
AUTOMATED DESKTOP SCREEN IMPLEMENTATION

SCREEN NUMBER: 1 of 96
MOBILE SCREEN: lib/screens/splash_screen.dart
DESKTOP SCREEN: lib/screens/desktop/common/desktop_splash_screen.dart

[Follow automated workflow above]
```

#### Screen 2: Login Screen
```
AUTOMATED DESKTOP SCREEN IMPLEMENTATION

SCREEN NUMBER: 2 of 96
MOBILE SCREEN: lib/screens/auth/login_screen.dart
DESKTOP SCREEN: lib/screens/desktop/auth/desktop_login_screen.dart

[Follow automated workflow above]
```

#### Screen 3: Register Screen
```
AUTOMATED DESKTOP SCREEN IMPLEMENTATION

SCREEN NUMBER: 3 of 96
MOBILE SCREEN: lib/screens/auth/register_screen.dart
DESKTOP SCREEN: lib/screens/desktop/auth/desktop_register_screen.dart

[Follow automated workflow above]
```

#### Screen 4: Forgot Password Screen
```
AUTOMATED DESKTOP SCREEN IMPLEMENTATION

SCREEN NUMBER: 4 of 96
MOBILE SCREEN: lib/screens/auth/forgot_password_screen.dart
DESKTOP SCREEN: lib/screens/desktop/auth/desktop_forgot_password_screen.dart

[Follow automated workflow above]
```

#### Screen 5: Reset Password Screen
```
AUTOMATED DESKTOP SCREEN IMPLEMENTATION

SCREEN NUMBER: 5 of 96
MOBILE SCREEN: lib/screens/auth/reset_password_screen.dart
DESKTOP SCREEN: lib/screens/desktop/auth/desktop_reset_password_screen.dart

[Follow automated workflow above]
```

---

## Batch Processing Template

For implementing multiple screens in one session:

```
BATCH DESKTOP SCREEN IMPLEMENTATION

SCREENS TO IMPLEMENT: [Start Number] to [End Number]

For each screen:
1. Check file existence
2. Read mobile screen
3. Create/enhance desktop screen
4. Verify implementation
5. Move to next screen

SCREENS LIST:
[Screen Number]: [Mobile Path] → [Desktop Path]
[Screen Number]: [Mobile Path] → [Desktop Path]
[Screen Number]: [Mobile Path] → [Desktop Path]

Follow Desktop Development Rules for all screens.
Use automated workflow for each screen.
Report completion status after each screen.
```

---

## Progress Tracking

### After Each Screen:
1. Mark screen as complete in `DESKTOP_SCREENS_IMPLEMENTATION_ORDER.md`
2. Update progress counter
3. Note any issues or deviations
4. Proceed to next screen

### Progress Report Template:
```
PROGRESS REPORT

Completed: [Number] of 96 screens ([Percentage]%)
Current Phase: [Phase Name]
Last Completed: [Screen Name]
Next Up: [Screen Name]

Issues Encountered: [List any issues]
Deviations from Plan: [List any deviations]
Estimated Completion: [Date/Time]
```

---

## Quality Checklist (Run After Each Screen)

Quick verification before moving to next screen:

- [ ] File exists in correct location
- [ ] Code compiles without errors
- [ ] Uses DesktopScaffold wrapper
- [ ] Follows color system
- [ ] Has loading state
- [ ] Has error state
- [ ] Has empty state
- [ ] Uses existing services
- [ ] Uses existing components
- [ ] Mobile screen not broken
- [ ] Responsive layout
- [ ] Proper spacing (24-32px)

---

## Error Recovery

If something goes wrong:

```
ERROR RECOVERY

Screen Number: [Number]
Error Description: [Description]

STEP 1: Identify the issue
STEP 2: Check if file was created/modified
STEP 3: If created incorrectly, read and fix using fsReplace
STEP 4: If broken, revert changes
STEP 5: Re-attempt with corrected approach
STEP 6: Verify fix
STEP 7: Continue to next screen
```

---

## Completion Criteria

A screen is considered complete when:

1. ✅ Desktop file exists in correct location
2. ✅ Code compiles without errors
3. ✅ Follows all Desktop Development Rules
4. ✅ Implements all features from mobile version
5. ✅ Enhanced with desktop-specific features
6. ✅ Has proper error handling
7. ✅ Has loading/empty/error states
8. ✅ Uses existing services and components
9. ✅ Mobile version still works
10. ✅ Passes quality checklist

---

## Daily Implementation Goal

**Recommended pace**: 5-10 screens per day

### Daily Workflow:
1. Start with next screen in order
2. Use automated workflow template
3. Implement screen
4. Verify quality
5. Mark complete
6. Repeat until daily goal reached
7. Generate progress report

### Weekly Milestones:
- **Week 1**: Complete Phase 0-1 (12 screens)
- **Week 2**: Complete Phase 2-3 (17 screens)
- **Week 3**: Complete Phase 4-5 (28 screens)
- **Week 4**: Complete Phase 6-7 (16 screens)
- **Week 5**: Complete Phase 8-9 (13 screens)
- **Week 6**: Complete Phase 10-13 (10 screens)

---

## Final Verification

After completing all 96 screens:

```
FINAL VERIFICATION CHECKLIST

- [ ] All 96 screens implemented
- [ ] All screens compile without errors
- [ ] All screens follow design system
- [ ] All mobile screens still work
- [ ] All routes registered
- [ ] All services used correctly
- [ ] All components reused
- [ ] Performance acceptable
- [ ] No memory leaks
- [ ] Accessibility compliant
- [ ] Documentation updated
- [ ] Ready for production
```

---

## Next Screen Command

Always use this to get the next screen to implement:

```
What is the next screen to implement according to DESKTOP_SCREENS_IMPLEMENTATION_ORDER.md?
Provide the screen number, mobile path, and desktop path.
Then start the automated workflow for that screen.
```
