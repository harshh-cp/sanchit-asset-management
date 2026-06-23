import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/asset_model.dart';
import '../../data/repositories/asset_repository.dart';
import '../bloc/asset/asset_bloc.dart';
import '../bloc/asset/asset_event.dart';

class AddAssetScreen extends StatefulWidget {
  final AssetModel? existingAsset; // null = add, non-null = edit

  const AddAssetScreen({super.key, this.existingAsset});

  @override
  State<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _serialController = TextEditingController();

  String _category = assetCategories.first;
  String _status = 'Available';
  DateTime? _purchaseDate;
  DateTime? _warrantyDate;

  String? _generatedAssetId;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    final asset = widget.existingAsset;
    if (asset != null) {
      _isEdit = true;
      _generatedAssetId = asset.assetId;
      _nameController.text = asset.assetName;
      _brandController.text = asset.brand ?? '';
      _modelController.text = asset.modelNumber ?? '';
      _serialController.text = asset.serialNumber ?? '';
    //  _category = asset.category;
      _status = asset.status;
      _purchaseDate = asset.purchaseDate != null
          ? DateTime.tryParse(asset.purchaseDate!)
          : null;
      _warrantyDate = asset.warrantyExpiryDate != null
          ? DateTime.tryParse(asset.warrantyExpiryDate!)
          : null;
    } else {
      _generateId();
    }
  }

  Future<void> _generateId() async {
    final id = await context.read<AssetRepository>().generateAssetId();
    setState(() => _generatedAssetId = id);
  }

  Future<void> _pickDate({required bool isPurchase}) async {
    final initial = isPurchase
        ? (_purchaseDate ?? DateTime.now())
        : (_warrantyDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2010),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isPurchase) {
          _purchaseDate = picked;
        } else {
          _warrantyDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    return DateFormat('dd MMM yyyy').format(date);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_generatedAssetId == null) return;

    final asset = AssetModel(
      assetId: _generatedAssetId!,
      assetName: _nameController.text.trim(),
      category: _category,
      brand: _brandController.text.trim().isEmpty
          ? null
          : _brandController.text.trim(),
      modelNumber: _modelController.text.trim().isEmpty
          ? null
          : _modelController.text.trim(),
      serialNumber: _serialController.text.trim().isEmpty
          ? null
          : _serialController.text.trim(),
      purchaseDate: _purchaseDate?.toIso8601String(),
      warrantyExpiryDate: _warrantyDate?.toIso8601String(),
      status: _status,
    );

    if (_isEdit) {
      context.read<AssetBloc>().add(UpdateAssetEvent(asset));
    } else {
      context.read<AssetBloc>().add(AddAssetEvent(asset));
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(_isEdit ? 'Edit Asset' : 'Add New Asset'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Asset ID (read-only, auto-generated)
              _buildLabel('Asset ID'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _generatedAssetId ?? 'Generating...',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel('Asset Name *'),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('e.g. Dell Latitude 5420'),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Category *'),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: _inputDecoration(''),
                items: assetCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => _category = val!),
              ),
              const SizedBox(height: 16),

              _buildLabel('Brand'),
              TextFormField(
                controller: _brandController,
                decoration: _inputDecoration('e.g. Dell, HP, Lenovo'),
              ),
              const SizedBox(height: 16),

              _buildLabel('Model Number'),
              TextFormField(
                controller: _modelController,
              //  decoration: _inputDecoration('e.g. Latitude 5420'),
              ),
              const SizedBox(height: 16),

              _buildLabel('Serial Number'),
              TextFormField(
                controller: _serialController,
                decoration: _inputDecoration('e.g. SN123456789'),
              ),
              const SizedBox(height: 16),

              _buildLabel('Purchase Date'),
              _buildDatePicker(
                value: _formatDate(_purchaseDate),
                onTap: () => _pickDate(isPurchase: true),
              ),
              const SizedBox(height: 16),

              _buildLabel('Warranty Expiry Date'),
              _buildDatePicker(
                value: _formatDate(_warrantyDate),
                onTap: () => _pickDate(isPurchase: false),
              ),
              const SizedBox(height: 16),

              _buildLabel('Asset Status'),
              if (_isEdit && _status == 'Assigned') ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.assigned,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Assigned',
                          style: TextStyle(color: AppColors.textDark)),
                      const Spacer(),
                      const Icon(Icons.lock_outline,
                          size: 16, color: AppColors.textGrey),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Status is locked while asset is assigned to an employee.\nUse "Return Asset" in the Assignments tab to release it.',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textGrey),
                ),
              ] else
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: _inputDecoration(''),
                  items: AssetStatus.values
                      .where((s) => s != AssetStatus.assigned)
                      .map((s) => DropdownMenuItem(
                            value: s.label,
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: s.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(s.label),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _status = val!),
                ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _isEdit ? 'Update Asset' : 'Save Asset',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  Widget _buildDatePicker({required String value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value, style: const TextStyle(color: AppColors.textDark)),
            const Icon(Icons.calendar_today,
                size: 18, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}
