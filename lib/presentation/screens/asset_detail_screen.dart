import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/asset_model.dart';
import '../../data/repositories/asset_repository.dart';
import '../bloc/history/history_bloc.dart';
import '../bloc/history/history_event.dart';
import '../bloc/history/history_state.dart';
import 'add_asset_screen.dart';

class AssetDetailScreen extends StatefulWidget {
  final AssetModel asset;

  const AssetDetailScreen({super.key, required this.asset});

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  late AssetModel _asset;

  @override
  void initState() {
    super.initState();
    _asset = widget.asset;
    context.read<HistoryBloc>().add(LoadHistoryForAsset(_asset.assetId));
  }

  Future<void> _refreshAsset() async {
    final updated =
        await context.read<AssetRepository>().getAssetById(_asset.assetId);
    if (updated != null && mounted) {
      setState(() => _asset = updated);
      context.read<HistoryBloc>().add(LoadHistoryForAsset(_asset.assetId));
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return '-';
    final date = DateTime.tryParse(iso);
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final asset = _asset;
    final status = AssetStatusX.fromString(asset.status);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(asset.assetName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddAssetScreen(existingAsset: asset),
                ),
              );
              await _refreshAsset();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // QR Code card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                QrImageView(
                  data: asset.assetId,
                  version: QrVersions.auto,
                  size: 180,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  asset.assetId,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: status.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.label,
                    style: TextStyle(
                        color: status.color, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Asset details card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Asset Details',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textDark)),
                const SizedBox(height: 12),
                _detailRow('Category', asset.category),
                _detailRow('Brand', asset.brand ?? '-'),
                _detailRow('Model Number', asset.modelNumber ?? '-'),
                _detailRow('Serial Number', asset.serialNumber ?? '-'),
                _detailRow('Purchase Date', _formatDate(asset.purchaseDate)),
                _detailRow('Warranty Expiry',
                    _formatDate(asset.warrantyExpiryDate)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // History card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('History',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textDark)),
                const SizedBox(height: 12),
                BlocBuilder<HistoryBloc, HistoryState>(
                  builder: (context, state) {
                    if (state is HistoryLoading) {
                      return const Center(
                          child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(),
                      ));
                    }
                    if (state is HistoryLoaded) {
                      if (state.history.isEmpty) {
                        return const Text('No history yet.',
                            style: TextStyle(color: AppColors.textGrey));
                      }
                      return Column(
                        children: state.history.map((h) {
                          final ts = DateTime.tryParse(h.timestamp);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        h.action,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      if (h.details != null)
                                        Text(h.details!,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textGrey)),
                                      if (ts != null)
                                        Text(
                                          DateFormat('dd MMM yyyy, hh:mm a')
                                              .format(ts),
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textGrey),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(color: AppColors.textGrey)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppColors.textDark, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
