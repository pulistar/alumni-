import {
  Injectable,
  Logger,
  BadRequestException,
  NotFoundException,
  InternalServerErrorException,
} from '@nestjs/common';
import { SupabaseService } from '../database/supabase.service';
import { TipoDocumento } from './dto/upload-documento.dto';
import { DocumentoResponseDto } from './dto/documento-response.dto';
import { NotificacionesService } from '../notificaciones/notificaciones.service';
import { MailService } from '../mail/mail.service';
import { PDFDocument, rgb, StandardFonts } from 'pdf-lib';
import * as sharp from 'sharp';

@Injectable()
export class DocumentosService {
  private readonly logger = new Logger(DocumentosService.name);
  private readonly BUCKET_NAME = 'egresados-documentos';
  private readonly MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
  private readonly ALLOWED_MIME_TYPES = ['application/pdf', 'image/png', 'image/jpeg', 'image/jpg'];

  constructor(
    private readonly supabaseService: SupabaseService,
    private readonly notificacionesService: NotificacionesService,
    private readonly mailService: MailService,
  ) { }

  /**
   * Upload document to Supabase Storage
   */
  async upload(
    uid: string,
    egresadoId: string,
    file: Express.Multer.File,
    tipoDocumento: TipoDocumento,
  ) {
    // 1. Validate file
    this.validateFile(file);

    // 2. Generate unique filename
    const timestamp = Date.now();
    const sanitizedFilename = file.originalname.replace(/[^a-zA-Z0-9.-]/g, '_');
    const filename = `${timestamp}-${sanitizedFilename}`;
    const storagePath = `${uid}/${filename}`;

    // 3. Upload to Supabase Storage
    const { error: uploadError } = await this.supabaseService
      .getClient()
      .storage.from(this.BUCKET_NAME)
      .upload(storagePath, file.buffer, {
        contentType: file.mimetype,
        upsert: false,
      });

    if (uploadError) {
      this.logger.error(`Error uploading file: ${uploadError.message}`);
      throw new InternalServerErrorException('Error al subir el archivo');
    }

    // 4. Create database record
    const { data: dbData, error: dbError } = await this.supabaseService
      .getClient()
      .from('documentos_egresado')
      .insert({
        egresado_id: egresadoId,
        tipo_documento: tipoDocumento,
        nombre_archivo: file.originalname,
        ruta_storage: storagePath,
        tamano_bytes: file.size,
        mime_type: file.mimetype,
        es_unificado: false,
      })
      .select()
      .single();

    if (dbError) {
      // Rollback: delete uploaded file
      await this.supabaseService.getClient().storage.from(this.BUCKET_NAME).remove([storagePath]);

      this.logger.error(`Error creating DB record: ${dbError.message}`);
      throw new InternalServerErrorException('Error al guardar el documento');
    }

    this.logger.log(`Document uploaded successfully: ${filename}`);

    // 5. Check if all required documents are uploaded
    await this.checkAndEnableAutoevaluacion(egresadoId);

    return dbData;
  }

