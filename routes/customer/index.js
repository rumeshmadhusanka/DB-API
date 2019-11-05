const fs = require("fs");
const router = require("express").Router();
const connection = require("../../db");
const path = require('path');
let json_response = JSON.parse(fs.readFileSync(path.resolve(__dirname, "../../response_format.json"), 'utf8'));

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
                json_response['data'].push(data);
                res.json(json_response);
            }
        });


});

// router.get('/:id/login',(req,res)=>{
//     let id = req.params['id'];
//     let data = {};
//     connection.query("select id, password from customer where id = ?",id)
// });

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
                res.json(json_response);
            } else {
                let affected_rows = results.affectedRows;
                json_response['message'] = 'Affected Rows: ' + affected_rows;
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
                res.json(json_response);
            } else {
                let affected_rows = results.affectedRows;
                json_response['message'] = 'Affected Rows: ' + affected_rows;
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
            res.json(json_response);
        } else {
            let affected_rows = results.affectedRows;
            json_response['message'] = 'Affected Rows: ' + affected_rows;
            res.json(json_response);
        }
    })
});
module.exports = router;

