import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1600));

    final authController = Get.find<AuthController>();

    if (await authController.isLoggedIn()) {
      await authController.loadInstances();

      if (authController.activeInstance.value != null) {
        Get.offAllNamed('/home');
      } else {
        Get.offAllNamed('/login');
      }
    } else {
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    const white = Colors.white;
    const black = Color(0xFF18181B);
    const gray = Color(0xFF71717A);
    const lightBorder = Color(0xFFE8E8F0);

    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -110,
              right: -90,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.18),
                      AppTheme.primaryColor.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                const Spacer(flex: 2),
                Container(
                  width: 132,
                  height: 132,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: lightBorder),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.25),
                        blurRadius: 36,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/icon/n8n_logo.png',
                    fit: BoxFit.contain,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1, 1),
                      curve: Curves.easeOutBack,
                    ),
                const SizedBox(height: 26),
                const Text(
                  'n8n Manager',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: black,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 500.ms)
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: 8),
                const Text(
                  'Workflow automation, anywhere',
                  style: TextStyle(fontSize: 15, color: gray),
                )
                    .animate()
                    .fadeIn(delay: 350.ms, duration: 500.ms)
                    .slideY(begin: 0.2, end: 0),
                const Spacer(flex: 3),
                const SpinKitFadingCircle(
                  color: AppTheme.primaryColor,
                  size: 42,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Loading…',
                  style: TextStyle(fontSize: 13, color: gray),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
