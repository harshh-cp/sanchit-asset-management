import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/asset_model.dart';
import '../../data/models/assignment_model.dart';
import '../../data/models/employee_model.dart';
import '../bloc/assignment/assignment_bloc.dart';
import '../bloc/assignment/assignment_event.dart';
import '../bloc/assignment/assignment_state.dart';
import '../widgets/add_employee_dialog.dart';

class AssignAssetScreen extends StatefulWidget {
  const AssignAssetScreen({super.key});

  @override
  State<AssignAssetScreen> createState() => _AssignAssetScreenState();
}

class _AssignAssetScreenState extends State<AssignAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _remarksController = TextEditingController();
  final _uuid = const Uuid();

  AssetModel? _selectedAsset;
  EmployeeModel? _selectedEmployee;
  DateTime _assignedDate = DateTime.now();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _assignedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _assignedDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAsset == null || _selectedEmployee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an asset and employee')),
      );
      return;
    }

    final assignment = AssignmentModel(
      assignmentId: _uuid.v4(),
      assetId: _selectedAsset!.assetId,
      employeeId: _selectedEmployee!.employeeId,
      employeeName: _selectedEmployee!.employeeName,
      department: _selectedEmployee!.department,
      assignedDate: _assignedDate.toIso8601String(),
      remarks: _remarksController.text.trim().isEmpty
          ? null
          : _remarksController.text.trim(),
    );

    context.read<AssignmentBloc>().add(AssignAssetEvent(assignment));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Assign Asset'),
      ),
      body: BlocConsumer<AssignmentBloc, AssignmentState>(
        listener: (context, state) {
          // When state reloads (e.g. after adding employee), validate
          // that selected values still exist in the new lists
          if (state is AssignmentLoaded) {
            final assetStillValid = state.availableAssets
                .any((a) => a.assetId == _selectedAsset?.assetId);
            final empStillValid = state.employees
                .any((e) => e.employeeId == _selectedEmployee?.employeeId);
            if (!assetStillValid) setState(() => _selectedAsset = null);
            if (!empStillValid) setState(() => _selectedEmployee = null);
          }
        },
        builder: (context, state) {
          if (state is AssignmentLoading || state is AssignmentInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AssignmentError) {
            return Center(child: Text(state.message));
          }

          final loaded = state as AssignmentLoaded;

          // Deduplicate by ID to prevent dropdown assertion crash
          final uniqueAssets = loaded.availableAssets
              .fold<Map<String, dynamic>>({}, (map, a) {
                map[a.assetId] = a;
                return map;
              })
              .values
              .toList()
              .cast();

          final uniqueEmployees = loaded.employees
              .fold<Map<String, dynamic>>({}, (map, e) {
                map[e.employeeId] = e;
                return map;
              })
              .values
              .toList()
              .cast();

          // Guard: clear selection if selected value no longer in list
          final validAssetId = uniqueAssets.any(
                  (a) => a.assetId == _selectedAsset?.assetId)
              ? _selectedAsset?.assetId
              : null;
          final validEmployeeId = uniqueEmployees.any(
                  (e) => e.employeeId == _selectedEmployee?.employeeId)
              ? _selectedEmployee?.employeeId
              : null;

          if (uniqueAssets.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No available assets to assign.\nAll assets are either assigned, '
                  'under maintenance, or retired.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textGrey),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Select Asset *'),
                  DropdownButtonFormField<String>(
                    value: validAssetId,
                    decoration: _decoration(),
                    items: uniqueAssets
                        .map<DropdownMenuItem<String>>((a) => DropdownMenuItem(
                              value: a.assetId,
                              child: Text('${a.assetName} (${a.assetId})'),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() {
                      _selectedAsset = uniqueAssets
                          .firstWhere((a) => a.assetId == val);
                    }),
                    validator: (val) => val == null ? 'Select an asset' : null,
                  ),
                  const SizedBox(height: 16),

                  _label('Select Employee *'),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: validEmployeeId,
                          decoration: _decoration(),
                          items: uniqueEmployees
                              .map<DropdownMenuItem<String>>((e) => DropdownMenuItem(
                                    value: e.employeeId,
                                    child: Text(
                                        '${e.employeeName} (${e.department})'),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() {
                            _selectedEmployee = uniqueEmployees
                                .firstWhere((e) => e.employeeId == val);
                          }),
                          validator: (val) =>
                              val == null ? 'Select an employee' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () async {
                          final newEmployee =
                              await showAddEmployeeDialog(context);
                          if (newEmployee != null) {
                            setState(() => _selectedEmployee = newEmployee);
                          }
                        },
                        icon: const Icon(Icons.person_add,
                            color: AppColors.primary),
                        tooltip: 'Add new employee',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _label('Assigned Date'),
                  InkWell(
                    onTap: _pickDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('dd MMM yyyy').format(_assignedDate)),
                          const Icon(Icons.calendar_today,
                              size: 18, color: AppColors.textGrey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _label('Remarks (optional)'),
                  TextFormField(
                    controller: _remarksController,
                    maxLines: 3,
                    decoration: _decoration().copyWith(
                      hintText: 'e.g. For remote work setup',
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Assign Asset',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  InputDecoration _decoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}
