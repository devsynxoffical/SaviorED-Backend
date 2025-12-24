import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:provider/provider.dart';
import '../../../consts/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../authentication/viewmodels/auth_viewmodel.dart';

class CastleGroundsView extends StatelessWidget {
  const CastleGroundsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA6B57E), // Base background color
      body: Stack(
        children: [
          // 1. Background image (full screen)
          Positioned.fill(
            child: Image.asset(
              'assets/images/final_house.jpg',
              width: 70,
              height: 70,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFA6B57E),
                );
              },
            ),
          ),
          // 2. Main content
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: const Color(
                0xFF95A56D,
              ), // Slightly darker version for contrast
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.menu, color: Colors.white, size: 24.sp),
                onPressed: () async {
                  final authViewModel = context.read<AuthViewModel>();
                  await authViewModel.logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.welcome,
                      (route) => false,
                    );
                  }
                },
              ),
              title: const Text(
                'SETTINGS',
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
                    child: Icon(Icons.person, color: Color(0xFFA6B57E), size: 18),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.profile);
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // Resource Bar
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    color: const Color(0xFFA6B57E), // Match AppBar color
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8.w,
                      runSpacing: 2.h,
                      children: [
                        _buildResourceChip(
                          Icons.monetization_on,
                          '1280 COINS',
                          AppColors.coinGold,
                        ),
                        _buildResourceChip(
                          Icons.construction,
                          '875 STONES',
                          AppColors.stoneGray,
                        ),
                        _buildResourceChip(
                          Icons.forest,
                          '500 WOOD',
                          AppColors.woodBrown,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 6.h),
                          Text(
                            'Castle Grounds',
                            style: TextStyle(
                              fontSize: 25.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(
                                0.9,
                              ), // Slightly less opaque
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 2.h),
                          // Centered final_house.jpg image - matching screenshot exactly
                        
                          SizedBox(height: 35.h),
                          // Level & Progress - matching timer progress bar design
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'LEVEL 1 CASTLE',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 1.h),
                                // Progress bar - same design as timer progress bar
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Progress bar
                                      Container(
                                        height: 10.sp, // Same height as timer progress bar
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(7.sp), // Same border radius
                                          color: AppColors.textDisabled.withOpacity(0.2),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(7.sp),
                                          child: LinearProgressIndicator(
                                            value: 0.65,
                                            backgroundColor: Colors.transparent,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Colors.lightBlue.shade300, // Light blue color
                                            ),
                                            minHeight: 10.sp,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 1.h),
                                      // Percentage text - centered below bar
                                      Text(
                                        '65% TO NEXT UPGRADE',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.white, // White color
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4.h),
                          // Action Buttons - matching screenshot layout and icons
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildCircularActionButton(
                                  Icons.castle,
                                  'VIEW CASTLE',
                                  () {},
                                ),
                                _buildCircularActionButton(
                                  Icons.card_giftcard,
                                  'REWARDS',
                                  () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.treasureChest,
                                    );
                                  },
                                ),
                                _buildCircularActionButton(
                                  Icons.emoji_events,
                                  'LEADERBOARD',
                                  () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.leaderboard,
                                    );
                                  },
                                ),
                                _buildCircularActionButton(
                                  Icons.access_time,
                                  'FOCUS',
                                  () {
                                    Navigator.pushNamed(context, AppRoutes.focusTime);
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 3.h),
                          // Start Focus Button - same size as GO TO BASE button
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Material(
                              color: Colors.lightBlue.shade300,
                              borderRadius: BorderRadius.circular(20.sp), // More rounded corners
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20.sp), // More rounded corners
                                onTap: () {
                                  Navigator.pushNamed(context, AppRoutes.focusTime);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                    vertical: 1.5.h,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color: Colors.white,
                                        size: 20.sp,
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        'START FOCUS',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
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

  Widget _buildCircularActionButton(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16.w,
            height: 16.w,
            decoration: BoxDecoration(
              color: AppColors.coinGold, // Yellow/gold color
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color.fromARGB(255, 255, 255, 255), // White icon
              size: 22.sp,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
