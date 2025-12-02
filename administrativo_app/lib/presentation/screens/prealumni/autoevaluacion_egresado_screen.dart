import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import '../../../data/models/respuesta_autoevaluacion.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/auth_service.dart';

class AutoevaluacionEgresadoScreen extends StatefulWidget {
  final String egresadoId;
  final String egresadoNombre;

  const AutoevaluacionEgresadoScreen({
    super.key,
    required this.egresadoId,
    required this.egresadoNombre,
  });

  @override
  State<AutoevaluacionEgresadoScreen> createState() => _AutoevaluacionEgresadoScreenState();
}

class _AutoevaluacionEgresadoScreenState extends State<AutoevaluacionEgresadoScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _respuestas = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRespuestas();
  }

  Future<void> _loadRespuestas() async {
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

      final respuestas = await _apiService.getEgresadoAutoevaluacion(token, widget.egresadoId);

      if (mounted) {
        setState(() {
          _respuestas = respuestas;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Check if it's a 404 or empty response (egresado has no responses)
          final errorMsg = e.toString().replaceAll('Exception: ', '');
          if (errorMsg.contains('404') || errorMsg.contains('no encontrad')) {
            // No error, just empty - let the empty state show
            _respuestas = [];
            _isLoading = false;
          } else {
            _errorMessage = errorMsg;
            _isLoading = false;
          }
        });
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
            const Text('Autoevaluación'),
            Text(
              widget.egresadoNombre,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_respuestas.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'Descargar respuestas',
              onPressed: _exportarRespuestas,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _buildRespuestasList(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text('Error al cargar respuestas', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(_errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadRespuestas,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildRespuestasList() {
    if (_respuestas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_late_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('No hay respuestas', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('El egresado no ha completado la autoevaluación'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _respuestas.length,
      itemBuilder: (context, index) {
        final respuesta = _respuestas[index] as Map<String, dynamic>;
        final pregunta = respuesta['pregunta'] as Map<String, dynamic>?;
        final preguntaTexto = pregunta?['texto'] ?? 'Pregunta sin texto';
        final tipoPregunta = pregunta?['tipo'] ?? 'unknown';
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  preguntaTexto,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _buildRespuestaContent(respuesta, tipoPregunta),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRespuestaContent(Map<String, dynamic> respuesta, String tipo) {
    switch (tipo) {
      case 'likert':
        final valor = respuesta['respuesta_numerica'] as int? ?? 0;
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Text(
                valor.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LinearProgressIndicator(
                value: valor / 5,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
              ),
            ),
            const SizedBox(width: 12),
            const Text('5', style: TextStyle(color: Colors.grey)),
          ],
        );
      
      case 'texto':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(respuesta['respuesta_texto'] ?? 'Sin respuesta'),
        );
        
      case 'multiple':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Text(
            respuesta['respuesta_texto'] ?? 'Sin selección',
            style: TextStyle(color: Colors.orange.shade800),
          ),
        );
        
      default:
        return Text(respuesta['respuesta_texto'] ?? '-');
    }
  }

  Future<void> _exportarRespuestas() async {
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
                  Text('Generando PDF...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Generate PDF
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            // Title
            pw.Header(
              level: 0,
              child: pw.Text(
                'Autoevaluación - ${widget.egresadoNombre}',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),

            // Responses table
            pw.Table.fromTextArray(
              headers: ['Pregunta', 'Tipo', 'Respuesta'],
              data: _respuestas.map((respuesta) {
                final pregunta = respuesta['pregunta'] as Map<String, dynamic>?;
                final preguntaTexto = pregunta?['texto'] ?? 'Pregunta sin texto';
                final tipoPregunta = pregunta?['tipo'] ?? 'unknown';
                
                String respuestaTexto = '';
                if (tipoPregunta == 'likert') {
                  final valor = respuesta['respuesta_numerica'] as int? ?? 0;
                  respuestaTexto = '$valor / 5';
                } else {
                  respuestaTexto = respuesta['respuesta_texto'] ?? 'Sin respuesta';
                }

                return [
                  preguntaTexto,
                  tipoPregunta.toUpperCase(),
                  respuestaTexto,
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.centerLeft,
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      // Save PDF
      final bytes = await pdf.save();

      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar respuestas',
        fileName: 'autoevaluacion-${widget.egresadoNombre.replaceAll(' ', '_')}-${DateTime.now().millisecondsSinceEpoch}.pdf',
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
    } catch (e) {
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
}
