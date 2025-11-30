import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/modulos_service.dart';
import 'modulos_event.dart';
import 'modulos_state.dart';

class ModulosBloc extends Bloc<ModulosEvent, ModulosState> {
  final ModulosService _modulosService;

  ModulosBloc({required ModulosService modulosService})
      : _modulosService = modulosService,
        super(ModulosInitial()) {
    on<ModulosLoadRequested>(_onModulosLoadRequested);
    on<ModulosRefreshRequested>(_onModulosRefreshRequested);
  }

  Future<void> _onModulosLoadRequested(
    ModulosLoadRequested event,
    Emitter<ModulosState> emit,
  ) async {
    emit(ModulosLoading());
    
    try {
      print('📱 ModulosBloc: Cargando módulos...');
      final modulos = await _modulosService.getModulos();
      
      // Filtrar módulos activos y ordenar por orden
      final modulosActivos = modulos
          .where((modulo) => modulo.activo)
          .toList()
        ..sort((a, b) => a.orden.compareTo(b.orden));
      
      print('📱 ModulosBloc: ${modulos.length} módulos cargados, ${modulosActivos.length} activos');
      
      emit(ModulosLoaded(
        modulos: modulos,
        modulosActivos: modulosActivos,
      ));
    } catch (e) {
      print('❌ ModulosBloc: Error cargando módulos: $e');
      emit(ModulosError(message: e.toString()));
    }
  }

  Future<void> _onModulosRefreshRequested(
    ModulosRefreshRequested event,
    Emitter<ModulosState> emit,
  ) async {
    // Refrescar sin mostrar loading si ya hay datos
    try {
      print('🔄 ModulosBloc: Refrescando módulos...');
      final modulos = await _modulosService.getModulos();
      
      final modulosActivos = modulos
          .where((modulo) => modulo.activo)
          .toList()
        ..sort((a, b) => a.orden.compareTo(b.orden));
      
      emit(ModulosLoaded(
        modulos: modulos,
        modulosActivos: modulosActivos,
      ));
    } catch (e) {
      print('❌ ModulosBloc: Error refrescando módulos: $e');
      emit(ModulosError(message: e.toString()));
    }
  }
}
