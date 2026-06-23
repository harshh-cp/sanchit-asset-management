import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/asset_repository.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final AssetRepository repository;

  HistoryBloc({required this.repository}) : super(HistoryInitial()) {
    on<LoadAllHistory>(_onLoadAll);
    on<LoadHistoryForAsset>(_onLoadForAsset);
  }

  Future<void> _onLoadAll(
      LoadAllHistory event, Emitter<HistoryState> emit) async {
    emit(HistoryLoading());
    try {
      final history = await repository.getAllHistory();
      emit(HistoryLoaded(history));
    } catch (e) {
      emit(HistoryError('Failed to load history: $e'));
    }
  }

  Future<void> _onLoadForAsset(
      LoadHistoryForAsset event, Emitter<HistoryState> emit) async {
    emit(HistoryLoading());
    try {
      final history = await repository.getHistoryForAsset(event.assetId);
      emit(HistoryLoaded(history));
    } catch (e) {
      emit(HistoryError('Failed to load history: $e'));
    }
  }
}
