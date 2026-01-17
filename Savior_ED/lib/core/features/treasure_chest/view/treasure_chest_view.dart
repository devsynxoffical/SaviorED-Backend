import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:provider/provider.dart';
import '../../../consts/app_colors.dart';
import '../../../consts/app_sizes.dart';
import '../viewmodels/treasure_chest_viewmodel.dart';
import '../models/treasure_chest_model.dart';
import '../../castle_grounds/viewmodels/castle_grounds_viewmodel.dart';

/// Treasure Chest View - Matching design with treasure image
class TreasureChestView extends StatefulWidget {
  const TreasureChestView({super.key});

  @override
  State<TreasureChestView> createState() => _TreasureChestViewState();
}

class _TreasureChestViewState extends State<TreasureChestView> {
  @override
  void initState() {
    super.initState();
    // Load treasure chest data when view opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTreasureChest();
    });
  }

  void _loadTreasureChest() {
    final treasureChestViewModel = Provider.of<TreasureChestViewModel>(
      context,
      listen: false,
    );
    final castleViewModel = Provider.of<CastleGroundsViewModel>(
      context,
      listen: false,
    );

    treasureChestViewModel.getMyChest().catchError((error) {
      print('❌ Failed to load treasure chest: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load treasure chest: ${error.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    castleViewModel.getMyCastle();
  }

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
                    return Container(color: const Color(0xFF1A1410));
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
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  Padding(
                    padding: EdgeInsets.only(right: 4.w),
                    child: Consumer<CastleGroundsViewModel>(
                      builder: (context, castleViewModel, child) {
                        final castle = castleViewModel.castle;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildResourceIcon(
                              Icons.monetization_on,
                              '${castle?.coins ?? 0}',
                              AppColors.coinGold,
                            ),
                            SizedBox(width: 2.w),
                            _buildResourceIcon(
                              Icons.construction,
                              '${castle?.stones ?? 0}',
                              AppColors.stoneGray,
                            ),
                            SizedBox(width: 2.w),
                            _buildResourceIcon(
                              Icons.forest,
                              '${castle?.wood ?? 0}',
                              AppColors.woodBrown,
                            ),
                            SizedBox(width: 2.w),
                            IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                final treasureChestViewModel =
                                    Provider.of<TreasureChestViewModel>(
                                      context,
                                      listen: false,
                                    );
                                treasureChestViewModel.refresh();
                                castleViewModel.getMyCastle();
                              },
                              tooltip: 'Refresh',
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
              // Body content
              Expanded(
                child: SafeArea(
                  child: Consumer<TreasureChestViewModel>(
                    builder: (context, treasureChestViewModel, child) {
                      final chest = treasureChestViewModel.treasureChest;

                      // Show loading only if actually loading and no error
                      if (treasureChestViewModel.isLoading &&
                          treasureChestViewModel.errorMessage == null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Loading treasure chest...',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (treasureChestViewModel.errorMessage != null) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(4.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red.shade300,
                                  size: 48.sp,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Error Loading Treasure Chest',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  treasureChestViewModel.errorMessage ??
                                      'Unknown error',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14.sp,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 3.h),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    treasureChestViewModel.getMyChest();
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry'),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4.w,
                                      vertical: 1.5.h,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (chest == null) {
                        return const Center(
                          child: Text(
                            'No treasure chest data available.',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 2.h,
                        ),
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
                              chest.isUnlocked
                                  ? chest.isClaimed
                                        ? 'Rewards claimed! Complete more sessions to unlock new rewards.'
                                        : 'Treasure chest unlocked! Claim your rewards.'
                                  : '${chest.progressPercentage.toStringAsFixed(0)}% complete to unlock a new treasure chest!',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 1.h),
                            // Progress bar with diamond marker
                            _buildProgressBar(chest.progressPercentage),
                            SizedBox(height: 41.h),
                            // Claim reward button
                            if (chest.isUnlocked && !chest.isClaimed)
                              Container(
                                width: double.infinity,
                                height: AppSizes.buttonHeightMedium,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFD54F),
                                      Color(0xFFFFC107),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(50.sp),
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
                                    onTap: () async {
                                      final success =
                                          await treasureChestViewModel
                                              .claimRewards();
                                      if (success) {
                                        // Refresh castle resources immediately
                                        Provider.of<CastleGroundsViewModel>(
                                          context,
                                          listen: false,
                                        ).getMyCastle();
                                      }
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              success
                                                  ? 'Rewards claimed successfully!'
                                                  : treasureChestViewModel
                                                            .errorMessage ??
                                                        'Failed to claim rewards',
                                            ),
                                            backgroundColor: success
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        );
                                      }
                                    },
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
                            if (chest.isUnlocked && chest.isClaimed)
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(50.sp),
                                  border: Border.all(
                                    color: Colors.green,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        'REWARDS CLAIMED',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (!chest.isUnlocked)
                              SizedBox(height: AppSizes.buttonHeightMedium),
                            SizedBox(height: 1.h),
                            SizedBox(height: 4.h),
                            // Virtual rewards section
                            _buildRewardsSection(chest.rewards),
                            SizedBox(height: 3.h),
                          ],
                        ),
                      );
                    },
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
        Icon(icon, color: color, size: 20.sp),
        SizedBox(width: 1.w),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double progressPercentage) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final progressBarWidth = constraints.maxWidth - (8.w);
        final progressValue = (progressPercentage / 100).clamp(0.0, 1.0);
        final markerPosition = (progressBarWidth * progressValue) - 8.sp;

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
                    value: progressValue,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.warning, // Gold color
                    ),
                  ),
                ),
              ),
              // Diamond marker
              Positioned(
                left: markerPosition.clamp(0.0, progressBarWidth - 16.sp),
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

  Widget _buildRewardsSection(List<RewardBadgeModel> rewards) {
    if (rewards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: Text(
            'VIRTUAL REWARDS',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(height: 3.h),
        Wrap(
          alignment: WrapAlignment.spaceEvenly,
          spacing: 4.w,
          runSpacing: 2.h,
          children: rewards.map((reward) => _buildRewardBadge(reward)).toList(),
        ),
      ],
    );
  }

  Widget _buildRewardBadge(RewardBadgeModel reward) {
    // Parse color from hex
    Color badgeColor;
    try {
      badgeColor = Color(int.parse(reward.colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      badgeColor = const Color(0xFF3b82f6); // Default blue
    }

    // Map iconName to Flutter icons
    IconData icon = _getIconForName(reward.iconName);

    return Column(
      children: [
        Container(
          width: 13.w,
          height: 13.w,
          decoration: BoxDecoration(
            color: reward.isUnlocked ? badgeColor : badgeColor.withOpacity(0.3),
            shape: BoxShape.circle,
            border: reward.isUnlocked
                ? null
                : Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            boxShadow: reward.isUnlocked
                ? [
                    BoxShadow(
                      color: badgeColor.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            color: reward.isUnlocked
                ? Colors.white
                : Colors.white.withOpacity(0.5),
            size: 24.sp,
          ),
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
              color: reward.isUnlocked
                  ? Colors.white
                  : Colors.white.withOpacity(0.6),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (reward.isUnlocked && reward.unlockedAt != null)
          Padding(
            padding: EdgeInsets.only(top: 0.5.h),
            child: Text(
              'Unlocked',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  /// Map iconName from backend to Flutter IconData
  IconData _getIconForName(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'focus':
        return Icons.access_time;
      case 'learner':
        return Icons.school;
      case 'castle':
        return Icons.castle;
      case 'fire':
      case 'streak':
        return Icons.local_fire_department;
      case 'shield':
        return Icons.shield;
      case 'star':
      case 'hero':
        return Icons.star;
      case 'trophy':
        return Icons.emoji_events;
      case 'medal':
        return Icons.military_tech;
      default:
        return Icons.star; // Default icon
    }
  }
}
