import 'package:flutter/material.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final double? fontSize;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.enabled = true,
    this.fontSize,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  String? _errorText;
  bool _isTouched = false;

  void _validate() {
    if (_isTouched && widget.validator != null) {
      final error = widget.validator!(widget.controller.text);
      setState(() {
        _errorText = error;
      });
    }
  }

  void _onFieldTap() {
    if (!_isTouched) {
      setState(() {
        _isTouched = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: TextStyle(
            fontSize: CustomTheme.fontSizeSM,
            fontWeight: CustomTheme.fontWeightMedium,
            color: CustomTheme.textSecondary,
          ),
        ),
        SizedBox(height: CustomTheme.spacingSM),

        // Text Field Container - Border ALWAYS secondary color
        Container(
          decoration: BoxDecoration(
            color: CustomTheme.surfaceColor,
            borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
            border: Border.all(
              color: CustomTheme.secondaryColor, // Always secondary color
              width: 1,
            ),
          ),
          child: Row(
            children: [
              if (widget.prefixIcon != null) ...[
                SizedBox(width: CustomTheme.spacingMD),
                Icon(
                  widget.prefixIcon,
                  size: 20,
                  color: CustomTheme.textTertiary,
                ),
              ],
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  enabled: widget.enabled,
                  style: TextStyle(
                    fontSize: widget.fontSize ?? CustomTheme.fontSizeMD,
                    color: CustomTheme.textSecondary,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      fontSize: widget.fontSize ?? CustomTheme.fontSizeMD,
                      color: CustomTheme.textTertiary,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: CustomTheme.spacingXL,
                      vertical: CustomTheme.spacingXL,
                    ),
                    isDense: true,
                    errorText: null, // No error inside the field
                  ),
                  onTap: _onFieldTap,
                ),
              ),
              if (widget.suffixIcon != null) widget.suffixIcon!,
            ],
          ),
        ),

        // Error message below the field - only shows when user has interacted and there's an error
        if (_errorText != null && _errorText!.isNotEmpty && _isTouched)
          Padding(
            padding: EdgeInsets.only(top: CustomTheme.spacingSM),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 14,
                  color: CustomTheme.errorColor,
                ),
                SizedBox(width: CustomTheme.spacingSM),
                Expanded(
                  child: Text(
                    _errorText!,
                    style: TextStyle(
                      fontSize: CustomTheme.fontSizeSM,
                      color: CustomTheme.errorColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
