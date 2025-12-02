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
import '../settings/about_screen.dart';

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
  final _celularController = TextEditingController();
  final _telefonoAlternativoController = TextEditingController();
  final _correoPersonalController = TextEditingController();
  final _documentoController = TextEditingController();
  final _lugarExpedicionController = TextEditingController();
  final _idUniversitarioController = TextEditingController();
  
  // Estado del formulario
  int _currentPage = 0;
  String? _selectedTipoDocumentoId;
  String? _selectedGradoAcademicoId;
  String? _selectedCarreraId;
  
  // Listas de catálogos
  List<Map<String, dynamic>> _tiposDocumento = [];
  List<Map<String, dynamic>> _gradosAcademicos = [];
  List<Map<String, dynamic>> _carreras = [];
  List<Map<String, dynamic>> _carrerasFiltradas = [];
  
  // Estados de carga
  bool _isLoadingTiposDocumento = true;
  bool _isLoadingGradosAcademicos = true;
  bool _isLoadingCarreras = true;
  
  // Aceptación de términos
  bool _termsAccepted = false;
  
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
    
    // Cargar catálogos
    _loadTiposDocumento();
    _loadGradosAcademicos();
    _loadCarreras();
  }

  Future<void> _loadTiposDocumento() async {
    try {
      final authService = context.read<AuthService>();
      final tipos = await authService.getTiposDocumento();
      setState(() {
        _tiposDocumento = tipos;
        _isLoadingTiposDocumento = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTiposDocumento = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando tipos de documento: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadGradosAcademicos() async {
    try {
      final authService = context.read<AuthService>();
      final grados = await authService.getGradosAcademicos();
      setState(() {
        _gradosAcademicos = grados;
        _isLoadingGradosAcademicos = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingGradosAcademicos = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando grados académicos: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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

  void _filterCarrerasByGrado() {
    if (_selectedGradoAcademicoId == null) {
      setState(() {
        _carrerasFiltradas = [];
        _selectedCarreraId = null;
      });
      return;
    }
    
    setState(() {
      _carrerasFiltradas = _carreras
          .where((c) => c['grado_academico_id'] == _selectedGradoAcademicoId)
          .toList();
      
      // Reset carrera seleccionada si no está en la lista filtrada
      if (_selectedCarreraId != null &&
          !_carrerasFiltradas.any((c) => c['id'] == _selectedCarreraId)) {
        _selectedCarreraId = null;
      }
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _celularController.dispose();
    _telefonoAlternativoController.dispose();
    _correoPersonalController.dispose();
    _documentoController.dispose();
    _lugarExpedicionController.dispose();
    _idUniversitarioController.dispose();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  bool _validateCurrentPage() {
    switch (_currentPage) {
      case 0: // Página 1: Datos Personales
        if (_nombreController.text.trim().isEmpty ||
            _apellidoController.text.trim().isEmpty ||
            _celularController.text.trim().isEmpty ||
            _correoPersonalController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor completa todos los campos obligatorios'),
              backgroundColor: AppColors.error,
            ),
          );
          return false;
        }
        
        // Validar formato de correo personal
        final emailError = Validators.email(_correoPersonalController.text);
        if (emailError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(emailError),
              backgroundColor: AppColors.error,
            ),
          );
          return false;
        }
        
        // Validar que no sea correo institucional
        if (_correoPersonalController.text.contains('@campusucc.edu.co')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El correo personal no puede ser institucional'),
              backgroundColor: AppColors.error,
            ),
          );
          return false;
        }
        break;
        
      case 1: // Página 2: Identificación
        if (_selectedTipoDocumentoId == null ||
            _documentoController.text.trim().isEmpty ||
            _lugarExpedicionController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor completa todos los campos obligatorios'),
              backgroundColor: AppColors.error,
            ),
          );
          return false;
        }
        break;
        
      case 2: // Página 3: Académica
        if (_selectedGradoAcademicoId == null ||
            _selectedCarreraId == null ||
            _idUniversitarioController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor completa todos los campos obligatorios'),
              backgroundColor: AppColors.error,
            ),
          );
          return false;
        }
        
        // Validar aceptación de términos
        if (!_termsAccepted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Debes aceptar los Términos y Condiciones para continuar'),
              backgroundColor: AppColors.error,
            ),
          );
          return false;
        }
        break;
    }
    
    return true;
  }

  void _nextPage() {
    if (_currentPage < 2) {
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
    if (!_validateCurrentPage()) {
      return;
    }
    
    context.read<AuthBloc>().add(
      AuthProfileCompleted(
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        celular: _celularController.text.trim(),
        telefonoAlternativo: _telefonoAlternativoController.text.trim().isEmpty 
            ? null : _telefonoAlternativoController.text.trim(),
        correoPersonal: _correoPersonalController.text.trim(),
        tipoDocumentoId: _selectedTipoDocumentoId!,
        documento: _documentoController.text.trim(),
        lugarExpedicion: _lugarExpedicionController.text.trim(),
        gradoAcademicoId: _selectedGradoAcademicoId!,
        carreraId: _selectedCarreraId!,
        idUniversitario: _idUniversitarioController.text.trim(),
      ),
    );
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
          if (state is AuthProfileCompletionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message.replaceAll('Exception: ', '')),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 4),
              ),
            );
          } else if (state is AuthenticatedWithProfile) {
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
            _buildProgressIndicator(),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Form(
                  key: _formKey,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      _buildPersonalInfoPage(),
                      _buildIdentificationPage(),
                      _buildAcademicInfoPage(),
                    ],
                  ),
                ),
              ),
            ),
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
            style: const TextStyle(
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
        return 'Datos Personales';
      case 1:
        return 'Identificación';
      case 2:
        return 'Información Académica';
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
          const Text(
            'Cuéntanos sobre ti',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          const Text(
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
            controller: _celularController,
            label: 'Celular *',
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
            controller: _correoPersonalController,
            label: 'Correo Personal *',
            hint: 'tu.correo@gmail.com',
            keyboardType: TextInputType.emailAddress,
            validator: (value) => Validators.email(value),
            prefixIcon: Icons.email_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildIdentificationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Identificación',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          const Text(
            'Información de tu documento de identidad',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingXLarge),
          
          // Dropdown de tipos de documento
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
                const Text(
                  'Tipo de Documento *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                _isLoadingTiposDocumento
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppConstants.paddingMedium),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : DropdownButtonFormField<String>(
                        value: _selectedTipoDocumentoId,
                        decoration: const InputDecoration(
                          hintText: 'Selecciona el tipo',
                          border: InputBorder.none,
                        ),
                        items: _tiposDocumento.map((tipo) {
                          return DropdownMenuItem<String>(
                            value: tipo['id'] as String,
                            child: SizedBox(
                              width: 200,
                              child: Text(
                                tipo['nombre'] as String,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTipoDocumentoId = value;
                          });
                        },
                      ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          
          CustomTextField(
            controller: _documentoController,
            label: 'Número de Documento *',
            hint: 'Ingresa tu número de documento',
            keyboardType: TextInputType.text,
            validator: (value) => Validators.required(value, 'El número de documento'),
            prefixIcon: Icons.badge_outlined,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          
          CustomTextField(
            controller: _lugarExpedicionController,
            label: 'Lugar de Expedición *',
            hint: 'Ciudad donde se expidió',
            validator: (value) => Validators.required(value, 'El lugar de expedición'),
            prefixIcon: Icons.location_city_outlined,
            inputFormatters: [CapitalizeWordsFormatter()],
            textCapitalization: TextCapitalization.words,
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
          const Text(
            'Información Académica',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          const Text(
            'Detalles sobre tu formación universitaria',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.paddingXLarge),
          
          // Dropdown de grados académicos
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
                const Text(
                  'Grado Académico *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                _isLoadingGradosAcademicos
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppConstants.paddingMedium),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : DropdownButtonFormField<String>(
                        value: _selectedGradoAcademicoId,
                        decoration: const InputDecoration(
                          hintText: 'Selecciona el grado',
                          border: InputBorder.none,
                        ),
                        items: _gradosAcademicos.map((grado) {
                          return DropdownMenuItem<String>(
                            value: grado['id'] as String,
                            child: Text(
                              grado['nombre'] as String,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedGradoAcademicoId = value;
                            _filterCarrerasByGrado();
                          });
                        },
                      ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          
          // Dropdown de carreras (filtrado)
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
                const Text(
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
                    : _selectedGradoAcademicoId == null
                        ? const Padding(
                            padding: EdgeInsets.all(AppConstants.paddingMedium),
                            child: Text(
                              'Primero selecciona un grado académico',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        : DropdownButtonFormField<String>(
                            value: _selectedCarreraId,
                            decoration: const InputDecoration(
                              hintText: 'Selecciona tu carrera',
                              border: InputBorder.none,
                            ),
                            items: _carrerasFiltradas.map((carrera) {
                              return DropdownMenuItem<String>(
                                value: carrera['id'] as String,
                                child: Text(
                                  carrera['nombre'] as String,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
          
          const SizedBox(height: AppConstants.paddingXLarge),
          
          // Checkbox de términos y condiciones
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: _termsAccepted ? AppColors.primary : AppColors.surfaceVariant,
                width: _termsAccepted ? 2 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _termsAccepted,
                  onChanged: (value) {
                    setState(() {
                      _termsAccepted = value ?? false;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _termsAccepted = !_termsAccepted;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(text: 'Acepto los '),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () => _showTermsDialog(),
                                child: Text(
                                  'Términos y Condiciones',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                            const TextSpan(text: ' de uso de la aplicación Alumni UCC'),
                          ],
                        ),
                      ),
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
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthCompletingProfile;
          
          return Row(
            children: [
              if (_currentPage > 0)
                Expanded(
                  child: CustomButton(
                    text: 'Atrás',
                    onPressed: isLoading ? null : _previousPage,
                    variant: ButtonVariant.outlined,
                  ),
                ),
              if (_currentPage > 0) const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                flex: 2,
                child: CustomButton(
                  text: _currentPage == 2 ? 'Completar Registro' : 'Siguiente',
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
  
  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Términos y Condiciones'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Última actualización: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              _buildTermSection(
                '1. Aceptación de los Términos',
                'Al acceder y utilizar la aplicación Alumni UCC, usted acepta estar sujeto a estos términos y condiciones de uso.',
              ),
              _buildTermSection(
                '2. Uso de la Aplicación',
                'Esta aplicación está destinada exclusivamente para egresados de la Universidad Cooperativa de Colombia. '
                'Usted se compromete a proporcionar información veraz y actualizada.',
              ),
              _buildTermSection(
                '3. Cuenta de Usuario',
                'El acceso a la aplicación se realiza mediante su correo institucional. Usted es responsable de mantener '
                'la confidencialidad de su cuenta y de todas las actividades que ocurran bajo su cuenta.',
              ),
              _buildTermSection(
                '4. Propiedad Intelectual',
                'Todo el contenido de esta aplicación, incluyendo textos, gráficos, logos e imágenes, es propiedad de la '
                'Universidad Cooperativa de Colombia y está protegido por las leyes de propiedad intelectual.',
              ),
              _buildTermSection(
                '5. Modificaciones',
                'La Universidad se reserva el derecho de modificar estos términos en cualquier momento. '
                'Las modificaciones entrarán en vigor inmediatamente después de su publicación en la aplicación.',
              ),
              _buildTermSection(
                '6. Contacto',
                'Para cualquier pregunta sobre estos términos, puede contactarnos a través de la opción "Ayuda" en el menú principal.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildTermSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
