const mysql = require('mysql');

//local mysql db connection
const connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'food_ordering'
});

connection.connect(function (err) {
    if (err) throw err;
});

module.exports = connection;