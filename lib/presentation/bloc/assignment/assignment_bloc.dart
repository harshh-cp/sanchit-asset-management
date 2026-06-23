import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/asset_repository.dart';
import 'assignment_event.dart';
import 'assignment_state.dart';

class AssignmentBloc extends Bloc<AssignmentEvent, AssignmentState> {
  final AssetRepository repository;

  AssignmentBloc({required this.repository}) : super(AssignmentInitial()) {
    on<LoadAssignmentData>(_onLoadData);
    on<AssignAssetEvent>(_onAssignAsset);
    on<ReturnAssetEvent>(_onReturnAsset);
    on<AddEmployeeEvent>(_onAddEmployee);
  }

  Future<void> _onLoadData(
      LoadAssignmentData event, Emitter<AssignmentState> emit) async {
    emit(AssignmentLoading());
    try {
      final activeAssignments = await repository.getActiveAssignments();
      final availableAssets = await repository.getAvailableAssets();
      final employees = await repository.getAllEmployees();

      emit(AssignmentLoaded(
        activeAssignments: activeAssignments,
        availableAssets: availableAssets,
        employees: employees,
      ));
    } catch (e) {
      emit(AssignmentError('Failed to load data: $e'));
    }
  }

  Future<void> _onAssignAsset(
      AssignAssetEvent event, Emitter<AssignmentState> emit) async {
    try {
      await repository.assignAsset(event.assignment);
      add(LoadAssignmentData());
    } catch (e) {
      emit(AssignmentError('Failed to assign asset: $e'));
    }
  }

  Future<void> _onReturnAsset(
      ReturnAssetEvent event, Emitter<AssignmentState> emit) async {
    try {
      await repository.returnAsset(
        assignmentId: event.assignmentId,
        assetId: event.assetId,
        returnedDate: event.returnedDate,
        remarks: event.remarks,
      );
      add(LoadAssignmentData());
    } catch (e) {
      emit(AssignmentError('Failed to return asset: $e'));
    }
  }

  Future<void> _onAddEmployee(
      AddEmployeeEvent event, Emitter<AssignmentState> emit) async {
    try {
      await repository.addEmployee(event.employee);
      add(LoadAssignmentData());
    } catch (e) {
      emit(AssignmentError('Failed to add employee: $e'));
    }
  }
}
