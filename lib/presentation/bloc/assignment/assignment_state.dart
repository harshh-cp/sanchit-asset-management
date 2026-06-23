import 'package:equatable/equatable.dart';
import '../../../data/models/asset_model.dart';
import '../../../data/models/assignment_model.dart';
import '../../../data/models/employee_model.dart';

abstract class AssignmentState extends Equatable {
  const AssignmentState();

  @override
  List<Object?> get props => [];
}

class AssignmentInitial extends AssignmentState {}

class AssignmentLoading extends AssignmentState {}

class AssignmentLoaded extends AssignmentState {
  final List<AssignmentModel> activeAssignments;
  final List<AssetModel> availableAssets;
  final List<EmployeeModel> employees;

  const AssignmentLoaded({
    required this.activeAssignments,
    required this.availableAssets,
    required this.employees,
  });

  @override
  List<Object?> get props => [activeAssignments, availableAssets, employees];
}

class AssignmentError extends AssignmentState {
  final String message;
  const AssignmentError(this.message);

  @override
  List<Object?> get props => [message];
}
