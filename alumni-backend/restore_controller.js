const fs = require('fs');
const path = require('path');

const controllerFile = path.join(__dirname, 'src', 'admin', 'admin.controller.ts');

try {
    let content = fs.readFileSync(controllerFile, 'utf8');

    const missingBlock = `    });

    res.send(buffer);
  }
`;

    // Find the place to insert. It's before @Get('reportes/pdfs-unificados')
    const target = "@Get('reportes/pdfs-unificados')";

    if (content.includes(target)) {
        content = content.replace(target, missingBlock + '\n  ' + target);
        fs.writeFileSync(controllerFile, content, 'utf8');
        console.log('✅ Archivo admin.controller.ts restaurado');
    } else {
        console.error('Target not found');
    }

} catch (error) {
    console.error('Error:', error.message);
}
