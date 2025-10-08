import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../models/subject.dart';
import '../../../../theme/app_theme.dart';
import '../../../../l10n/gen/app_localizations.dart';

class SubjectFormDialog extends StatefulWidget {
  final Subject? subject;
  final Function(Subject) onSave;

  const SubjectFormDialog({
    super.key,
    this.subject,
    required this.onSave,
  });

  @override
  State<SubjectFormDialog> createState() => _SubjectFormDialogState();
}

class _SubjectFormDialogState extends State<SubjectFormDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _maxMarksController = TextEditingController();
  final _passingMarksController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final bool _isLoading = false;
  String? _nameError;
  String? _maxMarksError;
  String? _passingMarksError;

  @override
  void initState() {
    super.initState();

    // Initialize animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();

    // Initialize form fields if editing
    if (widget.subject != null) {
      _nameController.text = widget.subject!.name;
      _maxMarksController.text = widget.subject!.maxMarks?.toString() ?? '';
      _passingMarksController.text = widget.subject!.passingMarks?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _maxMarksController.dispose();
    _passingMarksController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _validateAndSave() {
    setState(() {
      _nameError = null;
      _maxMarksError = null;
      _passingMarksError = null;
    });

    // Basic validation
    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = 'Subject name is required');
      return;
    }

    final maxMarks = int.tryParse(_maxMarksController.text);
    final passingMarks = int.tryParse(_passingMarksController.text);

    if (_maxMarksController.text.isNotEmpty && (maxMarks == null || maxMarks <= 0)) {
      setState(() => _maxMarksError = 'Enter a valid positive number');
      return;
    }

    if (_passingMarksController.text.isNotEmpty && (passingMarks == null || passingMarks < 0)) {
      setState(() => _passingMarksError = 'Enter a valid non-negative number');
      return;
    }

    if (maxMarks != null && passingMarks != null && passingMarks > maxMarks) {
      setState(() => _passingMarksError = 'Passing marks cannot exceed max marks');
      return;
    }

    // Create subject object
    final subject = Subject(
      id: widget.subject?.id ?? '',
      name: _nameController.text.trim(),
      classId: widget.subject?.classId ?? '',
      schoolId: widget.subject?.schoolId ?? '',
      createdAt: widget.subject?.createdAt ?? DateTime.now(),
      maxMarks: maxMarks,
      passingMarks: passingMarks,
      gradeScale: widget.subject?.gradeScale,
    );

    // Call save callback
    widget.onSave(subject);
    Navigator.of(context).pop();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    Widget? suffix,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
          suffix: suffix,
          filled: true,
          fillColor: cardBackgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: errorText != null ? Colors.red.withOpacity(0.3) : Colors.transparent,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.getAccentColorForContext('form'),
              width: 2,
            ),
          ),
          labelStyle: TextStyle(color: textLightGrey),
          hintStyle: TextStyle(color: textLightGrey.withOpacity(0.6)),
          errorStyle: TextStyle(color: Colors.red.shade600),
        ),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        onChanged: (_) => setState(() {}), // Trigger rebuild for error clearing
      ),
    );
  }

  Widget _buildGradeScalePreview() {
    final maxMarks = int.tryParse(_maxMarksController.text);
    final passingMarks = int.tryParse(_passingMarksController.text);

    if (maxMarks == null || passingMarks == null) {
      return const SizedBox.shrink();
    }

    final passingPercentage = (passingMarks / maxMarks) * 100;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentStudents.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                size: 20,
                color: iconColorStudents,
              ),
              const SizedBox(width: 8),
              Text(
                'Grade Preview',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textDarkGrey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGradeBar('A+', 90, 100, passingPercentage, Colors.green.shade600),
          _buildGradeBar('A', 80, 89, passingPercentage, Colors.blue.shade600),
          _buildGradeBar('B+', 70, 79, passingPercentage, Colors.orange.shade600),
          _buildGradeBar('B', 60, 69, passingPercentage, Colors.yellow.shade600),
          _buildGradeBar('C', 50, 59, passingPercentage, Colors.amber.shade600),
          _buildGradeBar('F', 0, 49, passingPercentage, Colors.red.shade600),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: passingPercentage >= 60 ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: passingPercentage >= 60 ? Colors.green.shade200 : Colors.red.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  passingPercentage >= 60 ? Icons.check_circle : Icons.warning,
                  size: 16,
                  color: passingPercentage >= 60 ? Colors.green.shade600 : Colors.red.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  passingPercentage >= 60 ? 'Good passing rate!' : 'Low passing rate - consider adjusting',
                  style: TextStyle(
                    color: passingPercentage >= 60 ? Colors.green.shade700 : Colors.red.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeBar(String grade, int min, int max, double passingPercentage, Color color) {
    final isPassing = passingPercentage >= min;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              grade,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPassing ? color : color.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: isPassing ? 1.0 : 0.3,
                child: Container(
                  decoration: BoxDecoration(
                    color: isPassing ? color : color.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '$min-$max%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditing = widget.subject != null;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: 500,
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.getAccentColorForContext('form').withOpacity(0.05),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isEditing ? Icons.edit : Icons.add,
                            color: AppTheme.getAccentColorForContext('form'),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isEditing ? 'Edit Subject' : 'Add New Subject',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textDarkGrey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Form content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Subject name
                              _buildTextField(
                                controller: _nameController,
                                label: 'Subject Name *',
                                hint: 'Enter subject name (e.g., Mathematics)',
                                errorText: _nameError,
                                maxLength: 100,
                              ),

                              // Max marks
                              _buildTextField(
                                controller: _maxMarksController,
                                label: 'Maximum Marks',
                                hint: 'Enter maximum marks for this subject',
                                errorText: _maxMarksError,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                suffix: _maxMarksController.text.isNotEmpty
                                    ? Text(
                                        'marks',
                                        style: TextStyle(color: textLightGrey),
                                      )
                                    : null,
                              ),

                              // Passing marks
                              _buildTextField(
                                controller: _passingMarksController,
                                label: 'Passing Marks',
                                hint: 'Enter minimum marks required to pass',
                                errorText: _passingMarksError,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                suffix: _passingMarksController.text.isNotEmpty
                                    ? Text(
                                        'marks',
                                        style: TextStyle(color: textLightGrey),
                                      )
                                    : null,
                              ),

                              // Grade preview
                              if (_maxMarksController.text.isNotEmpty &&
                                  _passingMarksController.text.isNotEmpty)
                                _buildGradeScalePreview(),

                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Actions
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: appBackgroundColor,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: textLightGrey),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _validateAndSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.getAccentColorForContext('form'),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: _isLoading ? 0 : 2,
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    isEditing ? 'Update Subject' : 'Add Subject',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}