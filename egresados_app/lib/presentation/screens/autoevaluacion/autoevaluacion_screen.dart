import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../blocs/autoevaluacion/autoevaluacion_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/constants.dart';
import '../../../data/models/autoevaluacion_model.dart';

class AutoevaluacionScreen extends StatefulWidget {
  const AutoevaluacionScreen({super.key});

  @override
  State<AutoevaluacionScreen> createState() => _AutoevaluacionScreenState();
}

class _AutoevaluacionScreenState extends State<AutoevaluacionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AutoevaluacionBloc>().add(LoadAutoevaluacion());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Autoevaluación'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: BlocConsumer<AutoevaluacionBloc, AutoevaluacionState>(
        listener: (context, state) {
          if (state is AutoevaluacionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is AutoevaluacionCompleted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('¡Felicitaciones!'),
                content: const Text(
                  'Has completado tu autoevaluación exitosamente. Tu proceso de grado está completo.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Go back to previous screen
                    },
                    child: const Text('Aceptar'),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AutoevaluacionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AutoevaluacionLoaded) {
            return _buildContent(state);
          }
          return const Center(child: Text('Iniciando...'));
        },
      ),
    );
  }

  Widget _buildContent(AutoevaluacionLoaded state) {
    final preguntas = state.preguntas;
    final progreso = state.progreso;
    final porcentaje = progreso['porcentaje_completado'] as int? ?? 0;

    return Column(
      children: [
        // Progress Bar
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tu Progreso',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '$porcentaje%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: porcentaje / 100,
                backgroundColor: AppColors.surface,
                color: AppColors.primary,
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),
            ],
          ),
        ),
        
        // Questions List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            itemCount: preguntas.length + 1, // +1 for the button
            itemBuilder: (context, index) {
              if (index == preguntas.length) {
                return _buildFinishButton(porcentaje == 100);
              }
              return _buildPreguntaCard(preguntas[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPreguntaCard(PreguntaModel pregunta) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pregunta.texto,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            if (pregunta.tipo == 'likert')
              _buildLikertOptions(pregunta)
            else if (pregunta.tipo == 'texto')
              _buildTextField(pregunta),
          ],
        ),
      ),
    );
  }

  Widget _buildLikertOptions(PreguntaModel pregunta) {
    final currentValue = pregunta.respuesta?.respuestaNumerica;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        final value = index + 1;
        final isSelected = currentValue == value;

        return InkWell(
          onTap: () {
            context.read<AutoevaluacionBloc>().add(
              SaveRespuesta(preguntaId: pregunta.id, respuesta: value),
            );
          },
          borderRadius: BorderRadius.circular(25),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              value.toString(),
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Widget _buildTextField(PreguntaModel pregunta) {
    return TextFormField(
      initialValue: pregunta.respuesta?.respuestaTexto,
      decoration: const InputDecoration(
        hintText: 'Escribe tu respuesta aquí...',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      onChanged: (value) {
        if (_debounce?.isActive ?? false) _debounce!.cancel();
        _debounce = Timer(const Duration(milliseconds: 1000), () {
          context.read<AutoevaluacionBloc>().add(
            SaveRespuesta(preguntaId: pregunta.id, respuesta: value),
          );
        });
      },
      onFieldSubmitted: (value) {
         if (_debounce?.isActive ?? false) _debounce!.cancel();
         context.read<AutoevaluacionBloc>().add(
            SaveRespuesta(preguntaId: pregunta.id, respuesta: value),
          );
      },
    );
  }

  Widget _buildFinishButton(bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingLarge),
      child: ElevatedButton(
        onPressed: isEnabled
            ? () {
                context.read<AutoevaluacionBloc>().add(CompleteAutoevaluacion());
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
        child: const Text(
          'Finalizar Autoevaluación',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
