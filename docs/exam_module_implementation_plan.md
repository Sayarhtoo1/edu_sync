# Exam Module - Implementation Plan

## Phase 1: Critical Features (Week 1-2)

### Task 1.1: Database Constraints & Optimizations
**Priority:** HIGH | **Estimated Time:** 2 hours

**Subtasks:**
- [ ] Create migration to make `exams.class_id` NOT NULL
- [ ] Add constraint to validate marks range in `student_exam_marks`
- [ ] Add database indexes for performance
- [ ] Test migration on development database

**Files to Create/Modify:**
- `supabase/migrations/YYYYMMDD_exam_constraints_and_indexes.sql`

**SQL:**
```sql
-- Make class_id mandatory
ALTER TABLE exams ALTER COLUMN class_id SET NOT NULL;

-- Add marks validation
ALTER TABLE student_exam_marks
  ADD CONSTRAINT chk_marks_range 
  CHECK (marks_obtained >= 0 AND marks_obtained <= total_marks);

-- Add indexes
CREATE INDEX idx_exams_school_date ON exams(school_id, exam_date);
CREATE INDEX idx_exams_class_date ON exams(class_id, exam_date);
CREATE INDEX idx_student_marks_exam ON student_exam_marks(exam_id, student_id);
CREATE INDEX idx_student_marks_subject ON student_exam_marks(subject_id);
```

---

### Task 1.2: Marks Entry Service
**Priority:** CRITICAL | **Estimated Time:** 4 hours

**Subtasks:**
- [ ] Create `ExamMarksService` class
- [ ] Implement `getStudentsForMarksEntry()` method
- [ ] Implement `saveStudentMark()` method
- [ ] Implement `bulkSaveMarks()` method
- [ ] Implement `getMarksEntryProgress()` method
- [ ] Add error handling and validation

**Files to Create:**
- `lib/services/exam_marks_service.dart`

**Key Methods:**
```dart
class ExamMarksService {
  Future<List<Map<String, dynamic>>> getStudentsForMarksEntry(String examId, String subjectId);
  Future<void> saveStudentMark(String examId, int studentId, String subjectId, int marks);
  Future<void> bulkSaveMarks(String examId, String subjectId, List<Map<String, dynamic>> marks);
  Future<Map<String, dynamic>> getMarksEntryProgress(String examId, String subjectId);
  Future<double> calculateGrade(int marks, int totalMarks, List<Grade> grades);
}
```

---

### Task 1.3: Marks Entry Screen UI
**Priority:** CRITICAL | **Estimated Time:** 8 hours

**Subtasks:**
- [ ] Create `MarksEntryScreen` widget
- [ ] Implement student list with search
- [ ] Add marks input fields with validation
- [ ] Implement real-time grade calculation
- [ ] Add color-coded pass/fail indicators
- [ ] Implement auto-save functionality
- [ ] Add progress summary section
- [ ] Add navigation between subjects

**Files to Create:**
- `lib/screens/admin/exam/marks_entry_screen.dart`
- `lib/screens/admin/exam/widgets/marks_entry_row.dart`
- `lib/screens/admin/exam/widgets/marks_summary_widget.dart`

**Route to Add:**
```dart
// In router.dart
GoRoute(
  path: 'marks-entry/:examId/:subjectId',
  builder: (context, state) => MarksEntryScreen(
    examId: state.pathParameters['examId']!,
    subjectId: state.pathParameters['subjectId']!,
  ),
),
```

---

### Task 1.4: Report Card Service
**Priority:** CRITICAL | **Estimated Time:** 3 hours

**Subtasks:**
- [ ] Create `ExamReportService` class
- [ ] Implement `getStudentReportCard()` method
- [ ] Implement `getClassRankings()` method
- [ ] Implement `calculateOverallPerformance()` method
- [ ] Add caching for report cards

**Files to Create:**
- `lib/services/exam_report_service.dart`

**Key Methods:**
```dart
class ExamReportService {
  Future<Map<String, dynamic>> getStudentReportCard(int studentId, String examId);
  Future<int> getStudentRank(int studentId, String examId);
  Future<Map<String, dynamic>> getClassAverage(String examId);
  Future<List<Map<String, dynamic>>> getTopPerformers(String examId, int limit);
}
```

---

