import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/common/app_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));

    _controller.forward();
    _checkStatus();
  }

  void _checkStatus() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext BuildContext) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryDeeper, AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      const Icon(Icons.airplanemode_active_rounded, color: AppColors.white, size: 80),
                      const SizedBox(height: AppDimensions.md),
                      Text('Voyago', style: AppTextStyles.heading1.copyWith(color: AppColors.white, fontSize: 36)),
                      const SizedBox(height: AppDimensions.xs),
                      const Text('Plan your perfect journey effortlessly', style: AppTextStyles.whiteMuted),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(AppDimensions.xl),
                child: Column(
                  children: [
                    AppButton(
                      label: 'Get Started',
                      isFullWidth: true,
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                    ),
                    const SizedBox(height: AppDimensions.md),
                    AppButton(
                      label: 'Sign In',
                      variant: ButtonVariant.outline,
                      isFullWidth: true,
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}