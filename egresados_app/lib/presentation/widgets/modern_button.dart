import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'micro_interactions.dart';

/// Botón moderno con diseño glassmorphism o sólido
class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isGlass;
  final Color? color;
  final Color? textColor;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isGlass = false,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return TapAnimation(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: isGlass
              ? null
              : LinearGradient(
                  colors: [
                    color ?? Colors.white,
                    (color ?? Colors.white).withOpacity(0.9),
                  ],
                ),
          color: isGlass ? Colors.white.withOpacity(0.2) : null,
          borderRadius: BorderRadius.circular(16),
          border: isGlass
              ? Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 2,
                )
              : null,
          boxShadow: isGlass
              ? null
              : [
                  BoxShadow(
                    color: (color ?? Colors.white).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      textColor ?? (isGlass ? Colors.white : AppColors.primary),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        color: textColor ?? (isGlass ? Colors.white : AppColors.primary),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor ?? (isGlass ? Colors.white : AppColors.primary),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Botón outline moderno
class ModernOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  const ModernOutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TapAnimation(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color ?? Colors.white,
            width: 2,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: color ?? Colors.white,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color ?? Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