### Task 1.5: Report Card Screen UI
**Priority:** CRITICAL | **Estimated Time:** 6 hours

**Subtasks:**
- [ ] Create `ReportCardScreen` widget
- [ ] Design report card layout
- [ ] Implement subject-wise marks display
- [ ] Add overall performance section
- [ ] Add class rank display
- [ ] Implement print functionality
- [ ] Add share functionality
- [ ] Style for print-friendly output

**Files to Create:**
- `lib/screens/common/report_card_screen.dart`
- `lib/screens/common/widgets/report_card_header.dart`
- `lib/screens/common/widgets/report_card_table.dart`
- `lib/screens/common/widgets/report_card_summary.dart`

**Dependencies to Add:**
```yaml
# pubspec.yaml
dependencies:
  pdf: ^3.10.0
  printing: ^5.11.0
  share_plus: ^7.2.0
```

---

## Phase 2: High Priority Features (Week 3-4)

### Task 2.1: Enhanced Analytics Dashboard
**Priority:** HIGH | **Estimated Time:** 10 hours

**Subtasks:**
- [ ] Create `ExamAnalyticsService`
- [ ] Implement trend analysis methods
- [ ] Create `ExamTrendsChart` widget using Syncfusion
- [ ] Create `SubjectComparisonChart` widget
- [ ] Create `ClassPerformanceHeatmap` widget
- [ ] Create `TopPerformersWidget`
- [ ] Integrate into ExamOverviewScreen

**Files to Create:**
- `lib/services/exam_analytics_service.dart`
- `lib/screens/admin/exam/widgets/exam_trends_chart.dart`
- `lib/screens/admin/exam/widgets/subject_comparison_chart.dart`
- `lib/screens/admin/exam/widgets/class_performance_heatmap.dart`
- `lib/screens/admin/exam/widgets/top_performers_widget.dart`

---

### Task 2.2: Exam Calendar View
**Priority:** HIGH | **Estimated Time:** 8 hours

**Subtasks:**
- [ ] Create `ExamCalendarScreen` widget
- [ ] Implement monthly calendar view
- [ ] Add color-coding by subject
- [ ] Implement exam detail popup
- [ ] Add filter by class/subject
- [ ] Add navigation between months

**Files to Create:**
- `lib/screens/admin/exam/exam_calendar_screen.dart`
- `lib/screens/admin/exam/widgets/calendar_day_cell.dart`
- `lib/screens/admin/exam/widgets/exam_detail_dialog.dart`

**Dependencies to Add:**
```yaml
dependencies:
  table_calendar: ^3.0.9
```

---

### Task 2.3: CSV Import/Export
**Priority:** HIGH | **Estimated Time:** 6 hours

**Subtasks:**
- [ ] Implement CSV export for marks template
- [ ] Implement CSV import for bulk marks entry
- [ ] Add validation for imported data
- [ ] Create import preview screen
- [ ] Add error reporting for failed imports

**Files to Create:**
- `lib/services/exam_import_export_service.dart`
- `lib/screens/admin/exam/marks_import_screen.dart`

**Methods:**
```dart
class ExamImportExportService {
  Future<String> generateMarksTemplate(String examId, String subjectId);
  Future<List<Map<String, dynamic>>> parseMarksCSV(String filePath);
  Future<void> importMarks(String examId, String subjectId, List<Map<String, dynamic>> data);
  Future<String> exportMarksToCSV(String examId);
}
```

---

### Task 2.4: Notification System
**Priority:** HIGH | **Estimated Time:** 8 hours

**Subtasks:**
- [ ] Create database migration for `exam_notifications` table
- [ ] Create `ExamNotificationService`
- [ ] Implement exam reminder notifications
- [ ] Implement result published notifications
- [ ] Implement marks entry deadline reminders
- [ ] Add notification preferences screen

**Files to Create:**
- `supabase/migrations/YYYYMMDD_exam_notifications.sql`
- `lib/services/exam_notification_service.dart`
- `lib/screens/settings/notification_preferences_screen.dart`

---

## Phase 3: Medium Priority Features (Week 5-6)

### Task 3.1: Exam Templates
**Priority:** MEDIUM | **Estimated Time:** 6 hours

