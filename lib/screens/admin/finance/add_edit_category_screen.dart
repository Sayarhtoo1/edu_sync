import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../services/finance_category_service.dart';
import '../../../providers/school_provider.dart';
import '../../../models/finance_category.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final FinanceCategory? category;

  const AddEditCategoryScreen({super.key, this.category});

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String _type = 'Income';
  String _icon = 'category';
  String _color = '#4CAF50';
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _icons = [
    {'name': 'category', 'icon': Icons.category},
    {'name': 'school', 'icon': Icons.school},
    {'name': 'volunteer_activism', 'icon': Icons.volunteer_activism},
    {'name': 'card_giftcard', 'icon': Icons.card_giftcard},
    {'name': 'payments', 'icon': Icons.payments},
    {'name': 'bolt', 'icon': Icons.bolt},
    {'name': 'inventory', 'icon': Icons.inventory},
    {'name': 'build', 'icon': Icons.build},
  ];

  final List<String> _colors = [
    '#4CAF50', '#F44336', '#2196F3', '#FF9800', '#9C27B0', '#00BCD4', '#795548', '#607D8B',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    if (widget.category != null) {
      _type = widget.category!.type;
      _icon = widget.category!.icon ?? 'category';
      _color = widget.category!.color ?? '#4CAF50';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final schoolId = context.read<SchoolProvider>().currentSchool?.id;
    final category = FinanceCategory(
      id: widget.category?.id ?? const Uuid().v4(),
      schoolId: schoolId,
      name: _nameController.text,
      type: _type,
      icon: _icon,
      color: _color,
      parentCategoryId: widget.category?.parentCategoryId,
      isActive: true,
      createdAt: widget.category?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final service = context.read<FinanceCategoryService>();
    final result = widget.category == null
        ? await service.createCategory(category)
        : await service.updateCategory(category.id, category.toJson());

    setState(() => _isSubmitting = false);

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.category == null ? 'Category created' : 'Category updated')),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save category')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(widget.category == null ? 'Add Category' : 'Edit Category',
            style: const TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _type,
                    decoration: InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: ['Income', 'Expense', 'Both']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (value) => setState(() => _type = value!),
                  ),
                  const SizedBox(height: 20),
                  const Text('Icon', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _icons.map((iconData) {
                      final isSelected = _icon == iconData['name'];
                      return InkWell(
                        onTap: () => setState(() => _icon = iconData['name']),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? Color(int.parse(_color.replaceFirst('#', '0xFF'))).withOpacity(0.2) : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? Color(int.parse(_color.replaceFirst('#', '0xFF'))) : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Icon(iconData['icon'], size: 24),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text('Color', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _colors.map((colorHex) {
                      final isSelected = _color == colorHex;
                      return InkWell(
                        onTap: () => setState(() => _color = colorHex),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color(int.parse(colorHex.replaceFirst('#', '0xFF'))),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.black : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF795548),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(widget.category == null ? 'Create Category' : 'Update Category', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
