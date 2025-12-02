import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../data/models/egresado.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/auth_service.dart';

class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  final ApiService _apiService = ApiService();
  DashboardStats? _stats;
  List<dynamic>? _distribucionCarrera;
  Map<String, dynamic>? _tasaEmpleabilidad;
  List<dynamic>? _empleabilidadCarrera;
  List<dynamic>? _embudoProceso;
  List<dynamic>? _radarCompetencias;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
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

      // Load all analytics data in parallel
      final results = await Future.wait([
        _apiService.getDashboardStats(token),
        _apiService.getDistribucionCarrera(token),
        _apiService.getTasaEmpleabilidad(token),
        _apiService.getEmpleabilidadCarrera(token),
        _apiService.getEmbudoProceso(token),
        _apiService.getRadarCompetencias(token),
      ]);

      if (mounted) {
        setState(() {
          _stats = results[0] as DashboardStats;
          _distribucionCarrera = results[1] as List<dynamic>;
          _tasaEmpleabilidad = results[2] as Map<String, dynamic>;
          _empleabilidadCarrera = results[3] as List<dynamic>;
          _embudoProceso = results[4] as List<dynamic>;
          _radarCompetencias = results[5] as List<dynamic>;
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
        title: const Text('Estadísticas Detalladas'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Descargar Estadísticas',
            onPressed: _exportEstadisticas,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _buildStatsContent(),
    );
  }

  Widget _buildErrorView() {
    return Center(
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
            onPressed: _loadAllData,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Distribution + Employment Rate
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildDistribucionCarrera()),
              const SizedBox(width: 16),
              Expanded(child: _buildTasaEmpleabilidad()),
            ],
          ),
          const SizedBox(height: 16),
          
          // Row 2: Employment by Career
          _buildEmpleabilidadCarrera(),
          const SizedBox(height: 16),
          
          // Row 3: Process Funnel + Competencies Radar
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildEmbudoProceso()),
              const SizedBox(width: 16),
              Expanded(child: _buildRadarCompetencias()),
            ],
          ),
        ],
      ),
    );
  }

  // Chart 1: Distribution by Career (Bar Chart)
  Widget _buildDistribucionCarrera() {
    if (_distribucionCarrera == null || _distribucionCarrera!.isEmpty) {
      return _buildEmptyCard('Distribución por Carrera', 'No hay datos disponibles');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribución por Carrera',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _distribucionCarrera!.map((e) => (e['total'] as num).toDouble()).reduce((a, b) => a > b ? a : b) * 1.2,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < _distribucionCarrera!.length) {
                            final carrera = _distribucionCarrera![value.toInt()]['carrera'] as String;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                carrera.length > 15 ? '${carrera.substring(0, 12)}...' : carrera,
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _distribucionCarrera!.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: (entry.value['total'] as num).toDouble(),
                          color: Colors.blue,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Chart 2: Employment Rate (Donut Chart)
  Widget _buildTasaEmpleabilidad() {
    if (_tasaEmpleabilidad == null) {
      return _buildEmptyCard('Tasa de Empleabilidad', 'No hay datos disponibles');
    }

    final empleados = (_tasaEmpleabilidad!['empleados'] as num?)?.toDouble() ?? 0;
    final desempleados = (_tasaEmpleabilidad!['desempleados'] as num?)?.toDouble() ?? 0;
    final estudiando = (_tasaEmpleabilidad!['estudiando'] as num?)?.toDouble() ?? 0;
    final otros = (_tasaEmpleabilidad!['otros'] as num?)?.toDouble() ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tasa de Empleabilidad',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: [
                    if (empleados > 0)
                      PieChartSectionData(
                        value: empleados,
                        title: '${empleados.toInt()}\nEmpleados',
                        color: Colors.green,
                        radius: 80,
                        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    if (desempleados > 0)
                      PieChartSectionData(
                        value: desempleados,
                        title: '${desempleados.toInt()}\nDesempleados',
                        color: Colors.red,
                        radius: 80,
                        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    if (estudiando > 0)
                      PieChartSectionData(
                        value: estudiando,
                        title: '${estudiando.toInt()}\nEstudiando',
                        color: Colors.blue,
                        radius: 80,
                        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    if (otros > 0)
                      PieChartSectionData(
                        value: otros,
                        title: '${otros.toInt()}\nOtros',
                        color: Colors.grey,
                        radius: 80,
                        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Chart 3: Employment by Career (Grouped Bar Chart)
  Widget _buildEmpleabilidadCarrera() {
    if (_empleabilidadCarrera == null || _empleabilidadCarrera!.isEmpty) {
      return _buildEmptyCard('Empleabilidad por Carrera', 'No hay datos disponibles');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Empleabilidad por Carrera',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._empleabilidadCarrera!.map((item) {
              final carrera = item['carrera'] as String;
              final empleados = (item['empleados'] as num?)?.toInt() ?? 0;
              final desempleados = (item['desempleados'] as num?)?.toInt() ?? 0;
              final total = (item['total'] as num?)?.toInt() ?? 1;
              final porcentaje = (item['porcentaje_empleados'] as num?)?.toInt() ?? 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            carrera,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          '$porcentaje% empleados',
                          style: TextStyle(
                            color: porcentaje >= 70 ? Colors.green : porcentaje >= 50 ? Colors.orange : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          flex: empleados,
                          child: Container(
                            height: 20,
                            color: Colors.green,
                            alignment: Alignment.center,
                            child: Text(
                              empleados > 0 ? '$empleados' : '',
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ),
                        if (desempleados > 0)
                          Expanded(
                            flex: desempleados,
                            child: Container(
                              height: 20,
                              color: Colors.red,
                              alignment: Alignment.center,
                              child: Text(
                                '$desempleados',
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Chart 4: Process Funnel
  Widget _buildEmbudoProceso() {
    if (_embudoProceso == null || _embudoProceso!.isEmpty) {
      return _buildEmptyCard('Embudo de Proceso', 'No hay datos disponibles');
    }

    final maxValue = _embudoProceso!.map((e) => (e['total'] as num).toDouble()).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Embudo de Proceso',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._embudoProceso!.map((stage) {
              final etapa = stage['etapa'] as String;
              final total = (stage['total'] as num).toInt();
              final percentage = maxValue > 0 ? (total / maxValue).toDouble() : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(etapa, style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text('$total', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage,
                      minHeight: 20,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue.withOpacity(0.7 + (percentage * 0.3)),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Chart 5: Competencies Radar
  Widget _buildRadarCompetencias() {
    // Validate that we have at least 3 entries for radar chart
    if (_radarCompetencias == null || _radarCompetencias!.length < 3) {
      return _buildEmptyCard('Radar de Competencias', 'No hay suficientes datos de autoevaluación (mínimo 3 categorías)');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Radar de Competencias',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Promedio de calificaciones (1-5)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: RadarChart(
                RadarChartData(
                  radarShape: RadarShape.polygon,
                  tickCount: 5,
                  ticksTextStyle: const TextStyle(fontSize: 10, color: Colors.transparent),
                  radarBorderData: const BorderSide(color: Colors.grey, width: 1),
                  gridBorderData: const BorderSide(color: Colors.grey, width: 0.5),
                  tickBorderData: const BorderSide(color: Colors.transparent),
                  getTitle: (index, angle) {
                    if (index < _radarCompetencias!.length) {
                      final categoria = _radarCompetencias![index]['categoria'] as String;
                      return RadarChartTitle(
                        text: categoria.length > 15 ? '${categoria.substring(0, 12)}...' : categoria,
                        angle: angle,
                      );
                    }
                    return const RadarChartTitle(text: '');
                  },
                  dataSets: [
                    RadarDataSet(
                      fillColor: Colors.blue.withOpacity(0.2),
                      borderColor: Colors.blue,
                      borderWidth: 2,
                      dataEntries: _radarCompetencias!.map((item) {
                        final promedio = (item['promedio'] as num).toDouble();
                        return RadarEntry(value: promedio);
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String title, String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(message, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportEstadisticas() async {
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
      
      // Add pages with statistics
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            // Title
            pw.Header(
              level: 0,
              child: pw.Text(
                'Estadísticas Detalladas',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            
            // Resumen General
            pw.Header(level: 1, text: 'Resumen General'),
            pw.Table.fromTextArray(
              headers: ['Métrica', 'Valor'],
              data: [
                ['Total Egresados', _stats?.totalEgresados.toString() ?? '0'],
                ['Egresados Habilitados', _stats?.egresadosHabilitados.toString() ?? '0'],
                ['Documentos Completos', _stats?.documentosCompletos.toString() ?? '0'],
                ['Autoevaluaciones Completas', _stats?.autoevaluacionesCompletas.toString() ?? '0'],
              ],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.centerLeft,
            ),
            pw.SizedBox(height: 20),
            
            // Distribución por Carrera
            if (_distribucionCarrera != null && _distribucionCarrera!.isNotEmpty) ...[
              pw.Header(level: 1, text: 'Distribución por Carrera'),
              pw.Table.fromTextArray(
                headers: ['Carrera', 'Total'],
                data: _distribucionCarrera!.map((item) => [
                  item['carrera'].toString(),
                  item['total'].toString(),
                ]).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              ),
              pw.SizedBox(height: 20),
            ],
            
            // Tasa de Empleabilidad
            if (_tasaEmpleabilidad != null) ...[
              pw.Header(level: 1, text: 'Tasa de Empleabilidad'),
              pw.Table.fromTextArray(
                headers: ['Estado', 'Cantidad', 'Porcentaje'],
                data: [
                  ['Empleados', _tasaEmpleabilidad!['empleados'].toString(), '${_tasaEmpleabilidad!['porcentaje_empleados']}%'],
                  ['Desempleados', _tasaEmpleabilidad!['desempleados'].toString(), '${_tasaEmpleabilidad!['porcentaje_desempleados']}%'],
                  ['Estudiando', _tasaEmpleabilidad!['estudiando'].toString(), '-'],
                  ['Otros', _tasaEmpleabilidad!['otros'].toString(), '-'],
                  ['Total', _tasaEmpleabilidad!['total'].toString(), '100%'],
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              ),
              pw.SizedBox(height: 20),
            ],
            
            // Empleabilidad por Carrera
            if (_empleabilidadCarrera != null && _empleabilidadCarrera!.isNotEmpty) ...[
              pw.Header(level: 1, text: 'Empleabilidad por Carrera'),
              pw.Table.fromTextArray(
                headers: ['Carrera', 'Empleados', 'Desempleados', 'Total', '% Empleados'],
                data: _empleabilidadCarrera!.map((item) => [
                  item['carrera'].toString(),
                  item['empleados'].toString(),
                  item['desempleados'].toString(),
                  item['total'].toString(),
                  '${item['porcentaje_empleados']}%',
                ]).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              ),
              pw.SizedBox(height: 20),
            ],
            
            // Embudo de Proceso
            if (_embudoProceso != null && _embudoProceso!.isNotEmpty) ...[
              pw.Header(level: 1, text: 'Embudo de Proceso'),
              pw.Table.fromTextArray(
                headers: ['Etapa', 'Total'],
                data: _embudoProceso!.map((item) => [
                  item['etapa'].toString(),
                  item['total'].toString(),
                ]).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              ),
              pw.SizedBox(height: 20),
            ],
            
            // Radar de Competencias
            if (_radarCompetencias != null && _radarCompetencias!.isNotEmpty) ...[
              pw.Header(level: 1, text: 'Radar de Competencias'),
              pw.Table.fromTextArray(
                headers: ['Categoría', 'Promedio', 'Total Respuestas'],
                data: _radarCompetencias!.map((item) => [
                  item['categoria'].toString(),
                  item['promedio'].toString(),
                  item['total_respuestas'].toString(),
                ]).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              ),
            ],
          ],
        ),
      );
      
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      
      // Save PDF
      final bytes = await pdf.save();
      
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar estadísticas PDF',
        fileName: 'estadisticas-${DateTime.now().millisecondsSinceEpoch}.pdf',
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
