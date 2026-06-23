import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/employee_model.dart';
import '../../data/repositories/asset_repository.dart';
import '../bloc/assignment/assignment_bloc.dart';
import '../bloc/assignment/assignment_event.dart';

/// Shows a dialog to add a new employee, or edit an existing one if
/// [existingEmployee] is provided. Returns the created/updated EmployeeModel
/// via Navigator.pop so the caller can immediately select it.
Future<EmployeeModel?> showAddEmployeeDialog(
  BuildContext context, {
  EmployeeModel? existingEmployee,
}) {
  final nameController =
      TextEditingController(text: existingEmployee?.employeeName ?? '');
  String department = existingEmployee?.department ?? 'General';
  final isEdit = existingEmployee != null;

  const departments = [
    'General',
    'IT',
    'HR',
    'Finance',
    'Operations',
    'Sales',
    'Marketing',
  ];

  return showDialog<EmployeeModel>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isEdit ? 'Edit Employee' : 'Add New Employee'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Employee Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: department,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(),
                  ),
                  items: departments
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (val) => setState(() => department = val!),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) return;

                  final repo = dialogContext.read<AssetRepository>();

                  if (isEdit) {
                    final updated = EmployeeModel(
                      employeeId: existingEmployee!.employeeId,
                      employeeName: nameController.text.trim(),
                      department: department,
                    );
                    await repo.updateEmployee(updated);
                    Navigator.pop(dialogContext, updated);
                  } else {
                    final id = await repo.generateEmployeeId();
                    final employee = EmployeeModel(
                      employeeId: id,
                      employeeName: nameController.text.trim(),
                      department: department,
                    );
                    dialogContext
                        .read<AssignmentBloc>()
                        .add(AddEmployeeEvent(employee));
                    Navigator.pop(dialogContext, employee);
                  }
                },
                child: Text(isEdit ? 'Save' : 'Add'),
              ),
            ],
          );
        },
      );
    },
  );
}
