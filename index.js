const express = require('express');
const app = express();
const routes = require('./routes');
const bodyParser = require('body-parser');
const path = require('path');

// const cores = require('cors');
// app.use(cores);


//serving static files from public folder
app.use('/public', express.static(path.resolve(__dirname, './public')));


// support parsing of application/json type post data
app.use(bodyParser.json());

//routes
routes(app);

//server
const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log("Server is listening to port " + port);
});
