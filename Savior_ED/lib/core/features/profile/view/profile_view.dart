import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:provider/provider.dart';
import '../../../widgets/gradient_background.dart';
import '../../../routes/app_routes.dart';
import '../../authentication/viewmodels/auth_viewmodel.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../../settings/viewmodels/settings_viewmodel.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load profile data when view opens
    _loadProfileData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when view becomes visible (after navigating back)
    _loadProfileData();
  }

  void _loadProfileData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileViewModel = Provider.of<ProfileViewModel>(
        context,
        listen: false,
      );
      profileViewModel.loadProfile().then((_) {
        // Update name controller with loaded data
        if (profileViewModel.name != null && mounted) {
          _nameController.text = profileViewModel.name!;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProfileViewModel, SettingsViewModel>(
      builder: (context, profileViewModel, settingsViewModel, child) {
        List<Color> gradientColors;
        if (settingsViewModel.darkTheme) {
          gradientColors = const [Color(0xFF121212), Color(0xFF2C3E50)];
        } else {
          switch (settingsViewModel.colorScheme) {
            case 'blue':
              gradientColors = [Colors.blue.shade200, Colors.blue.shade50];
              break;
            case 'purple':
              gradientColors = [Colors.purple.shade200, Colors.purple.shade50];
              break;
            case 'green':
            default:
              gradientColors = const [Color(0xFFA5D6A7), Color(0xFFE3F2FD)];
          }
        }

        return GradientBackground(
          colors: gradientColors,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: settingsViewModel.darkTheme
                                ? Colors.white
                                : Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          'Profile',
                          style: TextStyle(
                            color: settingsViewModel.darkTheme
                                ? Colors.white
                                : Theme.of(context).primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.refresh,
                            color: settingsViewModel.darkTheme
                                ? Colors.white
                                : Colors.white,
                          ),
                          onPressed: () async {
                            await profileViewModel.refresh();
                            if (mounted && profileViewModel.name != null) {
                              _nameController.text = profileViewModel.name!;
                            }
                          },
                          tooltip: 'Refresh Profile',
                        ),
                      ],
                    ),
                  ),

                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Profile Header Section
                          Padding(
                            padding: EdgeInsets.all(4.w),
                            child: _buildProfileHeader(profileViewModel),
                          ),

                          // Stats Section
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: _buildStatsSection(profileViewModel),
                          ),

                          SizedBox(height: 2.h),

                          // Level & XP Progress Section
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: _buildLevelProgressSection(profileViewModel),
                          ),

                          SizedBox(height: 2.h),

                          // Profile Edit Section
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: _buildProfileEditSection(profileViewModel),
                          ),

                          SizedBox(height: 2.h),

                          // Settings Section
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: _buildSettingsSection(settingsViewModel),
                          ),

                          SizedBox(height: 3.h),

                          // LOGOUT BUTTON
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                            child: Material(
                              color: Colors.red.shade600,
                              borderRadius: BorderRadius.circular(100),
                              elevation: 2,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(100),
                                onTap: () async {
                                  final authViewModel =
                                      Provider.of<AuthViewModel>(
                                        context,
                                        listen: false,
                                      );
                                  await authViewModel.logout();
                                  if (mounted) {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      AppRoutes.welcome,
                                      (route) => false,
                                    );
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 1.5.h,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Log Out',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 3.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static const List<String> _predefinedAvatars = [
    'assets/images/avatars/avatar_king.png',
    'assets/images/avatars/avatar_knight.png',
    'assets/images/avatars/avatar_wizard.png',
    'assets/images/avatars/avatar_queen.png',
    'assets/images/avatars/avatar_archer.png',
    'assets/images/avatars/avatar_viking.png',
  ];

  void _showAvatarPicker(ProfileViewModel profileViewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 5.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handlebar
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Customize Your Hero',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'MAJESTIC HEROES',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey.withOpacity(0.8),
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 2.h),

              SizedBox(
                height: 24.h,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                  ),
                  itemCount: _predefinedAvatars.length,
                  itemBuilder: (context, index) {
                    final avatarUrl = _predefinedAvatars[index];
                    final isSelected = profileViewModel.avatar == avatarUrl;
                    return GestureDetector(
                      onTap: () async {
                        // Optimistic Update: Set immediately for instant feel
                        await profileViewModel.updateProfile(avatar: avatarUrl);
                        if (mounted) Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(isSelected ? 2 : 0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.amber.shade400
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.amber.withOpacity(0.3),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade100,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _buildAvatarImage(avatarUrl),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatarImage(String? url, {double? size}) {
    if (url == null || url.isEmpty) {
      return Icon(
        Icons.person_rounded,
        size: size != null ? size * 0.6 : 32.sp,
        color: Colors.grey.shade400,
      );
    }

    // Since we now only use local assets for avatars
    return Image.asset(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ Failed to load avatar asset: $url');
        // Fallback to a default king avatar if specific asset fails
        return Image.asset(
          'assets/images/avatars/avatar_king.png',
          fit: BoxFit.cover,
        );
      },
    );
  }

  /// Build profile header with avatar, name, email
  Widget _buildProfileHeader(ProfileViewModel profileViewModel) {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(24.sp),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.8),
            Colors.white.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.blue.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showAvatarPicker(profileViewModel),
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.lightBlueAccent.shade200,
                        Colors.purpleAccent.shade200,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Container(
                    width: 60.sp,
                    height: 60.sp,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildAvatarImage(
                      profileViewModel.avatar,
                      size: 60.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profileViewModel.name ?? 'Guardian',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.2.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    profileViewModel.email ?? '',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w600,
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

  /// Build stats section (Focus Hours, Sessions, Coins)
  Widget _buildStatsSection(ProfileViewModel profileViewModel) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(20.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: Theme.of(context).primaryColor,
                size: 20.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                'Statistics',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  Icons.access_time,
                  'Focus Time',
                  _formatFocusTime(profileViewModel.totalFocusHours),
                  Colors.blue,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildStatItem(
                  Icons.check_circle,
                  'Sessions',
                  '${profileViewModel.completedSessions}/${profileViewModel.totalSessions}',
                  Colors.green,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildStatItem(
                  Icons.monetization_on,
                  'Coins',
                  '${profileViewModel.totalCoins}',
                  Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 1.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build level progress section with XP bar
  Widget _buildLevelProgressSection(ProfileViewModel profileViewModel) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(20.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.stars,
                color: Theme.of(context).primaryColor,
                size: 20.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                'Level & Progress',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level ${profileViewModel.level}',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${profileViewModel.experiencePoints} XP',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Next: Level ${profileViewModel.level + 1}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${profileViewModel.xpNeededForNextLevel} XP needed',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // XP Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: profileViewModel.levelProgress,
                  minHeight: 20.sp,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.lightBlue.shade300,
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                '${profileViewModel.levelProgressPercent} to Level ${profileViewModel.level + 1}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build profile edit section
  Widget _buildProfileEditSection(ProfileViewModel profileViewModel) {
    return _buildSettingsCard(
      title: 'Edit Profile',
      icon: Icons.edit,
      child: Column(
        children: [
          _buildRoundedTextField(
            controller: _nameController,
            hintText: 'Name',
            icon: Icons.person,
          ),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final success = await profileViewModel.updateProfile(
                  name: _nameController.text.trim().isNotEmpty
                      ? _nameController.text.trim()
                      : null,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Profile updated successfully'
                            : profileViewModel.errorMessage ??
                                  'Failed to update profile',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build settings section
  Widget _buildSettingsSection(SettingsViewModel settingsViewModel) {
    return Column(
      children: [
        _buildSettingsCard(
          title: 'Appearance & Settings',
          icon: Icons.settings,
          child: Column(
            children: [
              _buildToggleItem(
                'Light Mode',
                settingsViewModel.darkTheme,
                (val) => settingsViewModel.setDarkTheme(val),
                icon: Icons.light_mode,
              ),
              SizedBox(height: 1.h),
              _buildColorSchemeItem(settingsViewModel),
            ],
          ),
        ),
      ],
    );
  }

  // TEXT FIELD UI
  Widget _buildRoundedTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
          filled: true,
          fillColor: Colors.white, // Same as container background
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // SETTINGS CARD
  Widget _buildSettingsCard({
    required String title,
    IconData? icon,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(20.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null)
                Icon(icon, color: Theme.of(context).primaryColor, size: 20.sp),
              if (icon != null) SizedBox(width: 2.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          child,
        ],
      ),
    );
  }

  // SWITCH ITEM
  Widget _buildToggleItem(
    String label,
    bool value,
    ValueChanged<bool> onChanged, {
    IconData? icon,
  }) {
    return Row(
      children: [
        if (icon != null) Icon(icon, color: Colors.grey.shade700, size: 20.sp),
        if (icon != null) SizedBox(width: 3.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF4CAF50),
        ),
      ],
    );
  }

  // COLOR SCHEME
  Widget _buildColorSchemeItem(SettingsViewModel settingsViewModel) {
    return Row(
      children: [
        Icon(Icons.dark_mode, color: Colors.grey.shade700, size: 20.sp),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            'Color Scheme',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
          ),
        ),
        Row(
          children: [
            _buildColorSwatch(
              const Color(0xFF2196F3),
              settingsViewModel.colorScheme == 'blue',
              () => settingsViewModel.setScheme('blue'),
            ),
            SizedBox(width: 2.w),
            _buildColorSwatch(
              const Color(0xFF81C784),
              settingsViewModel.colorScheme == 'green',
              () => settingsViewModel.setScheme('green'),
            ),
            SizedBox(width: 2.w),
            _buildColorSwatch(
              Colors.purple,
              settingsViewModel.colorScheme == 'purple',
              () => settingsViewModel.setScheme('purple'),
            ),
          ],
        ),
      ],
    );
  }

  // COLOR SWATCH
  Widget _buildColorSwatch(Color color, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 24.sp,
        height: 24.sp,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  /// Format focus time from hours to readable format (e.g., "2h 30m" or "150m")
  String _formatFocusTime(double hours) {
    if (hours < 0.1) {
      // Less than 6 minutes, show in minutes
      final minutes = (hours * 60).round();
      return '${minutes}m';
    } else if (hours < 1.0) {
      // Less than 1 hour, show in minutes
      final minutes = (hours * 60).round();
      return '${minutes}m';
    } else {
      // 1 hour or more, show hours and minutes
      final totalHours = hours.floor();
      final minutes = ((hours - totalHours) * 60).round();
      if (minutes == 0) {
        return '${totalHours}h';
      } else {
        return '${totalHours}h ${minutes}m';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
