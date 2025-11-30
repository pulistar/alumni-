import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/constants.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/carreras_service.dart';
import '../../../data/services/estados_laborales_service.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final CarrerasService _carrerasService = CarrerasService();
  final EstadosLaboralesService _estadosLaboralesService = EstadosLaboralesService();
  
  // Controllers para los campos
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _telefonoController;
  late TextEditingController _ciudadController;
  late TextEditingController _empresaController;
  late TextEditingController _cargoController;
  
  // Datos para dropdowns
  List<Map<String, dynamic>> _carreras = [];
  List<Map<String, dynamic>> _estadosLaborales = [];
  
  // Valores seleccionados
  String? _selectedCarreraId;
  String? _selectedEstadoLaboralId;
  
  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadData();
  }

  void _initializeControllers() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthenticatedWithProfile) {
      final egresado = authState.egresado;
      
      _nombreController = TextEditingController(text: egresado.nombre);
      _apellidoController = TextEditingController(text: egresado.apellido);
      _telefonoController = TextEditingController(text: egresado.telefono ?? '');
      _ciudadController = TextEditingController(text: egresado.ciudad ?? '');
      _empresaController = TextEditingController(text: egresado.empresaActual ?? '');
      _cargoController = TextEditingController(text: egresado.cargoActual ?? '');
      
      _selectedCarreraId = egresado.carreraId;
      _selectedEstadoLaboralId = egresado.estadoLaboralId;
    } else {
      _nombreController = TextEditingController();
      _apellidoController = TextEditingController();
      _telefonoController = TextEditingController();
      _ciudadController = TextEditingController();
      _empresaController = TextEditingController();
      _cargoController = TextEditingController();
    }
  }

  Future<void> _loadData() async {
    try {
      final carreras = await _carrerasService.getCarreras();
      final estados = await _estadosLaboralesService.getEstadosLaborales();
      
      if (mounted) {
        setState(() {
          _carreras = carreras;
          _estadosLaborales = estados;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      print('❌ Error cargando datos: $e');
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    _ciudadController.dispose();
    _empresaController.dispose();
    _cargoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Editar Perfil',
          style: TextStyle(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textOnPrimary),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                'Guardar',
                style: TextStyle(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información Personal
                      _buildPersonalSection(),
                      
                      const SizedBox(height: AppConstants.paddingLarge),
                      
                      // Información Académica
                      _buildAcademicSection(),
                      
                      const SizedBox(height: AppConstants.paddingLarge),
                      
                      // Información Laboral
                      _buildWorkSection(),
                      
                      const SizedBox(height: AppConstants.paddingLarge * 2),
                      
                      // Botón Guardar
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildPersonalSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Información Personal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            TextFormField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre es requerido';
                }
                return null;
              },
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            TextFormField(
              controller: _apellidoController,
              decoration: InputDecoration(
                labelText: 'Apellido',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El apellido es requerido';
                }
                return null;
              },
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            TextFormField(
              controller: _telefonoController,
              decoration: InputDecoration(
                labelText: 'Teléfono',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            TextFormField(
              controller: _ciudadController,
              decoration: InputDecoration(
                labelText: 'Ciudad',
                prefixIcon: Icon(Icons.location_city),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.school_outlined,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Información Académica',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            DropdownButtonFormField<String>(
              value: _selectedCarreraId,
              decoration: InputDecoration(
                labelText: 'Carrera',
                prefixIcon: Icon(Icons.school),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
              items: _carreras.map((carrera) {
                return DropdownMenuItem<String>(
                  value: carrera['id'],
                  child: Text(carrera['nombre']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCarreraId = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.work_outline,
                  color: AppColors.info,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Información Laboral',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            DropdownButtonFormField<String>(
              value: _selectedEstadoLaboralId,
              decoration: InputDecoration(
                labelText: 'Estado Laboral',
                prefixIcon: Icon(Icons.work),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
              items: _estadosLaborales.map((estado) {
                return DropdownMenuItem<String>(
                  value: estado['id'],
                  child: Text(estado['nombre']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedEstadoLaboralId = value;
                });
              },
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            TextFormField(
              controller: _empresaController,
              decoration: InputDecoration(
                labelText: 'Empresa Actual',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            TextFormField(
              controller: _cargoController,
              decoration: InputDecoration(
                labelText: 'Cargo Actual',
                prefixIcon: Icon(Icons.badge),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
                ),
              )
            : Text(
                'Guardar Cambios',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textOnPrimary,
                ),
              ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.updateProfile(
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        telefono: _telefonoController.text.trim().isEmpty ? null : _telefonoController.text.trim(),
        ciudad: _ciudadController.text.trim().isEmpty ? null : _ciudadController.text.trim(),
        carreraId: _selectedCarreraId,
        estadoLaboralId: _selectedEstadoLaboralId,
        empresaActual: _empresaController.text.trim().isEmpty ? null : _empresaController.text.trim(),
        cargoActual: _cargoController.text.trim().isEmpty ? null : _cargoController.text.trim(),
      );

      // Refrescar el perfil en el AuthBloc
      if (mounted) {
        context.read<AuthBloc>().add(AuthProfileRefreshRequested());
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Perfil actualizado exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
        
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('❌ Error actualizando perfil: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al actualizar el perfil: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
