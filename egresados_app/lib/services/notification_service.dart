import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    try {
      // Solicitar permisos
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ Permisos de notificaciones concedidos');
        
        // Obtener el token FCM
        _fcmToken = await _firebaseMessaging.getToken();
        debugPrint('📱 FCM Token: $_fcmToken');
        
        // Escuchar cambios en el token
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          debugPrint('🔄 FCM Token actualizado: $newToken');
        });
        
        // Configurar manejadores de notificaciones
        _setupNotificationHandlers();
      } else {
        debugPrint('❌ Permisos de notificaciones denegados');
      }
    } catch (e) {
      debugPrint('❌ Error inicializando notificaciones: $e');
    }
  }

  /// Configurar manejadores de notificaciones
  void _setupNotificationHandlers() {
    // Notificación recibida cuando la app está en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📬 Notificación recibida (foreground)');
      debugPrint('Título: ${message.notification?.title}');
      debugPrint('Cuerpo: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');
      
      // Aquí puedes mostrar una notificación local o un diálogo
    });

    // Notificación tocada cuando la app está en background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📬 Notificación tocada (background)');
      debugPrint('Data: ${message.data}');
      
      // Navegar a la pantalla correspondiente según message.data
      _handleNotificationTap(message.data);
    });

    // Verificar si la app se abrió desde una notificación
    _checkInitialMessage();
  }

  /// Verificar si la app se abrió desde una notificación
  Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    
    if (initialMessage != null) {
      debugPrint('📬 App abierta desde notificación');
      debugPrint('Data: ${initialMessage.data}');
      _handleNotificationTap(initialMessage.data);
    }
  }

  /// Manejar el tap en una notificación
  void _handleNotificationTap(Map<String, dynamic> data) {
    // Aquí puedes navegar a diferentes pantallas según el tipo de notificación
    final String? type = data['type'];
    final String? action = data['action'];
    
    debugPrint('🔔 Tipo de notificación: $type');
    debugPrint('🔔 Acción: $action');
    
    // Ejemplo: si es una notificación de habilitación, navegar a PreAlumni
    if (type == 'habilitacion' && action == 'open_prealumni') {
      // Aquí deberías navegar a la pantalla de PreAlumni
      // Puedes usar un GlobalKey<NavigatorState> o un sistema de routing
      debugPrint('➡️ Navegar a PreAlumni');
    }
  }

  /// Obtener el token FCM actual
  Future<String?> getToken() async {
    if (_fcmToken != null) {
      return _fcmToken;
    }
    
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      return _fcmToken;
    } catch (e) {
      debugPrint('❌ Error obteniendo FCM token: $e');
      return null;
    }
  }
}
