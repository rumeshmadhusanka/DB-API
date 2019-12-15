let json_response_model = require('../../json_response');  //A function that returns the json response format object
const router = require("express").Router();
const path = require('path');
const connection = require("../../db");
const logger = require("../../logger");
const RegUser = require('../../models/RegUser');
const Joi_schema=require('../../validation/book_fight_schema'); 

router.get('/:id', async (req, res) => {
    let id_params = {id:req.params['id']};
    //let query = "select * from user inner join registered_user using(user_id) where user.user_id = ?";
    // connection.query(query, [id], (error, results, fields) => {
    //     let json_response = json_response_model(); //returns a new object
    //     let status_code = 404;
    //     if (error) {
    //         json_response.success = false;
    //         json_response.message = "Internal server error";
    //         logger.log(error);
    //         status_code = 502;
    //     } else if (!results.length) {
    //         json_response.success = false;
    //         json_response.message = "No user found";
    //         status_code = 404;
    //     } else {
    //         json_response.success = true;
    //         json_response.message = "Success";
    //         let person = {};
    //         results = results[0];
    //         person['user_id'] = results['user_id'];
    //         person['first_name'] = results['first_names'];
    //         person['email'] = results['email'];
    //         person['nic'] = results['nic'];
    //         person['passport_id'] = results['passport_id'];
    //         json_response.data.push(person);
    //         console.log(results);
    //         status_code = 200;
    //
    //     }
    //     res.status(status_code).json(json_response);
    //
    // })
    let user = new RegUser();
    let json_response = json_response_model();
    try {
        await Joi_schema.id_schema.validateAsync(id_params);
        let results = await user.getUserById(id_params.id);
        //console.log(results);
        let person = {};
        let send_results = results[0];
        send_results['password'] = null;
        json_response.data.push(send_results);
        res.status(200).json(json_response);
    } catch (e) {
        // console.log(e._message);
        json_response.message =  e;
        let code = e.statusCode || 502;  
        if (e._message==null && e.details[0].message ){
            code=400;
            json_response.message =  e.details[0].message;
            res.status(code).json(json_response);
        }else{
            res.status(code).json(json_response);
        }  
    }
});

//Sign in route
router.post('/', async(req, res) => {
    let first_names = req.body.first_names;
    let second_name = req.body.second_name;
    let email = req.body.email;
    let nic = req.body.nic;
    let passport_id = req.body.passport_id;
    let username = req.body.username;
    let password = req.body.password;
    let query =
        " insert into user(first_names, second_name, email, nic, passport_id) VALUES (?,?,?,?,?);" +
        "insert into registered_user(username, password) values(?,?);";
    let json_response = json_response_model();
    connection.beginTransaction((err) => {
        if (err) {
            connection.rollback();
            json_response.success = false;
            json_response.message = "Internal server error";
            logger.log(err);
            console.log(err);
            res.status(502).json(json_response);
        } else {
            connection.query(query, [first_names, second_name, email, nic, passport_id, username, password], function (err, results) {
                if (err) {
                    connection.rollback();
                    json_response.success = false;
                    json_response.message = "Invalid credentials";
                    logger.log(err);
                    console.log(err);
                    res.status(400).json(json_response);
                } else {
                    connection.commit(function (err) {
                        if (err) {
                            connection.rollback();
                            json_response.success = false;
                            json_response.message = "Internal server error";
                            logger.log(err);
                            console.log(err);
                            res.status(502).json(json_response);
                        } else {
                            //res.send
                            json_response.success = true;
                            json_response.message = "Success";
                            res.status(200).json(json_response);
                        }
                    })
                }
            })
        }
    })


});

router.post('/login', (req, res) => {

});

router.put('/:id', (req, res) => {

});

router.delete('/:id', (req, res) => {

});

//search route
// passenger/search?name=Kamal
// access the query param: req.query.name
router.get('/search', (req, res) => {

});

module.exports = router;

