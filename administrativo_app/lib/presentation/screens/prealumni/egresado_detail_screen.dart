import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/egresado.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/auth_service.dart';
import 'documentos_egresado_screen.dart';
import 'autoevaluacion_egresado_screen.dart';

/// Egresado Detail Screen
class EgresadoDetailScreen extends StatefulWidget {
  final String egresadoId;

  const EgresadoDetailScreen({super.key, required this.egresadoId});

  @override
  State<EgresadoDetailScreen> createState() => _EgresadoDetailScreenState();
}

class _EgresadoDetailScreenState extends State<EgresadoDetailScreen> {
  final ApiService _apiService = ApiService();
  Egresado? _egresado;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEgresado();
  }

  Future<void> _loadEgresado() async {
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

      final egresado = await _apiService.getEgresadoDetail(token, widget.egresadoId);

      if (mounted) {
        setState(() {
          _egresado = egresado;
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

  Future<void> _toggleHabilitado() async {
    if (_egresado == null) return;

    final newStatus = !_egresado!.habilitado;
    final confirmText = newStatus ? 'habilitar' : 'deshabilitar';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿$confirmText egresado?'),
        content: Text('¿Estás seguro de que deseas $confirmText a ${_egresado!.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = authService.accessToken;

      if (token == null) {
        throw Exception('No hay token');
      }

      await _apiService.toggleEgresadoHabilitado(token, widget.egresadoId, newStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Egresado ${newStatus ? "habilitado" : "deshabilitado"} exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        _loadEgresado(); // Reload data
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Detalle del Egresado'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_egresado != null)
            IconButton(
              icon: Icon(_egresado!.habilitado ? Icons.block : Icons.check_circle),
              onPressed: _toggleHabilitado,
              tooltip: _egresado!.habilitado ? 'Deshabilitar' : 'Habilitar',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _buildDetail(),
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
            Text('Error al cargar egresado', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadEgresado,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: _egresado!.habilitado ? Colors.green : Colors.orange,
                    child: Text(
                      _egresado!.nombre[0] + _egresado!.apellido[0],
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _egresado!.fullName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _egresado!.habilitado ? Colors.green.shade100 : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _egresado!.habilitado ? 'HABILITADO' : 'PENDIENTE',
                      style: TextStyle(
                        color: _egresado!.habilitado ? Colors.green.shade800 : Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Info sections
          _buildSection('Información Personal', [
            _buildInfoRow('Email', _egresado!.correo, Icons.email),
            if (_egresado!.telefono != null)
              _buildInfoRow('Teléfono', _egresado!.telefono!, Icons.phone),
            if (_egresado!.ciudad != null)
              _buildInfoRow('Ciudad', _egresado!.ciudad!, Icons.location_city),
          ]),

          if (_egresado!.carrera != null) ...[
            const SizedBox(height: 16),
            _buildSection('Información Académica', [
              _buildInfoRow('Carrera', _egresado!.carrera!, Icons.school),
              if (_egresado!.idUniversitario != null)
                _buildInfoRow('ID Universitario', _egresado!.idUniversitario!, Icons.badge),
            ]),
          ],

          if (_egresado!.estadoLaboral != null) ...[
            const SizedBox(height: 16),
            _buildSection('Información Laboral', [
              _buildInfoRow('Estado', _egresado!.estadoLaboral!, Icons.work),
              if (_egresado!.empresaActual != null)
                _buildInfoRow('Empresa', _egresado!.empresaActual!, Icons.business),
              if (_egresado!.cargoActual != null)
                _buildInfoRow('Cargo', _egresado!.cargoActual!, Icons.work_outline),
            ]),
          ],

          const SizedBox(height: 16),
          _buildSection('Estado del Proceso', [
            _buildStatusRow('Proceso de Grado', _egresado!.procesoGradoCompleto),
            _buildStatusRow('Autoevaluación', _egresado!.autoevaluacionCompletada),
          ]),

          const SizedBox(height: 16),
          _buildSection('Acciones', [
            ListTile(
              leading: const Icon(Icons.folder_shared, color: Colors.blue),
              title: const Text('Ver Documentos'),
              subtitle: Text(_egresado!.procesoGradoCompleto ? 'Completo' : 'Pendiente'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DocumentosEgresadoScreen(
                      egresadoId: _egresado!.id,
                      egresadoNombre: _egresado!.fullName,
                    ),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.assignment_turned_in, color: Colors.purple),
              title: const Text('Ver Autoevaluación'),
              subtitle: Text(_egresado!.autoevaluacionCompletada ? 'Completada' : 'Pendiente'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AutoevaluacionEgresadoScreen(
                      egresadoId: _egresado!.id,
                      egresadoNombre: _egresado!.fullName,
                    ),
                  ),
                );
              },
            ),
          ]),

          const SizedBox(height: 24),
          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _toggleHabilitado,
              icon: Icon(_egresado!.habilitado ? Icons.block : Icons.check_circle),
              label: Text(_egresado!.habilitado ? 'Deshabilitar Egresado' : 'Habilitar Egresado'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _egresado!.habilitado ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool completed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.pending,
            color: completed ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 12),
          Text(label),
          const Spacer(),
          Text(
            completed ? 'Completado' : 'Pendiente',
            style: TextStyle(
              color: completed ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
