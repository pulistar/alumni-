import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Widget para mostrar estados vacíos con ilustración y mensaje
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono grande con círculo de fondo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60,
                color: iconColor ?? AppColors.primary,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Título
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Mensaje
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            
            // Botón de acción (opcional)
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor ?? AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Estado vacío específico para documentos
class EmptyDocumentsState extends StatelessWidget {
  final VoidCallback? onUpload;

  const EmptyDocumentsState({
    super.key,
    this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.folder_open_rounded,
      title: 'No hay documentos',
      message: 'Aún no has subido ningún documento.\nComienza subiendo tu primer documento.',
      actionText: 'Subir Documento',
      onAction: onUpload,
      iconColor: AppColors.primary,
    );
  }
}

/// Estado vacío para notificaciones
class EmptyNotificationsState extends StatelessWidget {
  const EmptyNotificationsState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.notifications_none_rounded,
      title: 'Sin notificaciones',
      message: 'No tienes notificaciones nuevas.\nTe avisaremos cuando haya actualizaciones.',
      iconColor: Color(0xFF6C63FF),
    );
  }
}

/// Estado vacío para autoevaluación
class EmptyEvaluationState extends StatelessWidget {
  final VoidCallback? onStart;

  const EmptyEvaluationState({
    super.key,
    this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.assignment_rounded,
      title: 'Autoevaluación pendiente',
      message: 'Completa tu autoevaluación de competencias\npara continuar con tu proceso de grado.',
      actionText: 'Comenzar Autoevaluación',
      onAction: onStart,
      iconColor: Color(0xFFFF6584),
    );
  }
}

/// Estado de error genérico
class ErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.error_outline_rounded,
      title: 'Algo salió mal',
      message: message ?? 'Ocurrió un error al cargar los datos.\nPor favor, intenta de nuevo.',
      actionText: 'Reintentar',
      onAction: onRetry,
      iconColor: AppColors.error,
    );
  }
}

/// Estado sin conexión
class NoConnectionState extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoConnectionState({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.wifi_off_rounded,
      title: 'Sin conexión',
      message: 'No hay conexión a internet.\nVerifica tu conexión e intenta de nuevo.',
      actionText: 'Reintentar',
      onAction: onRetry,
      iconColor: AppColors.warning,
    );
  }
}

/// Estado de búsqueda sin resultados
class NoSearchResultsState extends StatelessWidget {
  final String? searchQuery;

  const NoSearchResultsState({
    super.key,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off_rounded,
      title: 'Sin resultados',
      message: searchQuery != null
          ? 'No encontramos resultados para "$searchQuery".\nIntenta con otros términos de búsqueda.'
          : 'No se encontraron resultados.\nIntenta con otros términos de búsqueda.',
      iconColor: AppColors.info,
    );
  }
}
