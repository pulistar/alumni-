# 🔧 Documentación Técnica - Sistema Alumni UCC

## Universidad Cooperativa de Colombia

**Versión**: 1.0.0  
**Fecha**: Noviembre 2025  
**Equipo**: Desarrollo Alumni UCC

---

## 📋 Tabla de Contenidos

1. [Introducción](#1-introducción)
2. [Arquitectura del Sistema](#2-arquitectura-del-sistema)
3. [Stack Tecnológico](#3-stack-tecnológico)
4. [Instalación y Configuración](#4-instalación-y-configuración)
5. [Base de Datos](#5-base-de-datos)
6. [Backend API](#6-backend-api)
7. [Frontend Flutter](#7-frontend-flutter)
8. [Autenticación y Seguridad](#8-autenticación-y-seguridad)
9. [Deployment](#9-deployment)
10. [Testing](#10-testing)
11. [Monitoreo y Logs](#11-monitoreo-y-logs)
12. [Troubleshooting](#12-troubleshooting)
13. [Contribución](#13-contribución)

---

## 1. Introducción

### 1.1 Propósito del Documento

Este documento proporciona información técnica detallada sobre el Sistema Alumni de la Universidad Cooperativa de Colombia, dirigido a:

- Desarrolladores que trabajarán en el proyecto
- Administradores de sistemas
- Personal de DevOps
- Arquitectos de software

### 1.2 Alcance del Sistema

El Sistema Alumni es una plataforma completa de gestión de egresados que incluye:

- **Backend API**: NestJS + Supabase
- **Frontend Móvil**: Flutter (Android, iOS, Web)
- **Base de Datos**: PostgreSQL con Supabase
- **Autenticación**: Dual (Magic Link + JWT)
- **Storage**: Supabase Storage para documentos

### 1.3 Convenciones del Documento

- `código`: Código inline
- **Negrita**: Términos importantes
- > Nota: Información adicional
- ⚠️ Advertencia: Información crítica

---

## 2. Arquitectura del Sistema

### 2.1 Arquitectura General

```
┌─────────────────────────────────────────────────────────────┐
│                     FRONTEND LAYER                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Android    │  │     iOS      │  │     Web      │     │
│  │   Flutter    │  │   Flutter    │  │   Flutter    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
                            ↓ HTTP/REST
┌─────────────────────────────────────────────────────────────┐
│                     BACKEND LAYER                           │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              NestJS API Server                        │  │
│  │  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐      │  │
│  │  │ Auth │ │Egres.│ │ Docs │ │AutoEv│ │Notif.│      │  │
│  │  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘      │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ↓ Supabase Client
┌─────────────────────────────────────────────────────────────┐
│                     DATA LAYER                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Supabase Platform                        │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐            │  │
│  │  │PostgreSQL│ │   Auth   │ │ Storage  │            │  │
│  │  │   +RLS   │ │Magic Link│ │   S3     │            │  │
│  │  └──────────┘ └──────────┘ └──────────┘            │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Patrón Arquitectónico

**Modular + Layered Architecture**

#### Capas:

1. **Presentation Layer** (Frontend)
   - Flutter BLoC para state management
   - Widgets reutilizables
   - Navegación con go_router

2. **Application Layer** (Backend)
   - Controllers: Manejo de HTTP requests
   - Services: Lógica de negocio
   - DTOs: Validación y transformación

3. **Infrastructure Layer**
   - Supabase Client
   - Storage Service
   - Mail Service
   - External APIs

4. **Data Layer**
   - PostgreSQL Database
   - Row Level Security (RLS)
   - Triggers y Functions

### 2.3 Principios SOLID

- **S**ingle Responsibility: Cada clase tiene una única responsabilidad
- **O**pen/Closed: Abierto a extensión, cerrado a modificación
- **L**iskov Substitution: Implementaciones intercambiables
- **I**nterface Segregation: Interfaces específicas
- **D**ependency Inversion: Depender de abstracciones

---

## 3. Stack Tecnológico

### 3.1 Backend

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| **Node.js** | 18+ | Runtime de JavaScript |
| **NestJS** | 10.0 | Framework web |
| **TypeScript** | 5.1+ | Lenguaje tipado |
| **Supabase** | 2.39+ | BaaS (Backend as a Service) |
| **PostgreSQL** | 15+ | Base de datos |
| **Winston** | 3.18+ | Logging |
| **Passport** | 0.7+ | Autenticación |
| **ExcelJS** | 4.4+ | Procesamiento de Excel |
| **Nodemailer** | 7.0+ | Envío de emails |
| **PDF-lib** | 1.17+ | Generación de PDFs |

### 3.2 Frontend

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| **Flutter** | 3.1+ | Framework UI |
| **Dart** | 3.0+ | Lenguaje de programación |
| **flutter_bloc** | 8.1+ | State management |
| **Dio** | 5.3+ | HTTP client |
| **Supabase Flutter** | 2.0+ | Cliente de Supabase |
| **go_router** | 12.1+ | Navegación |
| **flutter_secure_storage** | 9.0+ | Almacenamiento seguro |

### 3.3 Infraestructura

| Servicio | Propósito |
|----------|-----------|
| **Supabase** | Hosting de base de datos, auth, storage |
| **Vercel/Railway** | Hosting del backend NestJS |
| **Google Play Store** | Distribución Android |
| **App Store** | Distribución iOS |
| **GitHub** | Control de versiones |

---

## 4. Instalación y Configuración

### 4.1 Requisitos Previos

#### Para Backend:
```bash
# Node.js 18+
node --version  # v18.0.0 o superior

# npm o yarn
npm --version   # 9.0.0 o superior

# Git
git --version
```

#### Para Frontend:
```bash
# Flutter SDK 3.1+
flutter --version

# Android Studio (para Android)
# Xcode (para iOS, solo en macOS)
```

### 4.2 Clonar el Repositorio

```bash
# Clonar el proyecto
git clone https://github.com/tu-org/proyecto-alumni.git
cd proyecto-alumni

# Estructura del proyecto
proyecto-alumni/
├── alumni-backend/      # Backend NestJS
├── egresados_app/       # Frontend Flutter
└── administrativo_app/  # App administrativa (opcional)
```

### 4.3 Configurar Backend

#### Paso 1: Instalar Dependencias

```bash
cd alumni-backend
npm install
```

#### Paso 2: Configurar Variables de Entorno

Crear archivo `.env`:

```bash
cp .env.example .env
```

Editar `.env`:

```env
# Supabase
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-anon-key
SUPABASE_SERVICE_ROLE_KEY=tu-service-role-key

# JWT
JWT_SECRET=tu-secret-muy-seguro-aqui
JWT_EXPIRATION=7d

# Email (SMTP)
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USER=tu-email@gmail.com
MAIL_PASSWORD=tu-app-password
MAIL_FROM=noreply@campusucc.edu.co

# App
PORT=3000
NODE_ENV=development
FRONTEND_URL=http://localhost:8080

# Rate Limiting
THROTTLE_TTL=60
THROTTLE_LIMIT=100
```

#### Paso 3: Configurar Base de Datos

```bash
# Ejecutar el schema SQL en Supabase
# 1. Ir a Supabase Dashboard → SQL Editor
# 2. Copiar contenido de supabase_schema.sql
# 3. Ejecutar
```

#### Paso 4: Ejecutar Backend

```bash
# Desarrollo
npm run start:dev

# Producción
npm run build
npm run start:prod
```

El backend estará disponible en `http://localhost:3000`

### 4.4 Configurar Frontend

#### Paso 1: Instalar Dependencias

```bash
cd egresados_app
flutter pub get
```

#### Paso 2: Configurar Supabase

Editar `lib/core/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String url = 'https://tu-proyecto.supabase.co';
  static const String anonKey = 'tu-anon-key';
}
```

Editar `lib/core/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:3000';
  // Para producción: 'https://api.alumni.campusucc.edu.co'
}
```

#### Paso 3: Ejecutar Flutter

```bash
# Android
flutter run -d android

# iOS (solo en macOS)
flutter run -d ios

# Web
flutter run -d chrome

# Windows
flutter run -d windows
```

---

## 5. Base de Datos

### 5.1 Schema Overview

#### Tablas Principales (12)

```sql
-- 1. Carreras
CREATE TABLE carreras (
    id UUID PRIMARY KEY,
    nombre VARCHAR(255) UNIQUE NOT NULL,
    codigo VARCHAR(50) UNIQUE,
    activa BOOLEAN DEFAULT true
);

-- 2. Egresados
CREATE TABLE egresados (
    id UUID PRIMARY KEY,
    uid VARCHAR(255) UNIQUE NOT NULL,  -- Supabase Auth ID
    correo VARCHAR(255) UNIQUE NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    apellido VARCHAR(255) NOT NULL,
    carrera_id UUID REFERENCES carreras(id),
    telefono VARCHAR(20),
    estado_laboral VARCHAR(50),
    habilitado BOOLEAN DEFAULT false,
    deleted_at TIMESTAMP  -- Soft delete
);

-- 3. Documentos
CREATE TABLE documentos_egresado (
    id UUID PRIMARY KEY,
    egresado_id UUID REFERENCES egresados(id),
    tipo_documento VARCHAR(100) NOT NULL,
    ruta_storage TEXT NOT NULL,
    tamano_bytes BIGINT,
    deleted_at TIMESTAMP
);

-- 4. Autoevaluación
CREATE TABLE preguntas_autoevaluacion (
    id UUID PRIMARY KEY,
    texto TEXT NOT NULL,
    tipo VARCHAR(50) DEFAULT 'likert',
    orden INTEGER NOT NULL,
    activa BOOLEAN DEFAULT true
);

CREATE TABLE respuestas_autoevaluacion (
    id UUID PRIMARY KEY,
    egresado_id UUID REFERENCES egresados(id),
    pregunta_id UUID REFERENCES preguntas_autoevaluacion(id),
    respuesta_numerica INTEGER,
    UNIQUE(egresado_id, pregunta_id)
);

-- 5. Notificaciones
CREATE TABLE notificaciones (
    id UUID PRIMARY KEY,
    egresado_id UUID REFERENCES egresados(id),
    titulo VARCHAR(255) NOT NULL,
    mensaje TEXT NOT NULL,
    tipo VARCHAR(50),
    leida BOOLEAN DEFAULT false
);

-- ... (ver supabase_schema.sql para schema completo)
```

### 5.2 Row Level Security (RLS)

#### Políticas para Egresados

```sql
-- Los egresados solo ven sus propios datos
CREATE POLICY "Egresados ven su información"
ON egresados FOR SELECT
USING (auth.uid()::text = uid AND deleted_at IS NULL);

-- Los egresados pueden actualizar su información
CREATE POLICY "Egresados actualizan su información"
ON egresados FOR UPDATE
USING (auth.uid()::text = uid AND deleted_at IS NULL);
```

#### Políticas para Documentos

```sql
-- Los egresados solo ven sus documentos
CREATE POLICY "Egresados ven sus documentos"
ON documentos_egresado FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM egresados 
        WHERE id = documentos_egresado.egresado_id 
        AND uid = auth.uid()::text
        AND deleted_at IS NULL
    ) AND documentos_egresado.deleted_at IS NULL
);
```

### 5.3 Triggers

#### Actualizar Timestamps

```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_egresados_updated_at
BEFORE UPDATE ON egresados
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

#### Validar Correo Institucional

```sql
CREATE OR REPLACE FUNCTION validar_correo_institucional()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.correo NOT LIKE '%@campusucc.edu.co' THEN
    RAISE EXCEPTION 'Solo correos institucionales @campusucc.edu.co';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validar_correo_egresado
BEFORE INSERT OR UPDATE ON egresados
FOR EACH ROW EXECUTE FUNCTION validar_correo_institucional();
```

### 5.4 Vistas

#### Vista de Egresados Completo

```sql
CREATE OR REPLACE VIEW v_egresados_completo AS
SELECT 
    e.id,
    e.uid,
    e.correo,
    e.nombre,
    e.apellido,
    c.nombre AS carrera_nombre,
    e.habilitado,
    e.proceso_grado_completo,
    e.autoevaluacion_completada,
    (SELECT COUNT(*) FROM documentos_egresado 
     WHERE egresado_id = e.id AND deleted_at IS NULL) AS documentos_subidos
FROM egresados e
LEFT JOIN carreras c ON e.carrera_id = c.id
WHERE e.deleted_at IS NULL;
```

### 5.5 Funciones

#### Verificar Proceso Completo

```sql
CREATE OR REPLACE FUNCTION verificar_proceso_completo(p_egresado_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    v_documentos_requeridos INTEGER := 3;
    v_documentos_subidos INTEGER;
BEGIN
    SELECT COUNT(DISTINCT tipo_documento)
    INTO v_documentos_subidos
    FROM documentos_egresado
    WHERE egresado_id = p_egresado_id
    AND tipo_documento IN ('momento_ole', 'datos_egresados', 'bolsa_empleo')
    AND deleted_at IS NULL;
    
    RETURN v_documentos_subidos >= v_documentos_requeridos;
END;
$$ LANGUAGE plpgsql;
```

---

## 6. Backend API

### 6.1 Estructura del Proyecto

```
alumni-backend/
├── src/
│   ├── auth/                    # Módulo de autenticación
│   │   ├── auth.controller.ts
│   │   ├── auth.service.ts
│   │   ├── auth.module.ts
│   │   ├── guards/
│   │   │   ├── jwt-auth.guard.ts
│   │   │   └── supabase-auth.guard.ts
│   │   └── strategies/
│   │       ├── jwt.strategy.ts
│   │       └── supabase.strategy.ts
│   ├── egresados/               # Módulo de egresados
│   │   ├── egresados.controller.ts
│   │   ├── egresados.service.ts
│   │   ├── egresados.module.ts
│   │   └── dto/
│   │       ├── create-egresado.dto.ts
│   │       └── update-egresado.dto.ts
│   ├── documentos/              # Módulo de documentos
│   ├── autoevaluacion/          # Módulo de autoevaluación
│   ├── notificaciones/          # Módulo de notificaciones
│   ├── admin/                   # Módulo administrativo
│   ├── database/                # Cliente de Supabase
│   │   ├── supabase.service.ts
│   │   └── database.module.ts
│   ├── mail/                    # Servicio de email
│   ├── common/                  # Utilidades compartidas
│   │   ├── decorators/
│   │   ├── filters/
│   │   └── pipes/
│   ├── app.module.ts
│   └── main.ts
├── test/
├── .env
├── .env.example
├── package.json
└── tsconfig.json
```

### 6.2 Endpoints Principales

#### Autenticación

```typescript
// POST /auth/login
// Enviar magic link
{
  "email": "juan.perez@campusucc.edu.co"
}

// Response
{
  "message": "Magic link enviado a tu correo",
  "email": "juan.perez@campusucc.edu.co"
}

// POST /auth/admin/login
// Login de administradores
{
  "email": "admin@campusucc.edu.co",
  "password": "password123"
}

// Response
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid",
    "email": "admin@campusucc.edu.co",
    "rol": "admin"
  }
}
```

#### Egresados

```typescript
// GET /egresados/me
// Headers: Authorization: Bearer <supabase-token>
// Response
{
  "id": "uuid",
  "uid": "supabase-uid",
  "correo": "juan.perez@campusucc.edu.co",
  "nombre": "Juan",
  "apellido": "Pérez",
  "carrera": {
    "id": "uuid",
    "nombre": "Ingeniería de Sistemas"
  },
  "habilitado": true,
  "proceso_grado_completo": false,
  "autoevaluacion_completada": false
}

// PUT /egresados/complete-profile
// Headers: Authorization: Bearer <supabase-token>
{
  "telefono": "3001234567",
  "direccion": "Calle 123 #45-67",
  "ciudad": "Bogotá",
  "estado_laboral": "empleado",
  "empresa_actual": "Tech Corp",
  "cargo_actual": "Desarrollador"
}
```

#### Documentos

```typescript
// POST /documentos/upload
// Headers: Authorization: Bearer <supabase-token>
// Content-Type: multipart/form-data
{
  "file": <binary>,
  "tipo_documento": "momento_ole"
}

// Response
{
  "id": "uuid",
  "tipo_documento": "momento_ole",
  "nombre_archivo": "momento_ole_juan_perez.pdf",
  "ruta_storage": "egresados/uid/momento_ole_uuid.pdf",
  "tamano_bytes": 1024000,
  "created_at": "2025-11-30T10:00:00Z"
}

// GET /documentos
// Headers: Authorization: Bearer <supabase-token>
// Response
[
  {
    "id": "uuid",
    "tipo_documento": "momento_ole",
    "nombre_archivo": "momento_ole.pdf",
    "created_at": "2025-11-30T10:00:00Z"
  }
]
```

#### Autoevaluación

```typescript
// GET /autoevaluacion/preguntas
// Headers: Authorization: Bearer <supabase-token>
// Response
[
  {
    "id": "uuid",
    "texto": "¿Cómo calificarías tu capacidad de trabajo en equipo?",
    "tipo": "likert",
    "orden": 1,
    "categoria": "competencias"
  }
]

// POST /autoevaluacion/respuestas
// Headers: Authorization: Bearer <supabase-token>
{
  "respuestas": [
    {
      "pregunta_id": "uuid",
      "respuesta_numerica": 5
    },
    {
      "pregunta_id": "uuid",
      "respuesta_numerica": 4
    }
  ]
}
```

### 6.3 Guards y Decorators

#### Supabase Auth Guard

```typescript
// src/auth/guards/supabase-auth.guard.ts
import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { SupabaseService } from '../../database/supabase.service';

@Injectable()
export class SupabaseAuthGuard implements CanActivate {
  constructor(private supabase: SupabaseService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = this.extractToken(request);
    
    if (!token) return false;
    
    const { data: { user }, error } = await this.supabase.client.auth.getUser(token);
    
    if (error || !user) return false;
    
    request.user = user;
    return true;
  }

  private extractToken(request: any): string | null {
    const authHeader = request.headers.authorization;
    if (!authHeader) return null;
    return authHeader.replace('Bearer ', '');
  }
}
```

#### Current User Decorator

```typescript
// src/common/decorators/current-user.decorator.ts
import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export const CurrentUser = createParamDecorator(
  (data: unknown, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    return request.user;
  },
);
```

#### Uso en Controllers

```typescript
@Controller('egresados')
export class EgresadosController {
  @Get('me')
  @UseGuards(SupabaseAuthGuard)
  async getProfile(@CurrentUser() user: User) {
    return this.egresadosService.findByUid(user.id);
  }
}
```

### 6.4 DTOs y Validación

```typescript
// src/egresados/dto/complete-profile.dto.ts
import { IsString, IsOptional, IsEnum, Length } from 'class-validator';

export class CompleteProfileDto {
  @IsString()
  @Length(10, 20)
  telefono: string;

  @IsString()
  @IsOptional()
  telefono_alternativo?: string;

  @IsString()
  direccion: string;

  @IsString()
  ciudad: string;

  @IsEnum(['empleado', 'desempleado', 'emprendedor', 'estudiando'])
  estado_laboral: string;

  @IsString()
  @IsOptional()
  empresa_actual?: string;

  @IsString()
  @IsOptional()
  cargo_actual?: string;
}
```

---

## 7. Frontend Flutter

### 7.1 Estructura del Proyecto

```
egresados_app/
├── lib/
│   ├── core/
│   │   ├── config/
│   │   │   ├── api_config.dart
│   │   │   ├── app_config.dart
│   │   │   └── supabase_config.dart
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   └── utils/
│   │       ├── validators.dart
│   │       └── constants.dart
│   ├── data/
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── documento_model.dart
│   │   │   └── autoevaluacion_model.dart
│   │   └── services/
│   │       ├── auth_service.dart
│   │       ├── documentos_service.dart
│   │       └── autoevaluacion_service.dart
│   ├── presentation/
│   │   ├── blocs/
│   │   │   ├── auth/
│   │   │   │   ├── auth_bloc.dart
│   │   │   │   ├── auth_event.dart
│   │   │   │   └── auth_state.dart
│   │   │   └── autoevaluacion/
│   │   ├── screens/
│   │   │   ├── auth/
│   │   │   │   └── login_screen.dart
│   │   │   ├── home/
│   │   │   │   └── home_screen.dart
│   │   │   └── profile/
│   │   └── widgets/
│   │       ├── custom_button.dart
│   │       └── loading_widget.dart
│   └── main.dart
├── android/
├── ios/
├── web/
├── pubspec.yaml
└── README.md
```

### 7.2 BLoC Pattern

#### Auth BLoC

```dart
// lib/presentation/blocs/auth/auth_bloc.dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc({required this.authService}) : super(AuthInitial()) {
    on<AuthInitialized>(_onInitialized);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onInitialized(
    AuthInitialized event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final session = await authService.getCurrentSession();
      
      if (session != null) {
        final user = await authService.getCurrentUser();
        
        if (user.hasCompletedProfile) {
          emit(AuthenticatedWithProfile(user: user));
        } else {
          emit(AuthenticatedWithoutProfile(user: user));
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      await authService.sendMagicLink(event.email);
      emit(AuthMagicLinkSent(email: event.email));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
```

### 7.3 Services

#### Auth Service

```dart
// lib/data/services/auth_service.dart
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> sendMagicLink(String email) async {
    try {
      await _supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'io.supabase.alumni://login-callback',
      );
    } catch (e) {
      throw Exception('Error al enviar magic link: $e');
    }
  }

  Future<Session?> getCurrentSession() async {
    return _supabase.auth.currentSession;
  }

  Future<UserModel> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('No hay usuario autenticado');

    final response = await _supabase
        .from('egresados')
        .select()
        .eq('uid', user.id)
        .single();

    return UserModel.fromJson(response);
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}
```

#### Documentos Service

```dart
// lib/data/services/documentos_service.dart
class DocumentosService {
  final Dio _dio;
  final SupabaseClient _supabase;

  DocumentosService(this._dio, this._supabase);

  Future<List<DocumentoModel>> getDocumentos() async {
    final token = _supabase.auth.currentSession?.accessToken;
    
    final response = await _dio.get(
      '/documentos',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    return (response.data as List)
        .map((json) => DocumentoModel.fromJson(json))
        .toList();
  }

  Future<DocumentoModel> uploadDocumento({
    required File file,
    required String tipoDocumento,
  }) async {
    final token = _supabase.auth.currentSession?.accessToken;
    
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
      'tipo_documento': tipoDocumento,
    });

    final response = await _dio.post(
      '/documentos/upload',
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    return DocumentoModel.fromJson(response.data);
  }
}
```

### 7.4 Models

```dart
// lib/data/models/user_model.dart
class UserModel {
  final String id;
  final String uid;
  final String correo;
  final String nombre;
  final String apellido;
  final String? telefono;
  final bool habilitado;
  final bool procesoGradoCompleto;
  final bool autoevaluacionCompletada;

  UserModel({
    required this.id,
    required this.uid,
    required this.correo,
    required this.nombre,
    required this.apellido,
    this.telefono,
    required this.habilitado,
    required this.procesoGradoCompleto,
    required this.autoevaluacionCompletada,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      uid: json['uid'],
      correo: json['correo'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      telefono: json['telefono'],
      habilitado: json['habilitado'] ?? false,
      procesoGradoCompleto: json['proceso_grado_completo'] ?? false,
      autoevaluacionCompletada: json['autoevaluacion_completada'] ?? false,
    );
  }

  bool get hasCompletedProfile => telefono != null;
}
```

---

## 8. Autenticación y Seguridad

### 8.1 Flujo de Autenticación

#### Magic Link (Egresados)

```
1. Usuario ingresa email
   ↓
2. Frontend → POST /auth/login
   ↓
3. Backend → Supabase.auth.signInWithOtp()
   ↓
4. Supabase envía email con magic link
   ↓
5. Usuario hace clic en link
   ↓
6. Deep link abre app: io.supabase.alumni://login-callback#access_token=...
   ↓
7. App extrae tokens y establece sesión
   ↓
8. Frontend → GET /egresados/me (con token)
   ↓
9. Usuario autenticado
```

#### JWT (Administradores)

```
1. Admin ingresa email + password
   ↓
2. Frontend → POST /auth/admin/login
   ↓
3. Backend valida con bcrypt
   ↓
4. Backend genera JWT token
   ↓
5. Frontend guarda token
   ↓
6. Todas las requests incluyen: Authorization: Bearer <jwt>
```

### 8.2 Seguridad en Backend

#### Rate Limiting

```typescript
// src/main.ts
import { ThrottlerGuard } from '@nestjs/throttler';

app.useGlobalGuards(new ThrottlerGuard());

// Configuración en app.module.ts
ThrottlerModule.forRoot([{
  ttl: 60000,  // 60 segundos
  limit: 100,  // 100 requests por minuto
}])
```

#### CORS

```typescript
// src/main.ts
app.enableCors({
  origin: [
    'http://localhost:8080',
    'https://alumni.campusucc.edu.co',
  ],
  credentials: true,
});
```

#### Helmet

```typescript
import helmet from 'helmet';

app.use(helmet());
```

### 8.3 Seguridad en Frontend

#### Almacenamiento Seguro

```dart
// lib/core/utils/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
}
```

---

## 9. Deployment

### 9.1 Backend Deployment

#### Opción 1: Railway

```bash
# 1. Instalar Railway CLI
npm install -g @railway/cli

# 2. Login
railway login

# 3. Inicializar proyecto
railway init

# 4. Agregar variables de entorno
railway variables set SUPABASE_URL=https://...
railway variables set SUPABASE_SERVICE_ROLE_KEY=...

# 5. Deploy
railway up
```

#### Opción 2: Vercel

```bash
# 1. Instalar Vercel CLI
npm install -g vercel

# 2. Login
vercel login

# 3. Deploy
vercel

# 4. Configurar variables de entorno en dashboard
```

#### Dockerfile

```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

EXPOSE 3000

CMD ["node", "dist/main"]
```

### 9.2 Flutter Deployment

#### Android

```bash
# 1. Generar keystore
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# 2. Configurar android/key.properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>

# 3. Build APK
flutter build apk --release

# 4. Build App Bundle (para Play Store)
flutter build appbundle --release

# 5. Subir a Google Play Console
```

#### iOS

```bash
# 1. Configurar certificados en Xcode
# 2. Build
flutter build ios --release

# 3. Abrir en Xcode
open ios/Runner.xcworkspace

# 4. Archive y subir a App Store Connect
```

#### Web

```bash
# 1. Build
flutter build web --release

# 2. Deploy a Firebase Hosting
firebase deploy --only hosting

# O a Vercel
vercel --prod
```

---

## 10. Testing

### 10.1 Backend Testing

#### Unit Tests

```typescript
// src/egresados/egresados.service.spec.ts
import { Test, TestingModule } from '@nestjs/testing';
import { EgresadosService } from './egresados.service';

describe('EgresadosService', () => {
  let service: EgresadosService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [EgresadosService],
    }).compile();

    service = module.get<EgresadosService>(EgresadosService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should find egresado by uid', async () => {
    const uid = 'test-uid';
    const result = await service.findByUid(uid);
    expect(result).toBeDefined();
    expect(result.uid).toBe(uid);
  });
});
```

#### E2E Tests

```typescript
// test/egresados.e2e-spec.ts
import { Test } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';

describe('Egresados (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  it('/egresados/me (GET)', () => {
    return request(app.getHttpServer())
      .get('/egresados/me')
      .set('Authorization', 'Bearer test-token')
      .expect(200);
  });
});
```

### 10.2 Flutter Testing

#### Unit Tests

```dart
// test/services/auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockSupabaseClient mockSupabase;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      authService = AuthService(mockSupabase);
    });

    test('sendMagicLink should call Supabase auth', () async {
      when(mockSupabase.auth.signInWithOtp(email: anyNamed('email')))
          .thenAnswer((_) async => AuthResponse());

      await authService.sendMagicLink('test@campusucc.edu.co');

      verify(mockSupabase.auth.signInWithOtp(email: 'test@campusucc.edu.co'))
          .called(1);
    });
  });
}
```

#### Widget Tests

```dart
// test/widgets/login_screen_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('LoginScreen should display email field', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: LoginScreen()),
    );

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Enviar Magic Link'), findsOneWidget);
  });
}
```

---

## 11. Monitoreo y Logs

### 11.1 Logging en Backend

```typescript
// src/main.ts
import { WinstonModule } from 'nest-winston';
import * as winston from 'winston';

