#!/usr/bin/env python3
"""
Automatic Desktop Screen Generator for EduSync
Generates desktop versions of all mobile screens without modifying mobile code
"""

import os
import re
from pathlib import Path

# Screen mappings: mobile path -> desktop path
SCREEN_MAPPINGS = {
    # Admin screens
    'admin/modern_admin_dashboard.dart': 'desktop/admin/desktop_admin_dashboard.dart',
    'admin/student_management_screen.dart': 'desktop/admin/desktop_student_management.dart',
    'admin/staff_management_screen.dart': 'desktop/admin/desktop_staff_management.dart',
    'admin/class_management_screen.dart': 'desktop/admin/desktop_class_management.dart',
    'admin/user_management_screen.dart': 'desktop/admin/desktop_user_management.dart',
    'admin/timetable_management_screen.dart': 'desktop/admin/desktop_timetable_management.dart',
    'admin/admin_announcements_screen.dart': 'desktop/admin/desktop_admin_announcements.dart',
    'admin/manage_custom_forms_screen.dart': 'desktop/admin/desktop_manage_custom_forms.dart',
    'admin/school_profile_screen.dart': 'desktop/admin/desktop_school_profile.dart',
    'admin/admin_settings_screen.dart': 'desktop/admin/desktop_admin_settings.dart',
    'admin/staff_status_overview_screen.dart': 'desktop/admin/desktop_staff_status_overview.dart',
    'admin/salary_management_screen.dart': 'desktop/admin/desktop_salary_management.dart',
    
    # Admin Exam screens
    'admin/exam/exam_overview_screen.dart': 'desktop/admin/exam/desktop_exam_overview.dart',
    'admin/exam/exam_list_screen.dart': 'desktop/admin/exam/desktop_exam_list.dart',
    'admin/exam/exam_form_screen.dart': 'desktop/admin/exam/desktop_exam_form.dart',
    'admin/exam/subject_management_screen.dart': 'desktop/admin/exam/desktop_subject_management.dart',
    'admin/exam/grade_management_screen.dart': 'desktop/admin/exam/desktop_grade_management.dart',
    'admin/exam/unified_marks_entry_screen.dart': 'desktop/admin/exam/desktop_unified_marks_entry.dart',
    'admin/exam/exam_analytics_screen.dart': 'desktop/admin/exam/desktop_exam_analytics.dart',
    'admin/exam/marks_approval_screen.dart': 'desktop/admin/exam/desktop_marks_approval.dart',
    
    # Admin Finance screens
    'admin/finance/finance_overview_screen.dart': 'desktop/admin/finance/desktop_finance_overview.dart',
    'admin/finance/income_management_screen.dart': 'desktop/admin/finance/desktop_income_management.dart',
    'admin/finance/expense_management_screen.dart': 'desktop/admin/finance/desktop_expense_management.dart',
    'admin/finance/donation_management_screen.dart': 'desktop/admin/finance/desktop_donation_management.dart',
    'admin/fee/fee_structure_management_screen.dart': 'desktop/admin/fee/desktop_fee_structure_management.dart',
    
    # Teacher screens
    'teacher/modern_teacher_dashboard.dart': 'desktop/teacher/desktop_teacher_dashboard.dart',
    'teacher/attendance_marking_screen.dart': 'desktop/teacher/desktop_attendance_marking.dart',
    'teacher/lesson_plan_management_screen.dart': 'desktop/teacher/desktop_lesson_plan_management.dart',
    'teacher/teacher_timetable_screen.dart': 'desktop/teacher/desktop_teacher_timetable.dart',
    'teacher/teacher_student_management_screen.dart': 'desktop/teacher/desktop_teacher_student_management.dart',
    
    # Parent screens
    'parent/modern_parent_dashboard.dart': 'desktop/parent/desktop_parent_dashboard.dart',
    'parent/child_attendance_screen.dart': 'desktop/parent/desktop_child_attendance.dart',
    'parent/child_schedule_screen.dart': 'desktop/parent/desktop_child_schedule.dart',
    'parent/announcements_screen.dart': 'desktop/parent/desktop_announcements.dart',
    
    # Manager screens
    'manager/manager_dashboard_screen.dart': 'desktop/manager/desktop_manager_dashboard.dart',
    
    # Donator screens
    'donator/modern_donator_dashboard.dart': 'desktop/donator/desktop_donator_dashboard.dart',
    
    # Staff screens
    'staff/staff_profile_screen.dart': 'desktop/staff/desktop_staff_profile.dart',
    'staff/staff_attendance_screen.dart': 'desktop/staff/desktop_staff_attendance.dart',
    
    # Student screens
    'student/student_profile_screen.dart': 'desktop/student/desktop_student_profile.dart',
    'student/student_performance_screen.dart': 'desktop/student/desktop_student_performance.dart',
}

