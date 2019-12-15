const express = require('express');
const app = express();
const routes = require('./routes');
const bodyParser = require('body-parser');
const path = require('path');
const swaggerJsDoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');

const swaggerOptions = {
    swaggerDefinition: {
        info: {
            title: 'Airline API',
            description: "https://github.com/rumeshmadhusanka/DB-API",
            contact: {
                name: 'https://github.com/rumeshmadhusanka/DB-API'
            },
            host: 'http://localhost:3000',
            basePath: '/'
        }
    },
    apis: ['./routes/**/**.yaml']
};

const swaggerDocs = swaggerJsDoc(swaggerOptions);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocs));

// app.use(express.json()); 


app.use((req, res, next) => {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', '*');
    res.setHeader("Access-Control-Allow-Credentials", true);
    next();
});


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

module.exports = app;
