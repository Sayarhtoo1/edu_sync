import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/fee_structure.dart';
import '../../../services/fee_structure_service.dart';
import '../../../services/auth_service.dart';
import 'add_edit_fee_structure_screen.dart';

class FeeStructureManagementScreen extends StatefulWidget {
  const FeeStructureManagementScreen({super.key});

  @override
  State<FeeStructureManagementScreen> createState() => _FeeStructureManagementScreenState();
}

class _FeeStructureManagementScreenState extends State<FeeStructureManagementScreen> {
  List<FeeStructure> _feeStructures = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeeStructures();
  }

  Future<void> _loadFeeStructures() async {
    setState(() => _isLoading = true);
    final authService = context.read<AuthService>();
    final feeService = context.read<FeeStructureService>();
    final schoolId = await authService.getCurrentUserSchoolId();
    
    if (schoolId != null) {
      final structures = await feeService.getFeeStructuresBySchool(schoolId);
      setState(() {
        _feeStructures = structures;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteFeeStructure(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Fee Structure'),
        content: const Text('Are you sure you want to delete this fee structure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final feeService = context.read<FeeStructureService>();
      final success = await feeService.deleteFeeStructure(id);
      if (success) {
        _loadFeeStructures();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fee structure deleted')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Structure Management'),
        backgroundColor: Colors.blue.withOpacity(0.1),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditFeeStructureScreen()),
          );
          if (result == true) _loadFeeStructures();
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _feeStructures.isEmpty
              ? const Center(child: Text('No fee structures found'))
              : ListView.builder(
                  itemCount: _feeStructures.length,
                  itemBuilder: (context, index) {
                    final fee = _feeStructures[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(fee.feeType, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${fee.frequency} - \$${fee.amount.toStringAsFixed(2)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddEditFeeStructureScreen(feeStructure: fee),
                                  ),
                                );
                                if (result == true) _loadFeeStructures();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteFeeStructure(fee.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
