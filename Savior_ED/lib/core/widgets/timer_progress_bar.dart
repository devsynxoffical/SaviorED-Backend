import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../consts/app_colors.dart';

/// Elegant timer progress bar widget
class TimerProgressBar extends StatelessWidget {
  final String label;
  final double progress;

  const TimerProgressBar({
    super.key,
    required this.label,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // TIME LEFT label - centered above bar
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.white, // White color
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          // Progress bar
          Container(
            height: 10.sp,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7.sp), // Reduced from 10.sp to 7.sp
              color: AppColors.textDisabled.withOpacity(0.2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7.sp), // Reduced from 10.sp to 7.sp
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color.fromARGB(255, 60, 231, 65), // Bright green color
                ),
                minHeight: 10.sp,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          // Actual time percentage - centered below bar
          Text(
            '${(progress * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white, // White color
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
