/// API Configuration
/// Contains base URL and endpoints for the backend API
class ApiConfig {
  // Base URL for the backend API (includes /api prefix)
  static const String baseUrl = 'https://alumni-backend-4ej0.onrender.com/api';
  
  // API Endpoints
  static const String loginEndpoint = '/auth/admin/login';
  
  // Full URLs
  static String get loginUrl => '$baseUrl$loginEndpoint';
}
