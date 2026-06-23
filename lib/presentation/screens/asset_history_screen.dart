import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../bloc/history/history_bloc.dart';
import '../bloc/history/history_event.dart';
import '../bloc/history/history_state.dart';

class AssetHistoryScreen extends StatefulWidget {
  const AssetHistoryScreen({super.key});

  @override
  State<AssetHistoryScreen> createState() => _AssetHistoryScreenState();
}

class _AssetHistoryScreenState extends State<AssetHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HistoryBloc>().add(LoadAllHistory());
  }

  IconData _iconForAction(String action) {
    switch (action) {
      case 'Created':
        return Icons.add_circle_outline;
      case 'Updated':
        return Icons.edit_outlined;
      case 'Assigned':
        return Icons.person_add_alt_1_outlined;
      case 'Returned':
        return Icons.assignment_return_outlined;
      default:
        return Icons.history;
    }
  }

  Color _colorForAction(String action) {
    switch (action) {
      case 'Created':
        return AppColors.available;
      case 'Updated':
        return AppColors.maintenance;
      case 'Assigned':
        return AppColors.assigned;
      case 'Returned':
        return AppColors.primary;
      default:
        return AppColors.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Asset History'),
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading || state is HistoryInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HistoryError) {
            return Center(child: Text(state.message));
          }

          final history = (state as HistoryLoaded).history;

          if (history.isEmpty) {
            return const Center(
              child: Text('No history yet.',
                  style: TextStyle(color: AppColors.textGrey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final entry = history[index];
              final timestamp = DateTime.tryParse(entry.timestamp);
              final color = _colorForAction(entry.action);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_iconForAction(entry.action),
                          color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${entry.action} • ${entry.assetId}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              if (timestamp != null)
                                Text(
                                  DateFormat('dd MMM, hh:mm a').format(timestamp),
                                  style: const TextStyle(
                                      fontSize: 11, color: AppColors.textGrey),
                                ),
                            ],
                          ),
                          if (entry.details != null &&
                              entry.details!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                entry.details!,
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.textGrey),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
