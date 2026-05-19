import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';

class AppInput extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const AppInput({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late bool _obscureState;

  @override
  void initState() {
    super.initState();
    _obscureState = widget.obscureText;
  }

  @override
  Widget build(BuildContext buildContext) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.label),
        const SizedBox(height: AppDimensions.xs),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureState,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          maxLines: widget.maxLines,
          onChanged: widget.onChanged,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: Icon(widget.prefixIcon, color: AppColors.textMuted),
            suffixIcon: widget.obscureText
                ? IconButton(
              icon: Icon(_obscureState ? Icons.visibility_off : Icons.visibility, color: AppColors.textMuted),
              onPressed: () => setState(() => _obscureState = !_obscureState),
            )
                : null,
          ),
        ),
      ],
    );
  }
}