  /**
   * Check if all required documents are uploaded and enable autoevaluacion
   */
  private async checkAndEnableAutoevaluacion(egresadoId: string) {
    const requiredDocuments = ['momento_ole', 'datos_egresados', 'bolsa_empleo'];

    // Get all documents for this egresado
    const { data: documents } = await this.supabaseService
      .getClient()
      .from('documentos_egresado')
      .select('tipo_documento')
      .eq('egresado_id', egresadoId)
      .eq('es_unificado', false)
      .is('deleted_at', null);

    if (!documents) return;

    // Check if all required types are present
    const uploadedTypes = new Set(documents.map((doc) => doc.tipo_documento));
    const hasAllRequired = requiredDocuments.every((type) => uploadedTypes.has(type));

    if (hasAllRequired) {
      // Generate unified PDF
      await this.generateUnifiedPDF(egresadoId);

      // Update egresado profile
      const { error } = await this.supabaseService
        .getClient()
        .from('egresados')
        .update({
          proceso_grado_completo: true,
          autoevaluacion_habilitada: true,
        })
        .eq('id', egresadoId);

      if (error) {
        this.logger.error(`Error updating egresado profile: ${error.message}`);
      } else {
        this.logger.log(`✅ Autoevaluacion enabled for egresado: ${egresadoId}`);

        // Create notification for PDF generated
        await this.notificacionesService.crear({
          egresado_id: egresadoId,
          titulo: '¡Tu PDF unificado está listo!',
          mensaje: 'Tus documentos han sido procesados exitosamente.',
          tipo: 'documento',
          url_accion: '/documentos',
        });

        // Send email notification
        try {
          // Get egresado info for email
          const { data: egresadoData } = await this.supabaseService
            .getClient()
            .from('egresados')
            .select('correo_institucional, nombre, apellido')
            .eq('id', egresadoId)
            .single();

          if (egresadoData) {
            await this.mailService.sendPdfGenerado(
              egresadoData.correo_institucional,
              `${egresadoData.nombre} ${egresadoData.apellido}`,
            );
            this.logger.log(`PDF email sent to ${egresadoData.correo_institucional}`);
          }
        } catch (error) {
          this.logger.error(`Failed to send PDF email: ${error.message}`);
        }

        // Create notification for autoevaluacion enabled
        await this.notificacionesService.crear({
          egresado_id: egresadoId,
          titulo: 'Autoevaluación habilitada',
          mensaje: 'Ya puedes realizar tu autoevaluación de competencias.',
          tipo: 'autoevaluacion',
          url_accion: '/autoevaluacion',
        });
      }
    }
  }

