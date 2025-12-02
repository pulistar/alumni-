const fs = require('fs');
const path = require('path');

const controllerFile = path.join(__dirname, 'src', 'admin', 'admin.controller.ts');

try {
    let content = fs.readFileSync(controllerFile, 'utf8');

    // Identify the garbage block. It seems to be around line 349.
    // Look for "});" followed by "res.send(buffer);"

    const garbagePattern = /}\);\s+res\.send\(buffer\);\s+}/;

    if (garbagePattern.test(content)) {
        console.log('Found garbage pattern. Removing...');
        content = content.replace(garbagePattern, '');
    }

    // Also check for duplicated methods.
    // If "exportAutoevaluacionesExcel" appears twice, we have a problem.
    const exportMethod = 'exportAutoevaluacionesExcel';
    const firstIndex = content.indexOf(exportMethod);
    const lastIndex = content.lastIndexOf(exportMethod);

    if (firstIndex !== -1 && firstIndex !== lastIndex) {
        console.log('Found duplicated content. Attempting to fix...');
        // This is risky. If I duplicated the whole bottom half, I should find where the duplication starts.
        // The duplication likely starts after createGradoAcademico.

        const splitPoint = content.indexOf('async createGradoAcademico');
        if (splitPoint !== -1) {
            // Find the end of this method
            const methodEnd = content.indexOf('}', splitPoint);
            if (methodEnd !== -1) {
                // The content after this might be the duplicated part + the rest of the file.
                // But wait, the file has valid methods after createGradoAcademico (updateGradoAcademico, toggleGradoAcademico).
                // And THEN sendInvitationsExcel.

                // Let's look for the garbage specifically.
                // In step 1432, line 349 is "});". This is likely the end of the garbage block that was pasted.

                // Let's try to remove the specific garbage lines shown in the view_file.
                // 349: });
                // 350: 
                // 351: res.send(buffer);
                // 352:   }

                const specificGarbage = `});

  res.send(buffer);
  }`;

                // Normalize whitespace
                const normalizedContent = content.replace(/\r\n/g, '\n');
                const normalizedGarbage = specificGarbage.replace(/\r\n/g, '\n');

                if (normalizedContent.includes(normalizedGarbage)) {
                    console.log('Found specific garbage block. Removing...');
                    content = normalizedContent.replace(normalizedGarbage, '');
                } else {
                    // Try looser match
                    content = content.replace(/}\);\s+res\.send\(buffer\);\s+}/g, '');
                }
            }
        }
    }

    fs.writeFileSync(controllerFile, content, 'utf8');
    console.log('✅ Archivo admin.controller.ts reparado (intentado)');

} catch (error) {
    console.error('Error:', error.message);
}
