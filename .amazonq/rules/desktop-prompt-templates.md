# Desktop Development Prompt Templates

## Template 1: Check and Modify/Create Desktop Screen

```
TASK: [Create/Modify] desktop screen for [screen_name]

STEP 1 - CHECK FILE EXISTENCE (MANDATORY):
List all files in lib/screens/desktop/[role]/ directory.
Check if desktop_[screen_name].dart exists.

STEP 2 - IF FILE EXISTS:
Read lib/screens/desktop/[role]/desktop_[screen_name].dart
Analyze current implementation and identify what needs to change.
Then modify the existing file using fsReplace.

STEP 2 - IF FILE DOES NOT EXIST:
Read lib/screens/[role]/[screen_name].dart (mobile version)
Design desktop layout with multi-column design.
Create new file at lib/screens/desktop/[role]/desktop_[screen_name].dart

REQUIREMENTS:
- [Requirement 1]
- [Requirement 2]
- [Requirement 3]

RULES TO FOLLOW:
- Use existing services from lib/services/
- Use existing components from lib/widgets/
- Follow color system: #3498DB, #2ECC71, #E74C3C, #F39C12
- Use spacing: 24-32px between sections
- Add loading, error, and empty states
- Make minimal changes if modifying existing file

DO NOT:
- Delete and recreate existing files
- Duplicate service logic
- Break mobile screens
- Create new services unnecessarily
```

---

## Template 2: Enhance Existing Desktop Screen

```
TASK: Enhance desktop_[screen_name].dart

CURRENT ISSUES:
- [Issue 1]
- [Issue 2]
- [Issue 3]

STEP 1: Read lib/screens/desktop/[role]/desktop_[screen_name].dart

STEP 2: Analyze and identify root causes of issues

STEP 3: Plan minimal changes to fix issues

STEP 4: Use fsReplace to modify specific sections only

REQUIREMENTS:
- Fix [specific issue]
- Add [specific feature]
- Improve [specific aspect]

CONSTRAINTS:
- Make minimal changes
- Preserve existing functionality
- Don't refactor unnecessarily
- Follow Desktop Development Rules
```

---

## Template 3: Create Reusable Desktop Component

```
TASK: Create reusable desktop component: [ComponentName]

STEP 1: Check if similar component exists
List components in lib/widgets/desktop/ and lib/widgets/common/

STEP 2: If similar component exists, use or extend it
If no similar component, proceed to create new one

COMPONENT SPECIFICATION:
Purpose: [Description]
Location: lib/widgets/desktop/[component_name].dart

Required Parameters:
- [param1]: [type] - [description]
- [param2]: [type] - [description]

Optional Parameters:
- [param1]: [type] - [description]
- [param2]: [type] - [description]

Callbacks:
- [callback1]: [signature] - [description]

Variants:
- [variant1]: [description]
- [variant2]: [description]

REQUIREMENTS:
- Highly reusable
- Customizable via parameters
- Follows design system
- Includes documentation comments
- Provides usage examples
```

---

## Template 4: Fix Bug in Desktop Screen

```
TASK: Fix bug in desktop_[screen_name].dart

BUG DESCRIPTION:
Issue: [Detailed description]
Steps to reproduce:
1. [Step 1]
2. [Step 2]
3. [Step 3]
Expected: [Expected behavior]
Actual: [Actual behavior]

STEP 1: Read lib/screens/desktop/[role]/desktop_[screen_name].dart

STEP 2: Identify root cause of the bug

STEP 3: Plan minimal fix

STEP 4: Implement fix using fsReplace

STEP 5: Verify fix doesn't break other functionality

CONSTRAINTS:
- Minimal changes only
- Add error handling if missing
- Test edge cases
- No refactoring unless necessary
```

---

## Template 5: Add Feature to Multiple Desktop Screens

```
TASK: Add [feature_name] to multiple desktop screens

AFFECTED SCREENS:
- lib/screens/desktop/[role1]/desktop_[screen1].dart
- lib/screens/desktop/[role2]/desktop_[screen2].dart
- lib/screens/desktop/[role3]/desktop_[screen3].dart

STEP 1: Identify common logic
Determine if logic should be:
- Added to existing service
- Created as utility function
- Created as reusable component

STEP 2: Implement shared logic first

STEP 3: Update each screen to use shared logic
For each screen:
1. Read current implementation
2. Plan integration
3. Modify using fsReplace
4. Test functionality

FEATURE REQUIREMENTS:
- [Requirement 1]
- [Requirement 2]

CONSTRAINTS:
- Reuse logic across screens
- Make minimal changes per screen
- Maintain consistency
```

---

## Template 6: Optimize Desktop Screen Performance

```
TASK: Optimize performance of desktop_[screen_name].dart

PERFORMANCE ISSUES:
- [Issue 1: e.g., Slow initial load]
- [Issue 2: e.g., Laggy scrolling]
- [Issue 3: e.g., High memory usage]

STEP 1: Read and analyze current implementation

STEP 2: Identify performance bottlenecks

STEP 3: Plan optimizations:
- Add pagination if list > 50 items
- Debounce search (500ms)
- Use const constructors
- Lazy load data
- Cache frequently accessed data

STEP 4: Implement optimizations one by one

STEP 5: Measure performance improvements

TARGET METRICS:
- Initial load: < 2 seconds
- Smooth scrolling: 60fps
- Memory usage: < 500MB
```

---

## Template 7: Implement Data Table with Advanced Features

