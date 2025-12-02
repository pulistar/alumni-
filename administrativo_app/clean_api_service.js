const fs = require('fs');
const path = 'lib/data/services/api_service.dart';

try {
    const content = fs.readFileSync(path, 'utf8');
    const lines = content.split('\n');

    // Keep only the first 741 lines (up to and including the closing brace of the class)
    const cleanedLines = lines.slice(0, 741);

    fs.writeFileSync(path, cleanedLines.join('\n'), 'utf8');
    console.log('Successfully cleaned api_service.dart');
    console.log(`Removed ${lines.length - 741} lines`);

} catch (err) {
    console.error('Error:', err);
    process.exit(1);
}
