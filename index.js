const express = require('express');
const app = express();
const routes = require('./routes');
const bodyParser = require('body-parser');

const cores = require('cors');
//serving static files from public folder
app.use(express.static('public'));

app.use(cores);

// support parsing of application/json type post data
app.use(bodyParser.json());

//routes
routes(app);

//server
const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log("Server is listening to port " + port);
});
