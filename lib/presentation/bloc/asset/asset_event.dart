import 'package:equatable/equatable.dart';
import '../../../data/models/asset_model.dart';

abstract class AssetEvent extends Equatable {
  const AssetEvent();

  @override
  List<Object?> get props => [];
}

class LoadAssets extends AssetEvent {}

class AddAssetEvent extends AssetEvent {
  final AssetModel asset;
  const AddAssetEvent(this.asset);

  @override
  List<Object?> get props => [asset];
}

class UpdateAssetEvent extends AssetEvent {
  final AssetModel asset;
  const UpdateAssetEvent(this.asset);

  @override
  List<Object?> get props => [asset];
}
