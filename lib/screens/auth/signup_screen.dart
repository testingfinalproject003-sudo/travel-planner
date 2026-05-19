import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/common/app_button.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _passStrength = 'None';
  Color _strengthColor = AppColors.textMuted;

  void _checkStrength(String val) {
    if (val.isEmpty) {
      setState(() { _passStrength = 'None'; _strengthColor = AppColors.textMuted; });
    } else if (val.length < 6) {
      setState(() { _passStrength = 'Weak'; _strengthColor = AppColors.danger; });
    } else if (val.length < 10) {
      setState(() { _passStrength = 'Medium'; _strengthColor = AppColors.gold; });
    } else {
      setState(() { _passStrength = 'Strong'; _strengthColor = AppColors.success; });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = Provider.of<AuthProvider>(context, listen: false);
    final status = await provider.signup(_nameController.text, _emailController.text, _passwordController.text);

    if (!mounted) return;
    if (status) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.error ?? 'Error during signup')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext buildContext) {
    final loading = Provider.of<AuthProvider>(buildContext).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.xl),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text('Join Voyago', style: AppTextStyles.heading1),
                const SizedBox(height: AppDimensions.xxl),
                AppInput(
                  label: 'Full Name',
                  hint: 'John Doe',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                  validator: (v) => Validators.validateRequired(v, 'Name'),
                ),
                const SizedBox(height: AppDimensions.lg),
                AppInput(
                  label: 'Email Address',
                  hint: 'john@doe.com',
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
                  onChanged: _checkStrength,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: AppDimensions.xs),
                Row(
                  children: [
                    Text('Password Strength: ', style: AppTextStyles.small),
                    Text(_passStrength, style: AppTextStyles.small.copyWith(color: _strengthColor, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: AppDimensions.lg),
                AppInput(
                  label: 'Confirm Password',
                  hint: '••••••••',
                  controller: _confirmPasswordController,
                  prefixIcon: Icons.lock_clock_outlined,
                  obscureText: true,
                  validator: (v) => Validators.validateConfirmPassword(v, _passwordController.text),
                ),
                const SizedBox(height: AppDimensions.xl),
                AppButton(
                  label: 'Create Account',
                  isLoading: loading,
                  isFullWidth: true,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppDimensions.lg),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: Text('Already have an account? Login', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
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