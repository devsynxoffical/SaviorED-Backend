import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:provider/provider.dart';
import '../../../widgets/gradient_background.dart';
import '../../../routes/app_routes.dart';
import '../../authentication/viewmodels/auth_viewmodel.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _pushNotifications = false;
  bool _emailNotifications = false;
  bool _lightMode = false;
  String _selectedLanguage = 'GMT+1';
  String _selectedColorScheme = 'blue';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      colors: const [Color(0xFFA5D6A7), Color(0xFFE3F2FD)],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        color: Color(0xFF1B5E20),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // Profile area
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.person, color: Colors.white, size: 40),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sarah.T',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1B5E20),
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color.fromARGB(255, 66, 125, 153),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 2.h),

                    _buildRoundedTextField(
                      controller: _emailController,
                      hintText: 'Change Email',
                      icon: Icons.person,
                    ),

                    SizedBox(height: 1.h),

                    _buildRoundedTextField(
                      controller: _passwordController,
                      hintText: 'Change Password',
                      icon: Icons.lock,
                      isPassword: true,
                    ),
                  ],
                ),
              ),

              // MAIN CONTENT
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    children: [
                      _buildSettingsCard(
                        title: 'Notification Settings',
                        icon: Icons.notifications,
                        child: Column(
                          children: [
                            _buildToggleItem(
                              'Push Notifications',
                              _pushNotifications,
                              (val) => setState(() => _pushNotifications = val),
                            ),
                            SizedBox(height: 1.h),
                            _buildToggleItem(
                              'Email Notifications',
                              _emailNotifications,
                              (val) => setState(() => _emailNotifications = val),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 1.5.h),

                      _buildSettingsCard(
                        title: 'Language & Region Settings',
                        icon: Icons.language,
                        child: Column(
                          children: [
                            _buildLanguageItem(
                              Icons.language,
                              'Language',
                              _selectedLanguage,
                              () {},
                            ),
                            SizedBox(height: 1.h),
                            _buildToggleItem(
                              'Light Mode',
                              _lightMode,
                              (val) => setState(() => _lightMode = val),
                              icon: Icons.light_mode,
                            ),
                            SizedBox(height: 1.h),
                            _buildColorSchemeItem(),
                          ],
                        ),
                      ),

                      SizedBox(height: 3.5.h),

                      // SAVE BUTTON (REDUCED WIDTH + FULL ROUND)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Material(
                          color: const Color(0xFF2196F3),
                          borderRadius: BorderRadius.circular(100),
                          elevation: 2,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(100),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Changes saved successfully'),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              alignment: Alignment.center,
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
                        ),
                      ),

                      SizedBox(height: 1.h),

                      // LOGOUT BUTTON (REDUCED WIDTH + FULL ROUND)
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
                                  Provider.of<AuthViewModel>(context, listen: false);
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
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
        prefixIcon: Icon(icon, color: Color(0xFF1B5E20)),
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
        color: Colors.white,
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
                Icon(icon, color: const Color(0xFF1B5E20), size: 20.sp),
              if (icon != null) SizedBox(width: 2.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B5E20),
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
        if (icon != null)
          Icon(icon, color: Colors.grey.shade700, size: 20.sp),
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

  // LANGUAGE ITEM
  Widget _buildLanguageItem(
    IconData icon,
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade700, size: 20.sp),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
          ),
          SizedBox(width: 2.w),
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  // COLOR SCHEME
  Widget _buildColorSchemeItem() {
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
              _selectedColorScheme == 'blue',
              () => setState(() => _selectedColorScheme = 'blue'),
            ),
            SizedBox(width: 2.w),
            _buildColorSwatch(
              const Color(0xFF81C784),
              _selectedColorScheme == 'green',
              () => setState(() => _selectedColorScheme = 'green'),
            ),
            SizedBox(width: 2.w),
            _buildColorSwatch(
              Colors.purple,
              _selectedColorScheme == 'purple',
              () => setState(() => _selectedColorScheme = 'purple'),
            ),
          ],
        ),
      ],
    );
  }

  // COLOR SWATCH
  Widget _buildColorSwatch(
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
