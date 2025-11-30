import 'package:flutter/material.dart';

/// Module Model
/// Represents a system module/network
class Module {
  final String id;
  final String nombre;
  final String descripcion;
  final String icono;
  final int orden;
  final bool activo;
  final String? urlInfo;

  Module({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.orden,
    required this.activo,
    this.urlInfo,
  });

  /// Create Module from JSON
  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String? ?? '',
      icono: json['icono'] as String? ?? 'apps',
      orden: json['orden'] as int? ?? 0,
      activo: json['activo'] as bool? ?? false,
      urlInfo: json['url_info'] as String?,
    );
  }

  /// Get Material Icon based on icon name
  IconData get iconData {
    switch (icono.toLowerCase()) {
      case 'school':
        return Icons.school;
      case 'people':
        return Icons.people;
      case 'work':
        return Icons.work;
      case 'event':
        return Icons.event;
      case 'support':
        return Icons.support;
      case 'book':
        return Icons.book;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'forum':
        return Icons.forum;
      default:
        return Icons.apps;
    }
  }
}
