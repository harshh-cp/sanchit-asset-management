import 'package:equatable/equatable.dart';
import '../../../data/models/asset_history_model.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<AssetHistoryModel> history;
  const HistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}

class HistoryError extends HistoryState {
  final String message;
  const HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
