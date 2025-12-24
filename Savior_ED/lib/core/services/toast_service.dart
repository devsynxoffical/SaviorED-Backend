import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

/// Toast Service for showing notifications
class ToastService {
  /// Show success toast
  static void showSuccess(
    BuildContext context, {
    required String title,
    String? description,
    Alignment alignment = Alignment.topRight,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      title: Text(title),
      description: description != null ? Text(description) : null,
      alignment: alignment,
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  /// Show error toast
  static void showError(
    BuildContext context, {
    required String title,
    String? description,
    Alignment alignment = Alignment.topRight,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      title: Text(title),
      description: description != null ? Text(description) : null,
      alignment: alignment,
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  /// Show warning toast
  static void showWarning(
    BuildContext context, {
    required String title,
    String? description,
    Alignment alignment = Alignment.topRight,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.warning,
      title: Text(title),
      description: description != null ? Text(description) : null,
      alignment: alignment,
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  /// Show info toast
  static void showInfo(
    BuildContext context, {
    required String title,
    String? description,
    Alignment alignment = Alignment.topRight,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.info,
      title: Text(title),
      description: description != null ? Text(description) : null,
      alignment: alignment,
      autoCloseDuration: const Duration(seconds: 3),
    );
  }
}

