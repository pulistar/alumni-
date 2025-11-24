# Alumni Backend API

Backend API for the Alumni System - Universidad Cooperativa de Colombia

## 🏗️ Architecture

This project follows a **Modular + Layered Architecture** with Clean Code principles.

See [ARCHITECTURE.md](./ARCHITECTURE.md) for detailed documentation.

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ 
- npm or yarn
- Supabase account

### Installation

```bash
# Install dependencies
npm install

# Copy environment variables
cp .env.example .env

# Configure your .env file with Supabase credentials
```

### Running the app

```bash
# Development
npm run start:dev

# Production
npm run build
npm run start:prod
```

## 📁 Project Structure

```
src/
├── auth/              # Authentication module
├── egresados/         # Alumni management
├── documentos/        # Document handling
├── autoevaluacion/    # Self-assessment
├── notificaciones/    # Notifications
├── administradores/   # Admin management
├── cargas-excel/      # Excel processing
├── estadisticas/      # Statistics
├── carreras/          # Careers catalog
├── modulos/           # System modules
├── database/          # Supabase client
├── config/            # Configuration
└── common/            # Shared utilities
```

## 🔐 Authentication

- **Alumni**: Supabase Auth (Magic Link)
- **Admins**: JWT (Email + Password)

## 📚 API Documentation

API documentation available at `/api/docs` when running in development mode.

## 🧪 Testing

```bash
# Unit tests
npm run test

# E2E tests
npm run test:e2e

# Test coverage
npm run test:cov
```

## 📝 License

MIT
