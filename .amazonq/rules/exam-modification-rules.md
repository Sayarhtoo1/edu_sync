# Exam Module Modification - Amazon Q Automation Rules

## 🎯 Mission
Implement exam module enhancements following the plan in `docs/exam_module_modification_plan.md` with professional senior Flutter developer standards.

---

## 📋 Reference Documents
- **Plan**: `docs/exam_module_modification_plan.md`
- **Current Models**: `lib/models/exam.dart`, `lib/models/subject.dart`, `lib/models/exam_subject.dart`
- **Current Screens**: `lib/screens/admin/exam/`
- **Provider**: `lib/providers/exam_provider.dart`
- **Service**: `lib/services/exam_service.dart`

---

## 🔧 Core Implementation Rules

### Rule 1: Database First Approach
**ALWAYS start with database changes using MCP server**

```
Step 1: Verify current schema
  → Use: list_tables(schemas: ['public'])
  → Check: exams, exam_subjects, subjects tables

Step 2: Apply migration
  → Use: apply_migration(name="exam_module_enhancement_v2", query="...")
  → Verify: execute_sql to check new tables/columns

Step 3: Test migration
  → Insert sample data
  → Verify foreign keys work
  → Check indexes created
```

**Migration Script Location**: Create in `supabase/migrations/`

---

### Rule 2: Model Creation Pattern
**Create models matching EXACT database schema**

```dart
// ALWAYS follow this pattern:
class ModelName {
  // 1. Final fields matching DB columns (snake_case → camelCase)
  final String id;
  final String examId;  // exam_id in DB
  final int classId;    // class_id in DB
  
  // 2. Constructor with required/optional params
  ModelName({
    required this.id,
    required this.examId,
    required this.classId,
  });
  
  // 3. fromMap factory (EXACT column names)
  factory ModelName.fromMap(Map<String, dynamic> map) {
    return ModelName(
      id: map['id'],
      examId: map['exam_id'],  // Use DB column name
      classId: map['class_id'],
    );
  }
  
  // 4. toMap method (EXACT column names)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exam_id': examId,  // Use DB column name
      'class_id': classId,
    };
  }
}
```

**File Naming**: `lib/models/exam_class.dart` (snake_case)

---

### Rule 3: Service Layer Pattern
**Implement service methods with error handling**

```dart
// Pattern for ALL service methods:
Future<ReturnType> methodName({required params}) async {
  try {
    // 1. Query with proper error handling
    final response = await _supabase
        .from('table_name')
        .select()
        .eq('column', value)
        .order('created_at', ascending: false);
    
    // 2. Transform to models
    return (response as List)
        .map((e) => Model.fromMap(e))
        .toList();
        
  } catch (e) {
    // 3. Log error with context
    logger.e('Error in methodName: $e');
    
    // 4. Return safe default or rethrow
    return [];  // or rethrow for critical operations
  }
}
```

**Service File**: Update `lib/services/exam_service.dart`

---

### Rule 4: Provider State Management
**Update provider with ChangeNotifier pattern**

```dart
class ExamProvider with ChangeNotifier {
  // 1. Private state variables
  List<ExamClass> _examClasses = [];
  
  // 2. Public getters
  List<ExamClass> get examClasses => _examClasses;
  
  // 3. Async methods that update state
  Future<void> fetchExamClasses(String examId) async {
    try {
      _examClasses = await _examService.getExamClasses(examId);
      notifyListeners();  // ALWAYS call after state change
    } catch (e) {
      logger.e('Error fetching exam classes: $e');
      // Don't clear state on error - keep old data
    }
  }
}
```

**Provider File**: Update `lib/providers/exam_provider.dart`

---

### Rule 5: Screen Implementation Pattern
**Follow existing screen structure**

```dart
class ScreenName extends StatefulWidget {
  final RequiredParam param;
  
  const ScreenName({super.key, required this.param});
  
  @override
  State<ScreenName> createState() => _ScreenNameState();
}

class _ScreenNameState extends State<ScreenName> {
  // 1. State variables
  bool _isLoading = false;
  String? _errorMessage;
  List<Model> _data = [];
  
  // 2. Controllers
  final TextEditingController _controller = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  // 3. Data loading with error handling
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final provider = Provider.of<ExamProvider>(context, listen: false);
      await provider.fetchData();
      
      if (mounted) {
        setState(() => _data = provider.data);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screen Title')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : _buildContent(),
    );
  }
}
```

---

### Rule 6: UI Component Standards
**Use project's existing UI patterns**

