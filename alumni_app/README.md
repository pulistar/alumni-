# 📱 Alumni App - Universidad Cooperativa de Colombia

App móvil para egresados de la Universidad Cooperativa de Colombia.

## 🎯 Descripción

Aplicación móvil que permite a los egresados:
- Completar su perfil
- Subir documentos de grado
- Realizar autoevaluación de competencias
- Recibir notificaciones

## 🚀 Tecnologías

- **Framework:** Flutter 3.x
- **State Management:** flutter_bloc
- **HTTP Client:** dio + retrofit
- **Auth:** supabase_flutter
- **Storage:** flutter_secure_storage
- **Navigation:** go_router

## 📦 Instalación

```bash
# Clonar el repositorio
cd alumni_app

# Instalar dependencias
flutter pub get

# Ejecutar en modo desarrollo
flutter run
```

## 🏗️ Estructura del Proyecto

```
lib/
├── core/
│   ├── config/          # Configuración (API, etc)
│   ├── theme/           # Tema y colores UCC
│   ├── utils/           # Utilidades
│   └── widgets/         # Widgets reutilizables
├── data/
│   ├── models/          # Modelos de datos
│   ├── repositories/    # Repositorios
│   └── services/        # Servicios API
└── presentation/
    ├── auth/            # Autenticación
    ├── home/            # Home/Dashboard
    ├── profile/         # Perfil
    ├── documents/       # Documentos
    ├── notifications/   # Notificaciones
    └── autoevaluacion/  # Autoevaluación
```

## ⚙️ Configuración

### API Backend

Editar `lib/core/config/api_config.dart`:

```dart
static const String baseUrl = 'http://TU-IP:3000/api';
```

### Supabase

Configurar en el código las credenciales de Supabase.

## 🎨 Colores UCC

- **Azul Primario:** `#003366`
- **Verde Secundario:** `#00A859`
- **Amarillo Acento:** `#FFB81C`

## 📱 Plataformas Soportadas

- ✅ Android
- ✅ iOS

## 🧪 Testing

```bash
# Tests unitarios
flutter test

# Tests de integración
flutter test integration_test
```

## 📝 Próximos Pasos

1. Implementar pantallas de autenticación
2. Integrar con backend Alumni
3. Implementar gestión de documentos
4. Implementar autoevaluación
5. Agregar notificaciones push

## 👥 Equipo

Universidad Cooperativa de Colombia

## 📄 Licencia

Privado - UCC
