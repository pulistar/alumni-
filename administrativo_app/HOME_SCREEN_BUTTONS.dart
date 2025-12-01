// ============================================
// CÓDIGO PARA AGREGAR EN home_screen.dart
// ============================================

// 1. Agregar estos imports al inicio del archivo:
import 'prealumni/carreras_screen.dart';
import 'prealumni/grados_academicos_screen.dart';

// 2. Agregar estos dos botones en la sección donde están las acciones rápidas o módulos:

// Botón de Carreras
Card(
  elevation: 2,
  child: InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CarrerasScreen()),
      );
    },
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school,
            size: 40,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 8),
          const Text(
            'Carreras',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  ),
),

// Botón de Grados Académicos
Card(
  elevation: 2,
  child: InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GradosAcademicosScreen()),
      );
    },
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 40,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 8),
          const Text(
            'Grados Académicos',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  ),
),
