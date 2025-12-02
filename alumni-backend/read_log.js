const fs = require('fs');
try {
    const content = fs.readFileSync('build_log.txt', 'utf16le'); // Try utf16le for PowerShell output
    console.log(content);
} catch (err) {
    console.error(err);
}
