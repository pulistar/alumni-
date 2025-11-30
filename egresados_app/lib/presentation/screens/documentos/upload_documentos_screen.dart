import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/constants.dart';
import '../../../data/services/documentos_service.dart';
import '../../../data/models/documento_model.dart';

class UploadDocumentosScreen extends StatefulWidget {
  const UploadDocumentosScreen({super.key});

  @override
  State<UploadDocumentosScreen> createState() => _UploadDocumentosScreenState();
}

class _UploadDocumentosScreenState extends State<UploadDocumentosScreen>
    with TickerProviderStateMixin {
  final DocumentosService _documentosService = DocumentosService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  List<DocumentoModel> _documentos = [];
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadDocumentos();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  Future<void> _loadDocumentos() async {
    try {
      final documentos = await _documentosService.getDocumentos();
      if (mounted) {
        setState(() {
          _documentos = documentos;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error cargando documentos: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Error cargando documentos: $e');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Requisitos de Grado',
          style: TextStyle(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textOnPrimary),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header informativo
                      _buildInfoHeader(),
                      
                      const SizedBox(height: AppConstants.paddingLarge),
                      
                      // NUEVA SECCIÓN: Requisitos de Grado
                      _buildRequisitosGradoSection(),
                      
                      const SizedBox(height: AppConstants.paddingLarge * 2),
                      
                      // Divider
                      Divider(thickness: 2, color: AppColors.textSecondary.withOpacity(0.2)),
                      
                      const SizedBox(height: AppConstants.paddingLarge),
                      
                      // Sección de otros documentos
                      Text(
                        'Otros Documentos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      
                      const SizedBox(height: AppConstants.paddingMedium),
                      
                      // Botón para subir documento
                      _buildUploadButton(),
                      
                      const SizedBox(height: AppConstants.paddingLarge),
                      
                      // Lista de documentos
                      _buildDocumentosList(),
                      
                      if (_documentos.isNotEmpty) ...[
                        const SizedBox(height: AppConstants.paddingLarge),
                        _buildUnifiedPDFButton(),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInfoHeader() {
    return Card(
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.upload_file,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Documentos de Grado',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.paddingSmall),
            
            Text(
              'Sube los documentos requeridos para tu proceso de grado. Formatos permitidos: PDF, PNG, JPG, JPEG. Tamaño máximo: 10MB.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isUploading ? null : _pickAndUploadFile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
        icon: _isUploading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
                ),
              )
            : Icon(
                Icons.add,
                color: AppColors.textOnPrimary,
              ),
        label: Text(
          _isUploading ? 'Subiendo...' : 'Subir Nuevo Documento',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textOnPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentosList() {
    if (_documentos.isEmpty) {
      return Card(
        elevation: 2,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.paddingLarge * 2),
          child: Column(
            children: [
              Icon(
                Icons.description_outlined,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Text(
                'No hay documentos subidos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                'Sube tu primer documento usando el botón de arriba',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Documentos Subidos (${_documentos.length})',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: AppConstants.paddingMedium),
        
        ...(_documentos.map((documento) => _buildDocumentoCard(documento))),
      ],
    );
  }

  Widget _buildDocumentoCard(DocumentoModel documento) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: documento.esPDF 
                        ? AppColors.error.withOpacity(0.1)
                        : AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    documento.esPDF ? Icons.picture_as_pdf : Icons.image,
                    color: documento.esPDF ? AppColors.error : AppColors.info,
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: AppConstants.paddingMedium),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        documento.nombreArchivo,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        documento.tipoDocumentoDisplayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'download':
                        _downloadDocumento(documento);
                        break;
                      case 'delete':
                        _deleteDocumento(documento);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'download',
                      child: Row(
                        children: [
                          Icon(Icons.download, size: 20),
                          const SizedBox(width: 8),
                          Text('Descargar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: AppColors.error),
                          const SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.paddingSmall),
            
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${documento.tamanoArchivoFormateado} • ${_formatDate(documento.fechaSubida)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            
            if (documento.descripcion != null && documento.descripcion!.isNotEmpty) ...[
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                documento.descripcion!,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUnifiedPDFButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _downloadUnifiedPDF,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: AppColors.secondary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
        icon: Icon(
          Icons.picture_as_pdf,
          color: AppColors.secondary,
        ),
        label: Text(
          'Descargar PDF Unificado',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        await _showUploadDialog(file);
      }
    } catch (e) {
      print('❌ Error seleccionando archivo: $e');
      _showErrorSnackBar('Error seleccionando archivo: $e');
    }
  }

  Future<void> _showUploadDialog(File file) async {
    TipoDocumento? selectedTipo;
    String descripcion = '';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Subir Documento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Archivo: ${file.path.split('/').last}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<TipoDocumento>(
                value: selectedTipo,
                decoration: InputDecoration(
                  labelText: 'Tipo de Documento',
                  border: OutlineInputBorder(),
                ),
                items: TipoDocumento.values.map((tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedTipo = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) {
                  descripcion = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: selectedTipo != null
                  ? () => Navigator.of(context).pop(true)
                  : null,
              child: Text('Subir'),
            ),
          ],
        ),
      ),
    );

    if (result == true && selectedTipo != null) {
      await _uploadFile(file, selectedTipo!, descripcion);
    }
  }

  Future<void> _uploadFile(File file, TipoDocumento tipo, String descripcion) async {
    setState(() {
      _isUploading = true;
    });

    try {
      await _documentosService.uploadDocumento(
        file: file,
        tipoDocumento: tipo,
        descripcion: descripcion.isEmpty ? null : descripcion,
      );

      _showSuccessSnackBar('✅ Documento subido exitosamente');
      await _loadDocumentos();
    } catch (e) {
      print('❌ Error subiendo documento: $e');
      _showErrorSnackBar('Error subiendo documento: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _downloadDocumento(DocumentoModel documento) async {
    try {
      final url = await _documentosService.getDownloadUrl(documento.id);
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        _showErrorSnackBar('No se puede abrir el documento');
      }
    } catch (e) {
      print('❌ Error descargando documento: $e');
      _showErrorSnackBar('Error descargando documento: $e');
    }
  }

  Future<void> _downloadUnifiedPDF() async {
    try {
      final url = await _documentosService.getUnifiedPDF();
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        _showErrorSnackBar('No se puede abrir el PDF unificado');
      }
    } catch (e) {
      print('❌ Error descargando PDF unificado: $e');
      _showErrorSnackBar('Error descargando PDF unificado: $e');
    }
  }

  Future<void> _deleteDocumento(DocumentoModel documento) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Documento'),
        content: Text('¿Estás seguro de que quieres eliminar "${documento.nombreArchivo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _documentosService.deleteDocumento(documento.id);
        _showSuccessSnackBar('✅ Documento eliminado exitosamente');
        await _loadDocumentos();
      } catch (e) {
        print('❌ Error eliminando documento: $e');
        _showErrorSnackBar('Error eliminando documento: $e');
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  // ============================================
  // NUEVA SECCIÓN: REQUISITOS DE GRADO
  // ============================================

  Widget _buildRequisitosGradoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título principal
        Text(
          'REQUISITOS DE GRADO',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        
        const SizedBox(height: AppConstants.paddingMedium),
        
        // Instrucciones generales
        _buildInstruccionesCard(),
        
        const SizedBox(height: AppConstants.paddingLarge),
        
        // Card 1: Momento OLE
        _buildMomentoOleCard(),
        
        const SizedBox(height: AppConstants.paddingMedium),
        
        // Card 2: Datos Egresados
        _buildDatosEgresadosCard(),
        
        const SizedBox(height: AppConstants.paddingMedium),
        
        // Card 3: Bolsa de Empleo
        _buildBolsaEmpleoCard(),
      ],
    );
  }

  Widget _buildInstruccionesCard() {
    return Card(
      elevation: 3,
      color: AppColors.info.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 28),
                const SizedBox(width: AppConstants.paddingSmall),
                Expanded(
                  child: Text(
                    'Instrucciones Importantes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            Text(
              'Apreciados graduandos, reciban un cordial saludo:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingSmall),
            
            Text(
              'Con el fin de cumplir con los requisitos de grado, a continuación encontrará 3 encuestas (enlaces). Tener en cuenta que así haya generado su recibo de Derechos de Grado, estos soportes hacen parte del proceso de grado.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber, color: AppColors.warning, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'RECOMENDACIONES',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  _buildRecomendacion('Registrar en las encuestas su correo personal, NO el de campus.'),
                  _buildRecomendacion('En la Encuesta #2 Diligenciar EN MAYÚSCULAS SOSTENIDA.'),
                  _buildRecomendacion('En la hoja de vida de Bolsa de empleo, la fotografía debe ser formal, ejecutiva ya que ésta hoja de vida será visible para las empresas; así mismo es necesario que quede diligenciada al 100%.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecomendacion(String texto) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMomentoOleCard() {
    DocumentoModel? momentoOleDoc;
    try {
      momentoOleDoc = _documentos.firstWhere(
        (doc) => doc.tipoDocumento == 'momento_ole',
      );
    } catch (e) {
      momentoOleDoc = null;
    }
    final isCompleted = momentoOleDoc != null;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle : Icons.picture_as_pdf,
                    color: isCompleted ? AppColors.success : AppColors.error,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1. Momento OLE',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (isCompleted)
                        Text(
                          '✓ Completado',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingSmall),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Text(
                'NOTA: No aplica esta encuesta para el programa de Técnico en Auxiliar de enfermería - ni para Posgrados.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            Text(
              'Descargar la constancia en PDF para anexar en el archivo con los demás soportes.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Botón para ir a la encuesta
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _abrirEnlaceExterno(
                  'https://encuestasole.mineducacion.gov.co/hecaa-encuestas/login_encuestas',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: Icon(Icons.open_in_new, color: AppColors.textOnPrimary),
                label: Text(
                  'Ir a Encuesta Momento OLE',
                  style: TextStyle(color: AppColors.textOnPrimary),
                ),
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingSmall),
            
            // Botón para subir PDF
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isUploading ? null : () => _subirDocumentoEspecifico(TipoDocumento.momentoOle, true),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isCompleted ? AppColors.success : AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: Icon(
                  isCompleted ? Icons.check : Icons.upload_file,
                  color: isCompleted ? AppColors.success : AppColors.primary,
                ),
                label: Text(
                  isCompleted ? 'PDF Subido' : 'Subir PDF de Constancia',
                  style: TextStyle(
                    color: isCompleted ? AppColors.success : AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatosEgresadosCard() {
    DocumentoModel? datosDoc;
    try {
      datosDoc = _documentos.firstWhere(
        (doc) => doc.tipoDocumento == 'datos_egresados',
      );
    } catch (e) {
      datosDoc = null;
    }
    final isCompleted = datosDoc != null;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.success.withOpacity(0.1) : AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle : Icons.image,
                    color: isCompleted ? AppColors.success : AppColors.info,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '2. Actualización Datos Egresados',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (isCompleted)
                        Text(
                          '✓ Completado',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            Text(
              'Tomar pantallazo al finalizar la encuesta.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Botón para ir a la encuesta
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _abrirEnlaceExterno(
                  'https://forms.office.com/Pages/ResponsePage.aspx?id=BMPJbvsR70Kmr1tflzw5Zp3FVe__lW9PtwpTxEj390pUMk8xUU0wODVCVUMwUzVTNVFIVlVYVE1OSC4u',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: Icon(Icons.open_in_new, color: AppColors.textOnPrimary),
                label: Text(
                  'Ir a Encuesta Datos Egresados',
                  style: TextStyle(color: AppColors.textOnPrimary),
                ),
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingSmall),
            
            // Botón para subir pantallazo
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isUploading ? null : () => _subirDocumentoEspecifico(TipoDocumento.datosEgresados, false),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isCompleted ? AppColors.success : AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: Icon(
                  isCompleted ? Icons.check : Icons.upload_file,
                  color: isCompleted ? AppColors.success : AppColors.primary,
                ),
                label: Text(
                  isCompleted ? 'Pantallazo Subido' : 'Subir Pantallazo',
                  style: TextStyle(
                    color: isCompleted ? AppColors.success : AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBolsaEmpleoCard() {
    DocumentoModel? bolsaDoc;
    try {
      bolsaDoc = _documentos.firstWhere(
        (doc) => doc.tipoDocumento == 'bolsa_empleo',
      );
    } catch (e) {
      bolsaDoc = null;
    }
    final isCompleted = bolsaDoc != null;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.success.withOpacity(0.1) : AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle : Icons.image,
                    color: isCompleted ? AppColors.success : AppColors.info,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '3. Bolsa de Empleo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (isCompleted)
                        Text(
                          '✓ Completado',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            Text(
              'Tomar pantallazo al finalizar el registro.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingSmall),
            
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingSmall),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pasos:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '1. Ingresar a "Registrar hoja de vida"\n2. Usuario: Correo electrónico personal\n3. Contraseña: Número de Cédula',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Botón para ir a la encuesta
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _abrirEnlaceExterno(
                  'https://www.elempleo.com/co/sitio-empresarial/universidad-cooperativa-colombia',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: Icon(Icons.open_in_new, color: AppColors.textOnPrimary),
                label: Text(
                  'Ir a Bolsa de Empleo',
                  style: TextStyle(color: AppColors.textOnPrimary),
                ),
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingSmall),
            
            // Botón para subir pantallazo
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isUploading ? null : () => _subirDocumentoEspecifico(TipoDocumento.bolsaEmpleo, false),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isCompleted ? AppColors.success : AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: Icon(
                  isCompleted ? Icons.check : Icons.upload_file,
                  color: isCompleted ? AppColors.success : AppColors.primary,
                ),
                label: Text(
                  isCompleted ? 'Pantallazo Subido' : 'Subir Pantallazo',
                  style: TextStyle(
                    color: isCompleted ? AppColors.success : AppColors.primary,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingSmall),
            
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingSmall),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '¡PARA TENER EN CUENTA! Si no le es permitido el ingreso a la plataforma, acérquese a la oficina de Egresados e Internacionalización (2do piso), o envíe un correo a claudia.gomezt@ucc.edu.co con copia a yessica.munozr@ucc.edu.co',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _abrirEnlaceExterno(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Abre en navegador externo
      );
    } catch (e) {
      print('❌ Error abriendo enlace: $e');
      _showErrorSnackBar('No se pudo abrir el enlace. Por favor, verifica que tengas un navegador instalado.');
    }
  }

  Future<void> _subirDocumentoEspecifico(TipoDocumento tipo, bool soloPDF) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: soloPDF ? ['pdf'] : ['png', 'jpg', 'jpeg'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        
        // Validar tamaño (10MB)
        const maxSize = 10 * 1024 * 1024;
        final fileSize = await file.length();
        
        if (fileSize > maxSize) {
          _showErrorSnackBar(
            'El archivo es demasiado grande. Tamaño máximo: 10MB. '
            'Tu archivo: ${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB'
          );
          return;
        }
        
        // Subir directamente sin dialog
        await _uploadFileDirecto(file, tipo);
      }
    } catch (e) {
      print('❌ Error seleccionando archivo: $e');
      _showErrorSnackBar('Error seleccionando archivo: $e');
    }
  }

  Future<void> _uploadFileDirecto(File file, TipoDocumento tipo) async {
    setState(() {
      _isUploading = true;
    });

    try {
      await _documentosService.uploadDocumento(
        file: file,
        tipoDocumento: tipo,
        descripcion: null,
      );

      _showSuccessSnackBar('✅ Documento subido exitosamente');
      await _loadDocumentos();
    } catch (e) {
      print('❌ Error subiendo documento: $e');
      _showErrorSnackBar('Error subiendo documento: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
}
