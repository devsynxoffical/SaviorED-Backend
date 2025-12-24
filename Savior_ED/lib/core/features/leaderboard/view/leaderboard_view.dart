import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../consts/app_colors.dart';

/// Leaderboard View - Kingdom Rankings
class LeaderboardView extends StatelessWidget {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9DB89D), // Sage green background
      appBar: AppBar(
        backgroundColor: const Color(0xFF8BA88B),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white, size: 24.sp),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'KINGDOM RANKINGS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 16,
              child: Icon(Icons.person, color: AppColors.primary, size: 18),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Resource bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            color: const Color(0xFF8BA88B),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildResourceChip(
                  Icons.monetization_on,
                  '1280 COINS',
                  AppColors.coinGold,
                ),
                SizedBox(width: 4.w),
                _buildResourceChip(
                  Icons.construction,
                  '875 STONES',
                  AppColors.stoneGray,
                ),
                SizedBox(width: 4.w),
                _buildResourceChip(
                  Icons.forest,
                  '500 WOOD',
                  AppColors.woodBrown,
                ),
              ],
            ),
          ),

          // Navigation tabs
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            color: const Color(0xFF8BA88B),
            child: Row(
              children: [
                _buildTab('GLOBAL', isSelected: true),
                SizedBox(width: 2.w),
                _buildTab('SCHOOL', isSelected: true),
                const Spacer(),
                Text(
                  'SORT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 1.w),
                Icon(
                  Icons.filter_list,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 2.h),
                  
                  // Castle image - centered
                  Center(
                    child: Image.asset(
                      'assets/images/leadboard_castle.png',
                      width: 90.w,
                      height: 25.h,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Error loading leaderboard castle image: $error');
                        return Container(
                          width: 90.w,
                          height: 25.h,
                          color: Colors.black12,
                          child: Center(
                            child: Icon(
                              Icons.castle,
                              size: 80.sp,
                              color: Colors.white70,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 1.h),

                  // TOP 10 Banner
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shield,
                          color: AppColors.coinGold,
                          size: 24.sp,
                        ),
                        SizedBox(width: 2.w),
                        const Text(
                          'TOP 10',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Icon(
                          Icons.shield,
                          color: AppColors.coinGold,
                          size: 24.sp,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Rankings List
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      children: [
                        _buildRankingItem(
                          rank: 1,
                          name: 'KING',
                          level: 'Level 4 Royal Fortress',
                          coins: 1250,
                          shieldColor: AppColors.coinGold,
                          castleColor: AppColors.coinGold,
                          buttonText: 'VIEW PROFILE',
                          buttonColor: AppColors.secondary,
                        ),
                        SizedBox(height: 1.5.h),
                        _buildRankingItem(
                          rank: 2,
                          name: 'Ethan. S',
                          level: 'Level 4 Royal Fonesa',
                          coins: null,
                          shieldColor: AppColors.coinGold,
                          castleColor: AppColors.coinGold,
                          buttonText: 'CLAIM REWARD',
                          buttonColor: AppColors.warning,
                        ),
                        SizedBox(height: 1.5.h),
                        _buildRankingItem(
                          rank: 3,
                          name: 'Oliva. L',
                          level: 'Level 3 Royal Keep',
                          coins: 1250,
                          progress: 1830,
                          progressMax: 1800,
                          shieldColor: const Color(0xFFC0C0C0),
                          castleColor: AppColors.stoneGray,
                          buttonText: 'VIEW PROFILE',
                          buttonColor: AppColors.secondary,
                        ),
                        SizedBox(height: 1.5.h),
                        _buildRankingItem(
                          rank: 4,
                          name: 'Qize 3 Royal Keep',
                          level: 'Level 3 Royal 1800 hrs',
                          coins: 750,
                          shieldColor: const Color(0xFFC0C0C0),
                          castleColor: AppColors.stoneGray,
                          buttonText: 'COINS EARNED',
                          buttonColor: AppColors.stoneGray,
                        ),
                        SizedBox(height: 1.5.h),
                        _buildRankingItem(
                          rank: 5,
                          name: 'Ben. K',
                          level: 'Level 2 Guard Tower',
                          coins: null,
                          progress: 900,
                          progressMax: 1730,
                          shieldColor: const Color(0xFFFF6B6B),
                          castleColor: AppColors.stoneGray,
                          buttonText: null,
                          showStudyTime: true,
                        ),
                        SizedBox(height: 1.5.h),
                        _buildRankingItem(
                          rank: 6,
                          name: 'Level 2 Tower',
                          level: 'Level 2 Guard Tower',
                          coins: null,
                          shieldColor: const Color(0xFF8B4513),
                          castleColor: const Color(0xFF8B4513),
                          buttonText: null,
                          showStudyTime: true,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20.sp),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16.sp),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, {bool isSelected = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.coinGold.withOpacity(0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20.sp),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRankingItem({
    required int rank,
    required String name,
    required String level,
    int? coins,
    double? progress,
    double? progressMax,
    required Color shieldColor,
    required Color castleColor,
    String? buttonText,
    Color? buttonColor,
    bool showStudyTime = false,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank shield with crown
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.shield,
                color: shieldColor,
                size: 40.sp,
              ),
              if (rank <= 3)
                Positioned(
                  top: -2.sp,
                  child: Icon(
                    Icons.workspace_premium,
                    color: shieldColor,
                    size: 16.sp,
                  ),
                ),
              Text(
                '#$rank',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(width: 3.w),

          // Castle icon
          Icon(
            Icons.castle,
            color: castleColor,
            size: 32.sp,
          ),

          SizedBox(width: 3.w),

          // Name and level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  level,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (progress != null && progressMax != null) ...[
                  SizedBox(height: 1.h),
                  Container(
                    height: 6.sp,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.sp),
                      color: Colors.grey[300],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3.sp),
                      child: LinearProgressIndicator(
                        value: progress / progressMax,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${progress.toInt()}/${progressMax.toInt()} hrs',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Right side - Coins or Button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (coins != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: AppColors.coinGold,
                      size: 18.sp,
                    ),
                    SizedBox(width: 0.5.w),
                    Text(
                      '$coins COINS',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              if (showStudyTime) ...[
                SizedBox(height: 0.5.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 0.5.w),
                    Text(
                      'STUDY TIME',
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      size: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 0.5.w),
                    Text(
                      'COINS EARNED',
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
              if (buttonText != null) ...[
                SizedBox(height: 1.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: buttonColor ?? AppColors.secondary,
                    borderRadius: BorderRadius.circular(20.sp),
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