DESKTOP_TEMPLATE = '''import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_sync/services/auth_service.dart';
{additional_imports}

class {class_name} extends StatefulWidget {{
  const {class_name}({{super.key{constructor_params}}});
  
  {fields}

  @override
  State<{class_name}> createState() => _{class_name}State();
}}

class _{class_name}State extends State<{class_name}> {mixins} {{
  
  @override
  void initState() {{
    super.initState();
    {init_code}
  }}

  @override
  Widget build(BuildContext context) {{
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(child: _buildMainContent()),
        ],
      ),
    );
  }}

  Widget _buildSidebar() {{
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text('EduSync', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          _buildNavItem(Icons.dashboard, 'Dashboard', true),
          {nav_items}
          const Spacer(),
          _buildNavItem(Icons.settings, 'Settings', false),
          _buildNavItem(Icons.logout, 'Logout', false, onTap: _logout),
          const SizedBox(height: 20),
        ],
      ),
    );
  }}

  Widget _buildNavItem(IconData icon, String label, bool isActive, {{VoidCallback? onTap}}) {{
    return ListTile(
      leading: Icon(icon, color: isActive ? Colors.blue : Colors.grey),
      title: Text(label, style: TextStyle(
        color: isActive ? Colors.blue : Colors.grey,
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
      )),
      tileColor: isActive ? Colors.blue.withOpacity(0.1) : null,
      onTap: onTap,
    );
  }}

  Widget _buildMainContent() {{
    return Column(
      children: [
        _buildTopBar(),
        Expanded(child: _buildContent()),
      ],
    );
  }}

  Widget _buildTopBar() {{
    return Container(
      height: 70,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          const Text('{screen_title}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(icon: const Icon(Icons.search), onPressed: () {{}}),
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {{}}),
          const SizedBox(width: 16),
          const CircleAvatar(child: Icon(Icons.person)),
        ],
      ),
    );
  }}

  Widget _buildContent() {{
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          {content_widgets}
        ],
      ),
    );
  }}

  void _logout() async {{
    final authService = context.read<AuthService>();
    await authService.signOut();
    if (mounted) context.go('/login');
  }}
}}
'''

def extract_class_name(mobile_path):
    """Extract class name from mobile screen path"""
    filename = Path(mobile_path).stem
    # Convert snake_case to PascalCase
    parts = filename.split('_')
    return ''.join(word.capitalize() for word in parts)

def generate_desktop_class_name(mobile_class_name):
    """Generate desktop class name"""
    if mobile_class_name.startswith('Modern'):
        return 'Desktop' + mobile_class_name[6:]
    return 'Desktop' + mobile_class_name

