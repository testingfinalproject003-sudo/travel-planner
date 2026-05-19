import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class AppCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext buildContext) {
    return Container(
      margin: widget.margin,
      child: GestureDetector(
        onTapDown: (_) => widget.onTap != null ? _controller.forward() : null,
        onTapUp: (_) => widget.onTap != null ? _controller.reverse() : null,
        onTapCancel: () => widget.onTap != null ? _controller.reverse() : null,
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(AppDimensions.lg),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}