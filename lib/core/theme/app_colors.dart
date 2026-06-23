import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF2563EB);
  static const background = Color(0xFFF5F7FA);
  static const cardBg = Colors.white;
  static const textDark = Color(0xFF1E293B);
  static const textGrey = Color(0xFF64748B);

  // Status colors
  static const available = Color(0xFF16A34A);
  static const assigned = Color(0xFF2563EB);
  static const maintenance = Color(0xFFF59E0B);
  static const retired = Color(0xFF94A3B8);
}

enum AssetStatus { available, assigned, maintenance, retired }

extension AssetStatusX on AssetStatus {
  String get label {
    switch (this) {
      case AssetStatus.available:
        return 'Available';
      case AssetStatus.assigned:
        return 'Assigned';
      case AssetStatus.maintenance:
        return 'Under Maintenance';
      case AssetStatus.retired:
        return 'Retired';
    }
  }

  Color get color {
    switch (this) {
      case AssetStatus.available:
        return AppColors.available;
      case AssetStatus.assigned:
        return AppColors.assigned;
      case AssetStatus.maintenance:
        return AppColors.maintenance;
      case AssetStatus.retired:
        return AppColors.retired;
    }
  }

  static AssetStatus fromString(String value) {
    switch (value) {
      case 'Available':
        return AssetStatus.available;
      case 'Assigned':
        return AssetStatus.assigned;
      case 'Under Maintenance':
        return AssetStatus.maintenance;
      case 'Retired':
        return AssetStatus.retired;
      default:
        return AssetStatus.available;
    }
  }
}

const List<String> assetCategories = [
  'Laptop',
  'Monitor',
  'Keyboard',
  'Mouse',
  'Mobile Device',
  'Printer',
  'Other',
];
