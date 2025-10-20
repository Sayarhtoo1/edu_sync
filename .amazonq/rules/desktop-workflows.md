# Desktop Development Workflows

## Workflow 1: Creating/Modifying Desktop Screen

### Step 1: Check File Existence (MANDATORY)
```
PROMPT: "List all files in lib/screens/desktop/[role]/ directory. 
Check if desktop_[screen_name].dart exists."
```

**If file EXISTS:**
- Proceed to Step 2A (Modify Existing)

**If file DOES NOT EXIST:**
- Proceed to Step 2B (Create New)

### Step 2A: Modify Existing Desktop Screen

**Read Current Implementation:**
```
PROMPT: "Read lib/screens/desktop/[role]/desktop_[screen_name].dart 
and analyze:
1. Current layout structure
2. Features implemented
3. Services used
4. Components used
5. Issues or missing features"
```

**Plan Modifications:**
```
PROMPT: "Based on the analysis, plan modifications to:
1. Fix issues: [list issues]
2. Add features: [list features]
3. Improve layout: [list improvements]

Make MINIMAL changes. Preserve working functionality. 
Follow Desktop Development Rules."
```

**Implement Changes:**
```
PROMPT: "Modify lib/screens/desktop/[role]/desktop_[screen_name].dart 
to implement the planned changes. Use fsReplace tool to update 
specific sections. Do NOT recreate the entire file."
```

**Verify:**
```
PROMPT: "Review the changes. Verify:
1. No breaking changes
2. All features still work
3. Follows design system
4. No code duplication"
```

### Step 2B: Create New Desktop Screen

**Analyze Mobile Screen:**
```
PROMPT: "Read lib/screens/[role]/[screen_name].dart and analyze:
1. Features and functionality
2. Data displayed
3. User interactions
4. Services used
5. Models used"
```

**Design Desktop Layout:**
```
PROMPT: "Design desktop layout for [screen_name] with:
1. Multi-column layout (2-3 columns)
2. Enhanced data tables
3. Desktop-specific interactions
4. Proper spacing (24-32px)
Provide ASCII layout diagram."
```

**Check Required Components:**
```
PROMPT: "List components needed. Check if they exist in:
1. lib/widgets/desktop/
2. lib/widgets/common/
Identify which need to be created."
```

**Implement Screen:**
```
PROMPT: "Create lib/screens/desktop/[role]/desktop_[screen_name].dart.
Use:
- DesktopScaffold wrapper
- Existing services from lib/services/
- Existing components from lib/widgets/
- Color system: #3498DB, #2ECC71, #E74C3C, #F39C12
- Spacing: 24-32px between sections
Follow Desktop Development Rules."
```

**Test:**
```
PROMPT: "Review implementation. Check:
1. Compiles without errors
2. Follows design system
3. Has loading states
4. Has error states
5. Has empty states
6. Responsive layout"
```

---

## Workflow 2: Enhancing Existing Desktop Screen

### Step 1: Audit Current Screen
```
PROMPT: "Audit lib/screens/desktop/[role]/desktop_[screen_name].dart.
Identify:
1. UI/UX issues
2. Missing features
3. Performance problems
4. Inconsistent styling
5. Poor error handling"
```

### Step 2: Prioritize Issues
```
PROMPT: "Prioritize issues by severity:
1. Critical: Breaks functionality
2. High: Poor UX, missing essential features
3. Medium: Visual inconsistencies
4. Low: Nice-to-have improvements"
```

### Step 3: Fix Issues One by One
```
PROMPT: "Fix [specific issue] in desktop_[screen_name].dart.
Make minimal changes. Use fsReplace to update specific sections.
Preserve existing functionality."
```

### Step 4: Verify Each Fix
```
PROMPT: "Verify the fix:
1. Issue is resolved
2. No new issues introduced
3. Code follows rules
4. Performance not degraded"
```

---

## Workflow 3: Creating Reusable Desktop Component

### Step 1: Check Component Existence
```
PROMPT: "Check if similar component exists in:
1. lib/widgets/desktop/
2. lib/widgets/common/
List any similar components found."
```

### Step 2: Define Component API
```
PROMPT: "Define [component_name] component API:
- Purpose: [description]
- Required parameters: [list]
- Optional parameters: [list]
- Callbacks: [list]
- Variants: [list]
Provide usage examples."
```

### Step 3: Implement Component
```
PROMPT: "Create lib/widgets/desktop/[component_name].dart.
Make it highly reusable. Support customization via parameters.
Follow design system. Include documentation comments."
```

### Step 4: Test Component
```
PROMPT: "Create test usage examples showing:
1. Basic usage
2. All variants
3. Different configurations
4. Edge cases"
```

### Step 5: Update Screens
```
PROMPT: "Find screens that could use this component.
List files and locations where it should replace existing code.
Do NOT make changes yet, just list opportunities."
```

---

## Workflow 4: Implementing Feature Across Multiple Screens

### Step 1: Identify Affected Screens
```
PROMPT: "List all desktop screens that need [feature].
For each screen, note:
1. File path
2. Current implementation (if any)
3. Required changes"
```

### Step 2: Extract Common Logic
```
PROMPT: "Identify common logic for [feature] that can be:
1. Added to existing service
2. Created as new utility function
3. Created as reusable component
Recommend best approach."
```

### Step 3: Implement Shared Logic
```
PROMPT: "Implement shared logic for [feature] in [service/utility].
Make it reusable across all screens. Add proper error handling."
```

### Step 4: Update Each Screen
```
PROMPT: "Update lib/screens/desktop/[role]/desktop_[screen_name].dart
to use the shared logic. Handle screen-specific requirements.
Make minimal changes."
```

