const fs = require('fs');
const path = require('path');

const controllerFile = path.join(__dirname, 'src', 'admin', 'admin.controller.ts');

try {
    const content = fs.readFileSync(controllerFile, 'utf8');
    console.log('File length:', content.length);

    // Find all method decorators
    const methodMatches = [...content.matchAll(/@(Get|Post|Patch|Delete)\('([^']+)'\)/g)];

    console.log('Methods found:');
    methodMatches.forEach(m => {
        console.log(`${m.index}: ${m[0]}`);
    });

} catch (error) {
    console.error('Error:', error.message);
}