```dart
// Card with shadow
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: // content
)

// List item with action
Card(
  margin: const EdgeInsets.only(bottom: 12),
  child: ListTile(
    leading: CircleAvatar(
      backgroundColor: accentColor.withOpacity(0.1),
      child: Icon(Icons.icon_name, color: accentColor),
    ),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Text(subtitle),
    trailing: PopupMenuButton<String>(
      onSelected: (action) => _handleAction(action, item),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    ),
  ),
)
```

---

## 📐 Phase-Specific Implementation Rules

### PHASE 1: Database & Models

#### Step 1.1: Apply Database Migration
```
1. Create migration file: supabase/migrations/YYYYMMDDHHMMSS_exam_module_enhancement_v2.sql
2. Copy SQL from plan document
3. Use MCP: apply_migration(name="exam_module_enhancement_v2", query="...")
4. Verify: execute_sql("SELECT * FROM exam_classes LIMIT 0")
5. Check indexes: execute_sql("SELECT * FROM pg_indexes WHERE tablename = 'exam_classes'")
```

#### Step 1.2: Create ExamClass Model
```
File: lib/models/exam_class.dart

MUST include:
- All fields from exam_classes table
- fromMap factory with EXACT column names
- toMap method with EXACT column names
- TimeOfDay parsing for start_time/end_time
- Null safety for optional fields
```

#### Step 1.3: Update Exam Model
```
File: lib/models/exam.dart

REMOVE:
- final int classId;
- final DateTime examDate;

ADD:
- final String? examType;
- final List<ExamClass>? examClasses;

UPDATE:
- fromMap to handle new fields
- toMap to exclude removed fields
```

#### Step 1.4: Update Subject Model
```
File: lib/models/subject.dart

ADD:
- final String? parentSubjectId;
- final bool isSubSubject;
- final int displayOrder;
- final List<Subject>? subSubjects;

ADD METHODS:
- bool get hasSubSubjects => subSubjects != null && subSubjects!.isNotEmpty;
- int get totalMaxMarks => // Calculate including sub-subjects
```

#### Step 1.5: Update ExamSubject Model
```
File: lib/models/exam_subject.dart

ADD:
- final int? distinctionMarks;
- final String? examinerId;
- final bool isOptional;
- final double weightage;

ADD METHOD:
- bool get hasDistinction => distinctionMarks != null;
```

---

### PHASE 2: Service Layer

#### Step 2.1: Add ExamClass CRUD Methods
```dart
// In lib/services/exam_service.dart

Future<List<ExamClass>> getExamClasses(String examId) async {
  try {
    final response = await _supabase
        .from('exam_classes')
        .select()
        .eq('exam_id', examId)
        .order('exam_date', ascending: true);
    
    return (response as List)
        .map((e) => ExamClass.fromMap(e))
        .toList();
  } catch (e) {
    logger.e('Error fetching exam classes: $e');
    return [];
  }
}

Future<ExamClass> addExamClass({
  required String examId,
  required int classId,
  required DateTime examDate,
  TimeOfDay? startTime,
  TimeOfDay? endTime,
  String? venue,
  String? instructions,
}) async {
  try {
    final response = await _supabase
        .from('exam_classes')
        .insert({
          'exam_id': examId,
          'class_id': classId,
          'exam_date': examDate.toIso8601String().split('T')[0],
          'start_time': startTime?.format(context),
          'end_time': endTime?.format(context),
          'venue': venue,
          'instructions': instructions,
        })
        .select()
        .single();
    
    return ExamClass.fromMap(response);
  } catch (e) {
    logger.e('Error adding exam class: $e');
    rethrow;
  }
}

// Add updateExamClass, deleteExamClass similarly
```

#### Step 2.2: Add Multi-Class Exam Creation
```dart
Future<Exam> createMultiClassExam({
  required int schoolId,
  required String name,
  required List<int> classIds,
  required Map<int, DateTime> classDates,
  String? examType,
  String? examinerName,
  String? description,
}) async {
  try {
    // 1. Create exam (without class_id, exam_date)
    final examResponse = await _supabase
        .from('exams')
        .insert({
          'school_id': schoolId,
          'name': name,
          'exam_type': examType,
          'examiner_name': examinerName ?? 'Not Specified',
          'description': description,
        })
        .select()
        .single();
    
    final examId = examResponse['id'];
    
    // 2. Create exam_classes entries
    for (final classId in classIds) {
      await _supabase.from('exam_classes').insert({
        'exam_id': examId,
        'class_id': classId,
        'exam_date': classDates[classId]!.toIso8601String().split('T')[0],
      });
    }
    
    return Exam.fromMap(examResponse);
  } catch (e) {
    logger.e('Error creating multi-class exam: $e');
    rethrow;
  }
}
```

