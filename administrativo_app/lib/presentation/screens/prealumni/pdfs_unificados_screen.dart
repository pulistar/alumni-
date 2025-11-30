import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../../../core/config/api_config.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/auth_service.dart';

class PdfsUnificadosScreen extends StatefulWidget {
  const PdfsUnificadosScreen({super.key});

  @override
  State<PdfsUnificadosScreen> createState() => _PdfsUnificadosScreenState();
}

class _PdfsUnificadosScreenState extends State<PdfsUnificadosScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPDFs();
  }

  Future<void> _loadPDFs() async {
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

      final data = await _apiService.getPDFsUnificados(token);

      if (mounted) {
        setState(() {
          _data = data;
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

  Future<void> _downloadPDF(String documentoId, String nombre) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = authService.accessToken;

      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      if (kIsWeb) {
        // For web, open download endpoint in new tab
        final url = '${ApiConfig.baseUrl}/admin/documentos/$documentoId/download';
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } else {
        // For desktop, download the file
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Descargando archivo...'),
              backgroundColor: Colors.blue,
            ),
          );
        }

        // Download file bytes from backend endpoint
        final url = '${ApiConfig.baseUrl}/admin/documentos/$documentoId/download';
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );
        
        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          
          // Ask user where to save
          String? outputPath = await FilePicker.platform.saveFile(
            dialogTitle: 'Guardar PDF',
            fileName: nombre.endsWith('.pdf') ? nombre : '$nombre.pdf',
            type: FileType.custom,
            allowedExtensions: ['pdf'],
          );

          if (outputPath != null) {
            final file = File(outputPath);
            await file.writeAsBytes(bytes);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ PDF guardado en: $outputPath'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Descarga cancelada'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        } else {
          throw Exception('Error HTTP ${response.statusCode} al descargar el archivo');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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
        title: const Text('PDFs Unificados'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPDFs,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _buildContent(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text('Error al cargar PDFs', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(_errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadPDFs,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_data == null) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    final total = _data!['total'] as int? ?? 0;
    final porCarrera = _data!['por_carrera'] as List<dynamic>? ?? [];

    if (total == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('No hay PDFs unificados', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Los egresados aún no han generado sus PDFs unificados'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary card
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.picture_as_pdf, size: 40, color: Colors.blue.shade700),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total de PDFs',
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                        ),
                        Text(
                          total.toString(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // By career
          Text(
            'Por Carrera',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: porCarrera.length,
            itemBuilder: (context, index) {
              final carreraData = porCarrera[index] as Map<String, dynamic>;
              final carrera = carreraData['carrera'] as String;
              final totalCarrera = carreraData['total'] as int;
              final documentos = carreraData['documentos'] as List<dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      totalCarrera.toString(),
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    carrera,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('$totalCarrera PDF${totalCarrera != 1 ? 's' : ''} disponible${totalCarrera != 1 ? 's' : ''}'),
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: documentos.length,
                      itemBuilder: (context, docIndex) {
                        final doc = documentos[docIndex] as Map<String, dynamic>;
                        final documentoId = doc['id'] as String?;
                        final nombre = doc['egresado_nombre'] as String? ?? 'Sin nombre';
                        final correo = doc['egresado_correo'] as String? ?? '';
                        final nombreArchivo = doc['nombre_archivo'] as String? ?? 'documento.pdf';
                        final fecha = doc['fecha_generacion'] as String?;

                        return ListTile(
                          leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                          title: Text(nombre),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (correo.isNotEmpty) Text(correo, style: const TextStyle(fontSize: 12)),
                              if (fecha != null)
                                Text(
                                  'Generado: ${_formatDate(fecha)}',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                ),
                            ],
                          ),
                          trailing: documentoId != null
                              ? IconButton(
                                  icon: const Icon(Icons.download),
                                  color: Colors.blue,
                                  onPressed: () => _downloadPDF(documentoId, nombreArchivo),
                                )
                              : null,
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
