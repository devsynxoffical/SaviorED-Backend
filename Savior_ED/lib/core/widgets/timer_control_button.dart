import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../consts/app_colors.dart';

/// Elegant timer control button widget
class TimerControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String? label;

  const TimerControlButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22.sp),
          ),
        ),
        if (label != null) ...[
          SizedBox(height: 0.5.h),
          Text(
            label!,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
