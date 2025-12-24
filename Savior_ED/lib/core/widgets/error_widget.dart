import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../consts/app_colors.dart';
import '../consts/app_sizes.dart';
import 'custom_button.dart';

/// Custom error widget with retry option
class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48.sp,
              color: AppColors.error,
            ),
            SizedBox(height: 2.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppSizes.fontSizeMedium,
                color: AppColors.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 3.h),
              CustomButton(
                text: 'Retry',
                onPressed: onRetry,
                width: 40.w,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

