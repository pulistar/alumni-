- Gestionar perfiles de egresados (habilitar/deshabilitar)
- Validar documentos cargados por los egresados
- Configurar el sistema de autoevaluación
- Visualizar estadísticas y reportes en tiempo real
- Gestionar catálogos (carreras, grados académicos, módulos)
- Exportar datos y generar PDFs unificados
- Enviar invitaciones masivas a egresados

## Características Principales

### Autenticación
- Login con email y contraseña
- Autenticación JWT con backend
- Sesión persistente
- Control de acceso por roles

### Dashboard Pre-Alumni
- Estadísticas en tiempo real
- Total de egresados registrados
- Documentos pendientes de validación
- Autoevaluaciones completadas
- Progreso general del proceso
- Accesos rápidos a funcionalidades

### Gestión de Egresados
- Lista completa con búsqueda y filtros
- Filtrar por carrera, estado, progreso
- Paginación de resultados
- Habilitar/deshabilitar egresados
- Ver detalle completo de cada egresado
- Envío de invitaciones individuales o masivas

### Validación de Documentos
- Visualización de documentos PDF
- Marcar como validado/rechazado
- Descarga de documentos
- Generación de PDF unificado
- Ver historial de documentos

### Sistema de Autoevaluación
- Crear y editar preguntas
- Organizar por módulos temáticos
- Diferentes tipos de preguntas (Likert, múltiple, texto)
- Activar/desactivar preguntas
- Reordenar preguntas
- Ver respuestas de egresados

### Gestión de Catálogos
- **Carreras**: Crear, editar, activar/desactivar
- **Grados Académicos**: Gestión de niveles académicos
- **Módulos**: Organización temática de autoevaluación
- **Tipos de Documento**: Configuración de documentos requeridos

### Estadísticas y Reportes
- Gráficas de distribución por carrera
- Tasas de empleabilidad
- Embudo del proceso
- Radar de competencias
- Exportación a PDF de reportes
- Exportación a Excel de datos

### Carga Masiva
- Upload de Excel con datos de egresados
- Validación de formato
- Preview antes de importar
- Habilitación masiva de egresados

## Stack Tecnológico

### Framework y Lenguaje
- **Flutter Desktop** 3.1+ (Windows)
- **Dart** 3.1+

### Arquitectura y Patrones
- **MVC Pattern** simplificado
- **Provider Pattern** para manejo de estado
- **Repository Pattern** para acceso a datos
- **Service Pattern** para lógica de negocio

### Librerías Principales

#### State Management
- `provider` - Manejo de estado simple

#### Networking
- `dio` 5.3.3 - Cliente HTTP
- `http` - Cliente HTTP alternativo
- `json_annotation` - Serialización JSON

#### Backend Services
- `supabase_flutter` 2.0.0 - Cliente Supabase

#### Storage
- `shared_preferences` - Preferencias locales
- `flutter_secure_storage` 9.0.0 - Storage seguro de tokens

#### UI/UX
- `fl_chart` 0.70.2 - Gráficas y estadísticas
- `cached_network_image` 3.3.0 - Caché de imágenes
- `flutter_svg` 2.0.9 - Imágenes SVG

#### File Handling
- `file_picker` 8.3.7 - Selección de archivos
- `syncfusion_flutter_pdfviewer` 27.2.5 - Visor de PDFs
- `syncfusion_flutter_pdf` 27.2.5 - Generación de PDFs
- `excel` - Generación y lectura de Excel

#### Utilities
- `intl` 0.19.0 - Internacionalización y formatos
- `url_launcher` 6.2.1 - Abrir URLs
- `share_plus` 7.2.1 - Compartir archivos

#### Testing
- `mockito` 5.4.3 - Mocking para tests
- `flutter_test` - Framework de testing

## Estructura del Proyecto