  /**
   * Generate unified PDF from all required documents
   */
  private async generateUnifiedPDF(egresadoId: string) {
    try {
      this.logger.log(`📄 Generating unified PDF for egresado: ${egresadoId}`);

      // 1. Get all required documents
      const { data: documents } = await this.supabaseService
        .getClient()
        .from('documentos_egresado')
        .select('*')
        .eq('egresado_id', egresadoId)
        .eq('es_unificado', false)
        .is('deleted_at', null)
        .in('tipo_documento', ['momento_ole', 'datos_egresados', 'bolsa_empleo']);

      if (!documents || documents.length !== 3) {
        this.logger.warn('Not all required documents found');
        return;
      }


      // 2. Get egresado info for cover page and filename
      const { data: egresado } = await this.supabaseService
        .getClient()
        .from('egresados')
        .select(`
          nombre, 
          apellido, 
          correo_institucional,
          carrera:carreras(nombre)
        `)
        .eq('id', egresadoId)
        .single();

      // 3. Create PDF document
      const pdfDoc = await PDFDocument.create();

      // 4. Add cover page
      await this.addCoverPage(pdfDoc, egresado);

      // 5. Download and add each document
      const sortedDocs = this.sortDocuments(documents);
      this.logger.log(`📋 Processing ${sortedDocs.length} documents in order:`);
      sortedDocs.forEach((doc, index) => {
        this.logger.log(`  ${index + 1}. ${doc.tipo_documento}: ${doc.nombre_archivo}`);
      });

      for (const doc of sortedDocs) {
        await this.addDocumentToPDF(pdfDoc, doc);
      }

      // Log total pages before saving
      const totalPages = pdfDoc.getPageCount();
      this.logger.log(`📊 Total pages in PDF before saving: ${totalPages}`);
      this.logger.log(`   Expected: 4 pages (1 cover + 3 documents)`);

      if (totalPages !== 4) {
        this.logger.warn(`⚠️ WARNING: Expected 4 pages but got ${totalPages}`);
      }

      // 6. Save PDF with proper options to ensure all pages are written
      this.logger.log(`💾 Saving PDF with ${totalPages} pages...`);
      const pdfBytes = await pdfDoc.save({
        useObjectStreams: false, // Disable object streams for better compatibility
        addDefaultPage: false, // Don't add default page
        objectsPerTick: Infinity, // Process all objects at once
      });

      this.logger.log(`✅ PDF saved successfully, size: ${pdfBytes.length} bytes`);

      // 7. Generate descriptive filename with timestamp to avoid caching
      const nombreCompleto = `${egresado?.nombre || ''}_${egresado?.apellido || ''}`.trim();
      // Supabase returns carrera as an object, not an array
      const carreraData = egresado?.carrera as any;
      const nombreCarrera = carreraData?.nombre || 'Carrera';

      // Sanitize filename (remove special characters and spaces)
      const sanitizedNombre = nombreCompleto.replace(/[^a-zA-Z0-9]/g, '_');
      const sanitizedCarrera = nombreCarrera.replace(/[^a-zA-Z0-9]/g, '_');

      // Add timestamp to make filename unique and prevent caching
      const timestamp = Date.now();
      const filename = `Documentos_Grado_${sanitizedNombre}_${sanitizedCarrera}_${timestamp}.pdf`;
      const displayName = `Documentos de Grado - ${nombreCompleto} - ${nombreCarrera}.pdf`;

      // 8. Upload to storage
      const uid = documents[0].ruta_storage.split('/')[0]; // Extract uid from path
      const storagePath = `${uid}/${filename}`;

      const { error: uploadError } = await this.supabaseService
        .getClient()
        .storage.from(this.BUCKET_NAME)
        .upload(storagePath, pdfBytes, {
          contentType: 'application/pdf',
          upsert: false,
        });

      if (uploadError) {
        this.logger.error(`Error uploading unified PDF: ${uploadError.message}`);
        return;
      }

      // 9. Create database record
      const { error: dbError } = await this.supabaseService
        .getClient()
        .from('documentos_egresado')
        .insert({
          egresado_id: egresadoId,
          tipo_documento: 'unificado',
          nombre_archivo: displayName,
          ruta_storage: storagePath,
          tamano_bytes: pdfBytes.length,
          mime_type: 'application/pdf',
          es_unificado: true,
        });

      if (dbError) {
        this.logger.error(`Error creating unified PDF record: ${dbError.message}`);
      } else {
        this.logger.log(`✅ Unified PDF generated successfully: ${filename}`);
      }
    } catch (error) {
      this.logger.error(`Error generating unified PDF: ${error.message}`);
    }
  }

  /**
   * Add cover page to PDF
   */
  private async addCoverPage(pdfDoc: PDFDocument, egresado: any) {
    const page = pdfDoc.addPage();
    const { height } = page.getSize();
    const font = await pdfDoc.embedFont(StandardFonts.HelveticaBold);
    const fontRegular = await pdfDoc.embedFont(StandardFonts.Helvetica);

    // Title
    page.drawText('DOCUMENTOS DE GRADO', {
      x: 50,
      y: height - 100,
      size: 24,
      font,
      color: rgb(0, 0, 0.5),
    });

    // Egresado info
    page.drawText(`Egresado: ${egresado?.nombre || ''} ${egresado?.apellido || ''}`, {
      x: 50,
      y: height - 150,
      size: 14,
      font: fontRegular,
    });

    page.drawText(`correo_institucional: ${egresado?.correo_institucional || ''}`, {
      x: 50,
      y: height - 180,
      size: 14,
      font: fontRegular,
    });

    // Date
    const date = new Date().toLocaleDateString('es-CO');
    page.drawText(`Fecha de generación: ${date}`, {
      x: 50,
      y: height - 220,
      size: 12,
      font: fontRegular,
    });
  }

  /**
   * Sort documents in specific order
   */
  private sortDocuments(documents: any[]) {
    const order = ['momento_ole', 'datos_egresados', 'bolsa_empleo'];
    return documents.sort((a, b) => {
      return order.indexOf(a.tipo_documento) - order.indexOf(b.tipo_documento);
    });
  }

