import 'package:equatable/equatable.dart';
import '../../../data/models/assignment_model.dart';
import '../../../data/models/employee_model.dart';

abstract class AssignmentEvent extends Equatable {
  const AssignmentEvent();

  @override
  List<Object?> get props => [];
}

class LoadAssignmentData extends AssignmentEvent {}

class AssignAssetEvent extends AssignmentEvent {
  final AssignmentModel assignment;
  const AssignAssetEvent(this.assignment);

  @override
  List<Object?> get props => [assignment];
}

class ReturnAssetEvent extends AssignmentEvent {
  final String assignmentId;
  final String assetId;
  final String returnedDate;
  final String? remarks;

  const ReturnAssetEvent({
    required this.assignmentId,
    required this.assetId,
    required this.returnedDate,
    this.remarks,
  });

  @override
  List<Object?> get props => [assignmentId, assetId, returnedDate, remarks];
}

class AddEmployeeEvent extends AssignmentEvent {
  final EmployeeModel employee;
  const AddEmployeeEvent(this.employee);

  @override
  List<Object?> get props => [employee];
}
