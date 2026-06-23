import 'package:equatable/equatable.dart';

class AssignmentModel extends Equatable {
  final String assignmentId;
  final String assetId;
  final String employeeId;
  final String employeeName;
  final String department;
  final String assignedDate;
  final String? returnedDate;
  final String? remarks;
  final String status; // 'Active' or 'Returned'

  const AssignmentModel({
    required this.assignmentId,
    required this.assetId,
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.assignedDate,
    this.returnedDate,
    this.remarks,
    this.status = 'Active',
  });

  Map<String, dynamic> toMap() {
    return {
      'assignmentId': assignmentId,
      'assetId': assetId,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'department': department,
      'assignedDate': assignedDate,
      'returnedDate': returnedDate,
      'remarks': remarks,
      'status': status,
    };
  }

  factory AssignmentModel.fromMap(Map<String, dynamic> map) {
    return AssignmentModel(
      assignmentId: map['assignmentId'] as String,
      assetId: map['assetId'] as String,
      employeeId: map['employeeId'] as String,
      employeeName: map['employeeName'] as String,
      department: map['department'] as String,
      assignedDate: map['assignedDate'] as String,
      returnedDate: map['returnedDate'] as String?,
      remarks: map['remarks'] as String?,
      status: map['status'] as String? ?? 'Active',
    );
  }

  AssignmentModel copyWith({
    String? returnedDate,
    String? status,
  }) {
    return AssignmentModel(
      assignmentId: assignmentId,
      assetId: assetId,
      employeeId: employeeId,
      employeeName: employeeName,
      department: department,
      assignedDate: assignedDate,
      returnedDate: returnedDate ?? this.returnedDate,
      remarks: remarks,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        assignmentId,
        assetId,
        employeeId,
        employeeName,
        department,
        assignedDate,
        returnedDate,
        remarks,
        status,
      ];
}
