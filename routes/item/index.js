const fs = require("fs");
const router = require("express").Router();
const connection = require("../../db");
const auth = require('../../middleware/auth')
const path = require('path');
const multer = require('multer');
let json_response = JSON.parse(fs.readFileSync(path.resolve(__dirname, "../../response_format.json"), 'utf8'));


router.get('/', (req, res) => {
    connection.query("select id, name,price,description,photo from item",
        (error, results) => {
            if (error) {
                console.error("error: ", error);
                json_response['success'] = false;
                json_response['message'] = error;
                res.json(json_response);
            } else {
                json_response['data'] = results;
                res.json(json_response);
            }
        });


});

router.post('/', (req, res) => {
    let req_body = req.body;
    connection.query("insert into item(name, description, price) values (?,?,?)",
        [req_body['name'], req_body['description'], req_body['price']],
        (error, results) => {
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


//photo upload
let filename = "";
let Storage = multer.diskStorage({
    destination: function (req, file, callback) {
        callback(null, path.resolve(__dirname, "../../public/images"));
    },
    filename: function (req, file, callback) {
        filename = Date.now() + "_" + file.originalname;
        callback(null, filename);
    }
});
let upload = multer({
    storage: Storage
}).array("imgUploader", 3);

router.post('/:id/photo', (req, res) => {
    let id = req.params['id'];
    upload(req, res, function (error) {
        connection.query("update item set photo=? where id=?", [filename, id]);
        if (error) {
            console.error("error: ", error);
            json_response['success'] = false;
            json_response['message'] = error;
            res.json(json_response);
        } else {
            json_response['message'] = 'image uploaded successfully';
            res.json(json_response);
        }
    });
});


router.put('/:id', (req, res) => {
    let request_body = req.body;
    let id = req.params['id'];
    console.log(request_body);
    connection.query("update item set name=?, price=?, description=? where id=?",
        [request_body['name'], request_body['price'], request_body['description'], id],
        (error, results, fields) => {
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
    connection.query("delete from item where id=?", [id],
        (error, results) => {
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