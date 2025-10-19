#!/usr/bin/env python3
"""
Automatic Router Updater for Desktop Screens
Updates router.dart to use PlatformAdaptiveScreen for all routes
"""

import re
from pathlib import Path

# Route mappings: path -> (mobile_screen, desktop_screen)
ROUTE_UPDATES = {
    '/admin': ('ModernAdminDashboard', 'DesktopAdminDashboard'),
    '/admin/student-management': ('StudentManagementScreen', 'DesktopStudentManagement'),
    '/admin/staff-management': ('StaffManagementScreen', 'DesktopStaffManagement'),
    '/admin/class-management': ('ClassManagementScreen', 'DesktopClassManagement'),
    '/admin/user-management': ('UserManagementScreen', 'DesktopUserManagement'),
    '/admin/timetable-management': ('TimetableManagementScreen', 'DesktopTimetableManagement'),
    '/admin/announcements': ('AdminAnnouncementsScreen', 'DesktopAdminAnnouncements'),
    '/admin/manage-custom-forms': ('ManageCustomFormsScreen', 'DesktopManageCustomForms'),
    '/admin/school-profile': ('SchoolProfileScreen', 'DesktopSchoolProfile'),
    '/admin/settings': ('AdminSettingsScreen', 'DesktopAdminSettings'),
    '/admin/staff-status': ('StaffStatusOverviewScreen', 'DesktopStaffStatusOverview'),
    '/admin/salary-management': ('SalaryManagementScreen', 'DesktopSalaryManagement'),
    '/admin/exam-overview': ('ExamOverviewScreen', 'DesktopExamOverview'),
    '/admin/exam-management': ('ExamListScreen', 'DesktopExamList'),
    '/admin/exam-form': ('ExamFormScreen', 'DesktopExamForm'),
    '/admin/subject-management': ('SubjectManagementScreen', 'DesktopSubjectManagement'),
    '/admin/grade-management': ('GradeManagementScreen', 'DesktopGradeManagement'),
    '/admin/finance-management': ('FinanceOverviewScreen', 'DesktopFinanceOverview'),
    '/admin/income-management': ('IncomeManagementScreen', 'DesktopIncomeManagement'),
    '/admin/expense-management': ('ExpenseManagementScreen', 'DesktopExpenseManagement'),
    '/admin/donation-management': ('DonationManagementScreen', 'DesktopDonationManagement'),
    '/admin/fee-management': ('FeeStructureManagementScreen', 'DesktopFeeStructureManagement'),
    '/teacher-dashboard': ('ModernTeacherDashboard', 'DesktopTeacherDashboard'),
    '/teacher/attendance-marking': ('AttendanceMarkingScreen', 'DesktopAttendanceMarking'),
    '/teacher/lesson-plan-management': ('LessonPlanManagementScreen', 'DesktopLessonPlanManagement'),
    '/teacher/timetable': ('TeacherTimetableScreen', 'DesktopTeacherTimetable'),
    '/teacher/students': ('TeacherStudentManagementScreen', 'DesktopTeacherStudentManagement'),
    '/parent-dashboard': ('ModernParentDashboard', 'DesktopParentDashboard'),
    '/parent/child-attendance': ('ChildAttendanceScreen', 'DesktopChildAttendance'),
    '/parent/child-schedule': ('ChildScheduleScreen', 'DesktopChildSchedule'),
    '/parent/announcements': ('AnnouncementsScreen', 'DesktopAnnouncements'),
    '/manager-dashboard': ('ManagerDashboardScreen', 'DesktopManagerDashboard'),
    '/donator-dashboard': ('ModernDonatorDashboard', 'DesktopDonatorDashboard'),
}

