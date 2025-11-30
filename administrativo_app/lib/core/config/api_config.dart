/// API Configuration
/// Contains base URL and endpoints for the backend API
class ApiConfig {
  // Base URL for the backend API (includes /api prefix)
  static const String baseUrl = 'http://localhost:3000/api';
  
  // API Endpoints
  static const String loginEndpoint = '/auth/admin/login';
  
  // Full URLs
  static String get loginUrl => '$baseUrl$loginEndpoint';
}
