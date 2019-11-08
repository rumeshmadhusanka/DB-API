const fs = require("fs");
const router = require("express").Router();
const connection = require("../../db");
const path = require('path');
const jwt = require('jsonwebtoken')
const bcrypt = require('bcryptjs')
const config = JSON.parse(fs.readFileSync(path.resolve(__dirname, "../../env.config.json"), 'utf8'));
let json_response = JSON.parse(fs.readFileSync(path.resolve(__dirname, "../../response_format.json"), 'utf8'));

router.post('/register', (req, res) => {
    let firstName = req.body.firstName
    let lastName = req.body.lastName
    let email = req.body.email
    let contactNumber = req.body.contactNumber
    let password = req.body.password
    let hashedPassword = bcrypt.hashSync(password, 10)

    let query = "insert into customer (first_name, last_name, email, contact_no, password) values (?,?,?,?,?)"
    connection.query(query, [firstName, lastName, email, contactNumber, hashedPassword], (error, results) => {
        if (error) {
            console.error("error: ", error);
            json_response['success'] = false;
            json_response['message'] = error;
            json_response['data'] = []
            json_response['token'] = ''
            res.json(json_response);
        }
        else {
            customerId = results.insertId
            let token = jwt.sign({ customerId: customerId }, config.secret, config.optons)
            json_response['data'] = []
            json_response['data'].push({ customerId: customerId })
            json_response['token'] = token
            res.json(json_response);
        }
    })
})

router.post('/login', (req, res) => {
    let email = req.body.email
    let password = req.body.password

    let query = "select * from customer where email=? limit 1"
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
            let customerId = results[0].id
            let token = jwt.sign({customerId: customerId}, config.secret, config.options)
            json_response['data'] = []
            json_response['data'].push({ customerId: customerId })
            json_response['token'] = token
            res.json(json_response);
        }
    })
})

router.get('/:id', (req, res) => {
    let id = req.params['id'];
    let data = {};
    connection.query("select id, first_name, last_name, email, contact_no from customer where id = ?", id,
        (error, results, fields) => {
            if (error) {
                console.error("error: ", error);
                json_response['success'] = false;
                json_response['message'] = error;
                res.json(json_response);
            } else {
                //console.log(results);
                results = results[0];
                data['id'] = results['id'];
                data['first_name'] = results['first_name'];
                data['last_name'] = results['last_name'];
                data['email'] = results['email'];
                data['contact_no'] = results['contact_no'];
                json_response['data'] = []
                json_response['data'].push(data);
                res.json(json_response);
            }
        });


});

router.post('/', (req, res) => {
    let request_body = req.body;
    console.log(request_body);
    connection.query("insert into customer(first_name, last_name, email, contact_no, password) values (?,?,?,?,?)",
        [request_body['first_name'], request_body['last_name'], request_body['email'],
        request_body['contact_no'],
        request_body['password']], (error, results, fields) => {
            if (error) {
                console.error("error: ", error);
                json_response['success'] = false;
                json_response['message'] = error;
                json_response['data'] = []
                res.json(json_response);
            } else {
                let affected_rows = results.affectedRows;
                json_response['message'] = 'Affected Rows: ' + affected_rows;
                json_response['data'] = []
                res.json(json_response);
            }
        });

});

router.put('/:id', (req, res) => {
    let request_body = req.body;
    let id = req.params['id'];
    console.log(request_body);
    connection.query("update customer set first_name=?, last_name=?, email=?, contact_no=? ,password=? where id=?",
        [request_body['first_name'], request_body['last_name'], request_body['email'],
        request_body['contact_no'],
        request_body['password'], id], (error, results, fields) => {
            if (error) {
                console.error("error: ", error);
                json_response['success'] = false;
                json_response['message'] = error;
                json_response['data'] = []
                res.json(json_response);
            } else {
                let affected_rows = results.affectedRows;
                json_response['message'] = 'Affected Rows: ' + affected_rows;
                json_response['data'] = []
                res.json(json_response);
            }
        })
});

router.delete('/:id', (req, res) => {
    let id = req.params['id'];
    connection.query("delete from customer where id=?", [id], (error, results, fields) => {
        if (error) {
            console.error("error: ", error);
            json_response['success'] = false;
            json_response['message'] = error;
            json_response['data'] = []
            res.json(json_response);
        } else {
            let affected_rows = results.affectedRows;
            json_response['message'] = 'Affected Rows: ' + affected_rows;
            json_response['data'] = []
            res.json(json_response);
        }
    })
});
module.exports = router;

