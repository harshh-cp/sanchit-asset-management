import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../bloc/asset/asset_bloc.dart';
import '../bloc/asset/asset_event.dart';
import '../bloc/asset/asset_state.dart';
import 'add_asset_screen.dart';
import 'asset_detail_screen.dart';
import 'qr_scanner_screen.dart';

class AssetListScreen extends StatefulWidget {
  const AssetListScreen({super.key});

  @override
  State<AssetListScreen> createState() => _AssetListScreenState();
}

class _AssetListScreenState extends State<AssetListScreen> {
  String _searchQuery = '';
  String? _filterCategory;
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    context.read<AssetBloc>().add(LoadAssets());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Asset Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan QR Code',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QrScannerScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAssetScreen()),
          );
          context.read<AssetBloc>().add(LoadAssets());
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, brand, serial...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            ),
          ),

          // Filter chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _statusChip(null, 'All'),
                ...AssetStatus.values.map((s) => _statusChip(s.label, s.label)),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: BlocBuilder<AssetBloc, AssetState>(
              builder: (context, state) {
                if (state is AssetLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is AssetError) {
                  return Center(child: Text(state.message));
                }
                if (state is AssetLoaded) {
                  var assets = state.assets;

                  if (_filterStatus != null) {
                    assets = assets.where((a) => a.status == _filterStatus).toList();
                  }
                  if (_searchQuery.isNotEmpty) {
                    assets = assets.where((a) {
                      return a.assetName.toLowerCase().contains(_searchQuery) ||
                          (a.brand ?? '').toLowerCase().contains(_searchQuery) ||
                          (a.serialNumber ?? '').toLowerCase().contains(_searchQuery) ||
                          a.assetId.toLowerCase().contains(_searchQuery);
                    }).toList();
                  }

                  if (assets.isEmpty) {
                    return const Center(
                      child: Text('No assets found.',
                          style: TextStyle(color: AppColors.textGrey)),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: assets.length,
                    itemBuilder: (context, index) {
                      final asset = assets[index];
                      final status = AssetStatusX.fromString(asset.status);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(_iconForCategory(asset.category),
                                  color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    asset.assetName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${asset.assetId} • ${asset.category}',
                                    style: const TextStyle(
                                        fontSize: 12, color: AppColors.textGrey),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: status.color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status.label,
                                style: TextStyle(
                                  color: status.color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right,
                                  color: AppColors.textGrey),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AssetDetailScreen(asset: asset),
                                  ),
                                );
                                context.read<AssetBloc>().add(LoadAssets());
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String? statusValue, String label) {
    final isSelected = _filterStatus == statusValue;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: isSelected,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textDark,
        ),
        backgroundColor: Colors.white,
        onSelected: (_) => setState(() => _filterStatus = statusValue),
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Laptop':
        return Icons.laptop_mac;
      case 'Monitor':
        return Icons.monitor;
      case 'Keyboard':
        return Icons.keyboard;
      case 'Mouse':
        return Icons.mouse;
      case 'Mobile Device':
        return Icons.phone_android;
      case 'Printer':
        return Icons.print;
      default:
        return Icons.devices_other;
    }
  }
}
