const mysql = require('promise-mysql');
const path = require('path');
const fs = require('fs');

let db_config = JSON.parse(fs.readFileSync(path.resolve(__dirname, "db.conf.json"), 'utf8'));


const poolPromise = mysql.createPool(db_config);

module.exports = poolPromise;