```
administrativo_app/
├── lib/
│   ├── core/                      # Núcleo de la aplicación
│   │   ├── config/               # Configuración (API, Supabase)
│   │   ├── constants/            # Constantes globales
│   │   ├── theme/                # Tema y estilos
│   │   └── utils/                # Utilidades y validators
│   │
│   ├── data/                      # Capa de datos
│   │   ├── models/               # Modelos de datos
│   │   │   ├── user.dart
│   │   │   ├── egresado.dart
│   │   │   ├── documento.dart
│   │   │   ├── pregunta.dart
│   │   │   └── ...
│   │   ├── repositories/         # Repositorios
│   │   └── services/             # Servicios HTTP
│   │       ├── auth_service.dart
│   │       ├── egresados_service.dart
│   │       ├── documentos_service.dart
│   │       └── ...
│   │
│   ├── presentation/              # Capa de presentación
│   │   ├── providers/            # Providers (Estado global)
│   │   │   ├── auth_provider.dart
│   │   │   ├── egresados_provider.dart
│   │   │   └── ...
│   │   │
│   │   ├── screens/              # Pantallas (16 pantallas)
│   │   │   ├── login_screen.dart
│   │   │   ├── home_screen.dart
│   │   │   ├── modules_screen.dart
│   │   │   ├── prealumni/
│   │   │   │   ├── prealumni_dashboard_screen.dart
│   │   │   │   ├── egresados_list_screen.dart
│   │   │   │   ├── egresado_detail_screen.dart
│   │   │   │   ├── documentos_egresado_screen.dart
│   │   │   │   ├── autoevaluacion_egresado_screen.dart
│   │   │   │   ├── estadisticas_screen.dart
│   │   │   │   ├── preguntas_screen.dart
│   │   │   │   ├── modulos_screen.dart
│   │   │   │   ├── carreras_screen.dart
│   │   │   │   ├── grados_academicos_screen.dart
│   │   │   │   └── pdfs_unificados_screen.dart
│   │   │   └── register_screen.dart
│   │   │
│   │   └── widgets/              # Widgets reutilizables
│   │       ├── custom_button.dart
│   │       ├── custom_text_field.dart
│   │       ├── stat_card.dart
│   │       ├── data_table_custom.dart
│   │       └── ...
│   │
│   └── main.dart                 # Punto de entrada
│
├── test/                          # Tests unitarios
│   ├── core/
│   │   └── utils/
│   │       └── validators_test.dart
│   ├── data/
│   │   └── models/
│   │       ├── auth_response_test.dart
│   │       ├── login_request_test.dart
│   │       └── user_test.dart
│   └── presentation/
│       └── widgets/
│           ├── custom_button_test.dart
│           └── custom_text_field_test.dart
│
├── web/                           # Configuración Web
│   ├── index.html
│   ├── manifest.json
│   └── icons/
- Acceso a "Red de Egresados (Pre-Alumni)"

### 4. Dashboard Pre-Alumni
- Estadísticas generales
- Total de egresados
- Documentos pendientes
- Habilitados vs no habilitados
- Acciones rápidas:
  - Enviar invitaciones
  - Cargar Excel
  - Exportar datos
  - Ver estadísticas

### 5. Lista de Egresados
- Tabla paginada de egresados
- Búsqueda por nombre/email
- Filtros por carrera y estado
- Indicador de progreso por egresado
- Acceso a detalle

### 6. Detalle de Egresado
- Información personal completa
- Progreso de documentos
- Estado de autoevaluación
- Estado de grado académico
- Acciones:
  - Habilitar/deshabilitar
  - Ver documentos
  - Ver autoevaluación
  - Editar información

### 7. Documentos del Egresado
- Lista de documentos cargados
- Tipo, estado, tamaño, fecha
- Visor de PDF integrado
- Descargar documentos
- Generar PDF unificado

### 8. Autoevaluación del Egresado
- Ver respuestas por módulo
- Todas las preguntas y respuestas
- Exportar a PDF

### 9. Estadísticas
- Gráfica de distribución por carrera
- Gráfica de empleabilidad
- Embudo del proceso
- Radar de competencias
- Exportar reporte a PDF

### 10. Gestión de Preguntas
- Lista de preguntas activas/inactivas
- Crear nueva pregunta
- Editar pregunta existente
- Reordenar preguntas
- Activar/desactivar
- Configurar opciones (para múltiple opción)

### 11. Gestión de Módulos
- Lista de módulos temáticos
- Crear nuevo módulo
- Editar módulo
- Activar/desactivar

### 12. Gestión de Carreras
- Lista de carreras por facultad
- Crear nueva carrera
- Editar carrera
- Activar/desactivar
- Búsqueda de carreras

### 13. Gestión de Grados Académicos
- Lista de grados (Pregrado, Posgrado, etc.)
- Crear nuevo grado
- Editar grado
- Activar/desactivar

### 14. PDFs Unificados
- Lista de PDFs generados
- Ver PDF
- Descargar PDF
- Eliminar PDF
- Organización cronológica

### 15. Registro de Administrador
- Formulario de registro
- Email institucional
- Contraseña con confirmación
- Validaciones

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
cd administrativo_app
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Configurar API Backend**

Editar `lib/core/config/api_config.dart`:
```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:3000'; // Dev
  // static const String baseUrl = 'https://api.alumni.ucc.edu.co'; // Prod
}
```

4. **Configurar Supabase**

Editar `lib/core/config/supabase_config.dart`:
```dart
class SupabaseConfig {
  static const String url = 'https://tu-proyecto.supabase.co';
  static const String anonKey = 'tu-anon-key';
}
```

### Ejecutar en Desarrollo

```bash
# Ejecutar en Windows
flutter run -d windows

