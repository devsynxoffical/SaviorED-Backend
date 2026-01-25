import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:provider/provider.dart';
import '../../../consts/app_colors.dart';
import '../../../consts/app_consts.dart';
import '../viewmodels/treasure_chest_viewmodel.dart';
import '../../castle_grounds/viewmodels/castle_grounds_viewmodel.dart';
import '../../authentication/viewmodels/auth_viewmodel.dart';
import '../../profile/viewmodels/profile_viewmodel.dart';
import '../models/treasure_chest_model.dart';

/// Treasure Chest View - Redesigned to match the premium 3D dungeon look
class TreasureChestView extends StatefulWidget {
  const TreasureChestView({super.key});

  @override
  State<TreasureChestView> createState() => _TreasureChestViewState();
}

class _TreasureChestViewState extends State<TreasureChestView>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _shakeController;
  late AnimationController _openController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _openController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 30),
          TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 70),
        ]).animate(
          CurvedAnimation(parent: _openController, curve: Curves.easeInOut),
        );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _openController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Initial data load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    Provider.of<TreasureChestViewModel>(context, listen: false).getMyChest();
    Provider.of<CastleGroundsViewModel>(context, listen: false).getMyCastle();
    Provider.of<ProfileViewModel>(context, listen: false).loadProfile();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _shakeController.dispose();
    _openController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image - Dungeon Room
          Positioned.fill(
            child: Image.asset(
              'assets/images/treasure_room_background.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1B1B1B), Color(0xFF0A0A0A)],
                  ),
                ),
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                _buildTopBar(),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 2.h),
                        // Title Section
                        _buildTitleSection(),

                        SizedBox(height: 3.h),
                        // Chest Section
                        _buildChestSection(),

                        SizedBox(height: 4.h),
                        // Action Buttons
                        _buildActionButtons(),

                        SizedBox(height: 4.h),
                        // Virtual Rewards (Core Achievements)
                        Consumer<TreasureChestViewModel>(
                          builder: (context, viewModel, _) {
                            return _buildRewardsSection(
                              title: 'ACHIEVEMENTS & BADGES',
                              viewModel: viewModel,
                            );
                          },
                        ),

                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Consumer<CastleGroundsViewModel>(
      builder: (context, viewModel, _) {
        final castle = viewModel.castle;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              // Coins
              _buildCurrencyChip(
                icon: Icons.monetization_on,
                color: Colors.amber,
                value: '${castle?.coins ?? 0}',
              ),
              SizedBox(width: 2.w),
              // Stones
              _buildCurrencyChip(
                icon: Icons.hexagon,
                color: Colors.grey,
                value: '${castle?.stones ?? 0}',
              ),
              SizedBox(width: 2.w),
              // Wood
              _buildCurrencyChip(
                icon: Icons.forest,
                color: Colors.brown,
                value: '${castle?.wood ?? 0}',
              ),
              const Spacer(),
              // Avatar
              _buildTopAvatar(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrencyChip({
    required IconData icon,
    required Color color,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.6.h),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16.sp),
          SizedBox(width: 1.w),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAvatar() {
    return Consumer<AuthViewModel>(
      builder: (context, auth, _) {
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white54, width: 1.5),
            image: auth.user?.avatar != null
                ? DecorationImage(
                    image: NetworkImage(auth.user!.avatar!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: auth.user?.avatar == null
              ? const Icon(Icons.person, size: 18, color: Colors.white)
              : null,
        );
      },
    );
  }

  Widget _buildTitleSection() {
    return Consumer<TreasureChestViewModel>(
      builder: (context, viewModel, _) {
        final progressPerc = viewModel.treasureChest?.progressPercentage ?? 0.0;
        final unlockMinutes = viewModel.treasureChest?.unlockMinutes ?? 60;
        final minutesInCurrentCycle =
            viewModel.treasureChest?.minutesInCurrentCycle ?? 0;

        return Column(
          children: [
            Text(
              'TREASURE CHEST',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'PROGRESS: ${progressPerc.toInt()}%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              '$minutesInCurrentCycle / $unlockMinutes Minutes Focused',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Reach 100% to unlock your next Treasure Chest!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 13.sp),
            ),
            SizedBox(height: 2.h),
            // Progress Bar with Diamond
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Stack(
                alignment: Alignment.centerLeft,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: (progressPerc / 100).clamp(0.01, 1.0),
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE99D3C), Color(0xFFFFD54F)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Diamond Indicator
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double maxWidth = constraints.maxWidth;
                      // Ensure the diamond stays within the bar bounds
                      final double position = (progressPerc / 100 * maxWidth);

                      return Positioned(
                        left:
                            position.clamp(0, maxWidth) -
                            7, // Precise center adjustment
                        child: Transform.rotate(
                          angle: math.pi / 4,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFD54F),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber,
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChestSection() {
    return Consumer<TreasureChestViewModel>(
      builder: (context, viewModel, _) {
        final progress =
            (viewModel.treasureChest?.progressPercentage ?? 0) / 100;
        final isUnlocked = progress >= 1.0;

        return AnimatedBuilder(
          animation: Listenable.merge([
            _floatingController,
            _shakeController,
            _openController,
          ]),
          builder: (context, child) {
            final floatY =
                math.sin(_floatingController.value * 2 * math.pi) * 15;
            final shakeX = math.sin(_shakeController.value * 10 * math.pi) * 5;

            return Transform.translate(
              offset: Offset(shakeX, floatY),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow behind chest
                    Opacity(
                      opacity: 0.6 + (0.4 * _glowAnimation.value),
                      child: Container(
                        width: 60.w,
                        height: 60.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: isUnlocked
                                  ? Colors.amber.withOpacity(0.4)
                                  : Colors.blue.withOpacity(0.2),
                              blurRadius: 60,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Chest Image
                    GestureDetector(
                      onTap: () {
                        if (isUnlocked && !viewModel.treasureChest!.isClaimed) {
                          _handleClaim(context, viewModel);
                        } else if (!isUnlocked) {
                          _shakeController.forward(from: 0.0);
                        }
                      },
                      child: Image.asset(
                        (viewModel.treasureChest?.isClaimed ?? false)
                            ? 'assets/images/treasure_chest_open.png'
                            : 'assets/images/treasure_chest_closed.png',
                        width: 75.w,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.card_giftcard,
                          size: 50.w,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Consumer<TreasureChestViewModel>(
      builder: (context, viewModel, _) {
        final isUnlocked =
            (viewModel.treasureChest?.progressPercentage ?? 0) >= 100;
        final isClaimed = viewModel.treasureChest?.isClaimed ?? false;

        if (isClaimed) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              'CHEST CLAIMED! COME BACK SOON',
              style: TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          );
        }

        return Column(
          children: [
            // Gold Claim Button
            GestureDetector(
              onTap: isUnlocked
                  ? () => _handleClaim(context, viewModel)
                  : () => _shakeController.forward(from: 0.0),
              child: Container(
                width: 75.w,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  gradient: isUnlocked
                      ? const LinearGradient(
                          colors: [Color(0xFFFACB6B), Color(0xFFD4922D)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : const LinearGradient(
                          colors: [Colors.grey, Color(0xFF424242)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    isUnlocked ? 'CLAIM MY REWARD' : 'LOCKED',
                    style: TextStyle(
                      color: isUnlocked
                          ? const Color(0xFF4E342E)
                          : Colors.white38,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleClaim(BuildContext context, TreasureChestViewModel viewModel) {
    _openController.forward(from: 0.0).then((_) {
      viewModel.claimRewards().then((success) {
        if (success) {
          Provider.of<CastleGroundsViewModel>(
            context,
            listen: false,
          ).getMyCastle();
          _showRewardDialog(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                viewModel.errorMessage ?? "Failed to claim rewards",
              ),
            ),
          );
        }
      });
    });
  }

  void _showRewardDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B1B1B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.amber, width: 2),
        ),
        title: const Text(
          'REWARDS CLAIMED!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars, color: Colors.amber, size: 64),
            const SizedBox(height: 20),
            const Text(
              'You have received:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _rewardItem(Icons.monetization_on, 'Coins', Colors.amber),
                const SizedBox(width: 15),
                _rewardItem(Icons.forest, 'Wood', Colors.brown),
                const SizedBox(width: 15),
                _rewardItem(Icons.hexagon, 'Stone', Colors.grey),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'AWESOME!',
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rewardItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildRewardsSection({
    required String title,
    required TreasureChestViewModel viewModel,
  }) {
    final List<Map<String, dynamic>> defaultBadges = [
      {'title': 'Study Champion', 'icon': Icons.emoji_events},
      {'title': '7-Day Streak', 'icon': Icons.electric_bolt},
      {'title': 'Focus Hero', 'icon': Icons.shield},
      {'title': 'Mastermind', 'icon': Icons.military_tech},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        SizedBox(height: 1.5.h),
        SizedBox(
          height: 15.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            itemCount: defaultBadges.length,
            itemBuilder: (context, index) {
              final badge = defaultBadges[index];
              return _buildVirtualRewardItem(
                badge['title'] as String,
                badge['icon'] as IconData,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVirtualRewardItem(String title, IconData icon) {
    return Container(
      width: 21.w,
      margin: EdgeInsets.only(right: 2.w),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [
                  Color(0xFFFFD54F),
                  Color(0xFFE99D3C),
                ], // Premium Golden gradient
              ),
              border: Border.all(color: Colors.amber, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 22.sp, // Reduced icon size to fit all 4
              color: const Color(0xFF5D4037),
            ),
          ),
          SizedBox(height: 0.8.h),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.5.sp, // Reduced font size to fit all 4
              fontWeight: FontWeight.bold,
              shadows: const [
                Shadow(
                  color: Colors.black,
                  blurRadius: 2,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
