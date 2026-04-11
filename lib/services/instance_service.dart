import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/instance_model.dart';

class InstanceService extends GetxService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  late SharedPreferences _prefs;

  Future<InstanceService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  Future<List<N8nInstance>> getInstances() async {
    try {
      final raw = await _secureStorage.read(key: AppConstants.instancesKey);
      if (raw == null) return [];
      final List<dynamic> list = jsonDecode(raw) as List;
      return list.map((e) => N8nInstance.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveInstance(N8nInstance instance) async {
    final instances = await getInstances();
    final idx = instances.indexWhere((i) => i.id == instance.id);
    if (idx >= 0) {
      instances[idx] = instance;
    } else {
      instances.add(instance);
    }
    await _secureStorage.write(
      key: AppConstants.instancesKey,
      value: jsonEncode(instances.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> deleteInstance(String id) async {
    final instances = await getInstances();
    instances.removeWhere((i) => i.id == id);
    await _secureStorage.write(
      key: AppConstants.instancesKey,
      value: jsonEncode(instances.map((e) => e.toJson()).toList()),
    );
    final activeId = getActiveInstanceId();
    if (activeId == id) {
      await clearActiveInstance();
    }
  }

  String? getActiveInstanceId() {
    return _prefs.getString(AppConstants.activeInstanceKey);
  }

  Future<void> setActiveInstanceId(String id) async {
    await _prefs.setString(AppConstants.activeInstanceKey, id);
  }

  Future<void> clearActiveInstance() async {
    await _prefs.remove(AppConstants.activeInstanceKey);
  }

  Future<N8nInstance?> getActiveInstance() async {
    final id = getActiveInstanceId();
    if (id == null) return null;
    final instances = await getInstances();
    try {
      return instances.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> get isDarkTheme async {
    return _prefs.getBool(AppConstants.themeKey) ?? true;
  }

  Future<void> setDarkTheme(bool value) async {
    await _prefs.setBool(AppConstants.themeKey, value);
  }
}
