# Desktop Screens Development Rules

## Overview
This project supports separate desktop and mobile screen implementations using the PlatformAdaptiveScreen pattern. Desktop screens provide optimized layouts for larger screens (≥900px) without affecting existing mobile screens.

## Directory Structure

### Mobile Screens (Existing)
- `/lib/screens/admin/` - Admin mobile screens
- `/lib/screens/teacher/` - Teacher mobile screens
- `/lib/screens/parent/` - Parent mobile screens
- `/lib/screens/student/` - Student mobile screens
- `/lib/screens/staff/` - Staff mobile screens
- `/lib/screens/manager/` - Manager mobile screens
- `/lib/screens/donator/` - Donator mobile screens

### Desktop Screens (New)
- `/lib/screens/desktop/admin/` - Admin desktop screens
- `/lib/screens/desktop/teacher/` - Teacher desktop screens
- `/lib/screens/desktop/parent/` - Parent desktop screens
- `/lib/screens/desktop/student/` - Student desktop screens
- `/lib/screens/desktop/staff/` - Staff desktop screens
- `/lib/screens/desktop/manager/` - Manager desktop screens
- `/lib/screens/desktop/donator/` - Donator desktop screens

## Core Components

### PlatformAdaptiveScreen Widget
Location: `/lib/widgets/common/platform_adaptive_screen.dart`

Automatically switches between mobile and desktop screens based on screen width:
- Mobile: < 900px
- Desktop: ≥ 900px

### Responsive Utility
Location: `/lib/utils/responsive.dart`

Provides screen size detection:
- `Responsive.isMobile(context)` - < 600px
- `Responsive.isTablet(context)` - 600-900px
- `Responsive.isDesktop(context)` - ≥ 900px

## Desktop Screen Creation Rules

### Rule 1: File Naming and Location
**Pattern**: `desktop_[screen_name].dart`

**Location**: `/lib/screens/desktop/[role]/desktop_[screen_name].dart`

**Examples**:
- Mobile: `/lib/screens/admin/student_management_screen.dart`
- Desktop: `/lib/screens/desktop/admin/desktop_student_management.dart`

### Rule 2: Desktop Screen Structure

**Required Structure**:
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Import necessary services and models
// Import state mixins if available

class Desktop[ScreenName] extends StatefulWidget {
  const Desktop[ScreenName]({super.key});

  @override
  State<Desktop[ScreenName]> createState() => _Desktop[ScreenName]State();
}

class _Desktop[ScreenName]State extends State<Desktop[ScreenName]> {
  // Use existing state mixins when available
  // Example: with StudentManagementStateMixin
  
