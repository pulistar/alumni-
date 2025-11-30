import 'package:flutter/foundation.dart';
import '../models/login_request.dart';
import '../models/auth_response.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Authentication Service
/// Manages authentication state and operations
class AuthService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  User? _currentUser;
  String? _accessToken;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  /// Initialize auth service
  /// Check if user is already authenticated
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final hasToken = await _storageService.hasToken();
      if (hasToken) {
        _accessToken = await _storageService.getToken();
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
      }
    } catch (e) {
      _isAuthenticated = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _apiService.login(request);

      // Save token
      await _storageService.saveToken(response.accessToken);

      // Update state
      _currentUser = response.user;
      _accessToken = response.accessToken;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _storageService.deleteToken();
    _currentUser = null;
    _accessToken = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
