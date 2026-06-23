import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/employee_model.dart';
import '../../data/models/assignment_model.dart';
import '../../data/repositories/asset_repository.dart';
import '../bloc/assignment/assignment_bloc.dart';
import '../widgets/add_employee_dialog.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  late Future<List<_EmployeeWithAssignments>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<List<_EmployeeWithAssignments>> _loadData() async {
    final repo = context.read<AssetRepository>();
    final employees = await repo.getAllEmployees();

    final result = <_EmployeeWithAssignments>[];
    for (final emp in employees) {
      final assignments =
          await repo.getActiveAssignmentsForEmployee(emp.employeeId);
      result.add(_EmployeeWithAssignments(employee: emp, assignments: assignments));
    }
    return result;
  }

  Future<void> _refresh() async {
    final newFuture = _loadData();
    setState(() {
      _future = newFuture;
    });
    await newFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Employees'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          await showAddEmployeeDialog(context);
          _refresh();
        },
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      body: FutureBuilder<List<_EmployeeWithAssignments>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(
              child: Text(
                'No employees yet.\nAdd one from the Assignments tab.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                final emp = item.employee;
                final assignments = item.assignments;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Text(
                              emp.employeeName.isNotEmpty
                                  ? emp.employeeName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  emp.employeeName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark),
                                ),
                                Text(
                                  '${emp.employeeId} • ${emp.department}',
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.textGrey),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (assignments.isEmpty
                                      ? AppColors.textGrey
                                      : AppColors.assigned)
                                  .withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${assignments.length} asset${assignments.length == 1 ? '' : 's'}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: assignments.isEmpty
                                    ? AppColors.textGrey
                                    : AppColors.assigned,
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert,
                                color: AppColors.textGrey, size: 20),
                            onSelected: (value) async {
                              if (value == 'edit') {
                                await showAddEmployeeDialog(context,
                                    existingEmployee: emp);
                                _refresh();
                              } else if (value == 'delete') {
                                if (assignments.isNotEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Cannot delete: employee has active assigned assets.'),
                                    ),
                                  );
                                  return;
                                }
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Employee?'),
                                    content: Text(
                                        'Remove ${emp.employeeName} from the system?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await context
                                      .read<AssetRepository>()
                                      .deleteEmployee(emp.employeeId);
                                  _refresh();
                                }
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
                        ],
                      ),
                      if (assignments.isNotEmpty) ...[
                        const Divider(height: 20),
                        ...assignments.map((a) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  const Icon(Icons.devices_other,
                                      size: 16, color: AppColors.textGrey),
                                  const SizedBox(width: 8),
                                  Text(
                                    a.assetId,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textDark),
                                  ),
                                  if (a.remarks != null &&
                                      a.remarks!.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '(${a.remarks})',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textGrey),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            )),
                      ],
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _EmployeeWithAssignments {
  final EmployeeModel employee;
  final List<AssignmentModel> assignments;

  _EmployeeWithAssignments({required this.employee, required this.assignments});
}