  /**
   * Add document to PDF
   */
  private async addDocumentToPDF(pdfDoc: PDFDocument, doc: any) {
    try {
      this.logger.log(`📄 Adding document to PDF: ${doc.nombre_archivo} (${doc.tipo_documento})`);

      // Download file from storage
      const fileBuffer = await this.downloadFile(doc.ruta_storage);
      this.logger.log(`✅ Downloaded file: ${doc.nombre_archivo}, size: ${fileBuffer.length} bytes`);

      if (doc.mime_type === 'application/pdf') {
        // Merge PDF
        this.logger.log(`📄 Processing as PDF: ${doc.nombre_archivo}`);
        const srcDoc = await PDFDocument.load(fileBuffer);
        const copiedPages = await pdfDoc.copyPages(srcDoc, srcDoc.getPageIndices());
        copiedPages.forEach((page) => pdfDoc.addPage(page));
        this.logger.log(`✅ PDF merged successfully: ${doc.nombre_archivo}, pages added: ${copiedPages.length}`);
      } else {
        // Convert image to PDF
        this.logger.log(`🖼️ Processing as image: ${doc.nombre_archivo}, mime: ${doc.mime_type}`);
        const pdfBuffer = await this.convertImageToPDF(fileBuffer, doc.mime_type);
        this.logger.log(`✅ Image converted to PDF: ${doc.nombre_archivo}, buffer size: ${pdfBuffer.length} bytes`);

        const srcDoc = await PDFDocument.load(pdfBuffer);
        const copiedPages = await pdfDoc.copyPages(srcDoc, srcDoc.getPageIndices());
        copiedPages.forEach((page) => pdfDoc.addPage(page));
        this.logger.log(`✅ Image PDF merged successfully: ${doc.nombre_archivo}, pages added: ${copiedPages.length}`);
      }
    } catch (error) {
      this.logger.error(`❌ Error adding document to PDF: ${doc.nombre_archivo} - ${error.message}`);
      this.logger.error(`Stack trace: ${error.stack}`);
      // Re-throw to make the error more visible
      throw new Error(`Failed to add document ${doc.nombre_archivo}: ${error.message}`);
    }
  }

  /**
   * Download file from storage
   */
  private async downloadFile(storagePath: string): Promise<Buffer> {
    const { data, error } = await this.supabaseService
      .getClient()
      .storage.from(this.BUCKET_NAME)
      .download(storagePath);

    if (error || !data) {
      this.logger.error(`Failed to download file: ${storagePath} - ${error?.message}`);
      throw new InternalServerErrorException(`Error al descargar archivo: ${storagePath}`);
    }

    return Buffer.from(await data.arrayBuffer());
  }

  /**
   * Convert image to PDF
   */
  private async convertImageToPDF(imageBuffer: Buffer, mimeType: string): Promise<Buffer> {
    try {
      // Process image with sharp - convert to PNG for consistency
      const processedImage = await sharp(imageBuffer)
        .resize(1654, 2339, { fit: 'inside' }) // A4 size at 200 DPI
        .png() // Convert to PNG
        .toBuffer();

      // Create PDF
      const pdfDoc = await PDFDocument.create();
      const image = await pdfDoc.embedPng(processedImage);

      const page = pdfDoc.addPage();
      const { width, height } = page.getSize();

      // Calculate scale to fit image
      const scale = Math.min(width / image.width, height / image.height);

      const scaledWidth = image.width * scale;
      const scaledHeight = image.height * scale;

      page.drawImage(image, {
        x: (width - scaledWidth) / 2,
        y: (height - scaledHeight) / 2,
        width: scaledWidth,
        height: scaledHeight,
      });

      return Buffer.from(await pdfDoc.save());
    } catch (error) {
      this.logger.error(`Error converting image to PDF: ${error.message}`);
      throw new InternalServerErrorException('Error al convertir imagen a PDF');
    }
  }

