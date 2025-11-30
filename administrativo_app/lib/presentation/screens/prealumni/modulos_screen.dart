import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/modulo.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/auth_service.dart';

/// Modulos Management Screen
class ModulosScreen extends StatefulWidget {
  const ModulosScreen({super.key});

  @override
  State<ModulosScreen> createState() => _ModulosScreenState();
}

class _ModulosScreenState extends State<ModulosScreen> {
  final ApiService _apiService = ApiService();
  List<Modulo> _modulos = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool? _filterActivo;

  @override
  void initState() {
    super.initState();
    _loadModulos();
  }

  Future<void> _loadModulos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = authService.accessToken;

      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final data = await _apiService.getModulos(token, activo: _filterActivo);
      
      if (mounted) {
        setState(() {
          _modulos = data.map((json) => Modulo.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleModulo(Modulo modulo) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = authService.accessToken;

      if (token == null) {
        throw Exception('No hay token');
      }

      await _apiService.toggleModulo(token, modulo.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Módulo ${!modulo.activo ? "activado" : "desactivado"}'),
            backgroundColor: Colors.green,
          ),
        );
        _loadModulos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCreateDialog() {
    _showModuloDialog(null);
  }

  void _showEditDialog(Modulo modulo) {
    _showModuloDialog(modulo);
  }

  void _showModuloDialog(Modulo? modulo) {
    final isEditing = modulo != null;
    final nombreController = TextEditingController(text: modulo?.nombre ?? '');
    final descripcionController = TextEditingController(text: modulo?.descripcion ?? '');
    final ordenController = TextEditingController(text: modulo?.orden.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Módulo' : 'Nuevo Módulo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del módulo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ordenController,
                decoration: const InputDecoration(
                  labelText: 'Orden',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
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
              final nombre = nombreController.text.trim();
              final descripcion = descripcionController.text.trim();
              final ordenStr = ordenController.text.trim();

              if (nombre.isEmpty || ordenStr.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nombre y orden son obligatorios'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final orden = int.tryParse(ordenStr);
              if (orden == null || orden < 1) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('El orden debe ser un número mayor a 0'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);

              try {
                final authService = Provider.of<AuthService>(context, listen: false);
                final token = authService.accessToken;

                if (token == null) {
                  throw Exception('No hay token');
                }

                final data = {
                  'nombre': nombre,
                  'orden': orden,
                  if (descripcion.isNotEmpty) 'descripcion': descripcion,
                  'activo': true,
                };

                if (isEditing) {
                  await _apiService.updateModulo(token, modulo.id, data);
                } else {
                  await _apiService.createModulo(token, data);
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEditing ? 'Módulo actualizado' : 'Módulo creado'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadModulos();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(isEditing ? 'Actualizar' : 'Crear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Módulos del Sistema'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Menu icon for module management
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: PopupMenuButton<String>(
              icon: Icon(
                Icons.menu,
                color: Theme.of(context).primaryColor,
              ),
              tooltip: 'Gestionar Módulos',
              onSelected: (value) {
                if (value == 'create') {
                  _showCreateDialog();
                } else if (value == 'refresh') {
                  _loadModulos();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'create',
                  child: Row(
                    children: [
                      Icon(Icons.add, color: Colors.blue),
                      SizedBox(width: 12),
                      Text('Crear Módulo'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh, color: Colors.green),
                      SizedBox(width: 12),
                      Text('Actualizar'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Filter menu
          PopupMenuButton<bool?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar',
            onSelected: (value) {
              setState(() {
                _filterActivo = value;
              });
              _loadModulos();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Todos'),
              ),
              const PopupMenuItem(
                value: true,
                child: Text('Solo activos'),
              ),
              const PopupMenuItem(
                value: false,
                child: Text('Solo inactivos'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _buildModulosList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Módulo'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text('Error al cargar módulos', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadModulos,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModulosList() {
    if (_modulos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('No hay módulos', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Crea tu primer módulo usando el botón +'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadModulos,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _modulos.length,
        itemBuilder: (context, index) {
          final modulo = _modulos[index];
          return _buildModuloCard(modulo);
        },
      ),
    );
  }

  Widget _buildModuloCard(Modulo modulo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: modulo.activo ? Colors.blue : Colors.grey,
          child: Text(
            modulo.orden.toString(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          modulo.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: modulo.descripcion != null
            ? Text(
                modulo.descripcion!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                modulo.activo ? Icons.toggle_on : Icons.toggle_off,
                color: modulo.activo ? Colors.green : Colors.grey,
              ),
              onPressed: () => _toggleModulo(modulo),
              tooltip: modulo.activo ? 'Desactivar' : 'Activar',
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditDialog(modulo),
              tooltip: 'Editar',
            ),
          ],
        ),
      ),
    );
  }
}
