import 'dart:io';
import 'package:flutter/foundation.dart';

class PlatformUtils {
  // Detectar si estamos en emulador/simulador
  static bool get isEmulator {
    if (kIsWeb) return false;
    
    // En desarrollo, asumir que es emulador
    return kDebugMode;
  }
  
  // Obtener la URL base correcta para el backend local
  static String getLocalBackendUrl({int port = 3000}) {
    if (kIsWeb) {
      // Web development
      return 'http://localhost:$port/api';
    }
    
    if (Platform.isAndroid) {
      // Android emulator usa 10.0.2.2 para acceder al localhost del host
      return 'http://10.0.2.2:$port/api';
    }
    
    if (Platform.isIOS) {
      // iOS simulator puede usar localhost directamente
      return 'http://localhost:$port/api';
    }
    
    // Fallback
    return 'http://localhost:$port/api';
  }
  
  // Para dispositivos físicos, necesitarás tu IP local
  static String getPhysicalDeviceUrl(String hostIP, {int port = 3000}) {
    return 'http://$hostIP:$port/api';
  }
  
  // Detectar si es dispositivo físico
  static bool get isPhysicalDevice {
    if (kIsWeb) return false;
    return !kDebugMode; // En release mode, asumir dispositivo físico
  }
}
