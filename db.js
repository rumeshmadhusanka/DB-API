const mysql = require('mysql');
const path = require('path');
const fs = require('fs');
let db_config = JSON.parse(fs.readFileSync(path.resolve(__dirname, "db.conf.json"), 'utf8'));


//local mysql db connection
const connection = mysql.createConnection(db_config);

connection.connect(function (err) {
    if (err) throw err;
});

module.exports = connection;