  /**
   * Get all documents for egresado
   */
  async findAll(egresadoId: string): Promise<DocumentoResponseDto[]> {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('documentos_egresado')
      .select('*')
      .eq('egresado_id', egresadoId)
      .is('deleted_at', null);

    if (error) {
      this.logger.error(`Error fetching documents: ${error.message}`);
      throw new InternalServerErrorException('Error al obtener documentos');
    }

    // Get signed URLs for each document
    const documentsWithUrls = await Promise.all(
      data.map(async (doc) => {
        const url = await this.getSignedUrlInternal(doc.ruta_storage);
        return {
          ...doc,
          url,
        };
      }),
    );

    return documentsWithUrls;
  }

  /**
   * Get signed URL for document download
   */
  async getSignedUrl(documentoId: string, egresadoId: string): Promise<string> {
    // Verify document belongs to egresado
    const { data, error } = await this.supabaseService
      .getClient()
      .from('documentos_egresado')
      .select('ruta_storage')
      .eq('id', documentoId)
      .eq('egresado_id', egresadoId)
      .is('deleted_at', null)
      .single();

    if (error || !data) {
      throw new NotFoundException('Documento no encontrado');
    }

    return this.getSignedUrlInternal(data.ruta_storage);
  }

  /**
   * Get unified PDF for egresado
   * Generates it on-demand if it doesn't exist
   */
  async getUnifiedPDF(egresadoId: string) {
    try {
      this.logger.log(`🔍 Getting unified PDF for egresado: ${egresadoId}`);

      // Try to find existing unified PDF
      const { data: existingPdf, error } = await this.supabaseService
        .getClient()
        .from('documentos_egresado')
        .select('*')
        .eq('egresado_id', egresadoId)
        .eq('es_unificado', true)
        .is('deleted_at', null)
        .maybeSingle();

      // If PDF exists, return it
      if (existingPdf) {
        this.logger.log(`✅ Found existing unified PDF for egresado: ${egresadoId}`);
        const url = await this.getSignedUrlInternal(existingPdf.ruta_storage);
        return {
          ...existingPdf,
          url,
        };
      }

      // If PDF doesn't exist, check if we have documents to generate it
      this.logger.log(`📄 No unified PDF found, checking for documents...`);

      const { data: documents } = await this.supabaseService
        .getClient()
        .from('documentos_egresado')
        .select('*')
        .eq('egresado_id', egresadoId)
        .eq('es_unificado', false)
        .is('deleted_at', null);

      if (!documents || documents.length === 0) {
        this.logger.warn(`No documents found for egresado: ${egresadoId}`);
        throw new NotFoundException('No hay documentos para generar el PDF unificado. Sube al menos un documento primero.');
      }

      this.logger.log(`📄 Found ${documents.length} documents, generating PDF...`);

      // Generate PDF with available documents
      try {
        await this.generateUnifiedPDFFromDocs(egresadoId, documents);
        this.logger.log(`✅ PDF generation completed`);
      } catch (genError) {
        this.logger.error(`❌ Error in generateUnifiedPDFFromDocs: ${genError.message}`);
        this.logger.error(`Stack: ${genError.stack}`);
        throw new InternalServerErrorException(`Error al generar el PDF: ${genError.message}`);
      }

      // Fetch the newly generated PDF
      this.logger.log(`🔍 Fetching newly generated PDF...`);
      const { data: newPdf, error: fetchError } = await this.supabaseService
        .getClient()
        .from('documentos_egresado')
        .select('*')
        .eq('egresado_id', egresadoId)
        .eq('es_unificado', true)
        .is('deleted_at', null)
        .single();

      if (fetchError || !newPdf) {
        this.logger.error(`❌ PDF not found after generation. Error: ${fetchError?.message}`);
        throw new InternalServerErrorException('El PDF se generó pero no se pudo recuperar');
      }

      const url = await this.getSignedUrlInternal(newPdf.ruta_storage);
      this.logger.log(`✅ Successfully generated and retrieved PDF`);

      return {
        ...newPdf,
        url,
      };
    } catch (error) {
      this.logger.error(`❌ Error in getUnifiedPDF: ${error.message}`);
      this.logger.error(`Error stack: ${error.stack}`);
      throw error;
    }
  }