```
TASK: Implement/enhance data table in desktop_[screen_name].dart

STEP 1: Check if file exists in lib/screens/desktop/[role]/
If exists, read and modify. If not, create new.

STEP 2: Check for existing table component
Look in lib/widgets/desktop/ for DesktopDataTable or similar

STEP 3: Implement table with features:
- Sortable columns
- Multi-column filtering
- Row selection with checkboxes
- Pagination (50 items per page)
- Inline actions (view, edit, delete)
- Export to CSV/Excel

DATA STRUCTURE:
Columns: [List column names and types]
Data source: [Service method]
Actions: [List available actions]

REQUIREMENTS:
- Use existing DesktopDataTable component if available
- Add loading skeleton while fetching data
- Show empty state when no data
- Handle errors gracefully
```

---

## Template 8: Add Keyboard Shortcuts

```
TASK: Add keyboard shortcuts to desktop_[screen_name].dart

STEP 1: Read current implementation

STEP 2: Define shortcuts for common actions:
- Ctrl+S / Cmd+S: Save
- Ctrl+F / Cmd+F: Focus search
- Ctrl+N / Cmd+N: New item
- Esc: Close dialog/cancel
- Delete: Delete selected item
- [Add screen-specific shortcuts]

STEP 3: Implement using Shortcuts widget or RawKeyboardListener

STEP 4: Add shortcut hints to tooltips

STEP 5: Test on Windows, macOS, Linux

REQUIREMENTS:
- Handle both Ctrl (Windows/Linux) and Cmd (macOS)
- Don't conflict with browser shortcuts (web)
- Show shortcuts in tooltips
- Document shortcuts in help section
```

---

## Template 9: Implement Bulk Actions

```
TASK: Add bulk actions to desktop_[screen_name].dart

STEP 1: Read current implementation

STEP 2: Add row selection to data table:
- Checkbox column
- Select all checkbox in header
- Track selected items in state

STEP 3: Add bulk action bar (appears when items selected):
Actions:
- Delete selected
- Export selected
- Update status
- [Add screen-specific actions]

STEP 4: Implement each action:
- Show confirmation for destructive actions
- Update backend via service
- Refresh data after action
- Show success/error message

STEP 5: Test with various selections:
- Single item
- Multiple items
- All items
```

---

## Template 10: Create Dashboard with Widgets

```
TASK: Create/enhance desktop dashboard for [role]

STEP 1: Check if lib/screens/desktop/[role]/desktop_[role]_dashboard.dart exists
If exists, read and enhance. If not, create new.

STEP 2: Design layout:
┌─────────────────────────────────────────────┐
│ Welcome Section (full width)                │
├─────────┬─────────┬─────────┬───────────────┤
│ Metric 1│ Metric 2│ Metric 3│ Metric 4      │
├─────────┴─────────┴─────────┴───────────────┤
│ Main Content (2/3)          │ Sidebar (1/3) │
│ - Charts                    │ - Quick Actions│
│ - Tables                    │ - Recent Items │
│                             │ - Notifications│
└─────────────────────────────┴───────────────┘

STEP 3: Implement sections:
1. Welcome section with greeting and school info
2. Metric cards (4 cards with key stats)
3. Main content area (charts, tables)
4. Sidebar (quick actions, recent activity)

STEP 4: Add real-time updates (refresh every 2-5 minutes)

DATA SOURCES:
- [List services and methods to fetch data]

REQUIREMENTS:
- Use existing services
- Add loading states for each section
- Handle errors gracefully
- Make it visually appealing
```

---

## Quick Copy-Paste Prompts

### Check File Existence
```
List all files in lib/screens/desktop/admin/ and check if desktop_student_management.dart exists.
```

### Read and Analyze
```
Read lib/screens/desktop/admin/desktop_student_management.dart and analyze its current implementation, features, and any issues.
```

### Modify Existing
```
Modify lib/screens/desktop/admin/desktop_student_management.dart to add [feature]. Use fsReplace to update only necessary sections. Follow Desktop Development Rules.
```

### Create New
```
Create lib/screens/desktop/admin/desktop_student_management.dart based on lib/screens/admin/student_management_screen.dart. Use multi-column desktop layout. Follow Desktop Development Rules.
```

### Check Components
```
List all components in lib/widgets/desktop/ and lib/widgets/common/ that are relevant for building a data table.
```

### Verify Code
```
Review lib/screens/desktop/admin/desktop_student_management.dart and verify it follows all Desktop Development Rules. List any issues found.
```

---

## Common Mistakes to Avoid

### ❌ WRONG: Creating without checking
```
Create lib/screens/desktop/admin/desktop_student_management.dart with [features]
```

### ✅ CORRECT: Check first, then create or modify
```
STEP 1: List files in lib/screens/desktop/admin/ to check if desktop_student_management.dart exists.
STEP 2: If exists, read and modify. If not, create new.
```

### ❌ WRONG: Deleting and recreating
```
Delete lib/screens/desktop/admin/desktop_student_management.dart and create a new version with [features]
```

### ✅ CORRECT: Modify existing
```
Read lib/screens/desktop/admin/desktop_student_management.dart and use fsReplace to update specific sections to add [features]
```

### ❌ WRONG: Duplicating service logic
```
Add this method to the screen:
Future<List<Student>> fetchStudents() async {
  // duplicate service logic
}
```

### ✅ CORRECT: Use existing service
```
Use StudentService.getStudents() from lib/services/student_service.dart to fetch students
```

### ❌ WRONG: Creating new components unnecessarily
```
Create a new card component for this screen
```

### ✅ CORRECT: Check and reuse
```
Check if DesktopCard exists in lib/widgets/desktop/. If yes, use it. If no, check lib/widgets/common/. Only create new if none exist.
```
