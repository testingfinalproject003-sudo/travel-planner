import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/common/app_button.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(_emailController.text, _passwordController.text);

    if (!mounted) return;

    if (success) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Authentication failed')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext buildContext) {
    final loading = Provider.of<AuthProvider>(buildContext).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.xl),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: AppDimensions.xl),
                Text('Welcome Back', style: AppTextStyles.heading1),
                const SizedBox(height: AppDimensions.xs),
                Text('Sign in to continue your planning', style: AppTextStyles.small),
                const SizedBox(height: AppDimensions.xxl),
                AppInput(
                  label: 'Email Address',
                  hint: 'example@domain.com',
                  controller: _emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: AppDimensions.lg),
                AppInput(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outlined,
                  obscureText: true,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: AppDimensions.xl),
                AppButton(
                  label: 'Login',
                  isLoading: loading,
                  isFullWidth: true,
                  onPressed: _submitForm,
                ),
                const SizedBox(height: AppDimensions.xl),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, '/signup'),
                    child: Text("Don't have an account? Sign Up", style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}