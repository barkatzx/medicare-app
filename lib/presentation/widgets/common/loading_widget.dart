import 'dart:ui';
import 'package:flutter/material.dart';
import 'custom_theme.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool isOverlay;

  const LoadingWidget({
    super.key,
    this.message,
    this.isOverlay = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      CustomTheme.primaryColor.withOpacity(0.2),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      CustomTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            if (message != null) ...[
              const SizedBox(height: 20),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: CustomTextStyle.bodyMedium.copyWith(
                  color: CustomTheme.textPrimary,
                  fontWeight: CustomTheme.fontWeightMedium,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (!isOverlay) return content;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Container(
        color: Colors.black.withOpacity(0.2),
        child: content,
      ),
    );
  }
}
