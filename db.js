const mysql = require('mysql');

//local mysql db connection
const connection = mysql.createConnection({
    host: 'sql12.freemysqlhosting.net',
    user: 'sql12310953',
    password: 'Rg4zS5ceei',
    database: 'sql12310953'
});

connection.connect(function (err) {
    if (err) throw err;
});

module.exports = connection;