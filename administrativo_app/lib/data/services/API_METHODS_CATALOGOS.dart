// ============================================
// MÉTODOS API PARA CARRERAS Y GRADOS ACADÉMICOS
// Agregar estos métodos en lib/data/services/api_service.dart
// ============================================

import '../models/carrera.dart';
import '../models/grado_academico.dart';

// ==================== CARRERAS ====================

/// Get all carreras
Future<List<Carrera>> getCarreras(String token) async {
  try {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/admin/carreras'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList.map((json) => Carrera.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Error al obtener carreras');
    }
  } catch (e) {
    if (e is Exception) rethrow;
    throw Exception('Error al obtener carreras');
  }
}

/// Create carrera
Future<Carrera> createCarrera(String token, Map<String, dynamic> data) async {
  try {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/admin/carreras'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Carrera.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Error al crear carrera');
    }
  } catch (e) {
    if (e is Exception) rethrow;
    throw Exception('Error al crear carrera');
  }
}

/// Update carrera
Future<Carrera> updateCarrera(String token, String id, Map<String, dynamic> data) async {
  try {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/admin/carreras/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return Carrera.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Error al actualizar carrera');
    }
  } catch (e) {
    if (e is Exception) rethrow;
    throw Exception('Error al actualizar carrera');
  }
}

/// Toggle carrera activa status
Future<Carrera> toggleCarrera(String token, String id) async {
  try {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/admin/carreras/$id/toggle'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Carrera.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Error al cambiar estado de carrera');
    }
  } catch (e) {
    if (e is Exception) rethrow;
    throw Exception('Error al cambiar estado');
  }
}

// ==================== GRADOS ACADÉMICOS ====================

/// Get all grados académicos
Future<List<GradoAcademico>> getGradosAcademicos(String token) async {
  try {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/admin/grados-academicos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList.map((json) => GradoAcademico.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Error al obtener grados académicos');
    }
  } catch (e) {
    if (e is Exception) rethrow;
    throw Exception('Error al obtener grados académicos');
  }
}

/// Create grado académico
Future<GradoAcademico> createGradoAcademico(String token, Map<String, dynamic> data) async {
  try {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/admin/grados-academicos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return GradoAcademico.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Error al crear grado académico');
    }
  } catch (e) {
    if (e is Exception) rethrow;
    throw Exception('Error al crear grado académico');
  }
}

/// Update grado académico
Future<GradoAcademico> updateGradoAcademico(String token, String id, Map<String, dynamic> data) async {
  try {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/admin/grados-academicos/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return GradoAcademico.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Error al actualizar grado académico');
    }
  } catch (e) {
    if (e is Exception) rethrow;
    throw Exception('Error al actualizar grado académico');
  }
}

/// Toggle grado académico activo status
Future<GradoAcademico> toggleGradoAcademico(String token, String id) async {
  try {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/admin/grados-academicos/$id/toggle'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return GradoAcademico.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Error al cambiar estado de grado académico');
    }
  } catch (e) {
    if (e is Exception) rethrow;
    throw Exception('Error al cambiar estado');
  }
}
