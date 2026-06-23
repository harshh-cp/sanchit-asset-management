# Sanchit - Office Asset Management App

A Flutter-based Office Asset Management Application for managing and 
tracking office assets such as laptops, monitors, keyboards, mobile 
devices, printers, and other equipment.

## Features
- Asset Management (Add, Edit, View with auto-generated IDs like AST-0001)
- Asset Assignment to employees with date and remarks
- Asset Return with confirmation and history logging
- Complete Asset History (Created, Updated, Assigned, Returned)
- QR Code generation per asset + QR Scanner
- Dashboard with real-time statistics
- Employee Management

## Tech Stack
- Flutter / Dart
- BLoC State Management (flutter_bloc)
- SQLite — offline-first storage (sqflite)
- Clean Architecture with Repository pattern
- QR Flutter + Mobile Scanner

## Architecture
Three clear layers:
- **Data Layer** — Models + AssetRepository (single source of truth)
- **Presentation Layer** — BLoC (events/states) + Screens

## Developed By
Harshavardhan Chavan Patil
BCA — Dr. M.S. Sheshgiri College of Engineering & Technology, Belagavi
Internship Assignment — Ajinkya Technologies, Belagavi
