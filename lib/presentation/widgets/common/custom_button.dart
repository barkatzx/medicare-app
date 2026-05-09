import 'package:flutter/material.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? 48,
        decoration: BoxDecoration(
          color: isOutlined
              ? Colors.transparent
              : (backgroundColor ?? CustomTheme.primaryColor),
          borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
          border: isOutlined
              ? Border.all(
                  color: backgroundColor ?? CustomTheme.primaryColor,
                  width: 1.5,
                )
              : null,
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOutlined
                          ? (backgroundColor ?? CustomTheme.primaryColor)
                          : (textColor ?? Colors.white),
                    ),
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(
                    fontSize: CustomTheme.fontSizeMD,
                    fontWeight: CustomTheme.fontWeightSemiBold,
                    color: isOutlined
                        ? (textColor ??
                              backgroundColor ??
                              CustomTheme.primaryColor)
                        : (textColor ?? Colors.white),
                  ),
                ),
        ),
      ),
    );
  }
}
