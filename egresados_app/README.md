# Alumni UCC - App Móvil de Egresados

Aplicación móvil Flutter para egresados de la Universidad Cooperativa de Colombia. Permite a los graduados completar su proceso de titulación mediante la carga de documentos y realización de autoevaluaciones.

## Descripción

Esta aplicación móvil es parte del **Sistema de Gestión de Egresados UCC** y está diseñada exclusivamente para que los egresados puedan:

- Completar su perfil académico y personal
- Cargar documentos requeridos para el proceso de graduación
- Realizar autoevaluaciones por competencias
- Hacer seguimiento de su progreso en tiempo real
- Recibir notificaciones sobre el estado de su proceso

## Características Principales

### Autenticación
- **Magic Link**: Autenticación sin contraseña vía email institucional
- Integración con Supabase Auth
- Sesión persistente y segura
- Soporte para deep links

### Gestión de Perfil
- Formulario completo de datos personales
- Información académica (carrera, código estudiantil)
- Datos de contacto (teléfono, email personal)
- Información de documento de identidad
- Estado laboral actual

### Carga de Documentos
- Upload de documentos PDF requeridos:
  - Cédula de identidad
  - Foto tipo documento
  - Acta de grado
  - Paz y salvo académico
  - Paz y salvo financiero
- Validación de formato y tamaño
- Preview de documentos
- Indicador de progreso de carga

### Sistema de Autoevaluación
- Cuestionario de competencias por módulos temáticos
- Diferentes tipos de preguntas:
  - Escala Likert (1-5)
  - Opción múltiple
  - Texto libre
- Guardado automático de progreso
- Barra de progreso visual
- Validación de respuestas requeridas

### Dashboard
- Resumen del estado del proceso
- Progreso de documentos (%)
- Estado de autoevaluación
- Notificaciones importantes
- Accesos rápidos a funcionalidades

## Stack Tecnológico

### Framework y Lenguaje
- **Flutter** 3.1+
- **Dart** 3.1+

### Arquitectura y Patrones
- **Clean Architecture** (Data, Domain, Presentation)
- **BLoC Pattern** para manejo de estado
- **Repository Pattern** para acceso a datos
- **Dependency Injection** con GetIt

### Librerías Principales

#### State Management
- `flutter_bloc` 8.1.3 - Manejo de estado
- `equatable` 2.0.5 - Comparación de objetos

#### Networking
- `dio` 5.3.3 - Cliente HTTP
- `retrofit` 4.0.3 - API REST generada
- `json_annotation` 4.8.1 - Serialización JSON

#### Backend Services
- `supabase_flutter` 2.0.0 - Cliente Supabase
- `firebase_core` 2.24.2 - Firebase Core
- `firebase_messaging` 14.7.9 - Notificaciones Push

#### Storage
- `flutter_secure_storage` 9.0.0 - Storage seguro
- `shared_preferences` - Preferencias locales

#### UI/UX
- `cached_network_image` 3.3.0 - Caché de imágenes
- `shimmer` 3.0.0 - Efectos de carga
- `flutter_svg` 2.0.9 - Imágenes SVG

#### File Handling
- `file_picker` 10.0.0 - Selección de archivos
- `image_picker` 1.0.4 - Selección de imágenes
- `flutter_pdfview` 1.3.2 - Visor de PDFs

#### Navigation
- `go_router` 12.1.1 - Manejo de rutas

#### Testing
- `mockito` 5.4.3 - Mocking
- `mocktail` 1.0.1 - Mocking alternativo
- `bloc_test` 9.1.5 - Testing de BLoCs

## Estructura del Proyecto

```
egresados_app/
├── lib/
│   ├── core/                      # Núcleo de la aplicación
│   │   ├── config/               # Configuración (Supabase, Firebase)
│   │   ├── constants/            # Constantes globales
│   │   ├── errors/               # Manejo de errores
│   │   ├── network/              # Cliente HTTP base
│   │   └── utils/                # Utilidades y helpers
│   │
│   ├── data/                      # Capa de datos
│   │   ├── datasources/          # Fuentes de datos (API, Local)
│   │   ├── models/               # Modelos de datos (JSON)
│   │   ├── repositories/         # Implementación de repositorios
│   │   └── services/             # Servicios HTTP (Retrofit)
│   │
│   ├── domain/                    # Capa de dominio
│   │   ├── entities/             # Entidades de negocio
│   │   ├── repositories/         # Interfaces de repositorios
│   │   └── usecases/             # Casos de uso
│   │
│   ├── presentation/              # Capa de presentación
│   │   ├── blocs/                # BLoCs (Estado)
│   │   │   ├── auth/             # Autenticación
│   │   │   ├── profile/          # Perfil
│   │   │   ├── documentos/       # Documentos
│   │   │   └── autoevaluacion/   # Autoevaluación
│   │   │
│   │   ├── screens/              # Pantallas de la app
│   │   │   ├── auth/             # Login, Magic Link
│   │   │   ├── onboarding/       # Introducción
│   │   │   ├── profile/          # Perfil y edición
│   │   │   ├── documentos/       # Gestión de documentos
│   │   │   ├── autoevaluacion/   # Cuestionario
│   │   │   └── settings/         # Configuración
│   │   │
│   │   └── widgets/              # Widgets reutilizables
│   │       ├── buttons/
│   │       ├── cards/
│   │       ├── forms/
│   │       └── loaders/
│   │
│   └── main.dart                 # Punto de entrada
│
├── test/                          # Tests unitarios y de widgets
│   ├── unit/
│   │   ├── services/
│   │   ├── models/
│   │   ├── blocs/
│   │   └── utils/
│   └── widget/
│       ├── screens/
│       └── widgets/
│
├── integration_test/              # Tests de integración
│   └── auth_flow_test.dart
│
├── assets/                        # Recursos estáticos
│   ├── images/
│   ├── icons/
│   └── fonts/
│
├── android/                       # Configuración Android
├── ios/                          # Configuración iOS (opcional)
└── pubspec.yaml                   # Dependencias
```

