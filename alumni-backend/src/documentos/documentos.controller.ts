import {
  Controller,
  Get,
  Post,
  Delete,
  Param,
  Body,
  UseGuards,
  UseInterceptors,
  UploadedFile,
  ParseFilePipe,
  MaxFileSizeValidator,
  FileTypeValidator,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { DocumentosService } from './documentos.service';
import { UploadDocumentoDto } from './dto/upload-documento.dto';
import { SupabaseAuthGuard } from '../auth/guards/supabase-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { ICurrentUser } from '../auth/interfaces/current-user.interface';

@Controller('documentos')
@UseGuards(SupabaseAuthGuard)
export class DocumentosController {
  constructor(private readonly documentosService: DocumentosService) {}

  @Post('upload')
  @HttpCode(HttpStatus.CREATED)
  @UseInterceptors(FileInterceptor('file'))
  async uploadDocumento(
    @CurrentUser() user: ICurrentUser,
    @UploadedFile(
      new ParseFilePipe({
        validators: [
          new MaxFileSizeValidator({ maxSize: 10 * 1024 * 1024 }), // 10MB
          new FileTypeValidator({
            fileType: /(pdf|png|jpg|jpeg)$/,
          }),
        ],
      }),
    )
    file: Express.Multer.File,
    @Body() dto: UploadDocumentoDto,
  ) {
    const egresadoId = await this.documentosService.getEgresadoIdByUid(user.id);

    return this.documentosService.upload(user.id, egresadoId, file, dto.tipo_documento);
  }

  @Get()
  async listDocumentos(@CurrentUser() user: ICurrentUser) {
    const egresadoId = await this.documentosService.getEgresadoIdByUid(user.id);
    return this.documentosService.findAll(egresadoId);
  }

  @Get(':id/download')
  async getDownloadUrl(@CurrentUser() user: ICurrentUser, @Param('id') documentoId: string) {
    const egresadoId = await this.documentosService.getEgresadoIdByUid(user.id);
    const url = await this.documentosService.getSignedUrl(documentoId, egresadoId);
    return { url };
  }

  @Get('unificado/download')
  async getUnifiedPDF(@CurrentUser() user: ICurrentUser) {
    const egresadoId = await this.documentosService.getEgresadoIdByUid(user.id);
    return this.documentosService.getUnifiedPDF(egresadoId);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  async deleteDocumento(@CurrentUser() user: ICurrentUser, @Param('id') documentoId: string) {
    const egresadoId = await this.documentosService.getEgresadoIdByUid(user.id);
    return this.documentosService.delete(documentoId, egresadoId);
  }
}
