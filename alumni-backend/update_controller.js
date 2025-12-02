const fs = require('fs');
const path = 'src/admin/admin.controller.ts';

try {
    let content = fs.readFileSync(path, 'utf8');

    const newEndpoints = `
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
}
`;

    // Find the last closing brace
    const lastBraceIndex = content.lastIndexOf('}');

    if (lastBraceIndex === -1) {
        console.error('Could not find closing brace');
        process.exit(1);
    }

    // Replace the last brace with the new endpoints and a closing brace
    const updatedContent = content.substring(0, lastBraceIndex) + newEndpoints;

    fs.writeFileSync(path, updatedContent, 'utf8');
    console.log('Successfully updated admin.controller.ts');

} catch (err) {
    console.error('Error:', err);
    process.exit(1);
}
