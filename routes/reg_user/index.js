let json_response_model = require('../../json_response');  //A function that returns the json response format object
const router = require("express").Router();
const path = require('path');
const connection = require("../../db");
const logger = require("../../logger");
const RegUser = require('../../models/RegUser');
const Joi_schema=require('../../validation/reg_user_schema'); 
const jwt = require('jsonwebtoken');
const fs = require('fs');
const config = JSON.parse(fs.readFileSync(path.resolve(__dirname, '../../env.config.json'), 'utf8'));

router.get('/:id', async (req, res) => {
    let id_params = {id: req.params['id']};
    let user = new RegUser();
    let json_response = json_response_model();
    try {
        await Joi_schema.id_check.validateAsync(id_params);
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
        await Joi_schema.reg_user_schema.validateAsync({first_name,second_name,email,nic,passport_id,birthday,username,password});
        console.log(first_name, second_name, email, nic, passport_id, birthday, username, password);
        let results = await user.addUser(first_name, second_name, email, nic, passport_id, birthday, username, password);
        json_response.success = true;
        let send_results = results[0];
        json_response.message = "Successfully added " + first_name;
        res.status(201).json(json_response);
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

router.post('/login', async (req, res) => {
    let email = req.body.email;
    let password = req.body.password;
    let user = new RegUser();
    let json_response = json_response_model();
    try {
        await Joi_schema.log_in_schema.validateAsync({email,password});
        let results = await user.login(email, password);
        json_response.success = true;
        let send_results = results[0];
        let user_id = send_results["user_id"];
        //console.log(send_results);
        //console.log();
        json_response.message = "Login Success";
        let token = jwt.sign({"user_id": user_id}, config.secret, config.options);
        res.header('x-access-token', token).status(200).json(json_response);
    } catch (e) {
        console.log(e);
        json_response.message = e;
        let code = e.statusCode || 502;
        if (e._message == null && e.details[0].message) {
            code = 400;
            json_response.data =
                json_response.message = e.details[0].message;
            res.status(code).json(json_response);
        } else {

            res.status(code).json(json_response);
        }
        res.status(502).send();
    }
});

router.put('/:id', async (req, res) => {
    let user_id = req.params["id"];
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
        await Joi_schema.reg_user_schema.validateAsync({first_name,second_name,email,nic,passport_id,birthday,username,password});
        await Joi_schema.id_check.validateAsync({user_id})
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

