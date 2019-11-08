const fs = require("fs");
const router = require("express").Router();
const connection = require("../../db");
const path = require('path');
const jwt = require('jsonwebtoken')
const bcrypt = require('bcryptjs')
const config = JSON.parse(fs.readFileSync(path.resolve(__dirname, "../../env.config.json"), 'utf8'));
let json_response = JSON.parse(fs.readFileSync(path.resolve(__dirname, "../../response_format.json"), 'utf8'));

router.post('/register', (req, res) => {
    let email = req.body.email
    let password = req.body.password
    let role = req.body.role
    let hashedPassword = bcrypt.hashSync(password, 10)

    let query = "insert into shop (email, password, role) values (?,?,?)"
    connection.query(query, [email, hashedPassword, role], (error, results) => {
        if (error) {
            console.error("error: ", error);
            json_response['success'] = false;
            json_response['message'] = error;
            json_response['data'] = []
            json_response['token'] = ''
            res.json(json_response);
        }
        else {
            shopId = results.insertId
            let token = jwt.sign({ shopId: shopId }, config.secret, config.optons)
            json_response['data'] = []
            json_response['data'].push({ shopId: shopId })
            json_response['token'] = token
            res.json(json_response);
        }
    })
})

router.post('/login', (req, res) => {
    let email = req.body.email
    let password = req.body.password

    let query = "select * from shop where email=? limit 1"
    connection.query(query, email, (error, results) => {
        if (error || results.length == 0) {
            console.error("error: ", error);
            json_response['success'] = false;
            json_response['message'] = error || "Email not found";
            json_response['data'] = []
            json_response['token'] = ''
            res.json(json_response);
        }
        else {
            let hashedPassword = results[0].password
            let isPasswordValid = bcrypt.compareSync(password, hashedPassword)

            if (!isPasswordValid) {
                json_response['success'] = false;
                json_response['message'] = "Incorrect password";
                json_response['data'] = []
                json_response['token'] = ''
                return res.json(json_response);
            }
            let shopId = results[0].id
            let token = jwt.sign({shopId: shopId}, config.secret, config.options)
            json_response['data'] = []
            json_response['data'].push({ customerId: shopId })
            json_response['token'] = token
            res.json(json_response);
        }
    })
})

router.get('/', (req, res) => {
    res.status(200).json({
        "message": "Hello World"
    });
});


module.exports = router;