  /**
   * Generate unified PDF from available documents (flexible version)
   */
  private async generateUnifiedPDFFromDocs(egresadoId: string, documents: any[]) {
    try {
      this.logger.log(`📄 Generating unified PDF for egresado: ${egresadoId} with ${documents.length} documents`);

      // Get egresado info for cover page and filename
      const { data: egresado } = await this.supabaseService
        .getClient()
        .from('egresados')
        .select(`
          nombre, 
          apellido, 
          correo,
          carrera:carreras(nombre)
        `)
        .eq('id', egresadoId)
        .single();

      // Create PDF document
      const pdfDoc = await PDFDocument.create();

      // Add cover page
      await this.addCoverPage(pdfDoc, egresado);

      // Sort documents by tipo_documento if they include the required ones
      const sortedDocs = this.sortDocumentsFlexible(documents);
      this.logger.log(`📋 Processing ${sortedDocs.length} documents in order:`);
      sortedDocs.forEach((doc, index) => {
        this.logger.log(`  ${index + 1}. ${doc.tipo_documento}: ${doc.nombre_archivo}`);
      });

      // Add each document
      for (const doc of sortedDocs) {
        await this.addDocumentToPDF(pdfDoc, doc);
      }

      // Save PDF
      const totalPages = pdfDoc.getPageCount();
      this.logger.log(`📊 Total pages in PDF: ${totalPages}`);

      const pdfBytes = await pdfDoc.save({
        useObjectStreams: false,
        addDefaultPage: false,
        objectsPerTick: Infinity,
      });

      this.logger.log(`✅ PDF saved successfully, size: ${pdfBytes.length} bytes`);

      // Generate filename
      const nombreCompleto = `${egresado?.nombre || ''}_${egresado?.apellido || ''}`.trim();
      const carreraData = egresado?.carrera as any;
      const nombreCarrera = carreraData?.nombre || 'Carrera';

      const sanitizedNombre = nombreCompleto.replace(/[^a-zA-Z0-9]/g, '_');
      const sanitizedCarrera = nombreCarrera.replace(/[^a-zA-Z0-9]/g, '_');

      const timestamp = Date.now();
      const filename = `Documentos_Grado_${sanitizedNombre}_${sanitizedCarrera}_${timestamp}.pdf`;
      const displayName = `Documentos de Grado - ${nombreCompleto} - ${nombreCarrera}.pdf`;

      // Upload to storage
      const uid = documents[0].ruta_storage.split('/')[0];
      const storagePath = `${uid}/${filename}`;

      const { error: uploadError } = await this.supabaseService
        .getClient()
        .storage.from(this.BUCKET_NAME)
        .upload(storagePath, pdfBytes, {
          contentType: 'application/pdf',
          upsert: false,
        });

      if (uploadError) {
        this.logger.error(`Error uploading unified PDF: ${uploadError.message}`);
        throw new InternalServerErrorException('Error al subir el PDF unificado');
      }

      // Create database record
      const { error: dbError } = await this.supabaseService
        .getClient()
        .from('documentos_egresado')
        .insert({
          egresado_id: egresadoId,
          tipo_documento: 'unificado',
          nombre_archivo: displayName,
          ruta_storage: storagePath,
          tamano_bytes: pdfBytes.length,
          mime_type: 'application/pdf',
          es_unificado: true,
        });

      if (dbError) {
        this.logger.error(`Error creating unified PDF record: ${dbError.message}`);
        throw new InternalServerErrorException('Error al guardar el registro del PDF');
      }

      this.logger.log(`✅ Unified PDF generated successfully: ${filename}`);
    } catch (error) {
      this.logger.error(`Error generating unified PDF: ${error.message}`);
      throw error;
    }
  }