**Subtasks:**
- [ ] Create database migration for `exam_templates` table
- [ ] Create `ExamTemplateService`
- [ ] Create template management screen
- [ ] Implement save as template functionality
- [ ] Implement create from template functionality

**Files to Create:**
- `supabase/migrations/YYYYMMDD_exam_templates.sql`
- `lib/services/exam_template_service.dart`
- `lib/screens/admin/exam/exam_template_screen.dart`
- `lib/models/exam_template.dart`

---

### Task 3.2: Marks Approval Workflow
**Priority:** MEDIUM | **Estimated Time:** 10 hours

**Subtasks:**
- [ ] Create database migration for `marks_approvals` table
- [ ] Create `MarksApprovalService`
- [ ] Implement submit for approval functionality
- [ ] Create approval review screen
- [ ] Implement approval/rejection workflow
- [ ] Add audit trail display

**Files to Create:**
- `supabase/migrations/YYYYMMDD_marks_approvals.sql`
- `lib/services/marks_approval_service.dart`
- `lib/screens/admin/exam/marks_approval_screen.dart`
- `lib/models/marks_approval.dart`

---

### Task 3.3: Student Performance Analytics
**Priority:** MEDIUM | **Estimated Time:** 8 hours

**Subtasks:**
- [ ] Create `StudentPerformanceScreen`
- [ ] Implement performance timeline chart
- [ ] Create subject strength/weakness radar chart
- [ ] Add comparison with class average
- [ ] Implement improvement trends

**Files to Create:**
- `lib/screens/student/student_performance_screen.dart`
- `lib/screens/student/widgets/performance_timeline_chart.dart`
- `lib/screens/student/widgets/subject_radar_chart.dart`

---

### Task 3.4: Parent Portal Integration
**Priority:** MEDIUM | **Estimated Time:** 6 hours

**Subtasks:**
- [ ] Add exam schedule view for parents
- [ ] Add child's report card access
- [ ] Implement result notifications for parents
- [ ] Add performance comparison view

**Files to Modify:**
- `lib/screens/parent/modern_parent_dashboard.dart`
- `lib/screens/parent/child_exam_schedule_screen.dart`
- `lib/screens/parent/child_report_card_screen.dart`

---

## Phase 4: Nice-to-Have Features (Week 7-8)

### Task 4.1: Question Bank
**Priority:** LOW | **Estimated Time:** 12 hours

**Subtasks:**
- [ ] Create database schema for question bank
- [ ] Create question management screen
- [ ] Implement question tagging system
- [ ] Add random question paper generation
- [ ] Implement question usage tracking

---

### Task 4.2: Seating Arrangement
**Priority:** LOW | **Estimated Time:** 8 hours

**Subtasks:**
- [ ] Create seating arrangement algorithm
- [ ] Create seating plan screen
- [ ] Implement room allocation
- [ ] Add printable seating chart

---

### Task 4.3: Grade Moderation
**Priority:** LOW | **Estimated Time:** 6 hours

**Subtasks:**
- [ ] Implement bell curve grading
- [ ] Add grade adjustment tools
- [ ] Create moderation report

---

## Testing & Quality Assurance

### Unit Tests
- [ ] Test ExamMarksService methods
- [ ] Test ExamReportService methods
- [ ] Test ExamAnalyticsService methods
- [ ] Test validation logic
- [ ] Test grade calculation

### Integration Tests
- [ ] Test marks entry flow
- [ ] Test report card generation
- [ ] Test CSV import/export
- [ ] Test notification delivery

### UI Tests
- [ ] Test marks entry screen
- [ ] Test report card screen
- [ ] Test calendar view
- [ ] Test analytics dashboard

---

## Documentation

- [ ] Update API documentation
- [ ] Create user guide for marks entry
- [ ] Create admin guide for exam management
- [ ] Document CSV import format
- [ ] Create video tutorials

---

## Deployment Checklist

- [ ] Run database migrations on staging
- [ ] Test all features on staging
- [ ] Perform load testing
- [ ] Update app version
- [ ] Create release notes
- [ ] Deploy to production
- [ ] Monitor error logs
- [ ] Gather user feedback

---

## Success Metrics

- Marks entry time reduced by 70%
- Report card generation < 2 seconds
- 90% user satisfaction score
- Zero data loss incidents
- < 1% error rate in marks entry
