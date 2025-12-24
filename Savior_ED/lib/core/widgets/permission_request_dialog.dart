import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../consts/app_colors.dart';
import '../services/app_lock_service.dart';
import 'custom_button.dart';

/// Dialog to request Usage Stats permission for app lock functionality
class PermissionRequestDialog extends StatelessWidget {
  const PermissionRequestDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.sp)),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10.sp),
            ),
            child: Icon(Icons.security, color: AppColors.primary, size: 24.sp),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              'Permission Required',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'To keep you focused during study sessions, we need permission to monitor app usage.',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.sp),
              border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What this does:',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 1.h),
                _buildBulletPoint(
                  '• Prevents you from opening other apps during focus time',
                ),
                _buildBulletPoint(
                  '• Helps you stay focused and earn more rewards',
                ),
                _buildBulletPoint('• Only active when timer is running'),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'You\'ll be taken to Settings to grant this permission.',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Column(
            children: [
              CustomButton(
                text: 'Grant Permission',
                backgroundColor: AppColors.primary,
                prefixIcon: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 18.sp,
                ),
                onPressed: () async {
                  Navigator.of(context).pop(true);
                  await AppLockService().requestUsageStatsPermission();
                },
              ),
              SizedBox(height: 1.h),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text(
                  'Not Now',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          color: AppColors.textSecondary,
          height: 1.4,
        ),
      ),
    );
  }
}