## Pantallas Principales

### 1. Onboarding
- Introducción a la aplicación
- Explicación del proceso
- Instrucciones de uso

### 2. Login
- Campo de email institucional
- Envío de magic link
- Validación de email

### 3. Magic Link Verification
- Verificación automática del token
- Redirección a completar perfil o home

### 4. Completar Perfil
- Formulario de datos personales
- Información académica
- Datos de contacto
- Documento de identidad

### 5. Home (Dashboard)
- Resumen de estado
- Progreso de documentos
- Estado de autoevaluación
- Accesos rápidos
- Notificaciones

### 6. Gestión de Documentos
- Lista de documentos requeridos
- Estado de cada documento (pendiente/cargado/validado)
- Upload de PDFs
- Preview de documentos

### 7. Autoevaluación
- Lista de módulos temáticos
- Preguntas por módulo
- Diferentes tipos de respuesta
- Barra de progreso
- Finalización del cuestionario

### 8. Perfil
- Ver información personal
- Editar datos
- Cerrar sesión

### 9. Configuración
- Notificaciones
- Ayuda
- Acerca de
- Términos y privacidad

## Instalación y Configuración

### Prerrequisitos

```bash
# Flutter SDK 3.1 o superior
flutter --version

# Dart SDK 3.1 o superior
dart --version
```

### Instalación

1. **Clonar el repositorio**
```bash
git clone <url-repositorio>
cd egresados_app
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Configurar Supabase**

Editar `lib/core/config/supabase_config.dart`:
```dart
class SupabaseConfig {
  static const String url = 'https://tu-proyecto.supabase.co';
  static const String anonKey = 'tu-anon-key';
}
```

4. **Configurar Firebase (Opcional - para notificaciones)**

- Descargar `google-services.json` de Firebase Console
- Colocar en `android/app/`

5. **Generar código**
```bash
# Generar código de Retrofit y JSON serializable
flutter pub run build_runner build --delete-conflicting-outputs
```

### Ejecutar en Desarrollo

```bash
# Modo debug
flutter run

# Modo release
flutter run --release

# Dispositivo específico
flutter run -d <device-id>
```

## Testing

### Suite de Tests

La aplicación cuenta con **67 tests** que cubren:

- **Services** - Servicios HTTP y lógica de datos
- **Models** - Serialización/deserialización JSON
- **BLoCs** - Manejo de estado (removidos por incompatibilidad)
- **Validators** - Validaciones de formularios
- **Widgets** - Componentes UI
- **Integration** - Flujos completos

### Ejecutar Tests

```bash
# Todos los tests
flutter test

# Tests con cobertura
flutter test --coverage

# Tests de integración
flutter test integration_test/

# Un archivo específico
flutter test test/unit/services/auth_service_test.dart

# Modo verbose
flutter test --reporter expanded
```

### Ver Reporte de Cobertura

```bash
# Generar reporte HTML
genhtml coverage/lcov.info -o coverage/html

# Abrir en navegador
start coverage/html/index.html # Windows
```

## Compilación para Producción

### Android APK

```bash
# APK release
flutter build apk --release

# APK dividido por arquitectura (más pequeño)
flutter build apk --release --split-per-abi

# Output: build/app/outputs/flutter-apk/
```

### Android App Bundle (AAB)

```bash
# Para Google Play Store
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```


## Comandos Útiles

### Desarrollo
```bash
# Limpiar build
flutter clean

# Reinstalar dependencias
flutter pub get

# Análisis de código
flutter analyze

# Formatear código
dart format .

# Verificar actualizaciones
flutter pub outdated
```

### Debugging
```bash
# Logs del dispositivo
flutter logs

# Inspector de widgets
flutter run --observatory-port=8888

# Modo profile (performance)
flutter run --profile
```

## Troubleshooting

### Problemas Comunes

**Error de build_runner:**
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

**Error de Firebase:**
```bash
# Verificar google-services.json
# Verificar applicationId en build.gradle
```

**Error de Supabase:**
```bash
# Verificar URL y keys en supabase_config.dart
# Verificar conexión a internet
```


## Estado del Proyecto

- Autenticación con Magic Link
- Gestión de perfil completo
- Sistema de carga de documentos
- Autoevaluación por competencias
- Notificaciones push
- 67 tests unitarios y de integración
- Listo para producción

## Soporte

Para problemas técnicos o preguntas:
- Crear un issue en el repositorio
- Contactar al equipo de desarrollo

---

**Versión:** 1.0.0  
**Última actualización:** Diciembre 2025  
**Universidad Cooperativa de Colombia**
