import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
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
        title: const Text('Estadísticas Detalladas'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
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
            onPressed: _loadStats,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent() {
    if (_stats == null || _stats!.porCarrera.isEmpty) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    // Calculate global employment stats
    int totalEmpleados = 0;
    int totalDesempleados = 0;
    int totalEgresados = 0;

    for (var carrera in _stats!.porCarrera) {
      totalEmpleados += carrera.empleados;
      totalDesempleados += carrera.desempleados;
      totalEgresados += carrera.total;
    }

    int totalOtros = totalEgresados - totalEmpleados - totalDesempleados;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Global Charts Section
          Text(
            'Resumen Global',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildGlobalPieChart(
            'Estado Laboral',
            [
              PieChartSectionData(
                value: totalEmpleados.toDouble(),
                title: '${_calculatePercentage(totalEmpleados, totalEgresados)}%',
                color: Colors.green,
                radius: 50,
                titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              PieChartSectionData(
                value: totalDesempleados.toDouble(),
                title: '${_calculatePercentage(totalDesempleados, totalEgresados)}%',
                color: Colors.red,
                radius: 50,
                titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              if (totalOtros > 0)
                PieChartSectionData(
                  value: totalOtros.toDouble(),
                  title: '${_calculatePercentage(totalOtros, totalEgresados)}%',
                  color: Colors.grey,
                  radius: 50,
                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
            ],
            [
              _buildLegendItem('Empleados', Colors.green, totalEmpleados),
              _buildLegendItem('Desempleados', Colors.red, totalDesempleados),
              if (totalOtros > 0) _buildLegendItem('Sin Info / Otros', Colors.grey, totalOtros),
            ],
          ),
          const SizedBox(height: 24),
          
          // Per Career Section
          Text(
            'Detalle por Carrera',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _stats!.porCarrera.length,
            itemBuilder: (context, index) {
              final carrera = _stats!.porCarrera[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  leading: const Icon(Icons.school, color: Colors.blue),
                  title: Text(carrera.carrera, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${carrera.total} egresados'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 150,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 30,
                                  sections: [
                                    PieChartSectionData(
                                      value: carrera.empleados.toDouble(),
                                      title: '',
                                      color: Colors.green,
                                      radius: 40,
                                    ),
                                    PieChartSectionData(
                                      value: carrera.desempleados.toDouble(),
                                      title: '',
                                      color: Colors.red,
                                      radius: 40,
                                    ),
                                    PieChartSectionData(
                                      value: (carrera.total - carrera.empleados - carrera.desempleados).toDouble(),
                                      title: '',
                                      color: Colors.grey.shade300,
                                      radius: 40,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLegendItem('Empleados', Colors.green, carrera.empleados),
                                _buildLegendItem('Desempleados', Colors.red, carrera.desempleados),
                                _buildLegendItem('Otros', Colors.grey.shade300, carrera.total - carrera.empleados - carrera.desempleados),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildGlobalPieChart(String title, List<PieChartSectionData> sections, List<Widget> legendItems) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: sections,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: legendItems,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label ($value)',
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _calculatePercentage(int value, int total) {
    if (total == 0) return '0';
    return (value / total * 100).toStringAsFixed(1);
  }
}
