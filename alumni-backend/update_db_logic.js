const fs = require('fs');
const path = require('path');

const serviceFile = path.join(__dirname, 'src', 'admin', 'admin.service.ts');

const newUpdateLogic = `
          if (existente) {
            // Update existing with new data from Excel
            const updateData: any = {
                habilitado: true,
                fecha_habilitacion: new Date().toISOString(),
                id_universitario: id_universitario,
                documento: documento,
                nombre: nombre,
                apellido: apellido,
                correo_personal: correo_personal,
            };

            if (celular) updateData.celular = celular;
            if (telefono) updateData.telefono_alternativo = telefono;
            if (lugar_expedicion) updateData.lugar_expedicion = lugar_expedicion;
            if (carreraId) updateData.carrera_id = carreraId;

            const { error: updError } = await this.supabaseService
              .getClient()
              .from('egresados')
              .update(updateData)
              .eq('id', existente.id);
`;

try {
    let content = fs.readFileSync(serviceFile, 'utf8');

    // Replace the update block
    const startMarker = "if (existente) {";
    const endMarker = ".eq('id', existente.id);";

    // Find the FIRST occurrence after line 740 (approx) to avoid matching other blocks if any
    // But since we know the structure, let's look for the specific block inside the loop
    // The block contains "habilitado: true," and "fecha_habilitacion:"

    const searchString = `if (existente) {
            // Update existing
            const { error: updError } = await this.supabaseService
              .getClient()
              .from('egresados')
              .update({
                habilitado: true,
                fecha_habilitacion: new Date().toISOString(),
              })
              .eq('id', existente.id);`;

    // Normalize whitespace for search might be needed, but let's try exact match first based on previous view_file
    // The previous view_file showed:
    /*
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
    */

    // Let's construct a regex or use a more flexible search
    const startIndex = content.indexOf('if (existente) {');
    // We need to find the one inside the loop. The loop starts with "for (let i = 0; i < data.length; i++) {"
    // Let's search relative to that.

    const loopStart = content.indexOf('for (let i = 0; i < data.length; i++) {');
    if (loopStart === -1) throw new Error('Loop start not found');

    const targetStart = content.indexOf('if (existente) {', loopStart);
    if (targetStart === -1) throw new Error('Target block start not found');

    const targetEnd = content.indexOf(".eq('id', existente.id);", targetStart);
    if (targetEnd === -1) throw new Error('Target block end not found');

    const endOfBlock = targetEnd + ".eq('id', existente.id);".length;

    const before = content.substring(0, targetStart);
    const after = content.substring(endOfBlock);

    const newContent = before + newUpdateLogic + after;

    fs.writeFileSync(serviceFile, newContent, 'utf8');
    console.log('✅ Lógica de actualización de base de datos aplicada exitosamente');

} catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
}
