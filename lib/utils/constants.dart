import 'package:flutter/material.dart';

import '/utils/theme.dart';

abstract class AppAssets {
  static const String emptyStateImage =
      'https://img.freepik.com/premium-vector/nothing-rubber-stamp-seal-vector_140916-33117.jpg?semt=ais_hybrid&w=740&q=80';
}

abstract class AppDimensions {
  static const double emptyStateImageSize = 200.0;
  static const double emptyStateImageRadius = 16.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double monthFilterHeight = 110.0;
  static const double cornerRadius16 = 16.0;
  static const double cornerRadius24 = 24.0;
  static const double cornerRadius30 = 30.0;
}

abstract class AppTextStyles {
  static const headerStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  static const sectionTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const dateLabelStyle = TextStyle(color: AppColors.grey, fontSize: 14);

  static const emptyStateTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const monthFilterTitleStyle = TextStyle(color: AppColors.onPrimary);

  static const monthFilterAmountStyle = TextStyle(
    color: AppColors.onPrimary,
    fontSize: 20,
  );
}
