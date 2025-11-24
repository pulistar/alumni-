# 🏗️ Arquitectura del Backend Alumni - NestJS

## 📐 Patrón Arquitectónico

**Modular + Layered Architecture** con principios de Clean Architecture

```
┌──────────────────────────────────────────────────────────┐
│                  PRESENTATION LAYER                       │
│         (Controllers, DTOs, Guards, Pipes)                │
│  - Maneja HTTP requests/responses                         │
│  - Validación de entrada                                  │
│  - Transformación de datos                                │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│                  APPLICATION LAYER                        │
│            (Services, Use Cases)                          │
│  - Lógica de negocio                                      │
│  - Orquestación de operaciones                            │
│  - Reglas de dominio                                      │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│                INFRASTRUCTURE LAYER                       │
│      (Supabase Client, Storage, External Services)       │
│  - Acceso a datos                                         │
│  - Servicios externos                                     │
│  - Implementaciones concretas                             │
└──────────────────────────────────────────────────────────┘
```

## 🎯 Principios SOLID

### Single Responsibility Principle (SRP)
Cada clase tiene una única responsabilidad:
- **Controllers**: Solo manejan HTTP
- **Services**: Solo lógica de negocio
- **Repositories**: Solo acceso a datos

### Open/Closed Principle (OCP)
Abierto a extensión, cerrado a modificación:
- Uso de interfaces y abstracciones
- Estrategias intercambiables

### Liskov Substitution Principle (LSP)
Las implementaciones son intercambiables:
- Interfaces bien definidas
- Contratos claros

### Interface Segregation Principle (ISP)
Interfaces específicas y pequeñas:
- No interfaces "gordas"
- Cada cliente usa solo lo que necesita

### Dependency Inversion Principle (DIP)
Depender de abstracciones, no de concreciones:
- Inyección de dependencias
- Uso de interfaces

## 📦 Módulos del Sistema

### **Core Modules** (Funcionalidad principal)
1. **AuthModule**: Autenticación (Magic Link + JWT)
2. **EgresadosModule**: Gestión de egresados
3. **DocumentosModule**: Manejo de documentos y storage
4. **AutoevaluacionModule**: Sistema de autoevaluación
5. **NotificacionesModule**: Notificaciones in-app

### **Admin Modules** (Panel administrativo)
6. **AdministradoresModule**: Gestión de admins
7. **CargasExcelModule**: Procesamiento de Excel
8. **EstadisticasModule**: Dashboard y métricas

### **Auxiliary Modules** (Catálogos y utilidades)
9. **CarrerasModule**: Catálogo de carreras
10. **ModulosModule**: 9 módulos del sistema

### **Infrastructure Modules** (Servicios base)
11. **DatabaseModule**: Cliente de Supabase
12. **ConfigModule**: Configuración global

## 🔐 Estrategias de Autenticación

### **Egresados → Supabase Auth**
```typescript
@UseGuards(SupabaseAuthGuard)
@Get('me')
async getProfile(@CurrentUser() user: User) {
  return this.egresadosService.findByUid(user.id);
}
```

### **Administradores → JWT**
```typescript
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin', 'superadmin')
@Get('estadisticas')
async getStats() {
  return this.estadisticasService.getGeneral();
}
```

## 🎨 Patrones de Diseño Implementados

### **Creacionales**
- **Factory**: NotificacionFactory, DTOFactory
- **Builder**: QueryBuilder para consultas complejas
- **Singleton**: SupabaseClient

### **Estructurales**
- **Adapter**: SupabaseAdapter (abstrae Supabase)
- **Decorator**: Guards, Interceptors, Pipes
- **Facade**: Servicios complejos simplificados

### **Comportamentales**
- **Strategy**: AuthStrategy (JWT vs Supabase)
- **Observer**: Sistema de eventos
- **Chain of Responsibility**: Validación en cadena

## 📂 Estructura de Archivos por Módulo

```
module-name/
├── dto/
│   ├── create-entity.dto.ts
│   ├── update-entity.dto.ts
│   └── response-entity.dto.ts
├── entities/
│   └── entity.entity.ts
├── interfaces/
│   └── entity-repository.interface.ts
├── guards/
│   └── entity-specific.guard.ts
├── module-name.controller.ts
├── module-name.service.ts
├── module-name.repository.ts
└── module-name.module.ts
```

## 🔄 Flujo de una Request

```
1. HTTP Request
   ↓
2. Controller (validación inicial)
   ↓
3. Guard (autenticación/autorización)
   ↓
4. Pipe (transformación/validación)
   ↓
5. Service (lógica de negocio)
   ↓
6. Repository (acceso a datos)
   ↓
7. Supabase (base de datos)
   ↓
8. Response (transformada por interceptor)
```

## 🛡️ Capas de Seguridad

1. **CORS**: Configurado para dominios permitidos
2. **Rate Limiting**: Protección contra ataques
3. **Helmet**: Headers de seguridad
4. **Validation**: class-validator en todos los DTOs
5. **Guards**: Autenticación y autorización
6. **RLS**: Row Level Security en Supabase

## 📊 Manejo de Errores

```typescript
// Custom Exceptions
export class EgresadoNotFoundException extends NotFoundException {
  constructor(id: string) {
    super({
      statusCode: 404,
      message: `Egresado con ID ${id} no encontrado`,
      error: 'Egresado Not Found',
    });
  }
}

// Global Exception Filter
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    // Logging centralizado
    // Respuesta consistente
    // Ocultamiento de detalles sensibles
  }
}
```

## 🧪 Testing Strategy

```
Unit Tests → Services, Guards, Pipes
Integration Tests → Controllers + Services
E2E Tests → Flujos completos
```

## 📝 Logging

```typescript
// Winston Logger
this.logger.log('Operación exitosa', { userId, action });
this.logger.error('Error en operación', error.stack);
this.logger.warn('Advertencia', { details });
```

## 🚀 Performance

- **Caching**: Redis para datos frecuentes
- **Pagination**: Todas las listas paginadas
- **Lazy Loading**: Módulos cargados bajo demanda
- **Compression**: Respuestas comprimidas

---

**Versión**: 1.0.0  
**Última actualización**: 2025-11-23
