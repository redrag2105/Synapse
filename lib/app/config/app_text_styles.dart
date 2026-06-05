import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // --- SANS SERIF (Merriweather Sans) ---
  static final TextStyle _sansBase = GoogleFonts.merriweatherSans(
    color: AppColors.textPrimary,
  );

  static final TextStyle h1 = _sansBase.copyWith(
    fontSize: 25,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static final TextStyle h2 = _sansBase.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static final TextStyle h3 = _sansBase.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle metadata = _sansBase.copyWith(
    fontSize: 12,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w400,
  );

  static final TextStyle button = _sansBase.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  // --- SERIF (Merriweather) ---
  static final TextStyle _serifBase = GoogleFonts.merriweather(
    color: AppColors.textPrimary,
  );

  static final TextStyle bodyText = _serifBase.copyWith(
    fontSize: 14,
    height: 1.7,
    color: AppColors.textPrimary,
  );
}