  @override
  void initState() {
    super.initState();
    // Initialize services
    // Load data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(child: _buildMainContent()),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          // Logo and branding
          // Navigation items
          // User profile
          // Logout
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        _buildTopBar(),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 70,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text('Screen Title', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
          CircleAvatar(child: Icon(Icons.person)),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Desktop-optimized content
        ],
      ),
    );
  }
}
```

### Rule 3: Desktop Layout Patterns

**Pattern A: Sidebar + Content (Most Common)**
```dart
Row(
  children: [
    Container(width: 250, child: Sidebar()),
    Expanded(child: MainContent()),
  ],
)
```

**Pattern B: Master-Detail**
```dart
Row(
  children: [
    Expanded(flex: 2, child: ListPanel()),
    Expanded(flex: 3, child: DetailPanel()),
  ],
)
```

**Pattern C: Dashboard Grid**
```dart
GridView.count(
  crossAxisCount: 4,
  childAspectRatio: 2,
  children: [MetricCard1(), MetricCard2(), MetricCard3(), MetricCard4()],
)
```

**Pattern D: Three-Column Layout**
```dart
Row(
  children: [
    Container(width: 250, child: Sidebar()),
    Expanded(flex: 2, child: MainContent()),
    Container(width: 300, child: RightPanel()),
  ],
)
```

### Rule 4: Router Integration

**Step 1**: Import desktop screen in `/lib/config/router.dart`
```dart
import 'package:edu_sync/screens/desktop/[role]/desktop_[screen_name].dart';
```

**Step 2**: Update route to use PlatformAdaptiveScreen
```dart
GoRoute(
  path: '/[role]/[screen-route]',
  builder: (context, state) => const PlatformAdaptiveScreen(
    mobileScreen: [MobileScreenName](),
    desktopScreen: Desktop[ScreenName](),
  ),
),
```

**Example**:
```dart
GoRoute(
  path: '/admin/student-management',
  builder: (context, state) => const PlatformAdaptiveScreen(
    mobileScreen: StudentManagementScreen(),
    desktopScreen: DesktopStudentManagement(),
  ),
),
```

### Rule 5: Reusing Mobile Logic

**Approach 1: Share State Mixins**
```dart
// If mobile screen uses mixin
class _DesktopStudentManagementState extends State<DesktopStudentManagement>
    with StudentManagementStateMixin {
  // Reuse all data loading and state management
}
```

**Approach 2: Share Services**
```dart
// Both screens use same services
final studentService = Provider.of<StudentService>(context, listen: false);
final authService = Provider.of<AuthService>(context, listen: false);
```

**Approach 3: Share Widgets**
```dart
// Create shared widgets in /lib/widgets/common/
// Use in both mobile and desktop screens
```

### Rule 6: Desktop-Specific Features

**Add Desktop Enhancements**:
- Hover effects on cards and buttons
- Keyboard shortcuts (Ctrl+S, Ctrl+N, etc.)
- Context menus (right-click)
- Drag and drop functionality
- Multi-column layouts
- Larger data tables with more columns
- Side panels for quick actions
- Breadcrumb navigation

**Example Hover Effect**:
```dart
MouseRegion(
  onEnter: (_) => setState(() => _isHovered = true),
  onExit: (_) => setState(() => _isHovered = false),
  child: AnimatedContainer(
    duration: Duration(milliseconds: 200),
    decoration: BoxDecoration(
      color: _isHovered ? Colors.blue.shade50 : Colors.white,
    ),
    child: ListTile(...),
  ),
)
```

### Rule 7: Desktop Navigation Sidebar

**Standard Sidebar Structure**:
```dart
Widget _buildSidebar() {
  return Container(
    width: 250,
    color: Colors.white,
    child: Column(
      children: [
        const SizedBox(height: 20),
        // Logo
        const Text('EduSync', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 40),
        // Navigation items
        _buildNavItem(Icons.dashboard, 'Dashboard', true),
        _buildNavItem(Icons.school, 'Students', false, onTap: () => context.push('/admin/student-management')),
        _buildNavItem(Icons.people, 'Teachers', false, onTap: () => context.push('/admin/staff-management')),
        _buildNavItem(Icons.class_, 'Classes', false, onTap: () => context.push('/admin/class-management')),
        _buildNavItem(Icons.assignment, 'Exams', false, onTap: () => context.pushNamed('exam-overview')),
        _buildNavItem(Icons.account_balance_wallet, 'Finance', false, onTap: () => context.push('/admin/finance-management')),
        const Spacer(),
        _buildNavItem(Icons.settings, 'Settings', false),
        _buildNavItem(Icons.logout, 'Logout', false, onTap: _logout),
        const SizedBox(height: 20),
      ],
    ),
  );
}

