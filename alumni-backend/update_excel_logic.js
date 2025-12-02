const fs = require('fs');
const path = require('path');

const serviceFile = path.join(__dirname, 'src', 'admin', 'admin.service.ts');

const newLogic = `
      // Read Excel file
      const workbook = XLSX.read(file.buffer, { type: 'buffer' });
      const sheetName = workbook.SheetNames[0];
      const sheet = workbook.Sheets[sheetName];
      
      // Start from row 2 (index 1) because row 1 is a title
      const rawData: any[] = XLSX.utils.sheet_to_json(sheet, { range: 1 });

      if (rawData.length === 0) {
        throw new BadRequestException('El archivo Excel está vacío o no tiene datos válidos');
      }

      // Normalize headers (lowercase, trim)
      const data = rawData.map((r) => {
        return Object.fromEntries(Object.entries(r).map(([k, v]) => [k.toLowerCase().trim(), v]));
      });

      const resultados = {
        procesados: data.length,
        exitosos: 0,
        errores: [] as any[],
      };

      // Get carreras for validation
      const { data: carreras } = await this.supabaseService
        .getClient()
        .from('carreras')
        .select('id, nombre');

      const carrerasMap = new Map(
        (carreras || []).map((c) => [String(c.nombre).toLowerCase(), c.id]),
      );

      // Process each row
      for (let i = 0; i < data.length; i++) {
        const row = data[i];
        const rowNumber = i + 3; // Excel rows start at 1, title is row 1, header is row 2, data starts at 3

        try {
          // Map columns from the specific format provided
          const id_universitario = row['id estudiante'];
          const documento = row['documento'];
          const nombreCompleto = row['nombre'];
          const correo_institucional = row['correo-e campus'];
          const correo_personal = row['correo-e particular'];
          
          // Optional fields
          const celular = row['celular'];
          const telefono = row['tel domicilio'];
          const lugar_expedicion = row['lugar de exp'];

          // Strict Validation: All key fields must be present
          if (!id_universitario || !documento || !nombreCompleto || !correo_institucional || !correo_personal) {
            resultados.errores.push({
              fila: rowNumber,
              correo_institucional: correo_institucional || 'N/A',
              error: 'Faltan campos requeridos (Id Estudiante, Documento, Nombre, Correo-E Campus, Correo-E Particular)',
            });
            continue;
          }

          // Split nombre into nombre and apellido
          // Assuming "First Last" or "First Middle Last"
          // Strategy: First token is nombre, rest is apellido
          const nombreParts = String(nombreCompleto).trim().split(' ');
          let nombre = nombreParts[0];
          let apellido = nombreParts.slice(1).join(' ');
          
          if (!apellido) {
            apellido = '.'; // Placeholder if no last name found
          }

          // Get carrera_id if 'programa ac' column exists
          let carreraId = null;
          // Check for 'programa ac' or 'programa academico' or just 'carrera'
          const carreraRaw = row['programa ac'] || row['programa academico'] || row['carrera'];
          
          if (carreraRaw) {
            carreraId = carrerasMap.get(String(carreraRaw).toLowerCase());
            // Note: If career not found, we log it but maybe we shouldn't block the user creation?
            // User asked for strict validation on the fields above. 
            // Let's keep the logic: if career provided but not found, it's an error.
            if (!carreraId) {
               resultados.errores.push({
                fila: rowNumber,
                correo_institucional,
                error: \`Carrera "\${carreraRaw}" no encontrada\`,
              });
              continue;
            }
          }
`;

try {
    let content = fs.readFileSync(serviceFile, 'utf8');

    // We need to replace the block from "const workbook = XLSX.read" to the end of the validation logic
    // This is tricky with string replacement. Let's find start and end markers.

    const startMarker = "const workbook = XLSX.read(file.buffer, { type: 'buffer' });";
    const endMarker = "// Check if egresado exists (use maybeSingle to avoid error)";

    const startIndex = content.indexOf(startMarker);
    const endIndex = content.indexOf(endMarker);

    if (startIndex === -1 || endIndex === -1) {
        console.error('❌ No se encontraron los marcadores de código para reemplazar');
        process.exit(1);
    }

    const beforeBlock = content.substring(0, startIndex);
    const afterBlock = content.substring(endIndex);

    const newContent = beforeBlock + newLogic + '\n          ' + afterBlock;

    fs.writeFileSync(serviceFile, newContent, 'utf8');

    console.log('✅ Lógica de validación de Excel actualizada exitosamente');
} catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
}
