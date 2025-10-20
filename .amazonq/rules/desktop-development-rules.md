# Desktop Development Rules

## CRITICAL: File Existence Check

**RULE 0: ALWAYS CHECK FILE EXISTENCE BEFORE CREATING**
Before creating ANY desktop screen file, you MUST:
1. Check if the file already exists in `lib/screens/desktop/`
2. If file EXISTS: Read it, analyze it, and MODIFY the existing file
3. If file DOES NOT EXIST: Only then create a new file
4. NEVER delete and recreate unless explicitly requested by user

**File Check Command:**
```
List files in lib/screens/desktop/[role]/ to check if desktop_[screen_name].dart exists
```

## Core Development Rules

### RULE 1: Read Before Write
- Always read existing code before making changes
- Check `lib/screens/desktop/` for existing desktop screens
- Check `lib/widgets/desktop/` for existing components
- Check `lib/services/` for existing services
- Review related mobile screens in `lib/screens/[role]/`

### RULE 2: Reuse, Don't Recreate
- Use existing services from `lib/services/`
- Use existing models from `lib/models/`
- Use existing widgets from `lib/widgets/`
- Use existing providers from `lib/providers/`
- NEVER duplicate service logic

### RULE 3: Maintain Consistency
- Follow naming convention: `desktop_[screen_name].dart`
- Use DesktopScaffold for all desktop screens
- Follow color system: #3498DB (primary), #2ECC71 (success), #E74C3C (danger), #F39C12 (warning)
- Use consistent spacing: 24-32px between sections
- Follow typography: 24px headers, 14px body text

### RULE 4: Don't Break Mobile
- Keep mobile screens in `lib/screens/[role]/` untouched
- Desktop screens go in `lib/screens/desktop/[role]/`
- Use PlatformAdaptiveScreen wrapper if needed
- Test both platforms after changes

### RULE 5: Minimal Changes
- Make smallest possible changes to achieve goal
- Don't refactor working code unnecessarily
- Preserve existing functionality
- Focus on specific requirement only

### RULE 6: Desktop-First Design
- Optimize for 1920x1080+ screens
- Use multi-column layouts (2-3 columns)
- Leverage horizontal space
- Add desktop-specific interactions (hover, right-click)
- Implement keyboard shortcuts

### RULE 7: Component Hierarchy
Priority order for components:
1. Use existing desktop components from `lib/widgets/desktop/`
2. Use existing common components from `lib/widgets/common/`
3. Use Flutter Material components
4. Create new component only if none exist

### RULE 8: Error Handling
- Wrap all async operations in try-catch
- Show user-friendly error messages
- Implement loading states
- Implement empty states
- Add retry mechanisms

### RULE 9: Performance First
- Use const constructors where possible
- Implement pagination for large lists
- Debounce search inputs (500ms)
- Lazy load data
- Cache frequently accessed data

### RULE 10: State Management
- Use existing providers from `lib/providers/`
- Use Provider pattern for state
- Don't create new state management patterns
- Keep state immutable

## File Structure Rules

### Desktop Screen Location
```
lib/screens/desktop/
├── admin/
│   ├── desktop_admin_dashboard.dart
│   ├── desktop_student_management.dart
│   ├── desktop_staff_management.dart
│   └── ...
├── teacher/
│   ├── desktop_teacher_dashboard.dart
│   ├── desktop_attendance_marking.dart
│   └── ...
├── parent/
│   ├── desktop_parent_dashboard.dart
│   └── ...
└── common/
    └── ...
```

### Desktop Component Location
```
lib/widgets/desktop/
├── desktop_scaffold.dart
├── desktop_sidebar.dart
├── desktop_data_table.dart
├── desktop_card.dart
└── ...
```

## Code Quality Rules

### Imports
- Group imports: Flutter, packages, local
- Use relative imports for local files
- Remove unused imports

### Naming
- Classes: PascalCase (DesktopAdminDashboard)
- Files: snake_case (desktop_admin_dashboard.dart)
- Variables: camelCase (studentCount)
- Private: prefix with _ (_loadData)
- Constants: lowerCamelCase (kDefaultPadding)

### Comments
- Add comments for complex logic only
- Use /// for public API documentation
- Use // for inline comments
- Don't comment obvious code

### Formatting
- 2-space indentation
- Line length: 80-120 characters
- Trailing commas for better diffs
- Use dart format before committing

## Testing Rules

### Before Committing
- [ ] Code compiles without errors
- [ ] No warnings in console
- [ ] Screen displays correctly on desktop
- [ ] All interactions work
- [ ] Loading states work
- [ ] Error states work
- [ ] Empty states work
- [ ] Mobile screens still work

## Security Rules

- Never hardcode credentials
- Never expose service role keys
- Use environment variables for secrets
- Validate all user inputs
- Sanitize data before display

## Accessibility Rules

- Add semantic labels
- Support keyboard navigation
- Ensure color contrast (WCAG AA)
- Add focus indicators
- Support screen readers (web)
