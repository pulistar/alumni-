import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/validators.dart';
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

  void _nextPage() {
    if (_currentPage < 2) {
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
          const SizedBox(height: AppConstants.paddingXLarge),
          
          CustomTextField(
            controller: _nombreController,
            label: 'Nombres *',
            hint: 'Ingresa tus nombres',
            validator: (value) => Validators.required(value, 'Los nombres'),
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          
          CustomTextField(
            controller: _apellidoController,
            label: 'Apellidos *',
            hint: 'Ingresa tus apellidos',
            validator: (value) => Validators.required(value, 'Los apellidos'),
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          
          CustomTextField(
            controller: _idUniversitarioController,
            label: 'ID Universitario *',
            hint: 'Ej: 2019123456',
            validator: (value) => Validators.required(value, 'El ID universitario'),
            prefixIcon: Icons.badge_outlined,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          
          CustomTextField(
            controller: _telefonoController,
            label: 'Teléfono *',
            hint: 'Ej: +57 300 123 4567',
            keyboardType: TextInputType.phone,
            validator: (value) => Validators.required(value, 'El teléfono'),
            prefixIcon: Icons.phone_outlined,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          
          CustomTextField(
            controller: _telefonoAlternativoController,
            label: 'Teléfono Alternativo (Opcional)',
            hint: 'Teléfono adicional',
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
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
          const SizedBox(height: AppConstants.paddingXLarge),
          
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
                DropdownButtonFormField<String>(
                  value: _selectedCarreraId,
                  decoration: const InputDecoration(
                    hintText: 'Selecciona tu carrera',
                    border: InputBorder.none,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'carrera1',
                      child: Text('Ingeniería de Sistemas'),
                    ),
                    DropdownMenuItem(
                      value: 'carrera2',
                      child: Text('Administración de Empresas'),
                    ),
                    DropdownMenuItem(
                      value: 'carrera3',
                      child: Text('Contaduría Pública'),
                    ),
                    DropdownMenuItem(
                      value: 'carrera4',
                      child: Text('Derecho'),
                    ),
                    DropdownMenuItem(
                      value: 'carrera5',
                      child: Text('Psicología'),
                    ),
                    // TODO: Cargar desde API
                  ],
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
          const SizedBox(height: AppConstants.paddingLarge),
          
          CustomTextField(
            controller: _ciudadController,
            label: 'Ciudad *',
            hint: 'Ciudad donde estudiaste',
            validator: (value) => Validators.required(value, 'La ciudad'),
            prefixIcon: Icons.location_city_outlined,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          
          CustomTextField(
            controller: _paisController,
            label: 'País (Opcional)',
            hint: 'País donde estudiaste',
            prefixIcon: Icons.public_outlined,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          
          CustomTextField(
            controller: _direccionController,
            label: 'Dirección (Opcional)',
            hint: 'Dirección actual',
            prefixIcon: Icons.home_outlined,
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
                  'Estado Laboral (Opcional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                DropdownButtonFormField<String>(
                  value: _selectedEstadoLaboralId,
                  decoration: const InputDecoration(
                    hintText: 'Selecciona tu estado laboral',
                    border: InputBorder.none,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'empleado',
                      child: Text('Empleado'),
                    ),
                    DropdownMenuItem(
                      value: 'independiente',
                      child: Text('Trabajador Independiente'),
                    ),
                    DropdownMenuItem(
                      value: 'desempleado',
                      child: Text('Desempleado'),
                    ),
                    DropdownMenuItem(
                      value: 'estudiando',
                      child: Text('Estudiando'),
                    ),
                  ],
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
            label: 'Empresa Actual (Opcional)',
            hint: 'Nombre de tu empresa',
            prefixIcon: Icons.business_outlined,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          
          CustomTextField(
            controller: _cargoActualController,
            label: 'Cargo Actual (Opcional)',
            hint: 'Tu cargo o posición',
            prefixIcon: Icons.work_outline,
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
