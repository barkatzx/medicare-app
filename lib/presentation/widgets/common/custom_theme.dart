import 'package:flutter/material.dart';

class CustomTheme {
  // Font Families - Use 'Outfit' as the family name
  static const String primaryFontFamily = 'Outfit';
  static const String secondaryFontFamily = 'Outfit';

  // Colors
  static const Color primaryColor = Color(0xFF010101);
  static const Color secondaryColor = Color(0xFFF2F2F2);
  static const Color backgroundColor = Color(0xFFF7F7F7);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFDC2626);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Border Colors
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderMedium = Color(0xFFD1D5DB);

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 12.0;
  static const double spacingLG = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;

  // Border Radius
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusRound = 999.0;

  // Font Sizes
  static const double fontSizeXS = 10.0;
  static const double fontSizeSM = 12.0;
  static const double fontSizeMD = 14.0;
  static const double fontSizeLG = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 20.0;
  static const double fontSizeDisplay = 24.0;

  // Font Weights
  static const FontWeight fontWeightThin = FontWeight.w100;
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  static const FontWeight fontWeightExtraBold = FontWeight.w800;
  static const FontWeight fontWeightBlack = FontWeight.w900;

  // Shadows
  static List<BoxShadow> get boxShadowLight => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get boxShadowMedium => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get boxShadowHeavy => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}

// Custom Text Styles with Outfit Font
class CustomTextStyle {
  static TextStyle get heading1 => TextStyle(
    fontFamily: CustomTheme.primaryFontFamily,
    fontSize: CustomTheme.fontSizeDisplay,
    fontWeight: CustomTheme.fontWeightBold,
    color: CustomTheme.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle get heading2 => TextStyle(
    fontFamily: CustomTheme.primaryFontFamily,
    fontSize: CustomTheme.fontSizeXXL,
    fontWeight: CustomTheme.fontWeightSemiBold,
    color: CustomTheme.textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static TextStyle get heading3 => TextStyle(
    fontFamily: CustomTheme.primaryFontFamily,
    fontSize: CustomTheme.fontSizeXL,
    fontWeight: CustomTheme.fontWeightSemiBold,
    color: CustomTheme.textPrimary,
    height: 1.4,
  );

  static TextStyle get heading4 => TextStyle(
    fontFamily: CustomTheme.primaryFontFamily,
    fontSize: CustomTheme.fontSizeLG,
    fontWeight: CustomTheme.fontWeightSemiBold,
    color: CustomTheme.textPrimary,
    height: 1.4,
  );

  static TextStyle get bodyLarge => TextStyle(
    fontFamily: CustomTheme.secondaryFontFamily,
    fontSize: CustomTheme.fontSizeLG,
    fontWeight: CustomTheme.fontWeightRegular,
    color: CustomTheme.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontFamily: CustomTheme.secondaryFontFamily,
    fontSize: CustomTheme.fontSizeMD,
    fontWeight: CustomTheme.fontWeightRegular,
    color: CustomTheme.textSecondary,
    height: 1.5,
  );

  static TextStyle get bodySmall => TextStyle(
    fontFamily: CustomTheme.secondaryFontFamily,
    fontSize: CustomTheme.fontSizeSM,
    fontWeight: CustomTheme.fontWeightRegular,
    color: CustomTheme.textTertiary,
    height: 1.5,
  );

  static TextStyle get caption => TextStyle(
    fontFamily: CustomTheme.secondaryFontFamily,
    fontSize: CustomTheme.fontSizeXS,
    fontWeight: CustomTheme.fontWeightMedium,
    color: CustomTheme.textTertiary,
    height: 1.4,
  );

  static TextStyle get button => TextStyle(
    fontFamily: CustomTheme.primaryFontFamily,
    fontSize: CustomTheme.fontSizeMD,
    fontWeight: CustomTheme.fontWeightSemiBold,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static TextStyle get link => TextStyle(
    fontFamily: CustomTheme.secondaryFontFamily,
    fontSize: CustomTheme.fontSizeMD,
    fontWeight: CustomTheme.fontWeightMedium,
    color: CustomTheme.primaryColor,
    decoration: TextDecoration.underline,
  );
}
