import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage execution notification settings.
class ExecutionNotificationService {
  static const String _keyEnabled = 'execution_notify_enabled';
  static const String _keyDelayMinutes = 'execution_notify_delay_minutes';
  static const int defaultDelayMinutes = 5;

  /// Get notification settings.
  Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'enabled': prefs.getBool(_keyEnabled) ?? true,
      'delayMinutes': prefs.getInt(_keyDelayMinutes) ?? defaultDelayMinutes,
    };
  }

  /// Enable/disable notifications.
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, enabled);
  }

  /// Set check delay in minutes.
  Future<void> setCheckDelayMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDelayMinutes, minutes);
  }
}

/// Global instance.
final executionNotificationService = ExecutionNotificationService();
