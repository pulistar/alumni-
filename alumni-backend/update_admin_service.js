const fs = require('fs');
const path = 'src/admin/admin.service.ts';

try {
    let content = fs.readFileSync(path, 'utf8');

    // New implementation of habilitarDesdeExcel
    const newMethod = `  async habilitarDesdeExcel(file: Express.Multer.File, adminId: string) {
    if (!file) {
      throw new BadRequestException('No se proporcionó ningún archivo');
    }

    try {
      // Read Excel file
      const workbook = XLSX.read(file.buffer, { type: 'buffer' });
      const sheetName = workbook.SheetNames[0];
      const sheet = workbook.Sheets[sheetName];
      const rawData: any[] = XLSX.utils.sheet_to_json(sheet);

      if (rawData.length === 0) {
        throw new BadRequestException('El archivo Excel está vacío');
      }

      // Normalize headers (lowercase, trim, remove special chars)
      const data = rawData.map((r) => {
        return Object.fromEntries(
          Object.entries(r).map(([k, v]) => [
            k.toLowerCase().trim().replace(/\\s+/g, '_').replace(/-/g, '_'),
            v,
          ]),
        );
      });

      const resultados = {
        procesados: data.length,
        exitosos: 0,
        errores: [] as any[],
      };

      // Process each row
      for (let i = 0; i < data.length; i++) {
        const row = data[i];
        const rowNumber = i + 2; // Excel rows start at 1, header is row 1

        try {
          // Map columns from new format
          // Expected: id_estudiante, documento, nombre, correo_e_campus, correo_e_particular
          const id_estudiante = row['id_estudiante']?.toString();
          const documento = row['documento']?.toString();
          const nombre_completo = row['nombre'];
          const correo_campus = row['correo_e_campus'] || row['correo_institucional'] || row['email'];
          const correo_particular = row['correo_e_particular'] || row['correo_personal'];

          // Split nombre into nombre and apellido
          let nombre = '';
          let apellido = '';
          
          if (nombre_completo) {
            const parts = nombre_completo.toString().trim().split(/\\s+/);
            if (parts.length === 1) {
              nombre = parts[0];
              apellido = ''; // No surname provided
            } else if (parts.length === 2) {
              nombre = parts[0];
              apellido = parts[1];
            } else if (parts.length > 2) {
              // Assume last 2 are surnames (common in LatAm), rest are names
              apellido = parts.slice(-2).join(' ');
              nombre = parts.slice(0, -2).join(' ');
            }
          } else {
            // Fallback to old separate columns if present
            nombre = row['nombre'] || row['first_name'];
            apellido = row['apellido'] || row['last_name'];
          }

          // Validate we have at least ONE identifier
          if (!documento && !id_estudiante && !correo_campus && !correo_particular) {
            resultados.errores.push({
              fila: rowNumber,
              datos: { documento, nombre: nombre_completo },
              error: 'Faltan identificadores (Documento, Id Estudiante o Correos)',
            });
            continue;
          }

          // Build search query with OR logic
          let query = this.supabaseService
            .getClient()
            .from('egresados')
            .select('id, uid, correo_institucional, nombre, apellido, documento, id_universitario, correo_personal');

          const conditions = [];
          if (documento) conditions.push(\`documento.eq.\${documento}\`);
          if (id_estudiante) conditions.push(\`id_universitario.eq.\${id_estudiante}\`);
          if (correo_campus) conditions.push(\`correo_institucional.eq.\${correo_campus}\`);
          if (correo_particular) conditions.push(\`correo_personal.eq.\${correo_particular}\`);

          if (conditions.length > 0) {
            query = query.or(conditions.join(','));
          }

          // Execute search
          const { data: encontrados, error: searchError } = await query;

          if (searchError) {
            resultados.errores.push({
              fila: rowNumber,
              datos: { documento, nombre: nombre_completo },
              error: \`Error buscando egresado: \${searchError.message}\`,
            });
            continue;
          }

          // Check if found
          const existente = encontrados && encontrados.length > 0 ? encontrados[0] : null;

          if (existente) {
            // Update existing
            const { error: updError } = await this.supabaseService
              .getClient()
              .from('egresados')
              .update({
                habilitado: true,
                fecha_habilitacion: new Date().toISOString(),
              })
              .eq('id', existente.id);

            if (updError) {
              resultados.errores.push({
                fila: rowNumber,
                datos: { documento, nombre: nombre_completo },
                error: updError.message,
              });
              continue;
            }

            // Create notification
            await this.notificacionesService.crear({
              egresado_id: existente.id,
              titulo: '¡Tu cuenta ha sido habilitada!',
              mensaje: 'Ya puedes subir tus documentos de grado.',
              tipo: 'habilitacion',
              url_accion: '/documentos',
            });

            resultados.exitosos++;
          } else {
            resultados.errores.push({
              fila: rowNumber,
              datos: { documento, nombre: nombre_completo },
              error: 'Egresado no encontrado con los datos proporcionados',
            });
          }
        } catch (err) {
          resultados.errores.push({
            fila: rowNumber,
            error: err.message,
          });
        }
      }

      this.logger.log(
        \`Excel processed: \${resultados.exitosos} exitosos, \${resultados.errores.length} errores\`,
      );

      // Log to cargas_excel table (best effort)
      try {
        await this.supabaseService.getClient().from('cargas_excel').insert({
          admin_id: adminId,
          nombre_archivo: file.originalname,
          total_registros: data.length,
          registros_procesados: resultados.procesados,
          registros_habilitados: resultados.exitosos,
          registros_errores: resultados.errores.length,
          errores_detalle: resultados.errores,
        });
      } catch (logError) {
        this.logger.warn(\`Failed to log Excel upload: \${logError.message}\`);
      }

      return resultados;
    } catch (error) {
      this.logger.error(\`Error processing Excel: \${error.message}\`);
      throw new BadRequestException(\`Error al procesar archivo Excel: \${error.message}\`);
    }
  }`;

    // Find start and end of the method to replace
    // We look for the signature and the end of the method block
    // This is a simplified regex approach, assuming standard formatting
    const startRegex = /async habilitarDesdeExcel\(file: Express\.Multer\.File, adminId: string\) \{/;
    const match = content.match(startRegex);

    if (!match) {
        console.error('Method habilitarDesdeExcel not found');
        process.exit(1);
    }

    const startIndex = match.index;

    // Find the matching closing brace
    let braceCount = 0;
    let endIndex = -1;
    let foundStart = false;

    for (let i = startIndex; i < content.length; i++) {
        if (content[i] === '{') {
            braceCount++;
            foundStart = true;
        } else if (content[i] === '}') {
            braceCount--;
            if (foundStart && braceCount === 0) {
                endIndex = i + 1;
                break;
            }
        }
    }

    if (endIndex === -1) {
        console.error('Could not find end of method');
        process.exit(1);
    }

    // Replace content
    const updatedContent = content.substring(0, startIndex) + newMethod + content.substring(endIndex);

    fs.writeFileSync(path, updatedContent, 'utf8');
    console.log('Successfully updated habilitarDesdeExcel');

} catch (err) {
    console.error('Error:', err);
    process.exit(1);
}
