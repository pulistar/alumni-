const fs = require('fs');
const path = require('path');

const controllerFile = path.join(__dirname, 'src', 'admin', 'admin.controller.ts');

try {
    let content = fs.readFileSync(controllerFile, 'utf8');

    const searchString = "filename=autoevaluaciones-${Date.now()}.xlsx`,";
    const missingBlock = `    });

    res.send(buffer);
  }
`;

    if (content.includes(searchString)) {
        // Find the end of the line containing searchString
        const index = content.indexOf(searchString);
        const nextLineIndex = content.indexOf('\n', index);

        // Check if the next lines are already correct (to avoid double insertion)
        const nextContent = content.substring(nextLineIndex, nextLineIndex + 50);
        if (!nextContent.includes('res.send(buffer)')) {
            const before = content.substring(0, nextLineIndex);
            const after = content.substring(nextLineIndex);
            content = before + '\n' + missingBlock + after;
            fs.writeFileSync(controllerFile, content, 'utf8');
            console.log('✅ Archivo admin.controller.ts reparado correctamente');
        } else {
            console.log('El archivo ya parece estar correcto');
        }
    } else {
        console.error('Search string not found');
    }

} catch (error) {
    console.error('Error:', error.message);
}
