import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/asset_repository.dart';
import 'asset_event.dart';
import 'asset_state.dart';

class AssetBloc extends Bloc<AssetEvent, AssetState> {
  final AssetRepository repository;

  AssetBloc({required this.repository}) : super(AssetInitial()) {
    on<LoadAssets>(_onLoadAssets);
    on<AddAssetEvent>(_onAddAsset);
    on<UpdateAssetEvent>(_onUpdateAsset);
  }

  Future<void> _onLoadAssets(LoadAssets event, Emitter<AssetState> emit) async {
    emit(AssetLoading());
    try {
      final assets = await repository.getAllAssets();
      emit(AssetLoaded(assets));
    } catch (e) {
      emit(AssetError('Failed to load assets: $e'));
    }
  }

  Future<void> _onAddAsset(AddAssetEvent event, Emitter<AssetState> emit) async {
    try {
      await repository.addAsset(event.asset);
      final assets = await repository.getAllAssets();
      emit(AssetLoaded(assets));
    } catch (e) {
      emit(AssetError('Failed to add asset: $e'));
    }
  }

  Future<void> _onUpdateAsset(
      UpdateAssetEvent event, Emitter<AssetState> emit) async {
    try {
      await repository.updateAsset(event.asset);
      final assets = await repository.getAllAssets();
      emit(AssetLoaded(assets));
    } catch (e) {
      emit(AssetError('Failed to update asset: $e'));
    }
  }
}
