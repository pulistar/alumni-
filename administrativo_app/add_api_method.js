const fs = require('fs');
const path = require('path');

const apiFile = path.join(__dirname, 'lib', 'data', 'services', 'api_service.dart');

const methodCode = `
  /// Send invitations from Excel
  Future<Map<String, dynamic>> sendInvitationsExcel(String token, File file) async {
    try {
      final uri = Uri.parse('\${ApiConfig.baseUrl}/admin/invitaciones/excel');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al enviar invitaciones: \${response.body}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al enviar invitaciones: $e');
    }
  }
`;

try {
    let content = fs.readFileSync(apiFile, 'utf8');

    // Find the last closing brace of the class
    const lastBraceIndex = content.lastIndexOf('}');

    if (lastBraceIndex === -1) {
        console.error('❌ No se encontró la llave de cierre de la clase');
        process.exit(1);
    }

    const newContent = content.substring(0, lastBraceIndex) + methodCode + '\n}\n';

    fs.writeFileSync(apiFile, newContent, 'utf8');
    console.log('✅ Método sendInvitationsExcel agregado exitosamente a ApiService');

} catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
}
