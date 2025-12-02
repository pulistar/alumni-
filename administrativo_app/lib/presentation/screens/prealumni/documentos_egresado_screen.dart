import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../../../data/models/documento.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../core/config/api_config.dart';

class DocumentosEgresadoScreen extends StatefulWidget {
  final String egresadoId;
  final String egresadoNombre;

  const DocumentosEgresadoScreen({
    super.key,
    required this.egresadoId,
    required this.egresadoNombre,
  });

  @override
  State<DocumentosEgresadoScreen> createState() => _DocumentosEgresadoScreenState();
}

class _DocumentosEgresadoScreenState extends State<DocumentosEgresadoScreen> {
  final ApiService _apiService = ApiService();
  List<Documento> _documentos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDocumentos();
  }

  Future<void> _loadDocumentos() async {
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

      final data = await _apiService.getDocumentosEgresado(token, widget.egresadoId);
      
      if (mounted) {
        setState(() {
          _documentos = data.map((json) => Documento.fromJson(json)).toList();
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

  Future<void> _abrirDocumento(String documentoId) async {
    print('🔵 Intentando descargar documento con ID: $documentoId');
    
    if (documentoId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID de documento no disponible'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Show loading
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
                  Text('Descargando documento...'),
                ],
              ),
            ),
          ),
        ),
      );

      final authService = Provider.of<AuthService>(context, listen: false);
      final token = authService.accessToken;
      
      if (token == null) throw Exception('No hay token de autenticación');

      print('🔵 Descargando desde: ${ApiConfig.baseUrl}/admin/documentos/$documentoId/download');

      // Download file from backend
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/documentos/$documentoId/download'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('🔵 Status de descarga: ${response.statusCode}');

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      if (response.statusCode == 200) {
        // Get filename from headers or use default
        String filename = 'documento.pdf';
        final contentDisposition = response.headers['content-disposition'];
        if (contentDisposition != null) {
          final match = RegExp(r'filename="?([^"]+)"?').firstMatch(contentDisposition);
          if (match != null) {
            filename = match.group(1) ?? filename;
          }
        }

        print('🔵 Nombre de archivo: $filename');

        // Save file
        String? outputPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Guardar documento',
          fileName: filename,
        );

        if (outputPath != null) {
          final file = File(outputPath);
          await file.writeAsBytes(response.bodyBytes);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ Documento guardado en: $outputPath'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } else {
        print('❌ Error en descarga: ${response.body}');
        throw Exception('Error al descargar documento (${response.statusCode})');
      }
    } catch (e) {
      print('❌ Exception en descarga: $e');
      if (mounted) {
        Navigator.pop(context); // Close loading if open
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
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Documentos'),
            Text(
              widget.egresadoNombre,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _buildDocumentosList(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text('Error al cargar documentos', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(_errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadDocumentos,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentosList() {
    if (_documentos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('No hay documentos', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('El egresado no ha subido documentos aún'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _documentos.length,
      itemBuilder: (context, index) {
        final doc = _documentos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getEstadoColor(doc.estado).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.description, color: _getEstadoColor(doc.estado)),
            ),
            title: Text(
              _formatTipoDocumento(doc.tipoDocumento),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(doc.nombreArchivo),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getEstadoColor(doc.estado),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        doc.estado.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (doc.fechaSubida != null)
                      Text(
                        'Subido: ${_formatDate(doc.fechaSubida!)}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _abrirDocumento(doc.id),
              tooltip: 'Descargar documento',
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'aprobado':
        return Colors.green;
      case 'rechazado':
        return Colors.red;
      case 'pendiente':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatTipoDocumento(String tipo) {
    return tipo.replaceAll('_', ' ').toUpperCase();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
