import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../consts/app_colors.dart';
import '../../../consts/app_sizes.dart';

/// Treasure Chest View - Matching design with treasure image
class TreasureChestView extends StatelessWidget {
  const TreasureChestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1410), // Dark green/brown background
      body: Stack(
        children: [
          // Treasure image background
          Positioned.fill(
            child: Image.asset(
              'assets/images/treasure.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to treasure.jpg if treasure.png doesn't exist
                return Image.asset(
                  'assets/images/treasure.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF1A1410),
                    );
                  },
                );
              },
            ),
          ),
          // Content on top of background
          Column(
            children: [
              // AppBar
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                actions: [
                  Padding(
                    padding: EdgeInsets.only(right: 15.w),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildResourceIcon(
                          Icons.monetization_on,
                          'COINS',
                          AppColors.coinGold,
                        ),
                        SizedBox(width: 2.w),
                        _buildResourceIcon(
                          Icons.construction,
                          'STONES',
                          AppColors.stoneGray,
                        ),
                        SizedBox(width: 2.w),
                        _buildResourceIcon(
                          Icons.construction,
                          '875',
                          AppColors.stoneGray,
                        ),
                        SizedBox(width: 2.w),
                        _buildResourceIcon(Icons.forest, 'WOOD', AppColors.woodBrown),
                      ],
                    ),
                  ),
                ],
              ),
              // Body content
              Expanded(
                child: SafeArea(
                  child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 2.h),
              // Title - Single line
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'TREASURE CHEST',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 1.h),
              // Progress text
              Text(
                '50% complete to unlock a new treasure chest!',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              // Progress bar with diamond marker
              _buildProgressBar(),
              SizedBox(height: 41.h),
              // Claim reward button
              Container(
                width: double.infinity,
                height: AppSizes.buttonHeightMedium,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD54F), Color(0xFFFFC107)],
                  ),
                  borderRadius: BorderRadius.circular(50.sp), // Pill-shaped
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.warning.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(50.sp),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        'CLAIM MY REWARD',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C2416),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              // Re-roll button
              Container(
                width: double.infinity,
                height: AppSizes.buttonHeightMedium,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4FC3F7), Color(0xFF2196F3)],
                  ),
                  borderRadius: BorderRadius.circular(50.sp), // Pill-shaped
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2196F3).withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(50.sp),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        'RE-ROLL MYSTERY PRIZE',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              // Virtual rewards section
              _buildRewardsSection(
                title: 'VIRTUAL REWARDS',
                rewards: [
                  _RewardBadge(
                    'Study Champion',
                    Icons.castle,
                    const Color(0xFFFFD700), // Gold
                  ),
                  _RewardBadge(
                    '7-Day Streak',
                    Icons.local_fire_department,
                    const Color(0xFFC0C0C0), // Silver
                  ),
                  _RewardBadge(
                    'Focus Streak',
                    Icons.shield,
                    const Color(0xFF808080), // Grey
                  ),
                  _RewardBadge(
                    'Focus Hero',
                    Icons.star,
                    const Color(0xFF8B4513), // Brown
                  ),
                ],
              ),
              SizedBox(height: 3.h),
            ],
          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResourceIcon(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20.sp), // Increased size
        SizedBox(width: 1.w),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp, // Increased font size
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final progressBarWidth =
            constraints.maxWidth - (8.w); // Account for padding
        final markerPosition =
            (progressBarWidth * 0.5) -
            8.sp; // 50% position minus half marker width

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Stack(
            children: [
              // Progress bar track
              Container(
                height: 8.sp,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.sp),
                  color: Colors.white.withOpacity(0.3),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.sp),
                  child: LinearProgressIndicator(
                    value: 0.5, // 50%
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.warning, // Gold color
                    ),
                  ),
                ),
              ),
              // Diamond marker at 50%
              Positioned(
                left: markerPosition,
                top: -4.sp,
                child: Transform.rotate(
                  angle: 0.785, // 45 degrees for diamond shape
                  child: Container(
                    width: 16.sp,
                    height: 16.sp,
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(2.sp),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRewardsSection({
    required String title,
    required List<_RewardBadge> rewards,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(height: 3.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: rewards.map((reward) => _buildRewardBadge(reward)).toList(),
        ),
      ],
    );
  }

  Widget _buildRewardBadge(_RewardBadge reward) {
    return Column(
      children: [
        Container(
          width: 13.w,
          height: 13.w,
          decoration: BoxDecoration(
            color: reward.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: reward.color.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(reward.icon, color: Colors.white, size: 24.sp),
        ),
        SizedBox(height: 1.h),
        SizedBox(
          width: 20.w,
          child: Text(
            reward.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _RewardBadge {
  final String title;
  final IconData icon;
  final Color color;

  _RewardBadge(this.title, this.icon, this.color);
}