#### Step 2.3: Add Subject with Sub-Subjects Methods
```dart
Future<List<Subject>> getSubjectsWithSubSubjects(int schoolId, {int? classId}) async {
  try {
    // 1. Get all subjects
    var query = _supabase
        .from('subjects')
        .select()
        .eq('school_id', schoolId);
    
    if (classId != null) {
      query = query.eq('class_id', classId);
    }
    
    final response = await query.order('display_order', ascending: true);
    final allSubjects = (response as List)
        .map((e) => Subject.fromMap(e))
        .toList();
    
    // 2. Build parent-child hierarchy
    final parentSubjects = allSubjects
        .where((s) => s.parentSubjectId == null)
        .toList();
    
    for (final parent in parentSubjects) {
      final subs = allSubjects
          .where((s) => s.parentSubjectId == parent.id)
          .toList();
      
      // Create new instance with subSubjects
      // (You'll need to add copyWith method to Subject model)
    }
    
    return parentSubjects;
  } catch (e) {
    logger.e('Error fetching subjects with sub-subjects: $e');
    return [];
  }
}

Future<Subject> addSubSubject({
  required String parentSubjectId,
  required String name,
  required int schoolId,
  int? maxMarks,
  int? passingMarks,
}) async {
  try {
    final response = await _supabase
        .from('subjects')
        .insert({
          'name': name,
          'school_id': schoolId,
          'parent_subject_id': parentSubjectId,
          'is_sub_subject': true,
          'max_marks': maxMarks,
          'passing_marks': passingMarks,
        })
        .select()
        .single();
    
    return Subject.fromMap(response);
  } catch (e) {
    logger.e('Error adding sub-subject: $e');
    rethrow;
  }
}
```

---

### PHASE 3: Provider Updates

#### Step 3.1: Update ExamProvider
```dart
// Add to lib/providers/exam_provider.dart

class ExamProvider with ChangeNotifier {
  // ... existing code ...
  
  // NEW: Exam classes state
  List<ExamClass> _examClasses = [];
  List<ExamClass> get examClasses => _examClasses;
  
  // NEW: Fetch exam classes
  Future<void> fetchExamClasses(String examId) async {
    try {
      _examClasses = await _examService.getExamClasses(examId);
      notifyListeners();
    } catch (e) {
      logger.e('Error in fetchExamClasses: $e');
    }
  }
  
  // NEW: Create multi-class exam
  Future<Exam> createMultiClassExam({
    required int schoolId,
    required String name,
    required List<int> classIds,
    required Map<int, DateTime> classDates,
    String? examType,
    String? examinerName,
    String? description,
  }) async {
    final exam = await _examService.createMultiClassExam(
      schoolId: schoolId,
      name: name,
      classIds: classIds,
      classDates: classDates,
      examType: examType,
      examinerName: examinerName,
      description: description,
    );
    await fetchExams(schoolId.toString());
    return exam;
  }
  
  // NEW: Fetch subjects with hierarchy
  Future<void> fetchSubjectsWithSubSubjects(int schoolId, {int? classId}) async {
    try {
      _subjects = await _examService.getSubjectsWithSubSubjects(
        schoolId,
        classId: classId,
      );
      notifyListeners();
    } catch (e) {
      logger.e('Error in fetchSubjectsWithSubSubjects: $e');
    }
  }
}
```

---

### PHASE 4: UI Screen Updates

#### Step 4.1: Update ExamFormScreen
```
File: lib/screens/admin/exam/exam_form_screen.dart

CHANGES:
1. Add FormStep.classScheduling (between basic and subjects)
2. Add state variables:
   - Set<int> _selectedClasses = {}
   - Map<int, DateTime> _classDates = {}
   - String? _selectedExamType
3. Add _buildClassSchedulingStep() method
4. Update _saveExam() to use createMultiClassExam
5. Update validation to check classes selected
```

