import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/constants.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/carreras_service.dart';
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
  
  // Controllers para los campos
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _celularController;
  late TextEditingController _telefonoAlternativoController;
  late TextEditingController _correoPersonalController;
  
  // Datos para dropdowns
  List<Map<String, dynamic>> _carreras = [];
  List<Map<String, dynamic>> _gradosAcademicos = [];
  
  // Valores seleccionados
  String? _selectedCarreraId;
  String? _selectedGradoAcademicoId;
  
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
      _celularController = TextEditingController(text: egresado.celular);
      _telefonoAlternativoController = TextEditingController(text: egresado.telefonoAlternativo ?? '');
      _correoPersonalController = TextEditingController(text: egresado.correoPersonal);
      
      _selectedCarreraId = egresado.carreraId;
      _selectedGradoAcademicoId = egresado.gradoAcademicoId;
    } else {
      _nombreController = TextEditingController();
      _apellidoController = TextEditingController();
      _celularController = TextEditingController();
      _telefonoAlternativoController = TextEditingController();
      _correoPersonalController = TextEditingController();
    }
  }

  Future<void> _loadData() async {
    try {
      final carreras = await _carrerasService.getCarreras();
      final grados = await _authService.getGradosAcademicos();
      
      if (mounted) {
        setState(() {
          _carreras = carreras;
          _gradosAcademicos = grados;
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
    _celularController.dispose();
    _telefonoAlternativoController.dispose();
    _correoPersonalController.dispose();
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
                      
                      // Información de Contacto
                      _buildContactSection(),
                      
                      const SizedBox(height: AppConstants.paddingLarge),
                      
                      // Información Académica
                      _buildAcademicSection(),
                      
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
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
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
                  Icons.contact_phone_outlined,
                  color: AppColors.info,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Información de Contacto',
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
              controller: _celularController,
              decoration: InputDecoration(
                labelText: 'Celular',
                prefixIcon: Icon(Icons.phone_android),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El celular es requerido';
                }
                return null;
              },
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            TextFormField(
              controller: _telefonoAlternativoController,
              decoration: InputDecoration(
                labelText: 'Teléfono Alternativo (Opcional)',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            TextFormField(
              controller: _correoPersonalController,
              decoration: InputDecoration(
                labelText: 'Correo Personal',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El correo personal es requerido';
                }
                if (!value.contains('@')) {
                  return 'Ingrese un correo válido';
                }
                return null;
              },
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
              value: _selectedGradoAcademicoId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Grado Académico',
                prefixIcon: Icon(Icons.school),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
              items: _gradosAcademicos.map((grado) {
                return DropdownMenuItem<String>(
                  value: grado['id'],
                  child: Text(
                    grado['nombre'],
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGradoAcademicoId = value;
                  // Resetear carrera si cambia el grado (opcional, depende de la lógica)
                  _selectedCarreraId = null;
                });
              },
              validator: (value) => value == null ? 'Seleccione un grado' : null,
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            DropdownButtonFormField<String>(
              value: _selectedCarreraId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Carrera',
                prefixIcon: Icon(Icons.school),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
              items: _carreras
                  .where((c) => _selectedGradoAcademicoId == null || c['grado_academico_id'] == _selectedGradoAcademicoId)
                  .map((carrera) {
                return DropdownMenuItem<String>(
                  value: carrera['id'],
                  child: Text(
                    carrera['nombre'],
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCarreraId = value;
                });
              },
              validator: (value) => value == null ? 'Seleccione una carrera' : null,
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
        celular: _celularController.text.trim(),
        telefonoAlternativo: _telefonoAlternativoController.text.trim().isEmpty ? null : _telefonoAlternativoController.text.trim(),
        correoPersonal: _correoPersonalController.text.trim(),
        carreraId: _selectedCarreraId,
        gradoAcademicoId: _selectedGradoAcademicoId,
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
