import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

enum ConnectivityStatus {
  isConnected,
  isDisconnected,
  isChecking,
  isLowConnection,
}

class ConnectivityProvider with ChangeNotifier {
  ConnectivityStatus _status = ConnectivityStatus.isConnected;
  ConnectivityStatus get status => _status;

  DateTime? _disconnectionStartTime;
  Timer? _oneMinuteTimer;
  bool _showFullPageError = false;
  bool get showFullPageError => _showFullPageError;

  Duration get disconnectionDuration {
    if (_disconnectionStartTime == null) return Duration.zero;
    return DateTime.now().difference(_disconnectionStartTime!);
  }

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late StreamSubscription<InternetStatus> _internetSubscription;

  ConnectivityProvider() {
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    // Initial check
    final result = await Connectivity().checkConnectivity();
    _handleConnectivityChange(result);

    // Listen to connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _handleConnectivityChange,
    );

    // Also listen to actual internet status (more reliable)
    _internetSubscription = InternetConnection().onStatusChange.listen((
      status,
    ) {
      if (status == InternetStatus.connected) {
        _onConnected();
      } else {
        _onDisconnected();
      }
    });
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) async {
    if (results.contains(ConnectivityResult.none)) {
      _onDisconnected();
    } else {
      // If we have some connection, check if it actually has internet
      final hasInternet = await InternetConnection().hasInternetAccess;
      if (hasInternet) {
        _onConnected();
      } else {
        _onDisconnected();
      }
    }
  }

  void _onConnected() {
    _disconnectionStartTime = null;
    _oneMinuteTimer?.cancel();
    _showFullPageError = false;
    _updateStatus(ConnectivityStatus.isConnected);
  }

  void _onDisconnected() {
    if (_status == ConnectivityStatus.isConnected) {
      _disconnectionStartTime = DateTime.now();
      _updateStatus(ConnectivityStatus.isDisconnected);

      // Start 1-minute timer to show full screen error
      _oneMinuteTimer?.cancel();
      _oneMinuteTimer = Timer(const Duration(minutes: 1), () {
        _showFullPageError = true;
        notifyListeners();
      });
    }
  }

  void _updateStatus(ConnectivityStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      notifyListeners();
      print('🌐 Connectivity Status Changed: $_status');
    }
  }

  /// Manually trigger a check
  Future<void> checkConnection() async {
    _updateStatus(ConnectivityStatus.isChecking);
    final results = await Connectivity().checkConnectivity();
    _handleConnectivityChange(results);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _internetSubscription.cancel();
    _oneMinuteTimer?.cancel();
    super.dispose();
  }
}
