// ============================================
// ENDPOINTS PARA CARRERAS
// Agregar estos endpoints en admin.controller.ts
// ============================================

import { CreateCarreraDto, UpdateCarreraDto } from './dto/carrera.dto';
import { CreateGradoAcademicoDto, UpdateGradoAcademicoDto } from './dto/grado-academico.dto';

// ============================================
// CARRERAS ENDPOINTS
// ============================================

@Get('carreras')
@ApiOperation({ summary: 'Get all carreras' })
async getCarreras() {
    return this.adminService.getCarreras();
}

@Post('carreras')
@ApiOperation({ summary: 'Create a new carrera' })
async createCarrera(@Body() dto: CreateCarreraDto) {
    return this.adminService.createCarrera(dto);
}

@Patch('carreras/:id')
@ApiOperation({ summary: 'Update a carrera' })
async updateCarrera(
    @Param('id') id: string,
    @Body() dto: UpdateCarreraDto,
) {
    return this.adminService.updateCarrera(id, dto);
}

@Patch('carreras/:id/toggle')
@ApiOperation({ summary: 'Toggle carrera activa status' })
async toggleCarrera(@Param('id') id: string) {
    return this.adminService.toggleCarrera(id);
}

// ============================================
// GRADOS ACADÉMICOS ENDPOINTS
// ============================================

@Get('grados-academicos')
@ApiOperation({ summary: 'Get all grados académicos' })
async getGradosAcademicos() {
    return this.adminService.getGradosAcademicos();
}

@Post('grados-academicos')
@ApiOperation({ summary: 'Create a new grado académico' })
async createGradoAcademico(@Body() dto: CreateGradoAcademicoDto) {
    return this.adminService.createGradoAcademico(dto);
}

@Patch('grados-academicos/:id')
@ApiOperation({ summary: 'Update a grado académico' })
async updateGradoAcademico(
    @Param('id') id: string,
    @Body() dto: UpdateGradoAcademicoDto,
) {
    return this.adminService.updateGradoAcademico(id, dto);
}

@Patch('grados-academicos/:id/toggle')
@ApiOperation({ summary: 'Toggle grado académico activo status' })
async toggleGradoAcademico(@Param('id') id: string) {
    return this.adminService.toggleGradoAcademico(id);
}
