import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/pregunta.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/auth_service.dart';

/// Preguntas Management Screen
class PreguntasScreen extends StatefulWidget {
  const PreguntasScreen({super.key});

  @override
  State<PreguntasScreen> createState() => _PreguntasScreenState();
}

class _PreguntasScreenState extends State<PreguntasScreen> {
  final ApiService _apiService = ApiService();
  List<Pregunta> _preguntas = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool? _filterActiva;

  @override
  void initState() {
    super.initState();
    _loadPreguntas();
  }

  Future<void> _loadPreguntas() async {
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

      final data = await _apiService.getPreguntas(token, activa: _filterActiva);
      
      if (mounted) {
        setState(() {
          _preguntas = data.map((json) => Pregunta.fromJson(json)).toList();
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

  Future<void> _togglePregunta(Pregunta pregunta) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = authService.accessToken;

      if (token == null) {
        throw Exception('No hay token');
      }

      await _apiService.togglePregunta(token, pregunta.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pregunta ${!pregunta.activa ? "activada" : "desactivada"}'),
            backgroundColor: Colors.green,
          ),
        );
        _loadPreguntas();
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
    _showPreguntaDialog(null);
  }

  void _showEditDialog(Pregunta pregunta) {
    _showPreguntaDialog(pregunta);
  }

  void _showPreguntaDialog(Pregunta? pregunta) {
    final isEditing = pregunta != null;
    final textoController = TextEditingController(text: pregunta?.texto ?? '');
    final ordenController = TextEditingController(text: pregunta?.orden.toString() ?? '');
    final categoriaController = TextEditingController(text: pregunta?.categoria ?? '');
    
    // Initialize selected tipo
    TipoPregunta initialTipo = pregunta != null 
        ? TipoPregunta.fromString(pregunta.tipo)
        : TipoPregunta.likert;
    
    // For multiple choice options
    final opcionesControllers = <TextEditingController>[];
    if (pregunta?.tipo == 'multiple' && pregunta?.opciones != null) {
      final opciones = pregunta!.opciones!['opciones'] as List?;
      if (opciones != null) {
        for (var opcion in opciones) {
          opcionesControllers.add(TextEditingController(text: opcion.toString()));
        }
      }
    }
    if (opcionesControllers.isEmpty) {
      opcionesControllers.add(TextEditingController());
    }

    showDialog(
      context: context,
      builder: (context) {
        // State variable for the dialog
        TipoPregunta selectedTipo = initialTipo;
        
        return StatefulBuilder(
          builder: (context, setDialogState) {

          return AlertDialog(
            title: Text(isEditing ? 'Editar Pregunta' : 'Nueva Pregunta'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: textoController,
                    decoration: const InputDecoration(
                      labelText: 'Texto de la pregunta',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<TipoPregunta>(
                    value: selectedTipo,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de pregunta',
                      border: OutlineInputBorder(),
                    ),
                    items: TipoPregunta.values.map((tipo) {
                      return DropdownMenuItem(
                        value: tipo,
                        child: Text(tipo.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedTipo = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Show additional fields based on question type
                  if (selectedTipo == TipoPregunta.likert) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Los egresados responderán con una escala del 1 al 5',
                              style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (selectedTipo == TipoPregunta.texto) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.green.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Los egresados responderán con texto libre',
                              style: TextStyle(color: Colors.green.shade700, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (selectedTipo == TipoPregunta.multiple) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Define las opciones de respuesta:',
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(opcionesControllers.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: opcionesControllers[index],
                                      decoration: InputDecoration(
                                        labelText: 'Opción ${index + 1}',
                                        border: const OutlineInputBorder(),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (opcionesControllers.length > 1)
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                                      onPressed: () {
                                        setDialogState(() {
                                          opcionesControllers.removeAt(index);
                                        });
                                      },
                                    ),
                                ],
                              ),
                            );
                          }),
                          TextButton.icon(
                            onPressed: () {
                              setDialogState(() {
                                opcionesControllers.add(TextEditingController());
                              });
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar opción'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextField(
                    controller: ordenController,
                    decoration: const InputDecoration(
                      labelText: 'Orden',
                      border: OutlineInputBorder(),
                      helperText: 'Las preguntas se reorganizarán automáticamente',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: categoriaController,
                    decoration: const InputDecoration(
                      labelText: 'Categoría (opcional)',
                      border: OutlineInputBorder(),
                      hintText: 'ej: competencias, empleabilidad',
                    ),
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
                  final texto = textoController.text.trim();
                  final ordenStr = ordenController.text.trim();
                  final categoria = categoriaController.text.trim();

                  if (texto.isEmpty || ordenStr.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Texto y orden son obligatorios'),
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

                  // Validate multiple choice options
                  Map<String, dynamic>? opciones;
                  if (selectedTipo == TipoPregunta.multiple) {
                    final opcionesList = opcionesControllers
                        .map((c) => c.text.trim())
                        .where((t) => t.isNotEmpty)
                        .toList();
                    
                    if (opcionesList.length < 2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Debes proporcionar al menos 2 opciones'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    opciones = {'opciones': opcionesList};
                  }

                  Navigator.pop(context);

                  try {
                    final authService = Provider.of<AuthService>(context, listen: false);
                    final token = authService.accessToken;

                    if (token == null) {
                      throw Exception('No hay token');
                    }

                    // Check if we need to reorder
                    final existingWithSameOrder = _preguntas.where(
                      (p) => p.orden == orden && (!isEditing || p.id != pregunta.id)
                    ).toList();

                    // Reorder if necessary
                    if (existingWithSameOrder.isNotEmpty) {
                      await _reorderPreguntas(token, orden, isEditing ? pregunta.id : null);
                    }

                    final data = {
                      'texto': texto,
                      'tipo': selectedTipo.value,
                      'orden': orden,
                      if (categoria.isNotEmpty) 'categoria': categoria,
                      if (opciones != null) 'opciones': opciones,
                      'activa': true,
                    };

                    if (isEditing) {
                      await _apiService.updatePregunta(token, pregunta.id, data);
                    } else {
                      await _apiService.createPregunta(token, data);
                    }

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEditing ? 'Pregunta actualizada' : 'Pregunta creada'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      _loadPreguntas();
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
          );
        },
      );
      },
    );
  }

  Future<void> _reorderPreguntas(String token, int newOrden, String? excludeId) async {
    // Get all preguntas that need to be shifted
    final preguntasToShift = _preguntas.where((p) {
      if (excludeId != null && p.id == excludeId) return false;
      return p.orden >= newOrden;
    }).toList();

    // Sort by orden
    preguntasToShift.sort((a, b) => a.orden.compareTo(b.orden));

    // Update each one
    for (var pregunta in preguntasToShift) {
      try {
        await _apiService.updatePregunta(
          token,
          pregunta.id,
          {'orden': pregunta.orden + 1},
        );
      } catch (e) {
        print('Error reordering pregunta ${pregunta.id}: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Configurar Preguntas'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<bool?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar',
            onSelected: (value) {
              setState(() {
                _filterActiva = value;
              });
              _loadPreguntas();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Todas'),
              ),
              const PopupMenuItem(
                value: true,
                child: Text('Solo activas'),
              ),
              const PopupMenuItem(
                value: false,
                child: Text('Solo inactivas'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _buildPreguntasList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Pregunta'),
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
            Text('Error al cargar preguntas', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPreguntas,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreguntasList() {
    if (_preguntas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('No hay preguntas', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Crea tu primera pregunta usando el botón +'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPreguntas,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _preguntas.length,
        itemBuilder: (context, index) {
          final pregunta = _preguntas[index];
          return _buildPreguntaCard(pregunta);
        },
      ),
    );
  }

  Widget _buildPreguntaCard(Pregunta pregunta) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: pregunta.activa ? Colors.green : Colors.grey,
          child: Text(
            pregunta.orden.toString(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          pregunta.texto,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.category, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(pregunta.categoria ?? 'Sin categoría'),
                const SizedBox(width: 16),
                Icon(_getTipoIcon(pregunta.tipo), size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(TipoPregunta.fromString(pregunta.tipo).label),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                pregunta.activa ? Icons.toggle_on : Icons.toggle_off,
                color: pregunta.activa ? Colors.green : Colors.grey,
              ),
              onPressed: () => _togglePregunta(pregunta),
              tooltip: pregunta.activa ? 'Desactivar' : 'Activar',
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditDialog(pregunta),
              tooltip: 'Editar',
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  IconData _getTipoIcon(String tipo) {
    switch (tipo) {
      case 'likert':
        return Icons.linear_scale;
      case 'texto':
        return Icons.text_fields;
      case 'multiple':
        return Icons.checklist;
      default:
        return Icons.help_outline;
    }
  }
}
