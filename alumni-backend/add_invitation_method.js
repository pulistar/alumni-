const fs = require('fs');
const path = require('path');

const serviceFile = path.join(__dirname, 'src', 'admin', 'admin.service.ts');

const methodCode = `
  /**
   * Send invitations from Excel file
   */
  async sendInvitationsFromExcel(file: Express.Multer.File) {
    try {
      // Read Excel file
      const workbook = XLSX.read(file.buffer, { type: 'buffer' });
      const sheetName = workbook.SheetNames[0];
      const sheet = workbook.Sheets[sheetName];
      
      // Start from row 2 (index 1) because row 1 is a title
      const rawData: any[] = XLSX.utils.sheet_to_json(sheet, { range: 1 });

      if (rawData.length === 0) {
        throw new BadRequestException('El archivo Excel está vacío');
      }

      // Normalize headers
      const data = rawData.map((r) => {
        return Object.fromEntries(Object.entries(r).map(([k, v]) => [k.toLowerCase().trim(), v]));
      });

      const resultados = {
        procesados: data.length,
        enviados: 0,
        errores: [] as any[],
      };

      for (let i = 0; i < data.length; i++) {
        const row = data[i];
        const rowNumber = i + 3;

        try {
           // Map columns
          const nombreCompleto = row['nombre'];
          const correo_institucional = row['correo-e campus'];
          const correo_personal = row['correo-e particular'];

          if (!nombreCompleto) continue;

          // Split nombre
          const nombreParts = String(nombreCompleto).trim().split(' ');
          const nombre = nombreParts[0];

          // Send to institutional email
          if (correo_institucional && correo_institucional.includes('@')) {
             await this.mailService.sendInvitacion(correo_institucional, nombre);
             resultados.enviados++;
          }

          // Send to personal email
          if (correo_personal && correo_personal.includes('@')) {
             await this.mailService.sendInvitacion(correo_personal, nombre);
             resultados.enviados++;
          }

        } catch (err) {
          resultados.errores.push({
            fila: rowNumber,
            error: err.message,
          });
        }
      }

      return resultados;

    } catch (error) {
      this.logger.error(\`Error sending invitations: \${error.message}\`);
      throw new BadRequestException(\`Error al procesar invitaciones: \${error.message}\`);
    }
  }
`;

try {
    let content = fs.readFileSync(serviceFile, 'utf8');

    // Find the last closing brace of the class
    const lastBraceIndex = content.lastIndexOf('}');

    if (lastBraceIndex === -1) {
        console.error('❌ No se encontró la llave de cierre de la clase');
        process.exit(1);
    }

    const newContent = content.substring(0, lastBraceIndex) + methodCode + '\n}\n';

    fs.writeFileSync(serviceFile, newContent, 'utf8');
    console.log('✅ Método sendInvitationsFromExcel agregado exitosamente');

} catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
}
