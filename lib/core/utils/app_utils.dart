import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../theme/app_theme.dart';

class AppUtils {
  static String formatDate(String? isoDate) {
    if (isoDate == null) return '—';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return DateFormat('MMM d, yyyy HH:mm').format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  static String timeAgo(String? isoDate) {
    if (isoDate == null) return '—';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return timeago.format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  static String formatDuration(int? ms) {
    if (ms == null) return '—';
    if (ms < 1000) return '${ms}ms';
    if (ms < 60000) return '${(ms / 1000).toStringAsFixed(1)}s';
    final minutes = ms ~/ 60000;
    final seconds = (ms % 60000) ~/ 1000;
    return '${minutes}m ${seconds}s';
  }

  static Color statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'success':
      case 'active':
        return AppTheme.successColor;
      case 'error':
      case 'failed':
        return AppTheme.errorColor;
      case 'running':
      case 'waiting':
        return AppTheme.warningColor;
      default:
        return AppTheme.darkTextMuted;
    }
  }

  static IconData statusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'success':
        return Icons.check_circle_rounded;
      case 'error':
      case 'failed':
        return Icons.cancel_rounded;
      case 'running':
        return Icons.play_circle_rounded;
      case 'waiting':
        return Icons.pause_circle_rounded;
      default:
        return Icons.circle_outlined;
    }
  }

  static String sanitizeUrl(String url) {
    url = url.trim();
    if (url.endsWith('/')) url = url.substring(0, url.length - 1);
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    return url;
  }
}
