// Constantes de la aplicación
class AppConstants {
  // Información de la app
  static const String appName = 'Alumni';
  static const String appVersion = '1.0.0';
  static const String universityName = 'Universidad Cooperativa de Colombia';
  static const String supportPhone = '+573234427114';
  static const String supportEmail = 'jhon.ortizpa@campusucc.edu.co';
  
  // Tamaños
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  static const double borderRadius = 8.0;
  static const double borderRadiusLarge = 16.0;
  
  static const double buttonHeight = 48.0;
  static const double inputHeight = 56.0;
  
  // Animaciones
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 3);
  
  // Límites de archivos
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedFileTypes = ['pdf', 'jpg', 'jpeg', 'png'];
}

// Strings de la aplicación
class AppStrings {
  // Generales
  static const String loading = 'Cargando...';
  static const String error = 'Error';
  static const String success = 'Éxito';
  static const String cancel = 'Cancelar';
  static const String accept = 'Aceptar';
  static const String save = 'Guardar';
  static const String edit = 'Editar';
  static const String delete = 'Eliminar';
  static const String upload = 'Subir';
  static const String download = 'Descargar';
  
  // Autenticación
  static const String login = 'Iniciar Sesión';
  static const String logout = 'Cerrar Sesión';
  static const String email = 'Correo Electrónico';
  static const String password = 'Contraseña';
  static const String sendMagicLink = 'Enviar Enlace de Acceso';
  static const String checkEmail = 'Revisa tu correo electrónico';
  static const String magicLinkSent = 'Te hemos enviado un enlace de acceso a tu correo';
  
  // Perfil
  static const String profile = 'Perfil';
  static const String completeProfile = 'Completar Perfil';
  static const String firstName = 'Nombres';
  static const String lastName = 'Apellidos';
  static const String phone = 'Teléfono';
  static const String city = 'Ciudad';
  static const String career = 'Carrera';
  static const String currentJob = 'Trabajo Actual';
  static const String currentCompany = 'Empresa Actual';
  
  // Documentos
  static const String documents = 'Documentos';
  static const String uploadDocument = 'Subir Documento';
  static const String documentType = 'Tipo de Documento';
  static const String selectFile = 'Seleccionar Archivo';
  static const String documentUploaded = 'Documento subido exitosamente';
  
  // Autoevaluación
  static const String evaluation = 'Autoevaluación';
  static const String startEvaluation = 'Iniciar Autoevaluación';
  static const String continueEvaluation = 'Continuar Autoevaluación';
  static const String evaluationComplete = 'Autoevaluación Completada';
  static const String progress = 'Progreso';
  
  // Notificaciones
  static const String notifications = 'Notificaciones';
  static const String noNotifications = 'No tienes notificaciones';
  static const String markAsRead = 'Marcar como leída';
  static const String markAllAsRead = 'Marcar todas como leídas';
}

// Tipos de documento
enum DocumentType {
  momentoOle('momento_ole', 'Momento OLE'),
  datosEgresados('datos_egresados', 'Datos Egresados'),
  bolsaEmpleo('bolsa_empleo', 'Bolsa de Empleo'),
  otro('otro', 'Otro');

  const DocumentType(this.value, this.displayName);
  final String value;
  final String displayName;
}