Widget _buildNavItem(IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
  return ListTile(
    leading: Icon(icon, color: isActive ? Colors.blue : Colors.grey),
    title: Text(label, style: TextStyle(
      color: isActive ? Colors.blue : Colors.grey,
      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
    )),
    tileColor: isActive ? Colors.blue.withOpacity(0.1) : null,
    onTap: onTap,
  );
}
```

### Rule 8: Desktop Top Bar

**Standard Top Bar Structure**:
```dart
Widget _buildTopBar() {
  return Container(
    height: 70,
    color: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Row(
      children: [
        Text(
          'Screen Title',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C)),
        ),
        const Spacer(),
        // Search
        IconButton(icon: Icon(Icons.search), onPressed: () {}),
        // Notifications
        IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
        const SizedBox(width: 16),
        // User profile
        CircleAvatar(child: Icon(Icons.person)),
      ],
    ),
  );
}
```

### Rule 9: Desktop Data Tables

**Use DataTable for desktop with more columns**:
```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: DataTable(
    columns: [
      DataColumn(label: Text('ID')),
      DataColumn(label: Text('Name')),
      DataColumn(label: Text('Email')),
      DataColumn(label: Text('Phone')),
      DataColumn(label: Text('Class')),
      DataColumn(label: Text('Status')),
      DataColumn(label: Text('Actions')),
    ],
    rows: data.map((item) => DataRow(
      cells: [
        DataCell(Text(item.id.toString())),
        DataCell(Text(item.name)),
        DataCell(Text(item.email)),
        DataCell(Text(item.phone)),
        DataCell(Text(item.className)),
        DataCell(_buildStatusChip(item.status)),
        DataCell(_buildActionButtons(item)),
      ],
    )).toList(),
  ),
)
```

### Rule 10: Desktop Metric Cards

**Use wider cards with more details**:
```dart
Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: Offset(0, 2)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(color: Colors.grey, fontSize: 14)),
            Icon(icon, color: color, size: 28),
          ],
        ),
        const SizedBox(height: 12),
        Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.trending_up, color: Colors.green, size: 16),
            Text(' +5.2%', style: TextStyle(color: Colors.green, fontSize: 12)),
          ],
        ),
      ],
    ),
  );
}
```

## Automatic Desktop Screen Creation Process

### When User Requests Desktop Screen Creation

**Step 1: Identify Mobile Screen**
- Locate the mobile screen file in `/lib/screens/[role]/`
- Read the mobile screen to understand structure and logic

**Step 2: Create Desktop Directory**
- Ensure `/lib/screens/desktop/[role]/` exists
- Create if missing

**Step 3: Generate Desktop Screen**
- Create `desktop_[screen_name].dart` in desktop directory
- Use sidebar + content layout pattern
- Reuse state mixins if available
- Implement desktop-optimized UI:
  - 4-column metric grids
  - Wider data tables
  - Side navigation
  - Top bar with search and notifications

**Step 4: Update Router**
- Import desktop screen in `router.dart`
- Wrap existing route with PlatformAdaptiveScreen
- Keep mobile screen unchanged

**Step 5: Verify**
- Confirm mobile screen path unchanged
- Confirm desktop screen created
- Confirm router updated

## Testing Desktop Screens

### Manual Testing
1. Run app on Windows/Desktop
2. Resize window to < 900px (should show mobile)
3. Resize window to ≥ 900px (should show desktop)
4. Test all navigation and functionality

### Verification Checklist
- [ ] Mobile screen still works on mobile devices
- [ ] Desktop screen shows on desktop (≥900px)
- [ ] Navigation works in both versions
- [ ] Data loads correctly in both versions
- [ ] State management works in both versions
- [ ] No breaking changes to mobile code

## Best Practices

1. **Never modify mobile screens** when creating desktop versions
2. **Reuse business logic** through services and mixins
3. **Create shared widgets** for common UI elements
4. **Use consistent sidebar navigation** across desktop screens
5. **Implement hover effects** for better desktop UX
6. **Add keyboard shortcuts** for power users
7. **Use wider layouts** to take advantage of screen space
8. **Test both versions** after creating desktop screen

## Example: Complete Desktop Screen Creation

**User Request**: "Create desktop version of student management screen"

**Actions**:
1. Read `/lib/screens/admin/student_management_screen.dart`
2. Create `/lib/screens/desktop/admin/desktop_student_management.dart`
3. Implement sidebar + content layout
4. Reuse StudentManagementStateMixin if available
5. Add 4-column metric grid
6. Add wider data table with more columns
7. Update router.dart:
```dart
import 'package:edu_sync/screens/desktop/admin/desktop_student_management.dart';

GoRoute(
  path: '/admin/student-management',
  builder: (context, state) => const PlatformAdaptiveScreen(
    mobileScreen: StudentManagementScreen(),
    desktopScreen: DesktopStudentManagement(),
  ),
),
```
8. Confirm mobile screen unchanged
9. Test both versions

## Color Scheme for Desktop Screens

Use existing app theme colors:
- Background: `Color(0xFFF5F7FA)`
- Card background: `Colors.white`
- Primary: `Color(0xFF7A6FF0)` (purple)
- Secondary: `Color(0xFF3B9EFF)` (blue)
- Success: `Color(0xFF4CAF50)` (green)
- Warning: `Color(0xFFFFA726)` (orange)
- Text dark: `Color(0xFF2C2C2C)`
- Text light: `Color(0xFF8C8C8C)`

## Summary

- Desktop screens go in `/lib/screens/desktop/[role]/`
- Use `PlatformAdaptiveScreen` to switch between mobile and desktop
- Follow sidebar + content layout pattern
- Reuse mobile logic through services and mixins
- Never modify mobile screens
- Update router to use adaptive screen
- Test both versions after creation