def generate_desktop_imports():
    """Generate import statements for all desktop screens"""
    imports = []
    
    # Group by directory
    admin_screens = [v[1] for k, v in ROUTE_UPDATES.items() if '/admin' in k and 'exam' not in k and 'finance' not in k and 'fee' not in k]
    admin_exam_screens = [v[1] for k, v in ROUTE_UPDATES.items() if '/admin' in k and 'exam' in k]
    admin_finance_screens = [v[1] for k, v in ROUTE_UPDATES.items() if '/admin' in k and ('finance' in k or 'fee' in k)]
    teacher_screens = [v[1] for k, v in ROUTE_UPDATES.items() if '/teacher' in k]
    parent_screens = [v[1] for k, v in ROUTE_UPDATES.items() if '/parent' in k]
    other_screens = [v[1] for k, v in ROUTE_UPDATES.items() if not any(x in k for x in ['/admin', '/teacher', '/parent'])]
    
    # Generate imports
    for screen in admin_screens:
        snake_case = re.sub(r'(?<!^)(?=[A-Z])', '_', screen).lower()
        imports.append(f"import 'package:edu_sync/screens/desktop/admin/{snake_case}.dart';")
    
    for screen in admin_exam_screens:
        snake_case = re.sub(r'(?<!^)(?=[A-Z])', '_', screen).lower()
        imports.append(f"import 'package:edu_sync/screens/desktop/admin/exam/{snake_case}.dart';")
    
    for screen in admin_finance_screens:
        snake_case = re.sub(r'(?<!^)(?=[A-Z])', '_', screen).lower()
        if 'fee' in snake_case:
            imports.append(f"import 'package:edu_sync/screens/desktop/admin/fee/{snake_case}.dart';")
        else:
            imports.append(f"import 'package:edu_sync/screens/desktop/admin/finance/{snake_case}.dart';")
    
    for screen in teacher_screens:
        snake_case = re.sub(r'(?<!^)(?=[A-Z])', '_', screen).lower()
        imports.append(f"import 'package:edu_sync/screens/desktop/teacher/{snake_case}.dart';")
    
    for screen in parent_screens:
        snake_case = re.sub(r'(?<!^)(?=[A-Z])', '_', screen).lower()
        imports.append(f"import 'package:edu_sync/screens/desktop/parent/{snake_case}.dart';")
    
    for screen in other_screens:
        snake_case = re.sub(r'(?<!^)(?=[A-Z])', '_', screen).lower()
        if 'manager' in snake_case:
            imports.append(f"import 'package:edu_sync/screens/desktop/manager/{snake_case}.dart';")
        elif 'donator' in snake_case:
            imports.append(f"import 'package:edu_sync/screens/desktop/donator/{snake_case}.dart';")
    
    return '\n'.join(sorted(set(imports)))

def update_router_file():
    """Update router.dart with PlatformAdaptiveScreen for all routes"""
    router_path = Path('lib/config/router.dart')
    
    if not router_path.exists():
        print("❌ router.dart not found!")
        return False
    
    with open(router_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Add PlatformAdaptiveScreen import if not present
    if 'platform_adaptive_screen' not in content:
        # Find the last import statement
        last_import = list(re.finditer(r"import\s+['\"].*?['\"];", content))[-1]
        insert_pos = last_import.end()
        content = (content[:insert_pos] + 
                  "\nimport 'package:edu_sync/widgets/common/platform_adaptive_screen.dart';" +
                  content[insert_pos:])
    
    # Add desktop screen imports
    desktop_imports = generate_desktop_imports()
    if desktop_imports and desktop_imports not in content:
        # Find position after mobile imports
        last_import = list(re.finditer(r"import\s+['\"].*?['\"];", content))[-1]
        insert_pos = last_import.end()
        content = (content[:insert_pos] + 
                  "\n\n// Desktop screen imports\n" + desktop_imports +
                  content[insert_pos:])
    
    # Update each route
    for path, (mobile, desktop) in ROUTE_UPDATES.items():
        # Find the route definition
        pattern = rf"GoRoute\(\s*path:\s*'{re.escape(path)}',\s*(?:name:\s*'[^']*',\s*)?builder:\s*\([^)]*\)\s*=>\s*const\s*{mobile}\([^)]*\),"
        
        replacement = f"""GoRoute(
        path: '{path}',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: {mobile}(),
          desktopScreen: {desktop}(),
        ),"""
        
        if re.search(pattern, content):
            content = re.sub(pattern, replacement, content)
            print(f"✅ Updated route: {path}")
    
    # Write updated content
    with open(router_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("\n✨ Router updated successfully!")
    return True

def main():
    """Main function"""
    print("🔄 Updating Router for Desktop Screens\n")
    update_router_file()
    print("\n📝 Router update complete!")
    print("   All routes now use PlatformAdaptiveScreen")
    print("   Mobile screens unchanged")
    print("   Desktop screens will show on screens ≥900px")

if __name__ == '__main__':
    main()
