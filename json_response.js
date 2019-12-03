const fs = require('fs');
const path = require('path');
let json_response = JSON.parse(fs.readFileSync(path.resolve(__dirname, "response_format.json"), 'utf8'));

function getJsonRes() {
    return JSON.parse(JSON.stringify(json_response));
}

module.exports = getJsonRes;