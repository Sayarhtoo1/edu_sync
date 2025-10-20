# Desktop Development Checklist

## Pre-Implementation Checklist

### Before Starting Any Task

- [ ] Read the Desktop UI/UX Enhancement Plan
- [ ] Read Desktop Development Rules
- [ ] Read Desktop Workflows
- [ ] Understand the specific requirement
- [ ] Identify affected files

### File Existence Check (MANDATORY)

- [ ] List files in target directory
- [ ] Check if desktop screen already exists
- [ ] If exists: Plan to MODIFY existing file
- [ ] If not exists: Plan to CREATE new file
- [ ] NEVER delete and recreate without explicit user request

### Component Check

- [ ] List components in lib/widgets/desktop/
- [ ] List components in lib/widgets/common/
- [ ] Identify reusable components
- [ ] Plan to use existing components
- [ ] Only create new if none exist

### Service Check

- [ ] List services in lib/services/
- [ ] Identify required services
- [ ] Plan to use existing services
- [ ] NEVER duplicate service logic

---

## Implementation Checklist

### Code Structure

- [ ] Follows naming convention (desktop_[screen_name].dart)
- [ ] Located in correct directory (lib/screens/desktop/[role]/)
- [ ] Uses DesktopScaffold wrapper
- [ ] Imports organized (Flutter, packages, local)
- [ ] No unused imports

### Layout

- [ ] Multi-column layout (2-3 columns)
- [ ] Proper spacing (24-32px between sections)
- [ ] Responsive to screen size
- [ ] No horizontal overflow
- [ ] Smooth scrolling

### Design System

