import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../../core/config/api_config.dart';
import '../../../data/services/auth_service.dart';

/// PDF Viewer Screen
/// Preview PDF documents before downloading
class PdfViewerScreen extends StatefulWidget {
  final String documentoId;
  final String nombreArchivo;

  const PdfViewerScreen({
    super.key,
    required this.documentoId,
    required this.nombreArchivo,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  bool _isDownloading = false;

  Future<void> _downloadPDF() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = authService.accessToken;

      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      // Download file bytes from backend endpoint
      final url = '${ApiConfig.baseUrl}/admin/documentos/${widget.documentoId}/download';
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
          fileName: widget.nombreArchivo.endsWith('.pdf')
              ? widget.nombreArchivo
              : '${widget.nombreArchivo}.pdf',
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
        }
      } else {
        throw Exception('Error HTTP ${response.statusCode}');
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
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.accessToken;

    if (token == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('No hay token de autenticación')),
      );
    }

    final url = '${ApiConfig.baseUrl}/admin/documentos/${widget.documentoId}/download';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.nombreArchivo,
          style: const TextStyle(fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: _isDownloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.download),
            onPressed: _isDownloading ? null : _downloadPDF,
            tooltip: 'Descargar PDF',
          ),
        ],
      ),
      body: SfPdfViewer.network(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
        onDocumentLoadFailed: (details) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar PDF: ${details.error}'),
              backgroundColor: Colors.red,
            ),
          );
        },
      ),
    );
  }
}
