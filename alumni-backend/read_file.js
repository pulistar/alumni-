const fs = require('fs');
try {
    const content = fs.readFileSync('src/admin/admin.service.ts', 'utf8');
    const lines = content.split('\n');
    // Read the beginning of the method to verify new logic
    // Method starts around where we replaced it. Let's look for "const id_estudiante"
    const start = 620;
    const end = 700;
    console.log(lines.slice(start, end).join('\n'));
} catch (err) {
    console.error(err);
}
