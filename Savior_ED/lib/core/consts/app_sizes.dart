import 'package:responsive_sizer/responsive_sizer.dart';

/// Application size constants using responsive_sizer
class AppSizes {
  // Padding & Margins
  static double get paddingSmall => 1.w;
  static double get paddingMedium => 2.w;
  static double get paddingLarge => 4.w;
  static double get paddingXLarge => 6.w;
  
  // Font Sizes
  static double get fontSizeSmall => 12.sp;
  static double get fontSizeMedium => 14.sp;
  static double get fontSizeLarge => 16.sp;
  static double get fontSizeXLarge => 18.sp;
  static double get fontSizeXXLarge => 24.sp;
  
  // Icon Sizes
  static double get iconSizeSmall => 20.sp;
  static double get iconSizeMedium => 24.sp;
  static double get iconSizeLarge => 32.sp;
  
  // Border Radius
  static double get radiusSmall => 4.sp;
  static double get radiusMedium => 8.sp;
  static double get radiusLarge => 12.sp;
  static double get radiusXLarge => 16.sp;
  
  // Button Heights
  static double get buttonHeightSmall => 4.h;
  static double get buttonHeightMedium => 5.h;
  static double get buttonHeightLarge => 6.h;
  
  // Private constructor to prevent instantiation
  AppSizes._();
}

