import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:universal_html/html.dart' as html;
import '../../../data/models/egresado.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/auth_service.dart';
import 'egresados_list_screen.dart';
import 'preguntas_screen.dart';
import 'modulos_screen.dart';
import 'estadisticas_screen.dart';
import 'pdfs_unificados_screen.dart';

/// PreAlumni Dashboard Screen
class PreAlumniDashboardScreen extends StatefulWidget {
  const PreAlumniDashboardScreen({super.key});

  @override
  State<PreAlumniDashboardScreen> createState() => _PreAlumniDashboardScreenState();
}

class _PreAlumniDashboardScreenState extends State<PreAlumniDashboardScreen> {
  final ApiService _apiService = ApiService();
  DashboardStats? _stats;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
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

      final stats = await _apiService.getDashboardStats(token);

      if (mounted) {
        setState(() {
          _stats = stats;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Red de Contacto'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _buildDashboard(),
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
            Text('Error al cargar estadísticas', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadStats,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats cards
            _buildStatsGrid(),
            const SizedBox(height: 24),

            // Quick actions
            Text('Acciones Rápidas', 
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Egresados',
          _stats!.totalEgresados.toString(),
          Icons.people,
          Colors.blue,
        ),
        _buildStatCard(
          'Habilitados',
          _stats!.egresadosHabilitados.toString(),
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'Documentos Completos',
          _stats!.documentosCompletos.toString(),
          Icons.task_alt,
          Colors.orange,
        ),
        _buildStatCard(
          'Autoevaluaciones',
          _stats!.autoevaluacionesCompletas.toString(),
          Icons.assignment_turned_in,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.7)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareerStats() {
    return Column(
      children: _stats!.porCarrera.map((carrera) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.school, color: Colors.blue.shade700),
            ),
            title: Text(
              carrera.carrera,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${carrera.total} egresados'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildCareerStatRow(
                      'Habilitados',
                      carrera.habilitados,
                      carrera.total,
                      Colors.green,
                    ),
                    const SizedBox(height: 8),
                    _buildCareerStatRow(
                      'Documentos Completos',
                      carrera.documentosCompletos,
                      carrera.total,
                      Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    _buildCareerStatRow(
                      'Autoevaluaciones',
                      carrera.autoevaluacionesCompletas,
                      carrera.total,
                      Colors.purple,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCareerStatRow(String label, int value, int total, Color color) {
    final percentage = total > 0 ? (value / total * 100).toStringAsFixed(1) : '0.0';
    
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label),
        ),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$value / $total',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: total > 0 ? value / total : 0,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        _buildActionCard(
          'Ver Estadísticas Detalladas',
          'Empleo, autoevaluación y más',
          Icons.bar_chart,
          Colors.indigo,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EstadisticasScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          'Gestionar Egresados',
          'Ver, buscar y habilitar egresados',
          Icons.people_alt,
          Colors.blue,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EgresadosListScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          'Habilitar desde Excel',
          'Cargar archivo Excel para habilitar múltiples egresados',
          Icons.upload_file,
          Colors.purple,
          _handleExcelUpload,
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          'Exportar Reportes',
          'Descargar datos en Excel',
          Icons.download,
          Colors.green,
          _showExportMenu,
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          'Configurar Preguntas',
          'Gestionar autoevaluación',
          Icons.quiz,
          Colors.orange,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PreguntasScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          'PDFs Unificados',
          'Descargar PDFs por carrera',
          Icons.picture_as_pdf,
          Colors.red,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PdfsUnificadosScreen()),
            );
          },
        ),
      ],
    );
  }

  Future<void> _handleExcelUpload() async {
    try {
      // Import file_picker
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result == null || result.files.single.path == null) {
        return; // User canceled
      }

      final filePath = result.files.single.path!;
      
      // Show loading dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Procesando archivo Excel...'),
                ],
              ),
            ),
          ),
        ),
      );

      final authService = Provider.of<AuthService>(context, listen: false);
      final token = authService.accessToken;

      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final resultado = await _apiService.uploadExcelToEnableEgresados(token, filePath);

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Show results dialog
      _showResultsDialog(resultado);
      
      // Reload stats
      _loadStats();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog if open
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showResultsDialog(Map<String, dynamic> resultado) {
    final procesados = resultado['procesados'] ?? 0;
    final exitosos = resultado['exitosos'] ?? 0;
    final errores = (resultado['errores'] as List?) ?? [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resultados de la Carga'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📊 Total procesados: $procesados'),
              Text('✅ Habilitados exitosamente: $exitosos', 
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              Text('❌ Errores: ${errores.length}', 
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              
              if (errores.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Detalles de errores:', 
                  style: TextStyle(fontWeight: FontWeight.bold)),
                const Divider(),
                ...errores.take(5).map((error) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Fila ${error['fila']}: ${error['error']}',
                    style: const TextStyle(fontSize: 12),
                  ),
                )),
                if (errores.length > 5)
                  Text('... y ${errores.length - 5} errores más'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showExportMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Exportar Reportes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.people, color: Colors.blue.shade700),
              ),
              title: const Text('Exportar Egresados'),
              subtitle: const Text('Descargar lista completa de egresados'),
              trailing: const Icon(Icons.download),
              onTap: () async {
                Navigator.pop(context);
                await _exportEgresados();
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.assignment, color: Colors.orange.shade700),
              ),
              title: const Text('Exportar Autoevaluaciones'),
              subtitle: const Text('Descargar respuestas de autoevaluaciones'),
              trailing: const Icon(Icons.download),
              onTap: () async {
                Navigator.pop(context);
                await _exportAutoevaluaciones();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _exportEgresados() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = authService.accessToken;
      
      if (token == null) throw Exception('No hay token');
      
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      final bytes = await _apiService.exportEgresadosExcel(token);
      
      // Download file
      _downloadFile(bytes, 'egresados-${DateTime.now().millisecondsSinceEpoch}.xlsx');
      
      if (mounted) {
        Navigator.pop(context); // Close loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Reporte de egresados descargado'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportAutoevaluaciones() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = authService.accessToken;
      
      if (token == null) throw Exception('No hay token');
      
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      final bytes = await _apiService.exportAutoevaluacionesExcel(token);
      
      // Download file
      _downloadFile(bytes, 'autoevaluaciones-${DateTime.now().millisecondsSinceEpoch}.xlsx');
      
      if (mounted) {
        Navigator.pop(context); // Close loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Reporte de autoevaluaciones descargado'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _downloadFile(List<int> bytes, String filename) async {
    try {
      if (kIsWeb) {
        // For web platform
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', filename)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // For desktop/mobile - use file_picker to save
        String? outputPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Guardar archivo',
          fileName: filename,
          type: FileType.custom,
          allowedExtensions: ['xlsx'],
        );

        if (outputPath != null) {
          // Write file to selected path
          final file = File(outputPath);
          await file.writeAsBytes(bytes);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ Archivo guardado en: $outputPath'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else {
          // User cancelled
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Descarga cancelada'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar archivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
