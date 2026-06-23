import 'package:equatable/equatable.dart';

class EmployeeModel extends Equatable {
  final String employeeId;
  final String employeeName;
  final String department;

  const EmployeeModel({
    required this.employeeId,
    required this.employeeName,
    required this.department,
  });

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'employeeName': employeeName,
      'department': department,
    };
  }

  factory EmployeeModel.fromMap(Map<String, dynamic> map) {
    return EmployeeModel(
      employeeId: map['employeeId'] as String,
      employeeName: map['employeeName'] as String,
      department: map['department'] as String,
    );
  }

  @override
  List<Object?> get props => [employeeId, employeeName, department];
}
