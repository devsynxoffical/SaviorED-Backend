import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../widgets/gradient_background.dart';
import '../../../services/toast_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';
import '../../../routes/app_routes.dart';
import '../viewmodels/auth_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authViewModel = context.read<AuthViewModel>();
      final success = await authViewModel.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        ToastService.showSuccess(
          context,
          title: "Success",
          description: "Login successful",
        );

        Navigator.pushReplacementNamed(context, AppRoutes.castleGrounds);
      } else {
        ToastService.showError(
          context,
          title: "Error",
          description: authViewModel.errorMessage ?? "Login failed",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      colors: const [Color(0xFFA5D6A7), Color(0xFFE3F2FD)],
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              if (authViewModel.isLoading) {
                return const LoadingWidget(message: "Logging in...");
              }

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 6.h),

                      /// TITLE (Uses same style as SignUpView)
                      Text(
                        "Sign In to \nContinue",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF003300),
                          letterSpacing: 0.5,
                        ),
                      ),

                      SizedBox(height: 5.h),

                      /// EMAIL FIELD
                      _buildShadowTextField(
                        controller: _emailController,
                        hint: "Email Address",
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your email";
                          }
                          if (!value.contains('@')) {
                            return "Please enter a valid email";
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 2.5.h),

                      /// PASSWORD FIELD
                      _buildShadowTextField(
                        controller: _passwordController,
                        hint: "Password",
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.grey,
                            size: 20.sp,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your password";
                          }
                          if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 3.h),

                      /// LOGIN BUTTON
                      CustomButton(
                        text: "Sign In",
                        backgroundColor: const Color(0xFF4285F4),
                        borderRadius: 50.sp,
                        height: 6.5.h,
                        onPressed: _handleLogin,
                        textColor: Colors.white,
                      ),

                      SizedBox(height: 2.5.h),

                      /// GOOGLE BUTTON (same as signup)
                      _buildGoogleButton(),

                      SizedBox(height: 2.5.h),

                      /// FORGOT PASSWORD
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.forgotPassword,
                          );
                        },
                        child: Text(
                          "Forgot password?",
                          style: TextStyle(
                            color: const Color(0xFF4285F4),
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// -----------------------------------------------
  /// MATCHES SignUpView EXACTLY (Pill + shadow + style)
  /// -----------------------------------------------
  Widget _buildShadowTextField({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: 6.5.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(200), // pill shape
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      alignment: Alignment.center,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
        textAlign: TextAlign.start, // Start alignment (left)
        textAlignVertical: TextAlignVertical.center, // Vertically center
        style: TextStyle(fontSize: 16.sp, color: Colors.black87),

        decoration: InputDecoration(
          isDense: true, // 💚 Removes extra height
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16.sp),

          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0), // Vertically centered

          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,

          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  /// GOOGLE BUTTON (copied from SignUpView)
  Widget _buildGoogleButton() {
    return Container(
      width: double.infinity,
      height: 6.5.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50.sp),
          onTap: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/google_logo.png",
                width: 24.sp,
                height: 24.sp,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.g_mobiledata,
                  size: 28.sp,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                "Continue with Google",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
