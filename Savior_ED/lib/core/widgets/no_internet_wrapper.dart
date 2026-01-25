import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../providers/connectivity_provider.dart';

class NoInternetWrapper extends StatelessWidget {
  final Widget child;

  const NoInternetWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivity, _) {
        bool showIndicator =
            connectivity.status == ConnectivityStatus.isDisconnected ||
            connectivity.status == ConnectivityStatus.isChecking;

        return Stack(
          children: [
            child,
            // Small indicator at the top
            if (showIndicator && !connectivity.showFullPageError)
              Positioned(
                top: MediaQuery.of(context).padding.top + 1.h,
                left: 4.w,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 0.8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20.sp),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _ReconnectionLoadingIcon(),
                        SizedBox(width: 2.w),
                        Text(
                          connectivity.status == ConnectivityStatus.isChecking
                              ? 'RECONNECTING...'
                              : 'LOW CONNECTION',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            fontFamily: 'Cinzel',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Full screen blocker ONLY after 1 minute
            if (connectivity.showFullPageError)
              _buildFullScreenError(context, connectivity),
          ],
        );
      },
    );
  }

  Widget _buildFullScreenError(
    BuildContext context,
    ConnectivityProvider connectivity,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: 100.w,
        height: 100.h,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F1A0F), Color(0xFF1A472A)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              connectivity.status == ConnectivityStatus.isChecking
                  ? Icons.sync_rounded
                  : Icons.wifi_off_rounded,
              size: 20.w,
              color: const Color(0xFFD4AF37),
            ),
            SizedBox(height: 4.h),
            Text(
              connectivity.status == ConnectivityStatus.isChecking
                  ? 'CHECKING CONNECTION...'
                  : 'CONNECTION LOST',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                fontFamily: 'Cinzel',
              ),
            ),
            SizedBox(height: 2.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Text(
                'The realm connection is fading. Please check your internet and try again to restore your kingdom.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 15.sp),
              ),
            ),
            SizedBox(height: 5.h),
            ElevatedButton(
              onPressed: () => connectivity.checkConnection(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'TRY AGAIN',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReconnectionLoadingIcon extends StatefulWidget {
  const _ReconnectionLoadingIcon();

  @override
  State<_ReconnectionLoadingIcon> createState() =>
      _ReconnectionLoadingIconState();
}

class _ReconnectionLoadingIconState extends State<_ReconnectionLoadingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Icon(
        Icons.sync_rounded,
        color: const Color(0xFFD4AF37),
        size: 16.sp,
      ),
    );
  }
}
