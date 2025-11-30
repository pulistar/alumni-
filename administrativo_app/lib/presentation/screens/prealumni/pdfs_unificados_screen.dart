import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../core/config/api_config.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/auth_service.dart';
import 'pdf_viewer_screen.dart';

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
  
  // Selection mode state
  bool _selectionMode = false;
  Set<String> _selectedDocuments = {};
  bool _isDownloadingMultiple = false;

  @override
  void initState() {
    super.initState();
    _initializeAndLoadPDFs();
  }

  Future<void> _initializeAndLoadPDFs() async {
    // Initialize Spanish locale for date formatting
    await initializeDateFormatting('es', null);
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

      // Debug: Print data structure
      print('🔵 PDFs Unificados data: $data');
      if (data['por_carrera'] != null) {
        final porCarrera = data['por_carrera'] as List<dynamic>;
        print('🔵 Carreras count: ${porCarrera.length}');
        if (porCarrera.isNotEmpty) {
          print('🔵 First carrera: ${porCarrera[0]}');
          final docs = porCarrera[0]['documentos'] as List<dynamic>?;
          if (docs != null && docs.isNotEmpty) {
            print('🔵 First document: ${docs[0]}');
          }
        }
      }

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

  /// Group documents by month/year
  Map<String, List<dynamic>> _groupByMonth(List<dynamic> documents) {
    final Map<String, List<dynamic>> grouped = {};
    
    for (var doc in documents) {
      try {
        final fechaStr = doc['fecha_generacion'] as String?;
        String monthKey;
        
        if (fechaStr == null || fechaStr.isEmpty) {
          // Documents without date go to "Sin fecha"
          monthKey = 'Sin fecha';
        } else {
          try {
            // Parse the date - handle PostgreSQL timestamp format
            DateTime fecha;
            try {
              fecha = DateTime.parse(fechaStr);
            } catch (e) {
              // If parsing fails, try removing microseconds
              // Format: 2025-11-25T13:34:47.744251+00:00
              final cleanedDate = fechaStr.replaceAll(RegExp(r'\.\d+'), '');
              fecha = DateTime.parse(cleanedDate);
            }
            
            monthKey = DateFormat('MMMM yyyy', 'es').format(fecha);
          } catch (e) {
            // If date parsing fails, use "Sin fecha"
            print('❌ Error parsing date: $fechaStr - $e');
            monthKey = 'Sin fecha';
          }
        }
        
        if (!grouped.containsKey(monthKey)) {
          grouped[monthKey] = [];
        }
        grouped[monthKey]!.add(doc);
      } catch (e) {
        // If anything fails, add to "Sin fecha"
        print('❌ Error grouping document: $e');
        if (!grouped.containsKey('Sin fecha')) {
          grouped['Sin fecha'] = [];
        }
        grouped['Sin fecha']!.add(doc);
      }
    }
    
    return grouped;
  }

  /// Preview PDF in viewer screen
  void _previewPDF(String documentoId, String nombreArchivo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(
          documentoId: documentoId,
          nombreArchivo: nombreArchivo,
        ),
      ),
    );
  }

  /// Download single PDF
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

  /// Toggle selection mode
  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      if (!_selectionMode) {
        _selectedDocuments.clear();
      }
    });
  }

  /// Select all documents
  void _selectAll() {
    setState(() {
      _selectedDocuments.clear();
      if (_data != null) {
        final porCarrera = _data!['por_carrera'] as List<dynamic>?;
        if (porCarrera != null) {
          for (var carreraData in porCarrera) {
            final documentos = carreraData['documentos'] as List<dynamic>?;
            if (documentos != null) {
              for (var doc in documentos) {
                final id = doc['id'] as String?;
                if (id != null) {
                  _selectedDocuments.add(id);
                }
              }
            }
          }
        }
      }
    });
  }

  /// Download selected documents
  Future<void> _downloadSelected() async {
    if (_selectedDocuments.isEmpty) return;

    setState(() {
      _isDownloadingMultiple = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = authService.accessToken;

      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      int successCount = 0;
      int errorCount = 0;

      // Get all documents
      final allDocs = <Map<String, dynamic>>[];
      if (_data != null) {
        final porCarrera = _data!['por_carrera'] as List<dynamic>?;
        if (porCarrera != null) {
          for (var carreraData in porCarrera) {
            final documentos = carreraData['documentos'] as List<dynamic>?;
            if (documentos != null) {
              allDocs.addAll(documentos.cast<Map<String, dynamic>>());
            }
          }
        }
      }

      // Download each selected document
      for (var docId in _selectedDocuments) {
        try {
          final doc = allDocs.firstWhere((d) => d['id'] == docId);
          final nombre = doc['nombre_archivo'] as String? ?? 'documento.pdf';
          
          await _downloadPDF(docId, nombre);
          successCount++;
        } catch (e) {
          errorCount++;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Descargados: $successCount | ❌ Errores: $errorCount',
            ),
            backgroundColor: errorCount == 0 ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );

        setState(() {
          _selectionMode = false;
          _selectedDocuments.clear();
        });
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
          _isDownloadingMultiple = false;
        });
      }
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy', 'es').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('PDFs Unificados'),
        actions: [
          if (!_selectionMode)
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: _toggleSelectionMode,
              tooltip: 'Modo selección',
            ),
          if (_selectionMode) ...[
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: _selectAll,
              tooltip: 'Seleccionar todos',
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _toggleSelectionMode,
              tooltip: 'Cancelar',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPDFs,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _selectionMode && _selectedDocuments.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _isDownloadingMultiple ? null : _downloadSelected,
              icon: _isDownloadingMultiple
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download),
              label: Text('Descargar (${_selectedDocuments.length})'),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error al cargar PDFs',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadPDFs,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

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
            Icon(Icons.picture_as_pdf, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No hay PDFs disponibles',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: porCarrera.length,
      itemBuilder: (context, index) {
        final carreraData = porCarrera[index] as Map<String, dynamic>;
        final carrera = carreraData['carrera'] as String? ?? 'Sin carrera';
        final documentos = carreraData['documentos'] as List<dynamic>? ?? [];

        // Group documents by month
        final groupedByMonth = _groupByMonth(documentos);
        final sortedMonths = groupedByMonth.keys.toList()
          ..sort((a, b) {
            try {
              final dateA = DateFormat('MMMM yyyy', 'es').parse(a);
              final dateB = DateFormat('MMMM yyyy', 'es').parse(b);
              return dateB.compareTo(dateA); // Most recent first
            } catch (e) {
              return 0;
            }
          });

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Text(
              carrera,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${documentos.length} documentos'),
            children: sortedMonths.map((month) {
              final monthDocs = groupedByMonth[month]!;
              return ExpansionTile(
                title: Text(
                  month,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
                subtitle: Text('${monthDocs.length} documentos'),
                children: monthDocs.map((doc) {
                  final documentoId = doc['id'] as String?;
                  final nombre = doc['egresado_nombre'] as String? ?? 'Sin nombre';
                  final correo = doc['egresado_correo'] as String? ?? '';
                  final nombreArchivo = doc['nombre_archivo'] as String? ?? 'documento.pdf';
                  final fecha = doc['fecha_generacion'] as String?;
                  final isSelected = documentoId != null && _selectedDocuments.contains(documentoId);

                  return ListTile(
                    leading: _selectionMode
                        ? Checkbox(
                            value: isSelected,
                            onChanged: documentoId == null
                                ? null
                                : (value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedDocuments.add(documentoId);
                                      } else {
                                        _selectedDocuments.remove(documentoId);
                                      }
                                    });
                                  },
                          )
                        : const Icon(Icons.picture_as_pdf, color: Colors.red),
                    title: Text(nombre),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (correo.isNotEmpty)
                          Text(correo, style: const TextStyle(fontSize: 12)),
                        if (fecha != null)
                          Text(
                            'Generado: ${_formatDate(fecha)}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                      ],
                    ),
                    trailing: documentoId != null && !_selectionMode
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility),
                                color: Colors.blue,
                                onPressed: () => _previewPDF(documentoId, nombreArchivo),
                                tooltip: 'Vista previa',
                              ),
                              IconButton(
                                icon: const Icon(Icons.download),
                                color: Colors.green,
                                onPressed: () => _downloadPDF(documentoId, nombreArchivo),
                                tooltip: 'Descargar',
                              ),
                            ],
                          )
                        : null,
                    onTap: _selectionMode && documentoId != null
                        ? () {
                            setState(() {
                              if (isSelected) {
                                _selectedDocuments.remove(documentoId);
                              } else {
                                _selectedDocuments.add(documentoId);
                              }
                            });
                          }
                        : (documentoId != null
                            ? () => _previewPDF(documentoId, nombreArchivo)
                            : null),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
