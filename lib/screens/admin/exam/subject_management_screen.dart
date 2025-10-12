import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/subject.dart';
import '../../../models/school_class.dart';
import '../../../providers/exam_provider.dart';
import '../../../providers/class_provider.dart';
import '../../../providers/school_provider.dart';
import '../../../theme/app_theme.dart';

class SubjectManagementScreen extends StatefulWidget {
  const SubjectManagementScreen({super.key});

  @override
  State<SubjectManagementScreen> createState() => _SubjectManagementScreenState();
}

class _SubjectManagementScreenState extends State<SubjectManagementScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<Subject> _subjects = [];
  List<SchoolClass> _classes = [];
  SchoolClass? _selectedClass;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterSubjects);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
      final schoolId = schoolProvider.currentSchool?.id.toString();

      if (schoolId != null) {
        final examProvider = Provider.of<ExamProvider>(context, listen: false);
        final classProvider = Provider.of<ClassProvider>(context, listen: false);
        
        await Future.wait([
          examProvider.fetchSubjects(schoolId),
          classProvider.fetchClasses(schoolId),
        ]);

        if (mounted) {
          _subjects = examProvider.subjects;
          _classes = classProvider.classes;
        }
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterSubjects() {
    setState(() {});
  }

  List<Subject> _getFilteredSubjects() {
    final query = _searchController.text.toLowerCase();
    return _subjects.where((subject) {
      final matchesSearch = query.isEmpty || subject.name.toLowerCase().contains(query);
      final matchesClass = _selectedClass == null || subject.classId.toString() == _selectedClass!.id.toString();
      return matchesSearch && matchesClass;
    }).toList();
  }

  String _getClassName(String classId) {
    final schoolClass = _classes.where((c) => c.id.toString() == classId).firstOrNull;
    return schoolClass?.name ?? 'Unknown Class';
  }

  void _showAddSubjectDialog() {
    final nameController = TextEditingController();
    SchoolClass? selectedClass;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Subject'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Subject Name',
                  hintText: 'e.g., Mathematics, English',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<SchoolClass>(
                value: selectedClass,
                decoration: const InputDecoration(
                  labelText: 'Class',
                  border: OutlineInputBorder(),
                ),
                items: _classes.map((schoolClass) {
                  return DropdownMenuItem(
                    value: schoolClass,
                    child: Text(schoolClass.name),
                  );
                }).toList(),
                onChanged: (value) => setDialogState(() => selectedClass = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || selectedClass == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                Navigator.pop(context);
                if (mounted) {
                  await _addSubject(nameController.text, selectedClass!);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addSubject(String name, SchoolClass schoolClass) async {
    setState(() => _isLoading = true);

    try {
      final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
      final schoolId = schoolProvider.currentSchool?.id;

      if (schoolId != null) {
        await Provider.of<ExamProvider>(context, listen: false).addSubject(
          name: name,
          classId: schoolClass.id!,
          schoolId: schoolId,
        );
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$name added successfully')),
          );
        }
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showEditSubjectDialog(Subject subject) {
    final nameController = TextEditingController(text: subject.name);
    SchoolClass? selectedClass = _classes.where((c) => c.id == subject.classId).firstOrNull;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Subject'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Subject Name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<SchoolClass>(
                value: selectedClass,
                decoration: const InputDecoration(
                  labelText: 'Class',
                  border: OutlineInputBorder(),
                ),
                items: _classes.map((schoolClass) {
                  return DropdownMenuItem(
                    value: schoolClass,
                    child: Text(schoolClass.name),
                  );
                }).toList(),
                onChanged: (value) => setDialogState(() => selectedClass = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || selectedClass == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                Navigator.pop(context);
                if (mounted) {
                  await _updateSubject(subject, nameController.text, selectedClass!);
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateSubject(Subject subject, String name, SchoolClass schoolClass) async {
    setState(() => _isLoading = true);

    try {
      final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
      final schoolId = schoolProvider.currentSchool?.id;

      if (schoolId != null) {
        await Provider.of<ExamProvider>(context, listen: false).updateSubject(
          id: subject.id,
          name: name,
          classId: schoolClass.id!,
          schoolId: schoolId,
        );
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subject updated successfully')),
          );
        }
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSubject(Subject subject) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete "${subject.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
      final schoolId = schoolProvider.currentSchool?.id.toString();

      if (schoolId != null) {
        await Provider.of<ExamProvider>(context, listen: false).deleteSubject(subject.id, schoolId);
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subject deleted successfully')),
          );
        }
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredSubjects = _getFilteredSubjects();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subject Management'),
        backgroundColor: appBackgroundColor,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search subjects',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  value: _selectedClass?.id,
                  decoration: InputDecoration(
                    labelText: 'Filter by Class',
                    prefixIcon: const Icon(Icons.class_),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('All Classes'),
                    ),
                    ..._classes.map((schoolClass) {
                      return DropdownMenuItem<int?>(
                        value: schoolClass.id,
                        child: Text(schoolClass.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedClass = value == null ? null : _classes.firstWhere((c) => c.id == value));
                    _filterSubjects();
                  },
                ),
              ],
            ),
          ),

          // Error Message
          if (_errorMessage != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red))),
                  IconButton(
                    onPressed: () => setState(() => _errorMessage = null),
                    icon: const Icon(Icons.close, color: Colors.red),
                  ),
                ],
              ),
            ),

          // Results Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Showing ${filteredSubjects.length} subjects',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Subject List
          Expanded(
            child: _isLoading && _subjects.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : filteredSubjects.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.subject, size: 64, color: Colors.grey.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            Text(
                              'No subjects found',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _showAddSubjectDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Subject'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredSubjects.length,
                        itemBuilder: (context, index) {
                          final subject = filteredSubjects[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: defaultAccentColor.withOpacity(0.1),
                                child: Icon(Icons.subject, color: defaultAccentColor),
                              ),
                              title: Text(
                                subject.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(_getClassName(subject.classId.toString())),
                              trailing: PopupMenuButton<String>(
                                onSelected: (action) {
                                  if (action == 'edit') {
                                    _showEditSubjectDialog(subject);
                                  } else if (action == 'delete') {
                                    _deleteSubject(subject);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSubjectDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
        backgroundColor: defaultAccentColor,
      ),
    );
  }
}
