import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../consts/app_colors.dart';
import 'custom_button.dart';

/// Timer duration picker dialog
class TimerDurationPicker extends StatefulWidget {
  final int initialMinutes;

  const TimerDurationPicker({super.key, this.initialMinutes = 25});

  @override
  State<TimerDurationPicker> createState() => _TimerDurationPickerState();
}

class _TimerDurationPickerState extends State<TimerDurationPicker> {
  late int _selectedMinutes;
  final TextEditingController _customController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedMinutes = widget.initialMinutes;
    _customController.text = widget.initialMinutes.toString();
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.sp)),
      title: Text(
        'Set Focus Duration',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select how long you want to focus',
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 3.h),
          // Quick select buttons
          Wrap(
            spacing: 2.w,
            runSpacing: 2.h,
            alignment: WrapAlignment.center,
            children: [
              _buildDurationButton(5, '5 min'),
              _buildDurationButton(10, '10 min'),
              _buildDurationButton(15, '15 min'),
              _buildDurationButton(20, '20 min'),
              _buildDurationButton(25, '25 min'),
              _buildDurationButton(30, '30 min'),
              _buildDurationButton(45, '45 min'),
              _buildDurationButton(60, '60 min'),
            ],
          ),
          SizedBox(height: 3.h),
          // Custom duration input
          Column(
            children: [
              Text(
                'Or enter custom duration',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 1.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 25.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10.sp),
                      border: Border.all(
                        color: _selectedMinutes > 120 || _selectedMinutes < 1
                            ? AppColors.error
                            : AppColors.primary,
                        width: 2,
                      ),
                    ),
                    child: TextField(
                      controller: _customController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'min',
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textDisabled,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 2.w),
                      ),
                      onChanged: (value) {
                        final minutes = int.tryParse(value);
                        if (minutes != null && minutes > 0 && minutes <= 120) {
                          setState(() {
                            _selectedMinutes = minutes;
                          });
                        } else if (value.isEmpty) {
                          setState(() {
                            _selectedMinutes = widget.initialMinutes;
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'minutes',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (_selectedMinutes > 120 || _selectedMinutes < 1)
                Padding(
                  padding: EdgeInsets.only(top: 0.5.h),
                  child: Text(
                    'Please enter 1-120 minutes',
                    style: TextStyle(fontSize: 11.sp, color: AppColors.error),
                  ),
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        CustomButton(
          text: 'Set Duration',
          backgroundColor: AppColors.secondary,
          width: 40.w,
          height: 5.h,
          onPressed: _selectedMinutes > 0 && _selectedMinutes <= 120
              ? () {
                  Navigator.of(context).pop(_selectedMinutes);
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDurationButton(int minutes, String label) {
    final isSelected = _selectedMinutes == minutes;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMinutes = minutes;
          _customController.text = minutes.toString();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : AppColors.surface,
          borderRadius: BorderRadius.circular(12.sp),
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.textDisabled,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