const logger = WinstonModule.createLogger({
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.colorize(),
        winston.format.printf(({ timestamp, level, message }) => {
          return `${timestamp} [${level}]: ${message}`;
        }),
      ),
    }),
    new winston.transports.File({
      filename: 'logs/error.log',
      level: 'error',
    }),
    new winston.transports.File({
      filename: 'logs/combined.log',
    }),
  ],
});

app.useLogger(logger);
```

### 11.2 Uso de Logger

```typescript
import { Logger } from '@nestjs/common';

export class EgresadosService {
  private readonly logger = new Logger(EgresadosService.name);

  async findByUid(uid: string) {
    this.logger.log(`Buscando egresado con uid: ${uid}`);
    
    try {
      const egresado = await this.supabase
        .from('egresados')
        .select()
        .eq('uid', uid)
        .single();
      
      this.logger.log(`Egresado encontrado: ${egresado.data.correo}`);
      return egresado.data;
    } catch (error) {
      this.logger.error(`Error al buscar egresado: ${error.message}`);
      throw error;
    }
  }
}
```

---

## 12. Troubleshooting

### 12.1 Problemas Comunes

#### Backend no inicia

```bash
# Error: Cannot find module
npm install

# Error: Puerto en uso
# Cambiar PORT en .env o matar proceso
lsof -ti:3000 | xargs kill -9

# Error: Supabase connection
# Verificar variables de entorno
echo $SUPABASE_URL
```

#### Flutter no compila

```bash
# Limpiar cache
flutter clean
flutter pub get

# Regenerar archivos generados
flutter pub run build_runner build --delete-conflicting-outputs

# Error de dependencias
flutter pub upgrade
```

---

## 13. Contribución

### 13.1 Git Workflow

```bash
# 1. Crear rama feature
git checkout -b feature/nueva-funcionalidad

# 2. Hacer cambios y commits
git add .
git commit -m "feat: agregar nueva funcionalidad"

# 3. Push
git push origin feature/nueva-funcionalidad

# 4. Crear Pull Request en GitHub
```

### 13.2 Convenciones de Commits

```
feat: Nueva funcionalidad
fix: Corrección de bug
docs: Cambios en documentación
style: Formato, punto y coma, etc
refactor: Refactorización de código
test: Agregar tests
chore: Mantenimiento
```

---

**Documento creado por**: Equipo de Desarrollo Alumni UCC  
**Última actualización**: Noviembre 2025  
**Versión**: 1.0.0