**Implementation:**
```dart
// Add after FormStep enum
enum FormStep { basic, classScheduling, subjects, settings }

// Add state variables
Set<int> _selectedClasses = {};
Map<int, DateTime> _classDates = {};
String? _selectedExamType;

// Add step
Widget _buildClassSchedulingStep() {
  return ListView(
    padding: const EdgeInsets.all(16),
    children: [
      // Exam Type Dropdown
      DropdownButtonFormField<String>(
        value: _selectedExamType,
        decoration: const InputDecoration(
          labelText: 'Exam Type',
          border: OutlineInputBorder(),
        ),
        items: ['Midterm', 'Final', 'Quiz', 'Monthly', 'Unit Test', 'Other']
            .map((type) => DropdownMenuItem(value: type, child: Text(type)))
            .toList(),
        onChanged: (value) => setState(() => _selectedExamType = value),
      ),
      
      const SizedBox(height: 24),
      Text('Select Classes', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 16),
      
      // Class selection
      ...classes.map((schoolClass) => CheckboxListTile(
        title: Text(schoolClass.name),
        value: _selectedClasses.contains(schoolClass.id),
        onChanged: (selected) {
          setState(() {
            if (selected!) {
              _selectedClasses.add(schoolClass.id!);
              _classDates[schoolClass.id!] = DateTime.now().add(const Duration(days: 7));
            } else {
              _selectedClasses.remove(schoolClass.id);
              _classDates.remove(schoolClass.id);
            }
          });
        },
      )),
      
      if (_selectedClasses.isNotEmpty) ...[
        const SizedBox(height: 24),
        Text('Schedule Exam Dates', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        
        ..._selectedClasses.map((classId) {
          final className = classes.firstWhere((c) => c.id == classId).name;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(className),
              subtitle: Text(
                _classDates[classId] != null
                    ? DateFormat('MMM dd, yyyy').format(_classDates[classId]!)
                    : 'Not set',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDateForClass(classId),
              ),
            ),
          );
        }),
      ],
    ],
  );
}

Future<void> _selectDateForClass(int classId) async {
  final date = await showDatePicker(
    context: context,
    initialDate: _classDates[classId] ?? DateTime.now().add(const Duration(days: 7)),
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365)),
  );
  
  if (date != null) {
    setState(() => _classDates[classId] = date);
  }
}
```

#### Step 4.2: Update SubjectManagementScreen
```
File: lib/screens/admin/exam/subject_management_screen.dart

CHANGES:
1. Replace flat list with tree view
2. Add _buildSubjectTree() method
3. Add "Add Sub-Subject" action
4. Add indentation for hierarchy
5. Add expand/collapse functionality
```

**Implementation:**
```dart
// Add state variable
Map<String, bool> _expandedSubjects = {};

// Replace ListView.builder with tree view
Widget _buildSubjectsList() {
  final parentSubjects = filteredSubjects.where((s) => s.parentSubjectId == null).toList();
  
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: parentSubjects.length,
    itemBuilder: (context, index) => _buildSubjectTree(parentSubjects[index], 0),
  );
}

Widget _buildSubjectTree(Subject subject, int level) {
  final isExpanded = _expandedSubjects[subject.id] ?? true;
  
  return Column(
    children: [
      Card(
        margin: EdgeInsets.only(left: level * 20.0, bottom: 8),
        child: ListTile(
          leading: Icon(
            subject.hasSubSubjects 
                ? (isExpanded ? Icons.folder_open : Icons.folder)
                : Icons.subject,
            color: level == 0 ? defaultAccentColor : Colors.grey,
          ),
          title: Text(
            subject.name,
            style: TextStyle(
              fontWeight: level == 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: subject.hasSubSubjects
              ? Text('${subject.subSubjects!.length} sub-subjects')
              : Text('Max: ${subject.maxMarks ?? "Not set"}'),
          onTap: subject.hasSubSubjects
              ? () => setState(() => _expandedSubjects[subject.id] = !isExpanded)
              : null,
          trailing: PopupMenuButton<String>(
            onSelected: (action) => _handleSubjectAction(action, subject),
            itemBuilder: (context) => [
              if (!subject.isSubSubject)
                const PopupMenuItem(value: 'add-sub', child: Text('Add Sub-Subject')),
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ),
      ),
      if (subject.hasSubSubjects && isExpanded)
        ...subject.subSubjects!.map((sub) => _buildSubjectTree(sub, level + 1)),
    ],
  );
}

void _handleSubjectAction(String action, Subject subject) {
  switch (action) {
    case 'add-sub':
      _showAddSubSubjectDialog(subject);
      break;
    case 'edit':
      _showEditSubjectDialog(subject);
      break;
    case 'delete':
      _deleteSubject(subject);
      break;
  }
}
```

#### Step 4.3: Create ExamClassScheduleScreen
```
File: lib/screens/admin/exam/exam_class_schedule_screen.dart

NEW SCREEN - Full implementation following pattern
```

---

### PHASE 5: Routes & Navigation

