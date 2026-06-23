import 'package:equatable/equatable.dart';

class AssetModel extends Equatable {
  final String assetId;
  final String assetName;
  final String category;
  final String? brand;
  final String? modelNumber;
  final String? serialNumber;
  final String? purchaseDate;
  final String? warrantyExpiryDate;
  final String status;

  const AssetModel({
    required this.assetId,
    required this.assetName,
    required this.category,
    this.brand,
    this.modelNumber,
    this.serialNumber,
    this.purchaseDate,
    this.warrantyExpiryDate,
    this.status = 'Available',
  });

  Map<String, dynamic> toMap() {
    return {
      'assetId': assetId,
      'assetName': assetName,
      'category': category,
      'brand': brand,
      'modelNumber': modelNumber,
      'serialNumber': serialNumber,
      'purchaseDate': purchaseDate,
      'warrantyExpiryDate': warrantyExpiryDate,
      'status': status,
    };
  }

  factory AssetModel.fromMap(Map<String, dynamic> map) {
    return AssetModel(
      assetId: map['assetId'] as String,
      assetName: map['assetName'] as String,
      category: map['category'] as String,
      brand: map['brand'] as String?,
      modelNumber: map['modelNumber'] as String?,
      serialNumber: map['serialNumber'] as String?,
      purchaseDate: map['purchaseDate'] as String?,
      warrantyExpiryDate: map['warrantyExpiryDate'] as String?,
      status: map['status'] as String? ?? 'Available',
    );
  }

  AssetModel copyWith({
    String? assetName,
    String? category,
    String? brand,
    String? modelNumber,
    String? serialNumber,
    String? purchaseDate,
    String? warrantyExpiryDate,
    String? status,
  }) {
    return AssetModel(
      assetId: assetId,
      assetName: assetName ?? this.assetName,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      modelNumber: modelNumber ?? this.modelNumber,
      serialNumber: serialNumber ?? this.serialNumber,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      warrantyExpiryDate: warrantyExpiryDate ?? this.warrantyExpiryDate,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        assetId,
        assetName,
        category,
        brand,
        modelNumber,
        serialNumber,
        purchaseDate,
        warrantyExpiryDate,
        status,
      ];
}
