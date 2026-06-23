import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../bloc/assignment/assignment_bloc.dart';
import '../bloc/assignment/assignment_event.dart';
import '../bloc/assignment/assignment_state.dart';
import 'assign_asset_screen.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AssignmentBloc>().add(LoadAssignmentData());
  }

  Future<void> _showReturnDialog(
      BuildContext context, String assignmentId, String assetId, String assetName) async {
    final remarksController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Return $assetName?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Returned date: ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
              style: const TextStyle(color: AppColors.textGrey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: remarksController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Return remarks (optional)',
                border: OutlineInputBorder(),
                hintText: 'e.g. Returned in good condition',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm Return'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      context.read<AssignmentBloc>().add(ReturnAssetEvent(
            assignmentId: assignmentId,
            assetId: assetId,
            returnedDate: DateTime.now().toIso8601String(),
            remarks: remarksController.text.trim().isEmpty
                ? null
                : remarksController.text.trim(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Active Assignments'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AssignAssetScreen()),
          );
          context.read<AssignmentBloc>().add(LoadAssignmentData());
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocBuilder<AssignmentBloc, AssignmentState>(
        builder: (context, state) {
          if (state is AssignmentLoading || state is AssignmentInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AssignmentError) {
            return Center(child: Text(state.message));
          }

          final loaded = state as AssignmentLoaded;
          final assignments = loaded.activeAssignments;

          if (assignments.isEmpty) {
            return const Center(
              child: Text('No active assignments.',
                  style: TextStyle(color: AppColors.textGrey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final a = assignments[index];
              final assignedDate = DateTime.tryParse(a.assignedDate);

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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Asset: ${a.assetId}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.assigned.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              color: AppColors.assigned,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Employee: ${a.employeeName} (${a.department})',
                        style: const TextStyle(color: AppColors.textGrey)),
                    Text(
                      'Assigned: ${assignedDate != null ? DateFormat('dd MMM yyyy').format(assignedDate) : a.assignedDate}',
                      style: const TextStyle(color: AppColors.textGrey),
                    ),
                    if (a.remarks != null && a.remarks!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('Remarks: ${a.remarks}',
                            style: const TextStyle(
                                color: AppColors.textGrey, fontSize: 12)),
                      ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: () => _showReturnDialog(
                            context, a.assignmentId, a.assetId, a.assetId),
                        icon: const Icon(Icons.assignment_return, size: 18),
                        label: const Text('Return Asset'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