#### Step 5.1: Add Routes
```dart
// In lib/config/router.dart

// Add after existing exam routes
GoRoute(
  path: '/admin/exam-class-schedule/:examId',
  name: 'exam-class-schedule',
  builder: (context, state) {
    final examId = state.pathParameters['examId']!;
    final exam = state.extra as Exam;
    return ExamClassScheduleScreen(exam: exam);
  },
),
```

#### Step 5.2: Update Navigation
```dart
// In exam list screen, add action
PopupMenuItem(
  value: 'schedule',
  child: Text('Manage Schedule'),
),

// Handle action
case 'schedule':
  context.pushNamed(
    'exam-class-schedule',
    pathParameters: {'examId': exam.id},
    extra: exam,
  );
  break;
```

---

## ✅ Quality Assurance Rules

### Rule 7: Testing After Each Phase
```
After completing each phase:
1. Run flutter analyze - Fix ALL warnings
2. Test compilation - Must build without errors
3. Test basic functionality - Manual testing
4. Check logs - No error logs during normal operation
5. Verify data - Check database for correct data
```

### Rule 8: Error Handling Standards
```dart
// ALWAYS wrap async operations
try {
  // Operation
} catch (e) {
  logger.e('Context-specific error message: $e');
  // Handle gracefully - show user-friendly message
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to perform action. Please try again.')),
    );
  }
}
```

### Rule 9: Null Safety Compliance
```dart
// ALWAYS handle nulls properly
final value = nullableValue ?? defaultValue;
final result = object?.property;
if (value != null) {
  // Use value safely
}
```

### Rule 10: Performance Optimization
```dart
// Use const constructors
const Text('Static text')
const SizedBox(height: 16)

// Avoid rebuilds
final provider = Provider.of<ExamProvider>(context, listen: false);

// Paginate large lists
ListView.builder(itemCount: items.length, ...)
```

---

## 🚨 Critical Rules

### NEVER:
- ❌ Remove existing functionality without migration
- ❌ Hardcode values (use constants)
- ❌ Ignore errors (always log and handle)
- ❌ Skip null checks
- ❌ Forget to call notifyListeners() after state changes
- ❌ Use wrong column names in fromMap/toMap
- ❌ Skip database verification with MCP

### ALWAYS:
- ✅ Use MCP server for database operations
- ✅ Match database column names exactly
- ✅ Follow existing code patterns
- ✅ Add error handling to all async methods
- ✅ Test after each major change
- ✅ Update provider after service changes
- ✅ Add routes for new screens
- ✅ Dispose controllers in dispose()
- ✅ Check mounted before setState()
- ✅ Use logger for debugging

---

## 📊 Progress Tracking

### Report Format:
```
✅ Phase 1: Database & Models - COMPLETED
   - Migration applied successfully
   - ExamClass model created
   - Exam model updated
   - Subject model updated
   - ExamSubject model updated
   - All models tested

⏳ Phase 2: Service Layer - IN PROGRESS
   - ExamClass CRUD methods (80%)
   - Multi-class exam creation (50%)
   - Subject with sub-subjects (0%)
```

---

## 🎯 Success Criteria

### Phase Completion Checklist:
- [ ] All files created/updated
- [ ] No compilation errors
- [ ] No analyzer warnings
- [ ] Database schema verified
- [ ] Models tested with sample data
- [ ] Services tested with mock data
- [ ] Provider methods working
- [ ] UI renders without errors
- [ ] Navigation works end-to-end
- [ ] Error handling tested
- [ ] Performance acceptable

---

## 📝 Documentation Requirements

### Code Comments:
```dart
/// Fetches exam classes for a specific exam
/// 
/// [examId] The UUID of the exam
/// Returns list of [ExamClass] objects ordered by exam date
/// Returns empty list if error occurs
Future<List<ExamClass>> getExamClasses(String examId) async {
  // Implementation
}
```

### Update README:
- Document new features
- Add usage examples
- Update API documentation

---

## 🔄 Execution Order

1. **Phase 1**: Database & Models (Week 1)
2. **Phase 2**: Service Layer (Week 1-2)
3. **Phase 3**: Provider Updates (Week 2)
4. **Phase 4**: UI Screens (Week 2-3)
5. **Phase 5**: Routes & Navigation (Week 3)
6. **Phase 6**: Testing & Polish (Week 4)

**Execute phases sequentially - complete one before starting next**

---

**Status:** ✅ Ready for Implementation  
**Version:** 1.0  
**Last Updated:** 2025-01-XX
