import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../services/finance_category_service.dart';
import '../../../providers/school_provider.dart';
import '../../../models/finance_category.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  bool _isLoading = true;
  List<FinanceCategory> _categories = [];
  String _filterType = 'All';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    final schoolId = context.read<SchoolProvider>().currentSchool?.id;
    final categories = await context.read<FinanceCategoryService>().getCategories(schoolId);
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  List<FinanceCategory> get _filteredCategories {
    if (_filterType == 'All') return _categories;
    return _categories.where((c) => c.type == _filterType || c.type == 'Both').toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Finance Categories', style: TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'All', label: Text('All')),
                      ButtonSegment(value: 'Income', label: Text('Income')),
                      ButtonSegment(value: 'Expense', label: Text('Expense')),
                    ],
                    selected: {_filterType},
                    onSelectionChanged: (Set<String> selected) {
                      setState(() => _filterType = selected.first);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCategories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.category, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            const Text('No categories found', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredCategories.length,
                        itemBuilder: (context, index) {
                          final category = _filteredCategories[index];
                          return _buildCategoryCard(category);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/admin/add-finance-category');
          _loadCategories();
        },
        backgroundColor: const Color(0xFF795548),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }

  Widget _buildCategoryCard(FinanceCategory category) {
    final color = category.color != null ? Color(int.parse(category.color!.replaceFirst('#', '0xFF'))) : Colors.grey;
    final iconData = _getIconData(category.icon);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(iconData, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(category.type, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          if (category.schoolId != null)
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () async {
                await context.push('/admin/add-finance-category', extra: category);
                _loadCategories();
              },
            ),
        ],
      ),
    );
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'school': return Icons.school;
      case 'volunteer_activism': return Icons.volunteer_activism;
      case 'card_giftcard': return Icons.card_giftcard;
      case 'payments': return Icons.payments;
      case 'bolt': return Icons.bolt;
      case 'inventory': return Icons.inventory;
      case 'build': return Icons.build;
      default: return Icons.category;
    }
  }
}
