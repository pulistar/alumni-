import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/grado_academico.dart';
import '../../../data/services/api_service.dart';
import '../../../core/providers/auth_provider.dart';

class GradosAcademicosScreen extends StatefulWidget {
  const GradosAcademicosScreen({Key? key}) : super(key: key);

  @override
  State<GradosAcademicosScreen> createState() => _GradosAcademicosScreenState();
}

class _GradosAcademicosScreenState extends State<GradosAcademicosScreen> {
  final ApiService _apiService = ApiService();
  List<GradoAcademico> _grados = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _niveles = [
    {'value': 0, 'label': 'Otro'},
    {'value': 1, 'label': 'Auxiliar'},
    {'value': 2, 'label': 'Técnico'},
    {'value': 3, 'label': 'Tecnólogo'},
    {'value': 4, 'label': 'Pregrado'},
    {'value': 5, 'label': 'Especialización'},
    {'value': 6, 'label': 'Maestría'},
    {'value': 7, 'label': 'Doctorado'},
  ];

  @override
  void initState() {
    super.initState();
    _loadGrados();
  }

  Future<void> _loadGrados() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final grados = await _apiService.getGradosAcademicos(authProvider.token!);
      setState(() {
        _grados = grados;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar grados académicos: $e')),
        );
      }
    }
  }

  Future<void> _showGradoDialog({GradoAcademico? grado}) async {
    final nombreController = TextEditingController(text: grado?.nombre ?? '');
    final codigoController = TextEditingController(text: grado?.codigo ?? '');
    int? selectedNivel = grado?.nivel ?? 4;
    bool activo = grado?.activo ?? true;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(grado == null ? 'Nuevo Grado Académico' : 'Editar Grado Académico'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre *',
                    hintText: 'Ej: Pregrado',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: codigoController,
                  decoration: const InputDecoration(
                    labelText: 'Código',
                    hintText: 'Ej: PREG',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: selectedNivel,
                  decoration: const InputDecoration(
                    labelText: 'Nivel',
                    border: OutlineInputBorder(),
                  ),
                  items: _niveles.map((nivel) {
                    return DropdownMenuItem<int>(
                      value: nivel['value'] as int,
                      child: Text(nivel['label'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedNivel = value);
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Activo'),
                  value: activo,
                  onChanged: (value) {
                    setDialogState(() => activo = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nombreController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El nombre es requerido')),
                  );
                  return;
                }

                Navigator.pop(context);

                try {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final data = {
                    'nombre': nombreController.text.trim(),
                    'codigo': codigoController.text.trim().isEmpty ? null : codigoController.text.trim(),
                    'nivel': selectedNivel,
                    'activo': activo,
                  };

                  if (grado == null) {
                    await _apiService.createGradoAcademico(authProvider.token!, data);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Grado académico creado exitosamente')),
                      );
                    }
                  } else {
                    await _apiService.updateGradoAcademico(authProvider.token!, grado.id, data);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Grado académico actualizado exitosamente')),
                      );
                    }
                  }

                  _loadGrados();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: Text(grado == null ? 'Crear' : 'Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleGrado(GradoAcademico grado) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await _apiService.toggleGradoAcademico(authProvider.token!, grado.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              grado.activo ? 'Grado académico desactivado' : 'Grado académico activado',
            ),
          ),
        );
      }
      _loadGrados();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Grados Académicos'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _grados.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No hay grados académicos registrados',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _grados.length,
                  itemBuilder: (context, index) {
                    final grado = _grados[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: grado.activo ? Colors.blue : Colors.grey,
                          child: Text(
                            grado.nivel?.toString() ?? '?',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          grado.nombre,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: grado.activo ? Colors.black : Colors.grey,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (grado.codigo != null) Text('Código: ${grado.codigo}'),
                            Text('Nivel: ${grado.nivelDescripcion}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showGradoDialog(grado: grado),
                              tooltip: 'Editar',
                            ),
                            IconButton(
                              icon: Icon(
                                grado.activo ? Icons.toggle_on : Icons.toggle_off,
                                color: grado.activo ? Colors.green : Colors.grey,
                              ),
                              onPressed: () => _toggleGrado(grado),
                              tooltip: grado.activo ? 'Desactivar' : 'Activar',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGradoDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Grado'),
      ),
    );
  }
}
