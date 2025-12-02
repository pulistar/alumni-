import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Tipos de snackbar
enum SnackBarType {
  success,
  error,
  warning,
  info,
}

/// Clase helper para mostrar snackbars mejorados
class CustomSnackBar {
  /// Mostrar snackbar de éxito
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      type: SnackBarType.success,
      duration: duration,
    );
  }

  /// Mostrar snackbar de error
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      message: message,
      type: SnackBarType.error,
      duration: duration,
    );
  }

  /// Mostrar snackbar de advertencia
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      type: SnackBarType.warning,
      duration: duration,
    );
  }

  /// Mostrar snackbar de información
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      type: SnackBarType.info,
      duration: duration,
    );
  }

  /// Método privado para mostrar el snackbar
  static void _show(
    BuildContext context, {
    required String message,
    required SnackBarType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    final config = _getConfig(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                config.icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: config.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        duration: duration,
        elevation: 6,
      ),
    );
  }

  /// Obtener configuración según el tipo
  static _SnackBarConfig _getConfig(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return _SnackBarConfig(
          icon: Icons.check_circle_rounded,
          color: AppColors.success,
        );
      case SnackBarType.error:
        return _SnackBarConfig(
          icon: Icons.error_rounded,
          color: AppColors.error,
        );
      case SnackBarType.warning:
        return _SnackBarConfig(
          icon: Icons.warning_rounded,
          color: AppColors.warning,
        );
      case SnackBarType.info:
        return _SnackBarConfig(
          icon: Icons.info_rounded,
          color: AppColors.info,
        );
    }
  }
}

/// Configuración de snackbar
class _SnackBarConfig {
  final IconData icon;
  final Color color;

  _SnackBarConfig({
    required this.icon,
    required this.color,
  });
}

/// Snackbar con acción
class ActionSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 5),
  }) {
    final config = CustomSnackBar._getConfig(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              config.icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: config.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        duration: duration,
        action: SnackBarAction(
          label: actionLabel,
          textColor: Colors.white,
          onPressed: onAction,
        ),
      ),
    );
  }
}

/// Snackbar de progreso (para operaciones largas)
class ProgressSnackBar {
  static void show(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(days: 1), // Muy largo, se debe cerrar manualmente
      ),
    );
  }

  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}
