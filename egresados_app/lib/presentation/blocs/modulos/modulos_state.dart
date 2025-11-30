import '../../../data/models/modulo.dart';

abstract class ModulosState {}

class ModulosInitial extends ModulosState {}

class ModulosLoading extends ModulosState {}

class ModulosLoaded extends ModulosState {
  final List<Modulo> modulos;
  final List<Modulo> modulosActivos;

  ModulosLoaded({
    required this.modulos,
    required this.modulosActivos,
  });

  @override
  String toString() {
    return 'ModulosLoaded(total: ${modulos.length}, activos: ${modulosActivos.length})';
  }
}

class ModulosError extends ModulosState {
  final String message;

  ModulosError({required this.message});

  @override
  String toString() {
    return 'ModulosError(message: $message)';
  }
}