### Step 5: Test All Screens
```
PROMPT: "Verify [feature] works correctly in all screens:
1. [Screen 1]
2. [Screen 2]
3. [Screen 3]
Check for consistent behavior and edge cases."
```

---

## Workflow 5: Fixing Bugs in Desktop Screens

### Step 1: Reproduce Bug
```
PROMPT: "Analyze bug in desktop_[screen_name].dart:
Issue: [description]
Steps to reproduce: [steps]
Expected: [expected behavior]
Actual: [actual behavior]

Read the file and identify root cause."
```

### Step 2: Plan Fix
```
PROMPT: "Plan fix for the bug:
1. Root cause: [cause]
2. Solution: [solution]
3. Files to modify: [list]
4. Potential side effects: [list]"
```

### Step 3: Implement Fix
```
PROMPT: "Fix the bug in desktop_[screen_name].dart.
Make minimal changes. Add error handling if missing.
Use fsReplace to update specific sections."
```

### Step 4: Test Fix
```
PROMPT: "Verify bug is fixed:
1. Original issue resolved
2. No regression in other features
3. Edge cases handled
4. Error handling added"
```

---

## Workflow 6: Optimizing Desktop Screen Performance

### Step 1: Profile Performance
```
PROMPT: "Analyze performance of desktop_[screen_name].dart:
1. Initial load time
2. Data fetch time
3. Render time
4. Memory usage
5. Unnecessary rebuilds
Identify bottlenecks."
```

### Step 2: Plan Optimizations
```
PROMPT: "Plan optimizations:
1. Add pagination if list > 50 items
2. Debounce search (500ms)
3. Use const constructors
4. Lazy load data
5. Cache frequently accessed data
Prioritize by impact."
```

### Step 3: Implement Optimizations
```
PROMPT: "Implement [specific optimization] in desktop_[screen_name].dart.
Measure performance before and after. Make minimal changes."
```

### Step 4: Verify Improvements
```
PROMPT: "Verify performance improvements:
1. Load time reduced
2. Smooth scrolling (60fps)
3. No jank during interactions
4. Memory usage acceptable
5. Functionality preserved"
```

---

## Workflow 7: Adding Keyboard Shortcuts

### Step 1: Define Shortcuts
```
PROMPT: "Define keyboard shortcuts for desktop_[screen_name].dart:
Common actions:
- Ctrl+S: Save
- Ctrl+F: Search
- Ctrl+N: New item
- Esc: Close dialog
- Delete: Delete selected
List relevant shortcuts for this screen."
```

### Step 2: Implement Shortcuts
```
PROMPT: "Add keyboard shortcuts to desktop_[screen_name].dart using
RawKeyboardListener or Shortcuts widget. Handle shortcuts:
[list shortcuts]
Show shortcut hints in tooltips."
```

### Step 3: Test Shortcuts
```
PROMPT: "Test all keyboard shortcuts:
1. Each shortcut triggers correct action
2. Shortcuts don't conflict
3. Tooltips show shortcuts
4. Works on Windows, macOS, Linux"
```

---

## Workflow 8: Implementing Bulk Actions

### Step 1: Add Selection UI
```
PROMPT: "Add row selection to data table in desktop_[screen_name].dart:
1. Checkbox column
2. Select all checkbox in header
3. Selection state management
4. Selected count display"
```

### Step 2: Add Bulk Action Bar
```
PROMPT: "Add bulk action bar that appears when items selected:
Actions: [list actions like Delete, Export, Update Status]
Position: Above table or as floating bar
Include: Cancel selection button"
```

### Step 3: Implement Actions
```
PROMPT: "Implement bulk actions in desktop_[screen_name].dart:
1. Delete selected items
2. Export selected items
3. Update status of selected items
Add confirmation dialogs for destructive actions."
```

### Step 4: Test Bulk Actions
```
PROMPT: "Test bulk actions:
1. Select single item
2. Select multiple items
3. Select all items
4. Perform each action
5. Verify data updates correctly"
```

---

## Quick Reference: Common Prompts

### Check File Existence
```
List files in lib/screens/desktop/[role]/ to check if 
desktop_[screen_name].dart exists.
```

### Read Existing Screen
```
Read lib/screens/desktop/[role]/desktop_[screen_name].dart 
and summarize its current implementation.
```

### Modify Existing Screen
```
Modify lib/screens/desktop/[role]/desktop_[screen_name].dart 
to [specific change]. Use fsReplace to update only the 
necessary sections. Follow Desktop Development Rules.
```

### Create New Screen
```
Create lib/screens/desktop/[role]/desktop_[screen_name].dart 
based on lib/screens/[role]/[screen_name].dart. Use desktop 
layout with multi-column design. Follow Desktop Development Rules.
```

### Check Components
```
List all components in lib/widgets/desktop/ and lib/widgets/common/ 
that could be used for [screen_name].
```

### Verify Implementation
```
Review lib/screens/desktop/[role]/desktop_[screen_name].dart and 
verify it follows Desktop Development Rules. Check for issues.
```

---

## Error Prevention Checklist

Before submitting any code, verify:

- [ ] Checked if file exists before creating
- [ ] Read existing code before modifying
- [ ] Used existing services (no duplication)
- [ ] Used existing components
- [ ] Followed naming conventions
- [ ] Added error handling
- [ ] Added loading states
- [ ] Added empty states
- [ ] Followed color system
- [ ] Used proper spacing
- [ ] Code compiles without errors
- [ ] No breaking changes to mobile
- [ ] Tested on desktop platform
