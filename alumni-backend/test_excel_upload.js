const FormData = require('form-data');
const fs = require('fs');
const http = require('http');

// Create a simple test Excel file
const testData = 'Id Estudiante,Documento,Nombre,Correo-E Campus,Correo-E Particular\n392652,1085940183,Cielo Vanessa Andrade Burgos,cielo.andradeb@campusuco.edu.co,cielovane@yahoo.es';

fs.writeFileSync('test.csv', testData);

const form = new FormData();
form.append('file', fs.createReadStream('test.csv'));

const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/admin/egresados/habilitar-excel',
    method: 'POST',
    headers: {
        ...form.getHeaders(),
        'Authorization': 'Bearer YOUR_TOKEN_HERE' // Replace with actual token
    }
};

const req = http.request(options, (res) => {
    console.log(`Status: ${res.statusCode}`);

    let data = '';
    res.on('data', (chunk) => {
        data += chunk;
    });

    res.on('end', () => {
        console.log('Response:', data);
    });
});

req.on('error', (e) => {
    console.error(`Error: ${e.message}`);
});

form.pipe(req);
