// ── empty_tables_widget.dart ──────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class EmptyTablesWidget extends StatelessWidget {
  final VoidCallback onCreateTap;
  const EmptyTablesWidget({super.key, required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.table_chart_rounded,
                size: 52, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Tables Yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first data table to store structured data.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.darkTextSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onCreateTap,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Create Table'),
          ),
        ],
      ),
    );
  }
}
