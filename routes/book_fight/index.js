let json_response_model = require('../../json_response');  //A function that returns the json response format object
const router = require("express").Router();
const path = require('path');
const connection = require("../../db");
const logger = require("../../logger");

router.get('/all', (req, res) => {
    // let id = req.params['id'];
    let query = "SELECT * from schedule WHERE `date`> CURDATE()";
    connection.query(query,(error, results) => {
        let json_response = json_response_model();//returns a new object
        console.log(typeof(results.lenght));
        if (error) {
            json_response.success = false;
            json_response.message = "Internal server error";
            console.log(error);
            logger.log(error);
            res.status(502).json(json_response);
        } else if (typeof(results[0])=='undefined') {
            json_response.success = false;
            json_response.message = "No fight found";
            res.status(404).json(json_response);
        } else {
            json_response.success = true;
            json_response.message = "";
            json_response.data=results;
            // console.log(results);
            res.status(200).json(json_response);
        }


    })


});

router.get('/:id', (req, res) => {
    let id = req.params['id'];
    let json_response = json_response_model(); //returns a new object
    if(!isNaN(id)){
    let query = "SELECT * FROM schedule WHERE schedule_id=?";
    connection.query(query,id,(error, results,field) => {
        if (error) {
            json_response.success = false;
            json_response.message = "Internal server error";
            console.log(error);
            logger.log(error);
            res.status(502).json(json_response);
        } else if (typeof(results[0])=='undefined') {
            json_response.success = false;
            json_response.message = "No fight found";
            res.status(404).json(json_response);
        } else {
            json_response.success = true;
            json_response.message = "";
            json_response.data=results;
            // console.log(typeof(results[0]));    
            res.status(200).json(json_response);
        }
    })
    }else{
        json_response.success = false;
        json_response.message = "Bad request";
        res.status(400).json(json_response);
    }
    });
module.exports = router;