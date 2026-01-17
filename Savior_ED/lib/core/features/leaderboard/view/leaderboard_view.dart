import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:provider/provider.dart';
import '../../../consts/app_colors.dart';
import '../viewmodels/leaderboard_viewmodel.dart';
import '../../castle_grounds/viewmodels/castle_grounds_viewmodel.dart';
import '../../base_building/view/base_building_view.dart';
import '../../base_building/viewmodels/base_building_viewmodel.dart';

/// Leaderboard View - Kingdom Rankings
class LeaderboardView extends StatefulWidget {
  const LeaderboardView({super.key});

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaderboardViewModel>().getGlobalLeaderboard();
      // Also refresh common resources
      context.read<CastleGroundsViewModel>().getMyCastle();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LeaderboardViewModel>();
    final castleViewModel = context.watch<CastleGroundsViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF9DB89D), // Sage green background
      appBar: AppBar(
        backgroundColor: const Color(0xFF8BA88B),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 22.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'KINGDOM RANKINGS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white, size: 20.sp),
            onPressed: () => viewModel.getGlobalLeaderboard(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Resource bar (Live Data)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
            decoration: BoxDecoration(
              color: const Color(0xFF8BA88B),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildResourceChip(
                  Icons.monetization_on,
                  '${castleViewModel.castle?.coins ?? 0} COINS',
                  AppColors.coinGold,
                ),
                SizedBox(width: 4.w),
                _buildResourceChip(
                  Icons.construction,
                  '${castleViewModel.castle?.stones ?? 0} STONES',
                  AppColors.stoneGray,
                ),
                SizedBox(width: 4.w),
                _buildResourceChip(
                  Icons.forest,
                  '${castleViewModel.castle?.wood ?? 0} WOOD',
                  AppColors.woodBrown,
                ),
              ],
            ),
          ),

          // Navigation Info
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            color: const Color(0xFF8BA88B).withValues(alpha: 0.9),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppColors.coinGold.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(25.sp),
                    border: Border.all(color: AppColors.coinGold, width: 1.5),
                  ),
                  child: Text(
                    'GLOBAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'LIVE RANKINGS',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 1.5.w),
                Icon(Icons.flash_on, color: AppColors.coinGold, size: 14.sp),
              ],
            ),
          ),

          // Content
          Expanded(
            child: viewModel.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : viewModel.errorMessage != null
                ? Center(
                    child: Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => viewModel.getGlobalLeaderboard(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          SizedBox(height: 2.h),

                          // Castle image
                          Center(
                            child: Image.asset(
                              'assets/images/leadboard_castle.png',
                              width: 90.w,
                              height: 22.h,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.castle,
                                size: 60.sp,
                                color: Colors.white24,
                              ),
                            ),
                          ),

                          SizedBox(height: 2.h),

                          // TOP 10 Banner
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF1E88E5),
                                  const Color(0xFF42A5F5),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shield,
                                  color: AppColors.coinGold,
                                  size: 22.sp,
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  'TOP 10 GUARDIANS',
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Icon(
                                  Icons.shield,
                                  color: AppColors.coinGold,
                                  size: 22.sp,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 2.h),

                          // Dynamic Rankings List
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: viewModel.globalEntries.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: 1.5.h),
                              itemBuilder: (context, index) {
                                final item = viewModel.globalEntries[index];

                                // Map color logic
                                Color shieldColor;
                                if (item.rank == 1) {
                                  shieldColor = AppColors.coinGold;
                                } else if (item.rank == 2) {
                                  shieldColor = const Color(0xFFC0C0C0);
                                } else if (item.rank == 3) {
                                  shieldColor = const Color(0xFFCD7F32);
                                } else {
                                  shieldColor = Colors.grey[400]!;
                                }

                                return _buildRankingItem(
                                  rank: item.rank,
                                  name: item.name,
                                  level: item.level,
                                  coins: item.coins ?? 0,
                                  shieldColor: shieldColor,
                                  castleColor: _getCastleColor(item.rank),
                                  avatar: item.avatar,
                                  progress: item.progressHours,
                                  progressMax: item.progressMaxHours,
                                  buttonText: item.buttonText,
                                  buttonType: item.buttonType,
                                  userId: item.userId,
                                );
                              },
                            ),
                          ),

                          SizedBox(height: 4.h),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Color _getCastleColor(int rank) {
    if (rank == 1) return AppColors.coinGold;
    if (rank == 2) return const Color(0xFFB0BEC5);
    return AppColors.stoneGray;
  }

  Widget _buildResourceChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.sp),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16.sp),
          SizedBox(width: 1.5.w),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingItem({
    required int rank,
    required String name,
    required String level,
    required int coins,
    required Color shieldColor,
    required Color castleColor,
    String? avatar,
    double? progress,
    double? progressMax,
    String? buttonText,
    String? buttonType,
    required String userId,
  }) {
    return GestureDetector(
      onTap: () async {
        final bbViewModel = context.read<BaseBuildingViewModel>();
        await bbViewModel.fetchVisitorBase(userId, name);
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BaseBuildingView()),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(15.sp),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Rank shield
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.shield, color: shieldColor, size: 38.sp),
                if (rank <= 3)
                  Positioned(
                    top: -2.sp,
                    child: Icon(
                      Icons.workspace_premium,
                      color: Colors.white38,
                      size: 14.sp,
                    ),
                  ),
                Text(
                  '$rank',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),

            SizedBox(width: 4.w),

            // Avatar (from live data)
            CircleAvatar(
              radius: 18.sp,
              backgroundColor: castleColor.withValues(alpha: 0.2),
              backgroundImage: avatar != null ? NetworkImage(avatar) : null,
              child: avatar == null
                  ? Icon(Icons.castle, color: castleColor, size: 20.sp)
                  : null,
            ),

            SizedBox(width: 4.w),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  Text(
                    level,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (progress != null &&
                      progressMax != null &&
                      progressMax > 0) ...[
                    SizedBox(height: 0.8.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (progress / progressMax).clamp(0.0, 1.0),
                        minHeight: 1.h,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: AppColors.coinGold,
                      size: 16.sp,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '$coins',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF388E3C),
                      ),
                    ),
                  ],
                ),
                Text(
                  'COINS',
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black26,
                    letterSpacing: 0.5,
                  ),
                ),
                if (buttonText != null) ...[
                  SizedBox(height: 0.8.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: buttonType == 'claim_reward'
                          ? AppColors.warning
                          : AppColors.secondary,
                      borderRadius: BorderRadius.circular(15.sp),
                    ),
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
