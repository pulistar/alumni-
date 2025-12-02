import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/carrera.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/auth_service.dart';

class CarrerasScreen extends StatefulWidget {
  const CarrerasScreen({Key? key}) : super(key: key);

  @override
  State<CarrerasScreen> createState() => _CarrerasScreenState();
}

class _CarrerasScreenState extends State<CarrerasScreen> {
  final ApiService _apiService = ApiService();
  List<Carrera> _carreras = [];
  List<Carrera> _filteredCarreras = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCarreras();
  }

  Future<void> _loadCarreras() async {
    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = authService.accessToken;
      if (token == null) throw Exception('No hay token');
      final data = await _apiService.getCarreras(token);
      final carreras = data.map((json) => Carrera.fromJson(json)).toList();
      setState(() {
        _carreras = carreras;
        _filteredCarreras = carreras;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar carreras: $e')),
        );
      }
    }
  }

  void _filterCarreras(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredCarreras = _carreras;
      } else {
        _filteredCarreras = _carreras.where((carrera) {
          return carrera.nombre.toLowerCase().contains(query.toLowerCase()) ||
              (carrera.codigo?.toLowerCase().contains(query.toLowerCase()) ?? false);
        }).toList();
      }
    });
  }

  Future<void> _showCarreraDialog({Carrera? carrera}) async {
    final nombreController = TextEditingController(text: carrera?.nombre ?? '');
    final codigoController = TextEditingController(text: carrera?.codigo ?? '');
    bool activa = carrera?.activa ?? true;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(carrera == null ? 'Nueva Carrera' : 'Editar Carrera'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre *',
                    hintText: 'Ej: Ingeniería de Sistemas',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: codigoController,
                  decoration: const InputDecoration(
                    labelText: 'Código',
                    hintText: 'Ej: ING-SIS',
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Activa'),
                  value: activa,
                  onChanged: (value) {
                    setDialogState(() => activa = value);
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
                  final authService = Provider.of<AuthService>(context, listen: false);
                  final token = authService.accessToken;
                  if (token == null) throw Exception('No hay token');
                  final data = {
                    'nombre': nombreController.text.trim(),
                    'codigo': codigoController.text.trim().isEmpty ? null : codigoController.text.trim(),
                    'activa': activa,
                  };

                  if (carrera == null) {
                    await _apiService.createCarrera(token, data);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Carrera creada exitosamente')),
                      );
                    }
                  } else {
                    await _apiService.updateCarrera(token, carrera.id, data);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Carrera actualizada exitosamente')),
                      );
                    }
                  }

                  _loadCarreras();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: Text(carrera == null ? 'Crear' : 'Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleCarrera(Carrera carrera) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = authService.accessToken;
      if (token == null) throw Exception('No hay token');
      await _apiService.toggleCarrera(token, carrera.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              carrera.activa ? 'Carrera desactivada' : 'Carrera activada',
            ),
          ),
        );
      }
      _loadCarreras();
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
        title: const Text('Gestión de Carreras'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar carrera...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filterCarreras,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredCarreras.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No hay carreras registradas'
                            : 'No se encontraron carreras',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredCarreras.length,
                  itemBuilder: (context, index) {
                    final carrera = _filteredCarreras[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: carrera.activa ? Colors.green : Colors.grey,
                          child: Icon(
                            Icons.school,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          carrera.nombre,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: carrera.activa ? Colors.black : Colors.grey,
                          ),
                        ),
                        subtitle: carrera.codigo != null
                            ? Text('Código: ${carrera.codigo}')
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showCarreraDialog(carrera: carrera),
                              tooltip: 'Editar',
                            ),
                            IconButton(
                              icon: Icon(
                                carrera.activa ? Icons.toggle_on : Icons.toggle_off,
                                color: carrera.activa ? Colors.green : Colors.grey,
                              ),
                              onPressed: () => _toggleCarrera(carrera),
                              tooltip: carrera.activa ? 'Desactivar' : 'Activar',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCarreraDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Carrera'),
      ),
    );
  }
}
