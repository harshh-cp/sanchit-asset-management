import 'package:equatable/equatable.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllHistory extends HistoryEvent {}

class LoadHistoryForAsset extends HistoryEvent {
  final String assetId;
  const LoadHistoryForAsset(this.assetId);

  @override
  List<Object?> get props => [assetId];
}
