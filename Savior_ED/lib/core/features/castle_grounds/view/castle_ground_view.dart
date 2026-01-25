import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../consts/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../authentication/viewmodels/auth_viewmodel.dart';
import '../viewmodels/castle_grounds_viewmodel.dart';
import '../../profile/viewmodels/profile_viewmodel.dart';
import '../../settings/viewmodels/settings_viewmodel.dart';

class CastleGroundsView extends StatefulWidget {
  const CastleGroundsView({super.key});

  @override
  State<CastleGroundsView> createState() => _CastleGroundsViewState();
}

class _CastleGroundsViewState extends State<CastleGroundsView>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    // Safety Lock: Ensure the game is in Portrait Mode when here
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // Load data when view opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final castleViewModel = Provider.of<CastleGroundsViewModel>(
        context,
        listen: false,
      );
      final profileViewModel = Provider.of<ProfileViewModel>(
        context,
        listen: false,
      );
      castleViewModel.getMyCastle();
      profileViewModel.loadProfile();
    });

    // Initialize floating animation controller
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

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
                return Container(color: const Color(0xFFA6B57E));
              },
            ),
          ),
          // 2. Main content
          Scaffold(
            backgroundColor: Colors.transparent,
            drawer: _buildDrawer(context),
            appBar: AppBar(
              backgroundColor: const Color(
                0xFF95A56D,
              ), // Slightly darker version for contrast
              elevation: 0,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu, color: Colors.white, size: 24.sp),
                  onPressed: () {
                    // Open drawer menu
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
              title: const Text(
                'CASTLE GROUNDS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              centerTitle: true,
              actions: [
                Consumer<AuthViewModel>(
                  builder: (context, authViewModel, child) {
                    final user = authViewModel.user;
                    return IconButton(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: user?.avatar != null
                            ? Image.network(
                                user!.avatar!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    color: Color(0xFFA6B57E),
                                    size: 18,
                                  );
                                },
                              )
                            : const Icon(
                                Icons.person,
                                color: Color(0xFFA6B57E),
                                size: 18,
                              ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.profile);
                      },
                    );
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // Resource Bar
                  Consumer<CastleGroundsViewModel>(
                    builder: (context, castleViewModel, child) {
                      final castle = castleViewModel.castle;
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                        color: const Color(0xFFA6B57E), // Match AppBar color
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8.w,
                          runSpacing: 2.h,
                          children: [
                            _buildResourceChip(
                              Icons.monetization_on,
                              '${castle?.coins ?? 0} COINS',
                              AppColors.coinGold,
                            ),
                            _buildResourceChip(
                              Icons.construction,
                              '${castle?.stones ?? 0} STONES',
                              AppColors.stoneGray,
                            ),
                            _buildResourceChip(
                              Icons.forest,
                              '${castle?.wood ?? 0} WOOD',
                              AppColors.woodBrown,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
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
                          Consumer2<CastleGroundsViewModel, ProfileViewModel>(
                            builder: (context, castleViewModel, profileViewModel, child) {
                              final castle = castleViewModel.castle;
                              final progress =
                                  (castle?.progressPercentage ?? 0.0) / 100.0;
                              final level = castle?.level ?? 1;
                              final nextLevel = castle?.nextLevel ?? level + 1;

                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'LEVEL $level', // simplified to avoid duplication
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
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 2.w,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Progress bar
                                          Container(
                                            height: 10
                                                .sp, // Same height as timer progress bar
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    7.sp,
                                                  ), // Same border radius
                                              color: AppColors.textDisabled
                                                  .withOpacity(0.2),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(7.sp),
                                              child: LinearProgressIndicator(
                                                value: progress.clamp(0.0, 1.0),
                                                backgroundColor:
                                                    Colors.transparent,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(
                                                      Colors
                                                          .lightBlue
                                                          .shade300, // Light blue color
                                                    ),
                                                minHeight: 10.sp,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 1.h),
                                          // Percentage text - centered below bar
                                          Text(
                                            '${(progress * 100).toStringAsFixed(0)}% TO LEVEL $nextLevel',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color:
                                                  Colors.white, // White color
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 4.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildCircularActionButton(
                                  label: 'BUILD BASE',
                                  imagePath: 'assets/images/house.png',
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.baseBuilding,
                                    );
                                  },
                                ),
                                _buildCircularActionButton(
                                  label: 'REWARDS',
                                  imagePath:
                                      'assets/images/treasure_chest_closed.png',
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.treasureChest,
                                    );
                                  },
                                ),
                                _buildCircularActionButton(
                                  label: 'LEADERBOARD',
                                  imagePath: 'assets/images/leaderboard.png',
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.leaderboard,
                                    );
                                  },
                                ),
                                _buildCircularActionButton(
                                  label: 'FOCUS',
                                  imagePath: 'assets/images/focus.png',
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.focusTime,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 3.h),
                          // Start Focus Button - same size as GO TO BASE button
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.sp),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFD700), // AppColors.coinGold
                                    Color(0xFFD4AF37), // Metallic Gold
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFFD700,
                                    ).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20.sp),
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.focusTime,
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4.w,
                                      vertical: 1.5.h,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.military_tech,
                                          color: Colors.white,
                                          size: 20.sp,
                                          shadows: const [
                                            Shadow(
                                              color: Colors.white54,
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 2.w),
                                        Text(
                                          'START FOCUS SESSION',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
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

  Widget _buildCircularActionButton({
    required String label,
    required VoidCallback onTap,
    String? imagePath,
    IconData? icon,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatingController.value * 6),
                child: child,
              );
            },
            child: Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: (iconColor ?? AppColors.coinGold).withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipOval(
                child: imagePath != null
                    ? Padding(
                        padding: EdgeInsets.all(3.w),
                        child: Image.asset(imagePath, fit: BoxFit.contain),
                      )
                    : Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              (iconColor ?? Colors.white).withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: iconColor ?? Colors.white,
                          size: 24.sp,
                          shadows: [
                            Shadow(
                              color: (iconColor ?? Colors.white).withOpacity(
                                0.5,
                              ),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
              shadows: const [
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

  Widget _buildDrawer(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, settingsViewModel, child) {
        final authViewModel = Provider.of<AuthViewModel>(
          context,
          listen: false,
        );
        final user = authViewModel.user;
        final isDark = settingsViewModel.darkTheme;

        return Drawer(
          backgroundColor: isDark
              ? const Color(0xFF1E1E1E)
              : const Color(0xFFA6B57E),
          child: SafeArea(
            child: Column(
              children: [
                // Drawer Header with User Info
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2C3E50)
                        : const Color(0xFF95A56D),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 60.sp,
                        height: 60.sp,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: user?.avatar != null
                            ? Image.network(
                                user!.avatar!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person,
                                    size: 30.sp,
                                    color: isDark
                                        ? const Color(0xFF2C3E50)
                                        : const Color(0xFFA6B57E),
                                  );
                                },
                              )
                            : Icon(
                                Icons.person,
                                size: 30.sp,
                                color: isDark
                                    ? const Color(0xFF2C3E50)
                                    : const Color(0xFFA6B57E),
                              ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        user?.name ?? 'User',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (user?.email != null) ...[
                        SizedBox(height: 0.5.h),
                        Text(
                          user!.email!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Menu Items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildDrawerItem(
                        context,
                        icon: Icons.home,
                        title: 'Castle Grounds',
                        onTap: () {
                          Navigator.pop(context);
                          // Already on castle grounds, do nothing
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.person,
                        title: 'Profile',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.profile);
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.access_time,
                        title: 'Focus Time',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.focusTime);
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.card_giftcard,
                        title: 'Treasure Chest',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.treasureChest);
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.emoji_events,
                        title: 'Leaderboard',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.leaderboard);
                        },
                      ),
                      Divider(
                        color: Colors.white.withOpacity(0.3),
                        height: 1,
                        thickness: 1,
                        indent: 4.w,
                        endIndent: 4.w,
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.settings,
                        title: 'Settings',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.profile);
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.logout,
                        title: 'Logout',
                        onTap: () async {
                          Navigator.pop(context);
                          await authViewModel.logout();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.welcome,
                              (route) => false,
                            );
                          }
                        },
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red.shade300 : Colors.white,
        size: 24.sp,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red.shade300 : Colors.white,
        ),
      ),
      onTap: onTap,
      hoverColor: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
