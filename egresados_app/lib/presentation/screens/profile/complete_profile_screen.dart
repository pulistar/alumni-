import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/text_formatters.dart';
import '../../../data/services/auth_service.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';
import 'profile_success_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  
  // Controladores de texto
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _idUniversitarioController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _telefonoAlternativoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _paisController = TextEditingController();
  final _empresaActualController = TextEditingController();
  final _cargoActualController = TextEditingController();
  final _fechaGraduacionController = TextEditingController();
  final _semestreGraduacionController = TextEditingController();
  final _anioGraduacionController = TextEditingController();
  
  // Estado del formulario
  int _currentPage = 0;
  String? _selectedCarreraId;
  String? _selectedEstadoLaboralId;
  List<Map<String, dynamic>> _carreras = [];
  List<Map<String, dynamic>> _estadosLaborales = [];
  bool _isLoadingCarreras = true;
  bool _isLoadingEstadosLaborales = true;
  
  // Animaciones
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    
    // Valores por defecto
    _paisController.text = 'Colombia';
    
    // Cargar carreras y estados laborales
    _loadCarreras();
    _loadEstadosLaborales();
  }

  Future<void> _loadCarreras() async {
    try {
      final authService = context.read<AuthService>();
      final carreras = await authService.getCarreras();
      setState(() {
        _carreras = carreras;
        _isLoadingCarreras = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCarreras = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando carreras: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadEstadosLaborales() async {
    try {
      final authService = context.read<AuthService>();
      final estadosLaborales = await authService.getEstadosLaborales();
      setState(() {
        _estadosLaborales = estadosLaborales;
        _isLoadingEstadosLaborales = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingEstadosLaborales = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando estados laborales: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _idUniversitarioController.dispose();
    _telefonoController.dispose();
    _telefonoAlternativoController.dispose();
    _direccionController.dispose();
    _ciudadController.dispose();
    _paisController.dispose();
    _empresaActualController.dispose();
    _cargoActualController.dispose();
    _fechaGraduacionController.dispose();
    _semestreGraduacionController.dispose();
    _anioGraduacionController.dispose();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  bool _validateCurrentPage() {
    print('🔍 Validando página $_currentPage');
    
    // Validar página 1: Información Personal
    if (_currentPage == 0) {
      print('📝 Nombre: "${_nombreController.text}"');
      print('📝 Apellido: "${_apellidoController.text}"');
      print('📝 ID: "${_idUniversitarioController.text}"');
      print('📝 Teléfono: "${_telefonoController.text}"');
      print('📝 Ciudad: "${_ciudadController.text}"');
      print('📝 Carrera ID: $_selectedCarreraId');
      
      if (_nombreController.text.trim().isEmpty ||
          _apellidoController.text.trim().isEmpty ||
          _idUniversitarioController.text.trim().isEmpty ||
          _telefonoController.text.trim().isEmpty ||
          _ciudadController.text.trim().isEmpty ||
          _selectedCarreraId == null) {
        print('❌ Faltan campos obligatorios');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor completa todos los campos obligatorios'),
            backgroundColor: AppColors.error,
          ),
        );
        return false;
      }
      
      // Validar formato de nombre
      final nombreError = Validators.fullName(_nombreController.text, 'El nombre');
      if (nombreError != null) {
        print('❌ Error en nombre: $nombreError');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(nombreError),
            backgroundColor: AppColors.error,
          ),
        );
        return false;
      }
      
      // Validar formato de apellido
      final apellidoError = Validators.fullName(_apellidoController.text, 'El apellido');
      if (apellidoError != null) {
        print('❌ Error en apellido: $apellidoError');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(apellidoError),
            backgroundColor: AppColors.error,
          ),
        );
        return false;
      }
      
      // Validar ID universitario
      final idError = Validators.universityId(_idUniversitarioController.text);
      if (idError != null) {
        print('❌ Error en ID: $idError');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(idError),
            backgroundColor: AppColors.error,
          ),
        );
        return false;
      }
      
      // Validar teléfono
      final telefonoError = Validators.colombianPhone(_telefonoController.text);
      if (telefonoError != null) {
        print('❌ Error en teléfono: $telefonoError');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(telefonoError),
            backgroundColor: AppColors.error,
          ),
        );
        return false;
      }
      
      print('✅ Validación página 0 exitosa');
    }
    
    return true;
  }

  void _nextPage() {
    if (_currentPage < 2) {
      // Validar antes de avanzar
      if (!_validateCurrentPage()) {
        return;
      }
      
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitProfile() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthProfileCompleted(
          nombre: _nombreController.text.trim(),
          apellido: _apellidoController.text.trim(),
          idUniversitario: _idUniversitarioController.text.trim(),
          telefono: _telefonoController.text.trim(),
          ciudad: _ciudadController.text.trim(),
          carreraId: _selectedCarreraId,
          telefonoAlternativo: _telefonoAlternativoController.text.trim().isEmpty 
              ? null : _telefonoAlternativoController.text.trim(),
          direccion: _direccionController.text.trim().isEmpty 
              ? null : _direccionController.text.trim(),
          pais: _paisController.text.trim().isEmpty 
              ? null : _paisController.text.trim(),
          estadoLaboralId: _selectedEstadoLaboralId,
          empresaActual: _empresaActualController.text.trim().isEmpty 
              ? null : _empresaActualController.text.trim(),
          cargoActual: _cargoActualController.text.trim().isEmpty 
              ? null : _cargoActualController.text.trim(),
          fechaGraduacion: _fechaGraduacionController.text.trim().isEmpty 
              ? null : _fechaGraduacionController.text.trim(),
          semestreGraduacion: _semestreGraduacionController.text.trim().isEmpty 
              ? null : _semestreGraduacionController.text.trim(),
          anioGraduacion: _anioGraduacionController.text.trim().isEmpty 
              ? null : int.tryParse(_anioGraduacionController.text.trim()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Completar Perfil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is AuthenticatedWithProfile) {
            // Navegar a pantalla de éxito cuando el perfil se complete
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ProfileSuccessScreen(
                  nombreCompleto: state.egresado.nombreCompleto,
                ),
              ),
            );
          }
        },
        child: Column(
          children: [
            // Indicador de progreso
            _buildProgressIndicator(),
            
            // Contenido del formulario
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Form(
                  key: _formKey,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      _buildPersonalInfoPage(),
                      _buildAcademicInfoPage(),
                      _buildProfessionalInfoPage(),
                    ],
                  ),
                ),
              ),
            ),
            
            // Botones de navegación
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        children: [
          Row(
            children: List.generate(3, (index) {
              final isActive = index <= _currentPage;
              final isCompleted = index < _currentPage;
              
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: index < 2 ? AppConstants.paddingSmall : 0,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isCompleted 
                              ? AppColors.success 
                              : isActive 
                                  ? AppColors.primary 
                                  : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          isCompleted ? Icons.check : Icons.circle,
                          color: isActive || isCompleted 
                              ? AppColors.textOnPrimary 
                              : AppColors.textSecondary,
                          size: 16,
                        ),
                      ),
                      if (index < 2)
                        Expanded(
                          child: Container(
                            height: 2,
                            margin: const EdgeInsets.symmetric(
                              horizontal: AppConstants.paddingSmall,
                            ),
                            color: isCompleted 
                                ? AppColors.success 
                                : AppColors.surfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            _getPageTitle(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _getPageTitle() {
    switch (_currentPage) {
      case 0:
        return 'Información Personal';
      case 1:
        return 'Información Académica';
      case 2:
        return 'Información Profesional';
      default:
        return '';
    }
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cuéntanos sobre ti',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            'Completa tu información personal básica',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Los campos con * son obligatorios',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingXLarge),
          
          CustomTextField(
            controller: _nombreController,
            label: 'Nombres *',
            hint: 'Ingresa tus nombres',
            validator: (value) => Validators.fullName(value, 'Los nombres'),
            prefixIcon: Icons.person_outline,
            inputFormatters: [CapitalizeWordsFormatter()],
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          
          CustomTextField(
            controller: _apellidoController,
            label: 'Apellidos *',
            hint: 'Ingresa tus apellidos',
            validator: (value) => Validators.fullName(value, 'Los apellidos'),
            prefixIcon: Icons.person_outline,
            inputFormatters: [CapitalizeWordsFormatter()],
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          
          CustomTextField(
            controller: _idUniversitarioController,
            label: 'ID Universitario *',
            hint: 'Ej: 123456 (6 dígitos)',
            validator: (value) => Validators.universityId(value),
            prefixIcon: Icons.badge_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [DigitsOnlyFormatter(maxLength: 6)],
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          
          CustomTextField(
            controller: _telefonoController,
            label: 'Teléfono *',
            hint: 'Ej: 3001234567 (10 dígitos)',
            keyboardType: TextInputType.phone,
            validator: (value) => Validators.colombianPhone(value),
            prefixIcon: Icons.phone_outlined,
            inputFormatters: [DigitsOnlyFormatter(maxLength: 10)],
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          
          CustomTextField(
            controller: _telefonoAlternativoController,
            label: 'Teléfono Alternativo',
            hint: 'Teléfono adicional (Opcional)',
            keyboardType: TextInputType.phone,
            validator: (value) => Validators.colombianPhone(value, required: false),
            prefixIcon: Icons.phone_outlined,
            inputFormatters: [DigitsOnlyFormatter(maxLength: 10)],
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          
          CustomTextField(
            controller: _ciudadController,
            label: 'Ciudad *',
            hint: 'Ciudad donde estudiaste',
            validator: (value) => Validators.required(value, 'La ciudad'),
            prefixIcon: Icons.location_city_outlined,
            inputFormatters: [CapitalizeWordsFormatter()],
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          
          // Dropdown de carreras - OBLIGATORIO
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: AppColors.surfaceVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Carrera *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                _isLoadingCarreras
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppConstants.paddingMedium),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : DropdownButtonFormField<String>(
                        value: _selectedCarreraId,
                        decoration: const InputDecoration(
                          hintText: 'Selecciona tu carrera',
                          border: InputBorder.none,
                        ),
                        items: _carreras.map((carrera) {
                          return DropdownMenuItem<String>(
                            value: carrera['id'] as String,
                            child: Text(carrera['nombre'] as String),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCarreraId = value;
                          });
                        },
                        validator: (value) => value == null ? 'La carrera es obligatoria' : null,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información Académica',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            'Detalles sobre tu formación universitaria',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Los campos con * son obligatorios',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingXLarge),
          
          CustomTextField(
            controller: _paisController,
            label: 'País',
            hint: 'País donde estudiaste (Opcional)',
            prefixIcon: Icons.public_outlined,
            inputFormatters: [CapitalizeWordsFormatter()],
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          
          CustomTextField(
            controller: _direccionController,
            label: 'Dirección',
            hint: 'Dirección actual (Opcional)',
            prefixIcon: Icons.home_outlined,
            inputFormatters: [CapitalizeWordsFormatter()],
            textCapitalization: TextCapitalization.words,
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información Profesional',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            'Cuéntanos sobre tu situación laboral actual',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Todos los campos de esta página son opcionales',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingXLarge),
          
          // Estado laboral
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: AppColors.surfaceVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado Laboral',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                _isLoadingEstadosLaborales
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppConstants.paddingMedium),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : DropdownButtonFormField<String>(
                        value: _selectedEstadoLaboralId,
                        decoration: const InputDecoration(
                          hintText: 'Selecciona tu estado laboral',
                          border: InputBorder.none,
                        ),
                        items: _estadosLaborales.map((estado) {
                          return DropdownMenuItem<String>(
                            value: estado['id'] as String,
                            child: Text(estado['nombre'] as String),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedEstadoLaboralId = value;
                          });
                        },
                      ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          
          CustomTextField(
            controller: _empresaActualController,
            label: 'Empresa Actual',
            hint: 'Nombre de tu empresa (Opcional)',
            prefixIcon: Icons.business_outlined,
            inputFormatters: [CapitalizeWordsFormatter()],
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          
          CustomTextField(
            controller: _cargoActualController,
            label: 'Cargo Actual',
            hint: 'Tu cargo o posición (Opcional)',
            prefixIcon: Icons.work_outline,
            inputFormatters: [CapitalizeWordsFormatter()],
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: AppConstants.paddingXLarge),
          
          // Información adicional
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Expanded(
                  child: Text(
                    'Esta información nos ayuda a mantener estadísticas actualizadas de nuestros egresados.',
                    style: TextStyle(
                      color: AppColors.info,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthCompletingProfile;
          
          return Row(
            children: [
              // Botón anterior
              if (_currentPage > 0)
                Expanded(
                  child: CustomButton(
                    text: 'Anterior',
                    onPressed: isLoading ? null : _previousPage,
                    variant: ButtonVariant.outlined,
                  ),
                ),
              
              if (_currentPage > 0)
                const SizedBox(width: AppConstants.paddingMedium),
              
              // Botón siguiente/completar
              Expanded(
                flex: _currentPage == 0 ? 1 : 1,
                child: CustomButton(
                  text: _currentPage == 2 ? 'Completar Perfil' : 'Siguiente',
                  onPressed: isLoading 
                      ? null 
                      : _currentPage == 2 
                          ? _submitProfile 
                          : _nextPage,
                  isLoading: isLoading,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