def read_mobile_screen(mobile_path):
    """Read mobile screen to extract imports and structure"""
    full_path = Path('lib/screens') / mobile_path
    if not full_path.exists():
        return None
    
    with open(full_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Extract imports
    imports = re.findall(r"import\s+['\"](.+?)['\"];", content)
    
    # Extract mixins
    mixin_match = re.search(r'with\s+([^{]+){', content)
    mixins = mixin_match.group(1).strip() if mixin_match else ''
    
    return {
        'imports': imports,
        'mixins': mixins,
        'content': content
    }

def generate_desktop_screen(mobile_path, desktop_path):
    """Generate desktop screen from mobile screen"""
    mobile_info = read_mobile_screen(mobile_path)
    if not mobile_info:
        print(f"⚠️  Could not read {mobile_path}")
        return False
    
    mobile_class = extract_class_name(mobile_path)
    desktop_class = generate_desktop_class_name(mobile_class)
    
    # Determine screen title
    screen_title = desktop_class.replace('Desktop', '').replace('Screen', '')
    screen_title = re.sub(r'([A-Z])', r' \1', screen_title).strip()
    
    # Generate navigation items based on role
    role = desktop_path.split('/')[1]  # admin, teacher, parent, etc.
    nav_items = generate_nav_items(role)
    
    # Generate content
    desktop_content = DESKTOP_TEMPLATE.format(
        class_name=desktop_class,
        additional_imports='',
        constructor_params='',
        fields='',
        mixins=f' with {mobile_info["mixins"]}' if mobile_info['mixins'] else '',
        init_code='',
        nav_items=nav_items,
        screen_title=screen_title,
        content_widgets='const Text("Desktop content here")',
    )
    
    # Write desktop screen
    desktop_full_path = Path('lib/screens') / desktop_path
    desktop_full_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(desktop_full_path, 'w', encoding='utf-8') as f:
        f.write(desktop_content)
    
    print(f"✅ Created {desktop_path}")
    return True

def generate_nav_items(role):
    """Generate navigation items based on role"""
    nav_configs = {
        'admin': [
            ("Icons.school, 'Students', false, onTap: () => context.push('/admin/student-management')"),
            ("Icons.people, 'Teachers', false, onTap: () => context.push('/admin/staff-management')"),
            ("Icons.class_, 'Classes', false, onTap: () => context.push('/admin/class-management')"),
            ("Icons.assignment, 'Exams', false, onTap: () => context.pushNamed('exam-overview')"),
            ("Icons.account_balance_wallet, 'Finance', false, onTap: () => context.push('/admin/finance-management')"),
        ],
        'teacher': [
            ("Icons.how_to_reg, 'Attendance', false, onTap: () => context.push('/teacher/attendance-marking')"),
            ("Icons.book, 'Lesson Plans', false, onTap: () => context.push('/teacher/lesson-plan-management')"),
            ("Icons.schedule, 'Timetable', false, onTap: () => context.push('/teacher/timetable')"),
            ("Icons.school, 'Students', false, onTap: () => context.push('/teacher/students')"),
        ],
        'parent': [
            ("Icons.child_care, 'Attendance', false, onTap: () => context.push('/parent/child-attendance')"),
            ("Icons.schedule, 'Schedule', false, onTap: () => context.push('/parent/child-schedule')"),
            ("Icons.campaign, 'Announcements', false, onTap: () => context.push('/parent/announcements')"),
        ],
    }
    
    items = nav_configs.get(role, [])
    return '\n          '.join(f'_buildNavItem({item}),' for item in items)

def main():
    """Main function to generate all desktop screens"""
    print("🚀 Generating Desktop Screens for EduSync\n")
    
    created_count = 0
    failed_count = 0
    
    for mobile_path, desktop_path in SCREEN_MAPPINGS.items():
        if generate_desktop_screen(mobile_path, desktop_path):
            created_count += 1
        else:
            failed_count += 1
    
    print(f"\n✨ Generation Complete!")
    print(f"   Created: {created_count} screens")
    print(f"   Failed: {failed_count} screens")
    print(f"\n📝 Next step: Run update_router.py to update routes")

if __name__ == '__main__':
    main()
