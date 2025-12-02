import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';

/// Widget reutilizable para mostrar skeleton loaders mientras carga contenido
class SkeletonLoader extends StatelessWidget {
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;

  const SkeletonLoader({
    super.key,
    this.height,
    this.width,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Skeleton para tarjeta de documento
class DocumentCardSkeleton extends StatelessWidget {
  const DocumentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono
          const SkeletonLoader(
            height: 48,
            width: 48,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          const SizedBox(width: 16),
          // Contenido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(
                  height: 16,
                  width: double.infinity,
                ),
                const SizedBox(height: 8),
                SkeletonLoader(
                  height: 12,
                  width: MediaQuery.of(context).size.width * 0.4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Botón
          const SkeletonLoader(
            height: 36,
            width: 36,
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
        ],
      ),
    );
  }
}

/// Skeleton para lista de documentos
class DocumentListSkeleton extends StatelessWidget {
  final int itemCount;

  const DocumentListSkeleton({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) => const DocumentCardSkeleton(),
    );
  }
}

/// Skeleton para perfil de usuario
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          const SkeletonLoader(
            height: 100,
            width: 100,
            borderRadius: BorderRadius.all(Radius.circular(50)),
          ),
          const SizedBox(height: 16),
          // Nombre
          const SkeletonLoader(
            height: 24,
            width: 200,
          ),
          const SizedBox(height: 8),
          // Email
          const SkeletonLoader(
            height: 16,
            width: 150,
          ),
          const SizedBox(height: 32),
          // Campos de información
          ...List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(
                    height: 12,
                    width: MediaQuery.of(context).size.width * 0.3,
                  ),
                  const SizedBox(height: 8),
                  const SkeletonLoader(
                    height: 48,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton para tarjeta de pregunta de autoevaluación
class QuestionCardSkeleton extends StatelessWidget {
  const QuestionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categoría
          SkeletonLoader(
            height: 12,
            width: MediaQuery.of(context).size.width * 0.3,
          ),
          const SizedBox(height: 12),
          // Pregunta
          const SkeletonLoader(
            height: 16,
            width: double.infinity,
          ),
          const SizedBox(height: 8),
          SkeletonLoader(
            height: 16,
            width: MediaQuery.of(context).size.width * 0.7,
          ),
          const SizedBox(height: 20),
          // Opciones
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              5,
              (index) => const SkeletonLoader(
                height: 48,
                width: 48,
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton genérico para listas
class ListItemSkeleton extends StatelessWidget {
  final int itemCount;

  const ListItemSkeleton({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SkeletonLoader(
              height: 40,
              width: 40,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonLoader(
                    height: 14,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 8),
                  SkeletonLoader(
                    height: 12,
                    width: MediaQuery.of(context).size.width * 0.5,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
