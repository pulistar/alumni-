import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/egresado.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/auth_service.dart';
import 'egresado_detail_screen.dart';

/// Egresados List Screen
class EgresadosListScreen extends StatefulWidget {
  const EgresadosListScreen({super.key});

  @override
  State<EgresadosListScreen> createState() => _EgresadosListScreenState();
}

class _EgresadosListScreenState extends State<EgresadosListScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Egresado> _egresados = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  bool? _filtroHabilitado;

  @override
  void initState() {
    super.initState();
    _loadEgresados();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEgresados() async {
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

      final result = await _apiService.getEgresados(
        token: token,
        page: _currentPage,
        habilitado: _filtroHabilitado,
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
      );

      if (mounted) {
        setState(() {
          _egresados = result['egresados'] as List<Egresado>;
          _totalPages = result['totalPages'] as int;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          final errorMsg = e.toString().replaceAll('Exception: ', '');
          if (errorMsg.contains('500')) {
            _errorMessage = 'Error del servidor. Posiblemente no hay egresados en la base de datos o hay un problema de conexión con Supabase.';
          } else {
            _errorMessage = errorMsg;
          }
          _isLoading = false;
        });
      }
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtros'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Todos'),
              leading: Radio<bool?>(
                value: null,
                groupValue: _filtroHabilitado,
                onChanged: (value) {
                  setState(() => _filtroHabilitado = value);
                  Navigator.pop(context);
                  _currentPage = 1;
                  _loadEgresados();
                },
              ),
            ),
            ListTile(
              title: const Text('Solo Habilitados'),
              leading: Radio<bool?>(
                value: true,
                groupValue: _filtroHabilitado,
                onChanged: (value) {
                  setState(() => _filtroHabilitado = value);
                  Navigator.pop(context);
                  _currentPage = 1;
                  _loadEgresados();
                },
              ),
            ),
            ListTile(
              title: const Text('Solo Pendientes'),
              leading: Radio<bool?>(
                value: false,
                groupValue: _filtroHabilitado,
                onChanged: (value) {
                  setState(() => _filtroHabilitado = value);
                  Navigator.pop(context);
                  _currentPage = 1;
                  _loadEgresados();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Egresados'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _currentPage = 1;
                          _loadEgresados();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onSubmitted: (_) {
                _currentPage = 1;
                _loadEgresados();
              },
            ),
          ),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildErrorView()
                    : _egresados.isEmpty
                        ? _buildEmptyView()
                        : _buildList(),
          ),

          // Pagination
          if (!_isLoading && _egresados.isNotEmpty) _buildPagination(),
        ],
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
            Text('Error al cargar egresados', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadEgresados,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No se encontraron egresados', style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _loadEgresados,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _egresados.length,
        itemBuilder: (context, index) {
          final egresado = _egresados[index];
          return _buildEgresadoCard(egresado);
        },
      ),
    );
  }

  Widget _buildEgresadoCard(Egresado egresado) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: egresado.habilitado ? Colors.green : Colors.orange,
          child: Icon(
            egresado.habilitado ? Icons.check : Icons.pending,
            color: Colors.white,
          ),
        ),
        title: Text(
          egresado.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(egresado.correo),
            if (egresado.carrera != null) ...[
              const SizedBox(height: 2),
              Text(
                egresado.carrera!,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EgresadoDetailScreen(egresadoId: egresado.id),
            ),
          ).then((_) => _loadEgresados()); // Reload after returning
        },
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: _currentPage > 1
                ? () {
                    setState(() => _currentPage--);
                    _loadEgresados();
                  }
                : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Anterior'),
          ),
          Text('Página $_currentPage de $_totalPages'),
          ElevatedButton.icon(
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() => _currentPage++);
                    _loadEgresados();
                  }
                : null,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Siguiente'),
          ),
        ],
      ),
    );
  }
}
