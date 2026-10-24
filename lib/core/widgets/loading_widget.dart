import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/custom_theme.dart';

class LoadingWidget extends StatefulWidget {
  final String? message;
  final bool isOverlay;

  const LoadingWidget({super.key, this.message, this.isOverlay = true});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Scale pulse animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Rotation animation
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          decoration: BoxDecoration(
            color: CustomTheme.surfaceColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated spinner
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer rotating ring
                    RotationTransition(
                      turns: _rotationAnimation,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: CustomTheme.primaryColor.withValues(
                              alpha: 0.1,
                            ),
                            width: 3,
                          ),
                        ),
                      ),
                    ),

                    // Inner rotating gradient spinner
                    RotationTransition(
                      turns: _rotationAnimation,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              CustomTheme.primaryColor.withValues(alpha: 0.0),
                              CustomTheme.primaryColor.withValues(alpha: 0.3),
                              CustomTheme.primaryColor.withValues(alpha: 0.6),
                              CustomTheme.primaryColor,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Center dot
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: CustomTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),

              // Message
              if (widget.message != null) ...[
                const SizedBox(height: 18),
                Text(
                  widget.message!,
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.bodyMedium.copyWith(
                    color: CustomTheme.textPrimary,
                    fontWeight: CustomTheme.fontWeightMedium,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (!widget.isOverlay) return content;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        color: Colors.black.withValues(alpha: 0.25),
        child: content,
      ),
    );
  }
}
