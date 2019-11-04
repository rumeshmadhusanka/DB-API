const express = require('express');
const app = express();
const routes = require('./routes');
const bodyParser = require('body-parser');

//serving static files from public folder
app.use(express.static('public'));

// support parsing of application/json type post data
app.use(bodyParser.json());

//routes
routes(app);

//server
const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log("Server is listening to port " + port);
});
