import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/module.dart';
import '../../data/services/api_service.dart';
import '../../data/services/auth_service.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';
import 'prealumni/prealumni_dashboard_screen.dart';
import 'prealumni/modulos_screen.dart';

/// Modules Screen
/// Displays the 9 system modules/networks
class ModulesScreen extends StatefulWidget {
  const ModulesScreen({super.key});

  @override
  State<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  final ApiService _apiService = ApiService();
  List<Module>? _modules;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Ensure token is loaded from storage if not already in memory
      if (authService.accessToken == null) {
        print('🔵 Token not in memory, initializing AuthService...');
        await authService.initialize();
      }
      
      final token = authService.accessToken;
      
      print('🔵 Loading modules with token: ${token != null ? "YES (${token.substring(0, 20)}...)" : "NO"}');
      
      if (token == null) {
        throw Exception('No se encontró token de autenticación. Por favor, inicia sesión nuevamente.');
      }
      
      final modules = await _apiService.getModules(token: token);
      
      if (mounted) {
        setState(() {
          _modules = modules;
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

  Future<void> _handleLogout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _handleModuleTap(Module module) {
    if (!module.activo) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${module.nombre} estará disponible próximamente'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Navigate to module-specific screen
    // Use orden=1 to identify PreAlumni/Red de Contacto module (regardless of name changes)
    if (module.orden == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PreAlumniDashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Abriendo ${module.nombre}...'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Módulos del Sistema'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: Column(
        children: [
          // User info header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Menu icon button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.menu,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                    tooltip: 'Gestionar Módulos',
                    onSelected: (value) {
                      if (value == 'modules') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ModulosScreen()),
                        );
                      } else if (value == 'refresh') {
                        _loadModules();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'modules',
                        child: Row(
                          children: [
                            Icon(Icons.folder, color: Colors.teal),
                            SizedBox(width: 12),
                            Text('Gestionar Módulos'),
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
                const SizedBox(width: 16),
                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? "Administrador",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Modules grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildErrorView()
                    : _modules == null || _modules!.isEmpty
                        ? _buildEmptyView()
                        : _buildModulesGrid(),
          ),
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
            Text(
              'Error al cargar módulos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadModules,
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
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apps, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No hay módulos disponibles',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModulesGrid() {
    return RefreshIndicator(
      onRefresh: _loadModules,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _modules!.length,
        itemBuilder: (context, index) {
          final module = _modules![index];
          return _buildModuleCard(module);
        },
      ),
    );
  }

  Widget _buildModuleCard(Module module) {
    final isActive = module.activo;
    final color = isActive ? Theme.of(context).primaryColor : Colors.grey;

    return InkWell(
      onTap: () => _handleModuleTap(module),
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: isActive ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isActive
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color,
                      color.withOpacity(0.8),
                    ],
                  )
                : null,
            color: isActive ? null : Colors.grey.shade100,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white.withOpacity(0.2) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  module.iconData,
                  size: 32,
                  color: isActive ? Colors.white : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),

              // Module name
              Text(
                module.nombre,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),

              // Status badge
              if (!isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Próximamente',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