# Modo release
flutter run -d windows --release

# Con hot reload
flutter run -d windows --hot
```

### Instalación de Dependencias Windows

La primera vez que ejecutes en Windows, Flutter descargará automáticamente las dependencias necesarias.

## Testing

### Suite de Tests

La aplicación cuenta con **27 tests** que cubren:

- **Validators** - Validaciones de formularios
- **Models** - Serialización/deserialización JSON
- **Widgets** - Componentes UI personalizados

### Ejecutar Tests

```bash
# Todos los tests
flutter test

# Tests con cobertura
flutter test --coverage

# Un archivo específico
flutter test test/core/utils/validators_test.dart

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

### Build Windows Desktop

```bash
# Build release para Windows
flutter build windows --release

# Output: build/windows/runner/Release/
```

### Distribución

La aplicación compilada se encuentra en `build/windows/runner/Release/` y contiene:
- `administrativo_app.exe` - Ejecutable principal
- Archivos DLL necesarios
- Carpeta `data/` con recursos

**Opciones de distribución:**

1. **Instalador MSI/NSIS**
   - Usar herramientas como Inno Setup o NSIS
   - Crear instalador profesional

2. **Carpeta portable**
   - Comprimir carpeta Release
   - Distribuir como .zip

3. **Microsoft Store** (opcional)
   - Preparar paquete MSIX
   - Publicar en la tienda

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
```

### Debugging
```bash
# Logs de la app
flutter logs

# Modo profile (performance)
flutter run --profile -d windows

# DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

## Troubleshooting

### Problemas Comunes

**Error de conexión con API:**
```bash
# Verificar API URL en api_config.dart
# Verificar que el backend esté corriendo
# Verificar firewall de Windows
```

**Error de Supabase:**
```bash
# Verificar URL y keys en supabase_config.dart
```

## Características Especiales

### Gráficas y Estadísticas
- Uso de `fl_chart` para visualizaciones
- Gráficas de barras, líneas, pie
- Radar charts para competencias
- Exportación a PDF de reportes

### Visor de PDF
- Integración con Syncfusion PDF Viewer
- Zoom, scroll, búsqueda en PDF
- Download de PDFs

### Generación de Excel
- Export de datos de egresados
- Formato personalizado
- Múltiples hojas

### Carga Masiva
- Upload de Excel con validación
- Preview de datos antes de importar
- Manejo de errores por fila

## Estado del Proyecto

- Login de administradores
- Dashboard con estadísticas
- Gestión completa de egresados
- Validación de documentos
- Sistema de autoevaluación configurable
- Gestión de catálogos
- Reportes y exportaciones
- 27 tests unitarios
- Listo para producción

## Soporte

Para problemas técnicos o preguntas:
- Crear un issue en el repositorio
- Contactar al equipo de desarrollo

---

**Versión:** 1.0.0  
**Última actualización:** Diciembre 2025  
**Universidad Cooperativa de Colombia**
