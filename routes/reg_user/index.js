let json_response_model = require('../../json_response');  //A function that returns the json response format object
const router = require("express").Router();
const path = require('path');
const connection = require("../../db");
const logger = require("../../logger");
const RegUser = require('../../models/RegUser');
const Joi_schema=require('../../validation/book_fight_schema'); 

router.get('/:id', async (req, res) => {
    let id_params = {id:req.params['id']};
    let user = new RegUser();
    let json_response = json_response_model();
    try {
        await Joi_schema.id_schema.validateAsync(id_params);
        let results = await user.getUserById(id_params.id);
        let send_results = results[0];
        send_results['password'] = null;
        json_response.success = true;
        json_response.data.push(send_results);
        res.status(200).json(json_response);
    } catch (e) {
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
    let first_name = req.body.first_name;
    let second_name = req.body.second_name;
    let email = req.body.email;
    let nic = req.body.nic;
    let passport_id = req.body.passport_id;
    let birthday = req.body.birthday;
    let username = req.body.username;
    let password = req.body.password;

    let user = new RegUser();
    let json_response = json_response_model();
    try {
        console.log(first_name, second_name, email, nic, passport_id, birthday, username, password);
        let results = await user.addUser(first_name, second_name, email, nic, passport_id, birthday, username, password);
        json_response.success = true;
        let send_results = results[0];
        json_response.message = "Successfully added " + first_name;
        res.status(200).json(json_response);
    } catch (e) {
        json_response.message = e;
        let code = e.statusCode || 502;
        if (e._message == null && e.details[0].message) {
            code = 400;
            json_response.message = e.details[0].message;
            res.status(code).json(json_response);
        } else {
            res.status(code).json(json_response);
        }
        res.status(502).send();
    }


});

router.post('/login', (req, res) => {

});

router.put('/:id', (req, res) => {
    let user_id=req.params["id"];
    let first_name = req.body.first_name;
    let second_name = req.body.second_name;
    let email = req.body.email;
    let nic = req.body.nic;
    let passport_id = req.body.passport_id;
    let birthday = req.body.birthday;
    let username = req.body.username;
    let password = req.body.password;

    let user = new RegUser();
    let json_response = json_response_model();
    try {
        console.log(user_id,first_name, second_name, email, nic, passport_id, birthday, username, password);
        let results = await user.updateUser(user_id,first_name, second_name, email, nic, passport_id, birthday, username, password);
        json_response.success = true;
        let send_results = results[0];
        json_response.message = "Successfully Updated " + first_name;
        res.status(200).json(json_response);
    } catch (e) {
        json_response.message = e;
        let code = e.statusCode || 502;
        if (e._message == null && e.details[0].message) {
            code = 400;
            json_response.message = e.details[0].message;
            res.status(code).json(json_response);
        } else {
            res.status(code).json(json_response);
        }
        res.status(502).send();
    }

});

router.delete('/:id', (req, res) => {

});

//search route
// passenger/search?name=Kamal
// access the query param: req.query.name
router.get('/search', (req, res) => {

});

module.exports = router;

