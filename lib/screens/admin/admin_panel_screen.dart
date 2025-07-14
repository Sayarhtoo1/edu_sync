import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/models/school.dart';
import 'package:edu_sync/widgets/app_drawer.dart';
import 'package:edu_sync/widgets/hijri_calendar_card.dart';
import 'package:edu_sync/services/student_service.dart';
import 'package:edu_sync/services/class_service.dart'; // Import ClassService
import 'package:edu_sync/services/custom_form_service.dart';
import 'package:edu_sync/services/form_response_service.dart';
import 'package:edu_sync/models/form_response.dart';
import 'package:edu_sync/services/finance_service.dart'; // Added FinanceService import
import 'package:edu_sync/models/income.dart'; // Added Income model import
import 'package:edu_sync/models/expense.dart'; // Added Expense model import
// import 'package:edu_sync/models/student.dart' as app_student; // No longer aliased
import 'package:edu_sync/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

// Navigation imports for Quick Actions
import 'package:edu_sync/screens/admin/manage_custom_forms_screen.dart';
// import 'package:edu_sync/screens/admin/add_edit_custom_form_screen.dart'; // Not used in quick actions directly
import 'package:edu_sync/screens/admin/user_management_screen.dart';
// import 'package:edu_sync/screens/admin/view_form_responses_screen.dart'; // Not used in quick actions directly
import 'package:edu_sync/screens/admin/admin_announcements_screen.dart';
import 'package:edu_sync/screens/admin/finance_overview_screen.dart';

// TODO: Add fl_chart to pubspec.yaml if not already present for actual charts
import 'package:fl_chart/fl_chart.dart';
import 'package:edu_sync/models/school_class.dart' as app_class;


// --- Color Palette (Dribbble Inspired) ---
const Color appBackgroundColor = Color(0xFFF5F0FF); // Very light pastel purple
const Color cardBackgroundColor = Colors.white;
const Color textDarkGrey = Color(0xFF2C2C2C);
const Color textLightGrey = Color(0xFF8C8C8C);

// Accent colors for summary items
const Color accentStudents = Color(0xFFE0C7FF); // Pastel Purple
const Color iconBgStudents = Color(0xFFD4D0FB); // Slightly darker purple for icon bg
const Color iconColorStudents = Color(0xFF7A6FF0); // Icon color

const Color accentTeachers = Color(0xFFC7E9FF); // Pastel Blue
const Color iconBgTeachers = Color(0xFFB3E0FD);
const Color iconColorTeachers = Color(0xFF3B9EFF);

const Color accentParents = Color(0xFFFFD6C7); // Pastel Orange
const Color iconBgParents = Color(0xFFFFDAB3);
const Color iconColorParents = Color(0xFFFFA726);

const Color accentEarnings = Color(0xFFD5F5D1); // Pastel Green
const Color iconBgEarnings = Color(0xFFC8E6C9);
const Color iconColorEarnings = Color(0xFF4CAF50);
// --- End Color Palette ---

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

// --- Data Models (Simple versions for now) ---
class SummaryItemData {
  final String title;
  final String count;
  final IconData icon;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  // final double? progress; // Optional for progress bar

  SummaryItemData({
    required this.title,
    required this.count,
    required this.icon,
    required this.backgroundColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    // this.progress,
  });
}

class ActivityLogItem { // Renamed from RecentActivityItem for clarity
  final IconData icon;
  final String message;
  final String timestamp; // Or DateTime, formatted later

  ActivityLogItem({required this.icon, required this.message, required this.timestamp});
}

class StarStudentItem {
    final String name;
    final String id;
    final String marks;
    final String? avatarUrl; // Optional

    StarStudentItem({required this.name, required this.id, required this.marks, this.avatarUrl});
}
// --- End Data Models ---


