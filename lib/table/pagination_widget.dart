import 'package:flutter/material.dart';
import 'package:n8n_manager/presentation/controllers/data_tables_controller.dart';
import '../../core/theme/app_theme.dart';

class PaginationWidget extends StatelessWidget {
  final DataTableDetailController ctrl;
  const PaginationWidget({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          Text(
            'Page ${ctrl.currentPage.value + 1} of ${ctrl.totalPages}  ·  ${ctrl.filteredRows.length} rows',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const Spacer(),
          _PageBtn(
            icon: Icons.chevron_left_rounded,
            onTap: ctrl.currentPage.value > 0 ? ctrl.prevPage : null,
          ),
          const SizedBox(width: 4),
          _PageBtn(
            icon: Icons.chevron_right_rounded,
            onTap: ctrl.currentPage.value < ctrl.totalPages - 1
                ? ctrl.nextPage
                : null,
          ),
        ],
      ),
    );
  }
}

class _PageBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _PageBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: enabled
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppTheme.primaryColor : AppTheme.darkTextMuted,
        ),
      ),
    );
  }
}
