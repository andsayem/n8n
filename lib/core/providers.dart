import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'services/purchase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import 'services/ads_service.dart';

// Ads-removed flag provider (reads/writes SharedPreferences)
class AdsRemovedNotifier extends StateNotifier<bool> {
	AdsRemovedNotifier(this._ref) : super(false) {
		_load();
		_listenToPurchases();
	}

	final Ref _ref;

	Future<void> _load() async {
		final prefs = await SharedPreferences.getInstance();
		state = prefs.getBool('ads_removed') ?? false;
	}

	void _listenToPurchases() {
		try {
			final svc = _ref.read(purchaseServiceProvider);
			svc.purchaseUpdates.listen((removed) {
				if (removed) setRemoved(true);
			});
		} catch (_) {
			// purchase service may not be available yet; ignore
		}
	}

	Future<void> setRemoved(bool v) async {
		final prefs = await SharedPreferences.getInstance();
		await prefs.setBool('ads_removed', v);
		state = v;
	}
}

final adsRemovedProvider = StateNotifierProvider<AdsRemovedNotifier, bool>((ref) => AdsRemovedNotifier(ref));

// Purchase service provider
final purchaseServiceProvider = Provider<PurchaseService>((ref) => PurchaseService());

// Keep a single AuthService instance for the app so Dio options (baseUrl / headers)
// are shared and not lost due to auto-dispose or multiple provider instances.
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Ads service provider (singleton)
final adsServiceProvider = Provider<AdsService>((ref) => AdsService());
