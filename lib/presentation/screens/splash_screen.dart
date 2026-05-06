import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
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
    await Future.delayed(const Duration(milliseconds: 1200));

    final authController = Get.find<AuthController>();

    if (await authController.is_logged_in()) {
      // Ensure instances are loaded and API is configured
      await authController.loadInstances();

      if (authController.activeInstance.value != null) {
        // API is configured — go to home
        Get.offAllNamed('/home');
      } else {
        // No active instance found — go to login
        Get.offAllNamed('/login');
      }
    } else {
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Column(
          children: [
            const SizedBox(
              height: 190,
            ),
            Image.asset(
              "assets/icon/n8n_logo.png",
              height: 200,
              width: 200,
            ),
            const Spacer(),
            const SpinKitCircle(
              color: Colors.deepOrange,
              size: 60,
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        )));
  }
}