class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final AuthService _authService = AuthService();
  final StudentService _studentService = StudentService();
  final ClassService _classService = ClassService(); // Added ClassService
  final CustomFormService _customFormService = CustomFormService();
  final FormResponseService _formResponseService = FormResponseService();
  final FinanceService _financeService = FinanceService(); // Added FinanceService instance

  bool _isLoading = true; // Single loading state for simplicity initially

  // Data for summary cards
  List<SummaryItemData> _summaryData = [];
  // Data for charts
  Map<String, int> _studentCountsByClass = {};
  // Data for star students (placeholder)
  List<StarStudentItem> _starStudents = [];
  // Data for recent activity
  List<ActivityLogItem> _activityLogs = [];
  String? _adminProfilePhotoUrl;

  // State variables for financial summary
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  double _netBalance = 0.0;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context);

    if (schoolProvider.currentSchool == null && _authService.getCurrentUser() != null) {
      await schoolProvider.fetchCurrentSchool();
    }
    
    if (!mounted) return;
    final School? currentSchool = schoolProvider.currentSchool;

    if (currentSchool != null) {
      try {
        // Load financial summary
        await _loadFinancialSummary(currentSchool.id);

        // Fetch counts for summary cards
        final teachers = await _authService.getUsersByRole('Teacher', currentSchool.id);
        final parents = await _authService.getUsersByRole('Parent', currentSchool.id);
        final students = await _studentService.getStudentsBySchool(currentSchool.id);
        final activeForms = await _customFormService.getCustomFormsForSchool(currentSchool.id);
        int formsTodayCount = activeForms.where((form) {
              final today = DateTime.now();
              return form.activeFrom.isBefore(today.add(const Duration(days: 1))) && 
                     form.activeTo.isAfter(today.subtract(const Duration(days: 1)));
        }).length;

        // String earningsToday = "\$19.3K"; // Placeholder, replaced by formsTodayCount

        // Calculate student distribution by class for Donut Chart
        final List<app_class.SchoolClass> schoolClasses = await _classService.getClasses(currentSchool.id);
        Map<String, int> studentCounts = {};
        Map<int?, String> classNameMap = {for (var c in schoolClasses) c.id: c.name};
        classNameMap[null] = l10n.unassigned; // For students not in any class

        for (var student in students) {
          String className = classNameMap[student.classId] ?? l10n.unknown_class;
          studentCounts[className] = (studentCounts[className] ?? 0) + 1;
        }
        
        setState(() {
          _summaryData = [
            SummaryItemData(title: l10n.students, count: students.length.toString(), icon: Icons.school_outlined, backgroundColor: accentStudents, iconBackgroundColor: iconBgStudents, iconColor: iconColorStudents),
            SummaryItemData(title: l10n.teachers, count: teachers.length.toString(), icon: Icons.person_outline, backgroundColor: accentTeachers, iconBackgroundColor: iconBgTeachers, iconColor: iconColorTeachers),
            SummaryItemData(title: l10n.parents, count: parents.length.toString(), icon: Icons.group_outlined, backgroundColor: accentParents, iconBackgroundColor: iconBgParents, iconColor: iconColorParents),
            SummaryItemData(title: l10n.formsToday, count: formsTodayCount.toString(), icon: Icons.article_outlined, backgroundColor: accentEarnings, iconBackgroundColor: iconBgEarnings, iconColor: iconColorEarnings),
          ];
          _studentCountsByClass = studentCounts;
        });

        // Fetch recent activity
        final List<FormResponse> recentResponses = await _formResponseService.getRecentResponses(currentSchool.id, limit: 3);
        List<ActivityLogItem> activities = [];
        for (var response in recentResponses) {
          final studentDetails = await _studentService.getStudentById(response.studentId, currentSchool.id);
          activities.add(ActivityLogItem(
            icon: Icons.check_circle_outline, // Example icon
            message: "${studentDetails?.fullName ?? 'A student'} submitted a report.",
            timestamp: DateFormat('h:mm a').format(response.submittedAt.toLocal()),
          ));
        }
         _activityLogs = activities;


        // Placeholder for Star Students
        _starStudents = [
            StarStudentItem(name: "Evelyn Harper", id: "PRE43178", marks: "98%", avatarUrl: "https://via.placeholder.com/150"),
            StarStudentItem(name: "Diana Plenty", id: "PRE43174", marks: "91%", avatarUrl: "https://via.placeholder.com/150"),
            StarStudentItem(name: "John Millar", id: "PRE43187", marks: "92%", avatarUrl: "https://via.placeholder.com/150"),
        ];

        // Fetch admin profile photo URL
        final currentAuthUser = _authService.getCurrentUser();
        if (currentAuthUser != null) {
          final adminUserDetails = await _authService.getUserById(currentAuthUser.id); // Changed to getUserById
          if (mounted) {
            setState(() {
              _adminProfilePhotoUrl = adminUserDetails?.profilePhotoUrl;
            });
          }
        }

      } catch (e) {
        print("Error loading dashboard data: $e");
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading data: $e")));
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // final schoolProvider = Provider.of<SchoolProvider>(context); // Already got it in _loadDashboardData
    // final School? displaySchool = schoolProvider.currentSchool; // Use from state or provider as needed

    // Using Poppins as an example, ensure it's added to pubspec.yaml and assets
    // final textTheme = Theme.of(context).textTheme.apply(fontFamily: 'Poppins');
    final textTheme = Theme.of(context).textTheme;


    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        // title: Text(l10n.adminPanel, style: textTheme.titleLarge?.copyWith(color: textDarkGrey, fontWeight: FontWeight.bold)),
        backgroundColor: appBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: textDarkGrey),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none_outlined), onPressed: () { /* TODO */ }),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: _adminProfilePhotoUrl != null && _adminProfilePhotoUrl!.isNotEmpty 
                  ? NetworkImage(_adminProfilePhotoUrl!) 
                  : null,
              child: (_adminProfilePhotoUrl == null || _adminProfilePhotoUrl!.isEmpty) 
                  ? const Icon(Icons.person, size: 18) 
                  : null,
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(iconColorStudents))) // Use an accent color
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              color: iconColorStudents, // Use an accent color
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0), // Reduced horizontal padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGreetingRow(context, textTheme, l10n),
                      const SizedBox(height: 24),
                      HijriCalendarCard(),
                      const SizedBox(height: 24),
                      _buildSummaryItemsGrid(context, textTheme, l10n),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FinanceOverviewScreen(),)),
                        child: _buildFinancialSummarySection(context, textTheme, l10n)
                      ), // Added Financial Summary Section
                      const SizedBox(height: 24),
                      _buildQuickActionsSection(context, textTheme, l10n), // Added Quick Actions
                      const SizedBox(height: 24),
                      _buildChartsRow(context, textTheme, l10n),
                      const SizedBox(height: 24),
                      _buildBottomSectionsRow(context, textTheme, l10n),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _loadFinancialSummary(int schoolId) async {
    if (!mounted) return;
    try {
      final List<Income> incomeRecords = await _financeService.getIncomes(schoolId);
      final List<Expense> expenseRecords = await _financeService.getExpenses(schoolId);

      double currentTotalIncome = incomeRecords.fold(0.0, (sum, item) => sum + item.amount);
      double currentTotalExpenses = expenseRecords.fold(0.0, (sum, item) => sum + item.amount);
      double currentNetBalance = currentTotalIncome - currentTotalExpenses;

      if (mounted) {
        setState(() {
          _totalIncome = currentTotalIncome;
          _totalExpenses = currentTotalExpenses;
          _netBalance = currentNetBalance;
        });
      }
    } catch (e) {
      print("Error loading financial summary: $e");
      // Optionally show a snackbar or handle error in UI
    }
  }

  Widget _buildGreetingRow(BuildContext context, TextTheme textTheme, AppLocalizations l10n) {
    // final user = _authService.getCurrentUser(); // Assuming user name is not needed here per design
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.welcomeAdmin, // "Welcome, Admin!" or similar
          style: textTheme.bodyMedium?.copyWith(color: textLightGrey),
        ),
        const SizedBox(height: 4),
        Text(
          "Admin Dashboard", // As per Dribbble
          style: textTheme.headlineMedium?.copyWith(color: textDarkGrey, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSummaryItemDisplay(BuildContext context, SummaryItemData item, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0), // Reduced horizontal padding
      decoration: BoxDecoration(
        color: item.backgroundColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  item.title,
                  style: textTheme.bodySmall?.copyWith(color: textDarkGrey.withAlpha((0.7 * 255).round())),
                  overflow: TextOverflow.ellipsis, // Add overflow handling for title
                  maxLines: 2, // Allow title to wrap to two lines
                ),
                const SizedBox(height: 4),
                Text(
                  item.count,
                  style: textTheme.titleLarge?.copyWith(color: textDarkGrey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8), // Add a small space before the icon
          CircleAvatar(
            radius: 20, // Keep radius
            backgroundColor: item.iconBackgroundColor,
            child: Icon(item.icon, color: item.iconColor, size: 20), // Keep icon size
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItemsGrid(BuildContext context, TextTheme textTheme, AppLocalizations l10n) {
    // The Dribbble shot shows 4 items in a row.
    // double screenWidth = MediaQuery.of(context).size.width;
    // double itemWidth = (screenWidth - 40 - (16 * 3)) / 4; // Assuming 20 padding each side, 16 spacing
    // itemWidth = itemWidth < 100 ? 100 : itemWidth; // Min width

    if (_summaryData.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(builder: (context, constraints) {
      // Determine number of columns based on available width
      int crossAxisCount;
      if (constraints.maxWidth >= 800) { // Large screen, 4 items
        crossAxisCount = 4;
      } else if (constraints.maxWidth >= 500) { // Medium screen, 2 items
        crossAxisCount = 2;
      } else { // Small screen, 2 items (or 1 if very small, but 2 is common)
        crossAxisCount = 2; 
      }
      
      // Calculate item width based on crossAxisCount and spacing
      double availableWidth = constraints.maxWidth; 
      double totalSpacing = 16.0 * (crossAxisCount - 1);
      // Ensure totalSpacing is not greater than availableWidth before division
      double itemWidth = (totalSpacing < availableWidth) 
          ? ((availableWidth - totalSpacing) / crossAxisCount).floorToDouble() // Floor to avoid sub-pixel issues contributing to wrap
          : (availableWidth / crossAxisCount).floorToDouble(); // Fallback if spacing is too much for items (e.g. very narrow screen)
      
      itemWidth = itemWidth > 0 ? itemWidth : 50.0; // Min width safeguard, reduced from 100


      return Wrap(
        spacing: 16.0,
        runSpacing: 16.0,
        children: _summaryData.map((item) {
          return SizedBox(
            width: itemWidth,
            child: _buildSummaryItemDisplay(context, item, textTheme),
          );
        }).toList(),
      );
    });
  }

  Widget _buildFinancialSummarySection(BuildContext context, TextTheme textTheme, AppLocalizations l10n) {
    final NumberFormat currencyFormat = NumberFormat.currency(locale: l10n.localeName, symbol: ''); // Adjust symbol as needed, or use l10n for currency symbol

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.financialSummaryTitle, // "Financial Summary"
              style: textTheme.titleLarge?.copyWith(color: textDarkGrey, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildFinancialDetailRow(
              l10n.totalIncomeLabel, // "Total Income:"
              currencyFormat.format(_totalIncome),
              iconColorEarnings, // Green
              textTheme,
            ),
            const SizedBox(height: 8),
            _buildFinancialDetailRow(
              l10n.totalExpensesLabel, // "Total Expenses:"
              currencyFormat.format(_totalExpenses),
              iconColorParents, // Orange/Red for expenses
              textTheme,
            ),
            const Divider(height: 24, thickness: 1),
            _buildFinancialDetailRow(
              l10n.netBalanceLabel, // "Net Balance:"
              currencyFormat.format(_netBalance),
              _netBalance >= 0 ? iconColorEarnings : iconColorParents, // Green if positive, Red/Orange if negative
              textTheme,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialDetailRow(String label, String value, Color valueColor, TextTheme textTheme, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(color: textLightGrey, fontWeight: isBold ? FontWeight.w600 : FontWeight.normal),
        ),
        Text(
          value,
          style: textTheme.bodyLarge?.copyWith(color: valueColor, fontWeight: isBold ? FontWeight.bold : FontWeight.w600),
        ),
      ],
    );
  }


  Widget _buildChartsRow(BuildContext context, TextTheme textTheme, AppLocalizations l10n) {
    // Placeholder for charts
    return LayoutBuilder(builder: (context, constraints) {
      bool isMobile = constraints.maxWidth < 650; // Adjusted breakpoint for charts
      return Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Students Donut Chart (now first)
          Flexible( 
            flex: isMobile ? 0 : 1, // Takes 1/3 of space on web/tablet
            child: Container(
              height: isMobile ? 300 : 300, // Increased height for chart + legend
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardBackgroundColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.05 * 255).round()), blurRadius: 10, offset: const Offset(0,2))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Text(l10n.studentsDistributionByClassTitle, style: textTheme.titleMedium?.copyWith(color: textDarkGrey, fontWeight: FontWeight.w600)), // TODO: Add l10n
                  const SizedBox(height:10), 
                  Expanded(
                    child: _studentCountsByClass.isEmpty
                        ? Center(child: Text(l10n.noDataAvailable, style: textTheme.bodySmall?.copyWith(color: textLightGrey)))
                        : PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40, // Makes it a donut
                              sections: _generatePieChartSections(context, l10n), // Pass context for l10n
                              pieTouchData: PieTouchData(
                                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                  // Handle touch events if needed
                                },
                              ),
                            ),
                          ),
                  ),
                  if (_studentCountsByClass.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildChartLegend(context, textTheme, l10n),
                  ]
                ]
              ),
            ),
          ),
          SizedBox(width: isMobile ? 0 : 16, height: isMobile ? 16 : 0),
          // All Exam Results Line Chart (now second)
          Flexible( 
            flex: isMobile ? 0 : 2, // Takes 2/3 of space on web/tablet
            child: Container(
              height: isMobile ? 250 : 300, 
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardBackgroundColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.05 * 255).round()), blurRadius: 10, offset: const Offset(0,2))]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("All Exam Results", style: textTheme.titleMedium?.copyWith(color: textDarkGrey, fontWeight: FontWeight.w600)), const SizedBox(height:10), Center(child: Text("Line Chart Placeholder", style: textTheme.bodySmall?.copyWith(color: textLightGrey)))]),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildChartLegend(BuildContext context, TextTheme textTheme, AppLocalizations l10n) {
    final List<Color> sectionColors = _getSectionColors(); // Use a helper to get consistent colors
    int colorIndex = 0;

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: _studentCountsByClass.entries.map((entry) {
        final color = sectionColors[colorIndex % sectionColors.length];
        colorIndex++;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 10, height: 10, color: color),
            const SizedBox(width: 4),
            Text("${entry.key} (${entry.value})", style: textTheme.bodySmall?.copyWith(color: textDarkGrey)),
          ],
        );
      }).toList(),
    );
  }
  
  List<Color> _getSectionColors() { // Helper to ensure consistent color list
    return [
      Colors.purple.shade300, Colors.blue.shade300, Colors.orange.shade300,
      Colors.green.shade300, Colors.red.shade300, Colors.teal.shade300,
      Colors.pink.shade300, Colors.amber.shade300,
      // Add more if you expect more classes than this
    ];
  }


  Widget _buildStarStudentListItem(BuildContext context, StarStudentItem student, TextTheme textTheme) {
    return ListTile(
      contentPadding: EdgeInsets.zero, // Remove default ListTile padding if using custom spacing
      leading: CircleAvatar(
        backgroundImage: student.avatarUrl != null && student.avatarUrl!.isNotEmpty 
            ? NetworkImage(student.avatarUrl!) 
            : null,
        child: (student.avatarUrl == null || student.avatarUrl!.isEmpty) 
            ? const Icon(Icons.person) 
            : null,
      ),
      title: Text(student.name, style: textTheme.bodyMedium?.copyWith(color: textDarkGrey, fontWeight: FontWeight.w500)),
      subtitle: Text(student.id, style: textTheme.bodySmall?.copyWith(color: textLightGrey)),
      trailing: Text(student.marks.toString(), style: textTheme.bodyMedium?.copyWith(color: iconColorStudents, fontWeight: FontWeight.w600)), // Ensure marks is string
    );
}

 Widget _buildActivityLogListItem(BuildContext context, ActivityLogItem item, TextTheme textTheme) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: accentEarnings.withAlpha((0.2 * 255).round()), 
        child: Icon(item.icon, size: 18, color: accentEarnings),
      ),
      title: Text(item.message, style: textTheme.bodyMedium?.copyWith(color: textDarkGrey), maxLines: 2, overflow: TextOverflow.ellipsis,),
      trailing: Text(item.timestamp, style: textTheme.bodySmall?.copyWith(color: textLightGrey)),
    );
  }


  Widget _buildBottomSectionsRow(BuildContext context, TextTheme textTheme, AppLocalizations l10n) {
    // Placeholder for Star Students and Recent Activity
     return LayoutBuilder(builder: (context, constraints) {
      bool isMobile = constraints.maxWidth < 700; 
      return Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible( // Use Flexible
            flex: isMobile ? 0 : 3, 
            child: Container(
              constraints: BoxConstraints(minHeight: isMobile ? 300 : 350),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardBackgroundColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.05 * 255).round()), blurRadius: 10, offset: const Offset(0,2))]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Star Students", style: textTheme.titleMedium?.copyWith(color: textDarkGrey, fontWeight: FontWeight.w600)),
                const SizedBox(height:10),
                _starStudents.isEmpty 
                ? Center(child: Text("No star students to display.", style: textTheme.bodySmall?.copyWith(color: textLightGrey)))
                : ListView.builder( // This ListView needs to be constrained or not inside a Column that's in a Flexible with flex:0
                    shrinkWrap: true, 
                    physics: const NeverScrollableScrollPhysics(), 
                    itemCount: _starStudents.length,
                    itemBuilder: (ctx, i) => _buildStarStudentListItem(context, _starStudents[i], textTheme),
                  )
              ]),
            ),
          ),
          SizedBox(width: isMobile ? 0 : 16, height: isMobile ? 16 : 0),
          Flexible( 
            flex: isMobile ? 0 : 2,
            child: Container(
              constraints: BoxConstraints(minHeight: isMobile ? 250 : 350), 
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardBackgroundColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.05 * 255).round()), blurRadius: 10, offset: const Offset(0,2))]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Recent Activity", style: textTheme.titleMedium?.copyWith(color: textDarkGrey, fontWeight: FontWeight.w600)),
                const SizedBox(height:10),
                _activityLogs.isEmpty
                ? Center(child: Text(l10n.noRecentActivity, style: textTheme.bodySmall?.copyWith(color: textLightGrey)))
                : ListView.builder( // Same here
                    shrinkWrap: true, 
                    physics: const NeverScrollableScrollPhysics(), 
                    itemCount: _activityLogs.length,
                    itemBuilder: (ctx, i) => _buildActivityLogListItem(context, _activityLogs[i], textTheme),
                  )
              ]),
            ),
          ),
        ],
      );
    });
  }

  // Keep _buildQuickActionGrid and _buildRecentActivityFeed if they are to be reused or adapted
  // For now, the Dribbble design doesn't show a separate quick action grid like our previous one.
  // The "Recent Activity" is part of the bottom sections.
  // I'll comment out the old _buildQuickActionGrid and _buildRecentActivityFeed for now.

  // Widget _buildQuickActionGrid(BuildContext context, AppLocalizations l10n) { ... } // Old one, can be removed fully later
  // Widget _buildRecentActivityFeed(BuildContext context, AppLocalizations l10n) { ... }


  Widget _buildQuickActionItem(BuildContext context, TextTheme textTheme, String title, IconData icon, Color bgColor, Color iconBgColor, Color iconFgColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.0),
           boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha((0.08 * 255).round()), // Changed withOpacity to withAlpha
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: iconBgColor,
              child: Icon(icon, color: iconFgColor, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: textDarkGrey, fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, TextTheme textTheme, AppLocalizations l10n) {
    // final schoolId = Provider.of<SchoolProvider>(context, listen: false).currentSchool?.id; // Unused
    // final currentUserId = _authService.getCurrentUser()?.id; // Unused

    // Define actions - using some of the summary item colors for consistency
    final actions = [
      {
        'title': l10n.manageTeachersAction, // "Teachers"
        'icon': Icons.person_search_outlined,
        'bgColor': accentTeachers.withAlpha(100), // Lighter version of accentTeachers
        'iconBgColor': iconBgTeachers,
        'iconFgColor': iconColorTeachers,
        'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserManagementScreen(initialTabIndex: 0))),
      },
      {
        'title': l10n.manageParentsAction, // "Parents"
        'icon': Icons.group_add_outlined,
        'bgColor': accentParents.withAlpha(100),
        'iconBgColor': iconBgParents,
        'iconFgColor': iconColorParents,
        'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserManagementScreen(initialTabIndex: 1))),
      },
      {
        'title': l10n.manageFormsAction, // "Manage Forms"
        'icon': Icons.folder_open_outlined,
        'bgColor': accentEarnings.withAlpha(100),
        'iconBgColor': iconBgEarnings,
        'iconFgColor': iconColorEarnings,
        'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManageCustomFormsScreen())),
      },
      {
        'title': l10n.announcementsAction, // "Announcements"
        'icon': Icons.campaign_outlined,
        'bgColor': accentStudents.withAlpha(100),
        'iconBgColor': iconBgStudents,
        'iconFgColor': iconColorStudents,
        'onTap': () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminAnnouncementsScreen())),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions, // "Quick Actions"
          style: textTheme.titleLarge?.copyWith(color: textDarkGrey, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
          double itemWidth = (constraints.maxWidth - (16 * (crossAxisCount - 1))) / crossAxisCount;
          itemWidth = itemWidth > 0 ? itemWidth.floorToDouble() : 100.0;

          return Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            children: actions.map((action) {
              return SizedBox(
                width: itemWidth,
                height: itemWidth * 0.9, // Maintain aspect ratio slightly
                child: _buildQuickActionItem(
                  context,
                  textTheme,
                  action['title'] as String,
                  action['icon'] as IconData,
                  action['bgColor'] as Color,
                  action['iconBgColor'] as Color,
                  action['iconFgColor'] as Color,
                  action['onTap'] as VoidCallback,
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }


  List<PieChartSectionData> _generatePieChartSections(BuildContext context, AppLocalizations l10n) {
    final List<Color> sectionColors = _getSectionColors();
    int colorIndex = 0;
    
    if (_studentCountsByClass.isEmpty) return [];

    return _studentCountsByClass.entries.map((entry) {
      final sectionColor = sectionColors[colorIndex % sectionColors.length];
      colorIndex++;

      return PieChartSectionData(
        color: sectionColor,
        value: entry.value.toDouble(),
        title: entry.value.toInt().toString(), // Show count on section
        radius: 50, 
        titleStyle: const TextStyle(
          fontSize: 14, // Slightly larger for count
          fontWeight: FontWeight.bold,
          color: Colors.white, // Or a contrasting color
          shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
        // You can add a badgeWidget here for class name if needed and space allows
      );
    }).toList();
  }
}
