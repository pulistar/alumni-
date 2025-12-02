import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../blocs/documentos/documentos_bloc.dart';
import '../../blocs/documentos/documentos_event.dart';
import '../../blocs/documentos/documentos_state.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/custom_snackbar.dart';

/// Ejemplo de cómo implementar Pull-to-Refresh en una lista
class DocumentosListExample extends StatelessWidget {
  const DocumentosListExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Documentos'),
      ),
      body: BlocConsumer<DocumentosBloc, DocumentosState>(
        listener: (context, state) {
          // Mostrar snackbars según el estado
          if (state is DocumentosError) {
            CustomSnackBar.showError(context, state.message);
          }
          if (state is DocumentoUploaded) {
            CustomSnackBar.showSuccess(
              context,
              '¡Documento subido exitosamente!',
            );
          }
        },
        builder: (context, state) {
          // Estado de carga inicial
          if (state is DocumentosLoading && state.isFirstLoad) {
            return const DocumentListSkeleton(itemCount: 5);
          }

          // Estado de error
          if (state is DocumentosError) {
            return ErrorState(
              message: state.message,
              onRetry: () {
                context.read<DocumentosBloc>().add(LoadDocumentos());
              },
            );
          }

          // Estado con datos
          if (state is DocumentosLoaded) {
            // Si no hay documentos
            if (state.documentos.isEmpty) {
              return EmptyDocumentsState(
                onUpload: () {
                  // Navegar a pantalla de subida
                },
              );
            }

            // Lista con Pull-to-Refresh
            return RefreshIndicator(
              // Color del indicador
              color: AppColors.primary,
              backgroundColor: Colors.white,
              
              // Función que se ejecuta al hacer pull
              onRefresh: () async {
                // Disparar evento para recargar
                context.read<DocumentosBloc>().add(LoadDocumentos());
                
                // Esperar a que termine la carga
                await Future.delayed(const Duration(seconds: 1));
              },
              
              // Lista de documentos
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.documentos.length,
                itemBuilder: (context, index) {
                  final documento = state.documentos[index];
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(
                        Icons.insert_drive_file_rounded,
                        color: AppColors.primary,
                      ),
                      title: Text(documento.nombreArchivo),
                      subtitle: Text(documento.tipoDocumento),
                      trailing: IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          // Mostrar opciones
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          }

          // Estado por defecto
          return const SizedBox.shrink();
        },
      ),
      
      // FAB para subir documento
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Mostrar snackbar de progreso
          ProgressSnackBar.show(context, 'Subiendo documento...');
          
          // Simular subida
          Future.delayed(const Duration(seconds: 2), () {
            ProgressSnackBar.hide(context);
            CustomSnackBar.showSuccess(
              context,
              '¡Documento subido!',
            );
          });
        },
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text('Subir'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

/// Ejemplo de Pull-to-Refresh simple (sin BLoC)
class SimplePullToRefreshExample extends StatefulWidget {
  const SimplePullToRefreshExample({super.key});

  @override
  State<SimplePullToRefreshExample> createState() =>
      _SimplePullToRefreshExampleState();
}

class _SimplePullToRefreshExampleState
    extends State<SimplePullToRefreshExample> {
  bool _isLoading = false;
  List<String> _items = ['Item 1', 'Item 2', 'Item 3'];

  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // Simular carga de datos
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _items = List.generate(5, (index) => 'Item ${index + 1}');
      _isLoading = false;
    });

    // Mostrar confirmación
    if (mounted) {
      CustomSnackBar.showSuccess(
        context,
        'Lista actualizada',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const ListItemSkeleton(itemCount: 5);
    }

    if (_items.isEmpty) {
      return const EmptyState(
        icon: Icons.inbox_rounded,
        title: 'Sin elementos',
        message: 'No hay elementos para mostrar',
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppColors.primary,
      child: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_items[index]),
          );
        },
      ),
    );
  }
}

/// Ejemplo de uso de todos los componentes juntos
class UXComponentsShowcase extends StatelessWidget {
  const UXComponentsShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UX Components'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección: Snackbars
          const Text(
            'Snackbars',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: () {
                  CustomSnackBar.showSuccess(
                    context,
                    '¡Operación exitosa!',
                  );
                },
                child: const Text('Success'),
              ),
              ElevatedButton(
                onPressed: () {
                  CustomSnackBar.showError(
                    context,
                    'Ocurrió un error',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Error'),
              ),
              ElevatedButton(
                onPressed: () {
                  CustomSnackBar.showWarning(
                    context,
                    'Advertencia importante',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                ),
                child: const Text('Warning'),
              ),
              ElevatedButton(
                onPressed: () {
                  CustomSnackBar.showInfo(
                    context,
                    'Información útil',
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.info,
                ),
                child: const Text('Info'),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Sección: Skeleton Loaders
          const Text(
            'Skeleton Loaders',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          const DocumentCardSkeleton(),
          const QuestionCardSkeleton(),
          
          const SizedBox(height: 32),
          
          // Sección: Empty States
          const Text(
            'Empty States',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(title: const Text('Empty State')),
                    body: const EmptyDocumentsState(),
                  ),
                ),
              );
            },
            child: const Text('Ver Empty States'),
          ),
        ],
      ),
    );
  }
}
