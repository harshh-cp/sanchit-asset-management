import 'package:equatable/equatable.dart';

class AssetHistoryModel extends Equatable {
  final String historyId;
  final String assetId;
  final String action; // e.g. 'Created', 'Updated', 'Assigned', 'Returned'
  final String? details;
  final String timestamp;

  const AssetHistoryModel({
    required this.historyId,
    required this.assetId,
    required this.action,
    this.details,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'historyId': historyId,
      'assetId': assetId,
      'action': action,
      'details': details,
      'timestamp': timestamp,
    };
  }

  factory AssetHistoryModel.fromMap(Map<String, dynamic> map) {
    return AssetHistoryModel(
      historyId: map['historyId'] as String,
      assetId: map['assetId'] as String,
      action: map['action'] as String,
      details: map['details'] as String?,
      timestamp: map['timestamp'] as String,
    );
  }

  @override
  List<Object?> get props => [historyId, assetId, action, details, timestamp];
}
