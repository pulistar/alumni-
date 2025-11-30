import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/autoevaluacion_model.dart';
import '../../../data/services/autoevaluacion_service.dart';

// Events
abstract class AutoevaluacionEvent extends Equatable {
  const AutoevaluacionEvent();

  @override
  List<Object?> get props => [];
}

class LoadAutoevaluacion extends AutoevaluacionEvent {}

class SaveRespuesta extends AutoevaluacionEvent {
  final String preguntaId;
  final dynamic respuesta; // int or String

  const SaveRespuesta({required this.preguntaId, required this.respuesta});

  @override
  List<Object?> get props => [preguntaId, respuesta];
}

class CompleteAutoevaluacion extends AutoevaluacionEvent {}

// States
abstract class AutoevaluacionState extends Equatable {
  const AutoevaluacionState();

  @override
  List<Object?> get props => [];
}

class AutoevaluacionInitial extends AutoevaluacionState {}

class AutoevaluacionLoading extends AutoevaluacionState {}

class AutoevaluacionLoaded extends AutoevaluacionState {
  final List<PreguntaModel> preguntas;
  final Map<String, dynamic> progreso;
  final bool isSaving;

  const AutoevaluacionLoaded({
    required this.preguntas,
    required this.progreso,
    this.isSaving = false,
  });

  AutoevaluacionLoaded copyWith({
    List<PreguntaModel>? preguntas,
    Map<String, dynamic>? progreso,
    bool? isSaving,
  }) {
    return AutoevaluacionLoaded(
      preguntas: preguntas ?? this.preguntas,
      progreso: progreso ?? this.progreso,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [preguntas, progreso, isSaving];
}

class AutoevaluacionError extends AutoevaluacionState {
  final String message;

  const AutoevaluacionError(this.message);

  @override
  List<Object?> get props => [message];
}

class AutoevaluacionCompleted extends AutoevaluacionState {}

// Bloc
class AutoevaluacionBloc extends Bloc<AutoevaluacionEvent, AutoevaluacionState> {
  final AutoevaluacionService _service;

  AutoevaluacionBloc(this._service) : super(AutoevaluacionInitial()) {
    on<LoadAutoevaluacion>(_onLoadAutoevaluacion);
    on<SaveRespuesta>(_onSaveRespuesta);
    on<CompleteAutoevaluacion>(_onCompleteAutoevaluacion);
  }

  Future<void> _onLoadAutoevaluacion(
    LoadAutoevaluacion event,
    Emitter<AutoevaluacionState> emit,
  ) async {
    emit(AutoevaluacionLoading());
    try {
      final preguntas = await _service.getPreguntas();
      final progreso = await _service.getProgreso();
      emit(AutoevaluacionLoaded(preguntas: preguntas, progreso: progreso));
    } catch (e) {
      emit(AutoevaluacionError(e.toString()));
    }
  }

  Future<void> _onSaveRespuesta(
    SaveRespuesta event,
    Emitter<AutoevaluacionState> emit,
  ) async {
    final currentState = state;
    if (currentState is AutoevaluacionLoaded) {
      // Optimistic update or show saving indicator
      emit(currentState.copyWith(isSaving: true));

      try {
        final nuevaRespuesta = await _service.guardarRespuesta(
          event.preguntaId,
          event.respuesta,
        );

        // Update local state with new answer
        final updatedPreguntas = currentState.preguntas.map((p) {
          if (p.id == event.preguntaId) {
            return p.copyWith(respuesta: nuevaRespuesta);
          }
          return p;
        }).toList();

        // Refresh progress
        final nuevoProgreso = await _service.getProgreso();

        emit(currentState.copyWith(
          preguntas: updatedPreguntas,
          progreso: nuevoProgreso,
          isSaving: false,
        ));
      } catch (e) {
        emit(AutoevaluacionError(e.toString()));
        // Revert to loaded state after error? Or stay in error?
        // Ideally, we should show a snackbar and revert to loaded state, 
        // but for simplicity, we emit error. The UI should handle it.
        // To allow retry, we might want to re-emit the previous loaded state after a delay or user action.
        // For now, let's just re-emit the loaded state but with isSaving false so user can try again,
        // and maybe handle error display via listener.
        // Actually, emitting Error state replaces Loaded state, which clears the screen.
        // Better approach: Emit Loaded with a separate error field or use a listener for one-time errors.
        // Given the simple state structure, let's just log and maybe not break the UI flow too much.
        // But to follow standard pattern:
        emit(AutoevaluacionError("Error al guardar: ${e.toString()}"));
        // Then reload to restore state
        add(LoadAutoevaluacion()); 
      }
    }
  }

  Future<void> _onCompleteAutoevaluacion(
    CompleteAutoevaluacion event,
    Emitter<AutoevaluacionState> emit,
  ) async {
    emit(AutoevaluacionLoading());
    try {
      await _service.completarAutoevaluacion();
      emit(AutoevaluacionCompleted());
    } catch (e) {
      emit(AutoevaluacionError(e.toString()));
    }
  }
}