- [ ] Uses correct colors (#3498DB, #2ECC71, #E74C3C, #F39C12)
- [ ] Uses correct typography (24px headers, 14px body)
- [ ] Consistent card design
- [ ] Consistent button styles
- [ ] Proper whitespace

### State Management

- [ ] Uses existing providers
- [ ] State is immutable
- [ ] Proper state initialization
- [ ] Cleanup in dispose()
- [ ] No memory leaks

### Data Handling

- [ ] Uses existing services
- [ ] Proper error handling (try-catch)
- [ ] Loading states implemented
- [ ] Empty states implemented
- [ ] Error states implemented

### User Interactions

- [ ] Hover states on interactive elements
- [ ] Click feedback (ripple/color change)
- [ ] Tooltips on icon buttons
- [ ] Confirmation dialogs for destructive actions
- [ ] Success/error messages after actions

### Forms (if applicable)

- [ ] Two-column layout
- [ ] Inline validation
- [ ] Clear error messages
- [ ] Required fields marked
- [ ] Submit button disabled during submission

### Tables (if applicable)

- [ ] Sortable columns
- [ ] Filterable data
- [ ] Pagination (50 items per page)
- [ ] Row selection (if needed)
- [ ] Inline actions
- [ ] Export functionality

### Performance

- [ ] Uses const constructors where possible
- [ ] Pagination for large lists
- [ ] Debounced search (500ms)
- [ ] Lazy loading implemented
- [ ] No unnecessary rebuilds

### Accessibility

- [ ] Keyboard navigation works
- [ ] Focus indicators visible
- [ ] Semantic labels added
- [ ] Color contrast meets WCAG AA
- [ ] Screen reader friendly (web)

---

## Testing Checklist

### Compilation

- [ ] Code compiles without errors
- [ ] No warnings in console
- [ ] All imports resolve correctly
- [ ] No type errors

### Visual Testing

- [ ] Screen displays correctly
- [ ] Layout is responsive
- [ ] Colors are correct
- [ ] Typography is correct
- [ ] Spacing is correct
- [ ] Icons display correctly

### Functional Testing

- [ ] All buttons work
- [ ] All links navigate correctly
- [ ] Forms submit correctly
- [ ] Tables sort correctly
- [ ] Filters apply correctly
- [ ] Search works correctly

### State Testing

- [ ] Loading state displays correctly
- [ ] Empty state displays correctly
- [ ] Error state displays correctly
- [ ] Success messages display
- [ ] Error messages display

### Edge Cases

- [ ] Handles empty data
- [ ] Handles API errors
- [ ] Handles network errors
- [ ] Handles invalid input
- [ ] Handles large datasets

### Cross-Platform Testing

- [ ] Works on Windows
- [ ] Works on macOS
- [ ] Works on Linux
- [ ] Mobile screens still work
- [ ] No breaking changes

---

## Code Quality Checklist

### Readability

- [ ] Code is well-organized
- [ ] Meaningful variable names
- [ ] Meaningful function names
- [ ] Complex logic has comments
- [ ] No commented-out code

### Maintainability

- [ ] No code duplication
- [ ] Functions are focused (single responsibility)
- [ ] Files are reasonable size (< 500 lines)
- [ ] Easy to understand
- [ ] Easy to modify

### Best Practices

- [ ] Follows Dart conventions
- [ ] Follows Flutter best practices
- [ ] Follows project patterns
- [ ] No anti-patterns
- [ ] No security issues

### Documentation

- [ ] Public APIs documented (///)
- [ ] Complex logic explained (//)
- [ ] TODOs marked if needed
- [ ] Breaking changes noted

---

## Pre-Commit Checklist

### Final Verification

- [ ] All checklists above completed
- [ ] Code reviewed by self
- [ ] Tested on desktop platform
- [ ] Mobile screens verified working
- [ ] No breaking changes introduced

### Files Modified

- [ ] List all modified files
- [ ] Verify each change is necessary
- [ ] Verify no unintended changes
- [ ] Verify formatting is correct

### Documentation

- [ ] Updated relevant documentation
- [ ] Added comments where needed
- [ ] Updated CHANGELOG if applicable

### Ready to Commit

- [ ] All tests pass
- [ ] Code follows all rules
- [ ] No known issues
- [ ] Ready for review

---

## Post-Implementation Checklist

### Verification

- [ ] Feature works as expected
- [ ] No regressions introduced
- [ ] Performance is acceptable
- [ ] User experience is good

### Documentation

- [ ] Code is documented
- [ ] User guide updated (if needed)
- [ ] Technical docs updated (if needed)

### Cleanup

- [ ] Removed debug code
- [ ] Removed console logs
- [ ] Removed unused code
- [ ] Removed unused imports

### Knowledge Transfer

- [ ] Document any gotchas
- [ ] Document any workarounds
- [ ] Document any future improvements needed

---

## Common Issues Checklist

### If Screen Doesn't Display

- [ ] Check if route is registered in router.dart
- [ ] Check if file is in correct location
- [ ] Check for compilation errors
- [ ] Check for runtime errors in console

### If Data Doesn't Load

- [ ] Check service method is called
- [ ] Check API endpoint is correct
- [ ] Check error handling
- [ ] Check network connectivity
- [ ] Check loading state

### If Layout Looks Wrong

- [ ] Check spacing values
- [ ] Check color values
- [ ] Check typography values
- [ ] Check responsive breakpoints
- [ ] Check for overflow errors

### If Performance Is Poor

- [ ] Check for unnecessary rebuilds
- [ ] Check for large lists without pagination
- [ ] Check for missing const constructors
- [ ] Check for expensive computations
- [ ] Check for memory leaks

### If Mobile Breaks

- [ ] Verify mobile files not modified
- [ ] Verify shared components still work
- [ ] Verify services still work
- [ ] Verify routes still work
- [ ] Test on mobile platform

---

## Emergency Rollback Checklist

### If Something Goes Wrong

- [ ] Identify what broke
- [ ] Identify which changes caused it
- [ ] Revert problematic changes
- [ ] Test that revert fixes issue
- [ ] Document what went wrong
- [ ] Plan better approach

### Prevention

- [ ] Make smaller changes
- [ ] Test more frequently
- [ ] Follow checklists more carefully
- [ ] Ask for help if unsure
- [ ] Review code before committing