  /**
   * Sort documents flexibly (prioritizes required docs if present)
   */
  private sortDocumentsFlexible(documents: any[]) {
    const preferredOrder = ['momento_ole', 'datos_egresados', 'bolsa_empleo', 'otro'];
    return documents.sort((a, b) => {
      const indexA = preferredOrder.indexOf(a.tipo_documento);
      const indexB = preferredOrder.indexOf(b.tipo_documento);

      // If both are in preferred order, sort by that
      if (indexA !== -1 && indexB !== -1) {
        return indexA - indexB;
      }

      // Preferred items come first
      if (indexA !== -1) return -1;
      if (indexB !== -1) return 1;

      // Otherwise maintain original order
      return 0;
    });
  }

  /**
   * Delete document (soft delete + physical file deletion)
   */
  async delete(documentoId: string, egresadoId: string) {
    // Verify document belongs to egresado
    const { data: doc, error: fetchError } = await this.supabaseService
      .getClient()
      .from('documentos_egresado')
      .select('*')
      .eq('id', documentoId)
      .eq('egresado_id', egresadoId)
      .is('deleted_at', null)
      .single();

    if (fetchError || !doc) {
      throw new NotFoundException('Documento no encontrado');
    }

    // Delete physical file from storage
    this.logger.log(`🗑️ Deleting physical file from storage: ${doc.ruta_storage}`);
    const { error: storageError } = await this.supabaseService
      .getClient()
      .storage.from(this.BUCKET_NAME)
      .remove([doc.ruta_storage]);

    if (storageError) {
      this.logger.error(`Error deleting file from storage: ${storageError.message}`);
      // Continue with soft delete even if storage deletion fails
    } else {
      this.logger.log(`✅ Physical file deleted from storage: ${doc.ruta_storage}`);
    }

    // Soft delete in database
    const { error } = await this.supabaseService
      .getClient()
      .from('documentos_egresado')
      .update({ deleted_at: new Date().toISOString() })
      .eq('id', documentoId);

    if (error) {
      this.logger.error(`Error deleting document: ${error.message}`);
      throw new InternalServerErrorException('Error al eliminar documento');
    }

    this.logger.log(`Document deleted: ${documentoId}`);

    return { message: 'Documento eliminado exitosamente' };
  }

  /**
   * Get signed URL (internal helper)
   */
  private async getSignedUrlInternal(storagePath: string): Promise<string> {
    const { data, error } = await this.supabaseService
      .getClient()
      .storage.from(this.BUCKET_NAME)
      .createSignedUrl(storagePath, 3600); // 1 hour

    if (error) {
      this.logger.error(`Error creating signed URL: ${error.message}`);
      return '';
    }

    return data.signedUrl;
  }

  /**
   * Get egresado ID from Supabase Auth UID
   */
  async getEgresadoIdByUid(uid: string): Promise<string> {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('egresados')
      .select('id')
      .eq('uid', uid)
      .single();

    if (error || !data) {
      throw new NotFoundException('Perfil de egresado no encontrado');
    }

    return data.id;
  }

  /**
   * Validate file
   */
  private validateFile(file: Express.Multer.File) {
    if (!file) {
      throw new BadRequestException('No se proporcionó ningún archivo');
    }

    if (file.size > this.MAX_FILE_SIZE) {
      throw new BadRequestException(
        `El archivo excede el tamaño máximo permitido (${this.MAX_FILE_SIZE / 1024 / 1024}MB)`,
      );
    }

    if (!this.ALLOWED_MIME_TYPES.includes(file.mimetype)) {
      throw new BadRequestException(
        `Tipo de archivo no permitido. Solo se permiten: ${this.ALLOWED_MIME_TYPES.join(', ')}`,
      );
    }
  }
}

