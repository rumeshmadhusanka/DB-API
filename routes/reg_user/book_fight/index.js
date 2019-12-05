let json_response_model = require('../../../json_response');  //A function that returns the json response format object
const router = require("express").Router();
const path = require('path');
const connection = require("../../../db");
const logger = require("../../../logger");

router.get('/all', (req, res) => {
    // let id = req.params['id'];
    let query = "SELECT * from schedule WHERE `date`> CURDATE()";
    connection.query(query,(error, results) => {
        let json_response = json_response_model(); //returns a new object
        if (error) {
            json_response.success = false;
            json_response.message = "Internal server error";
            console.log(error);
            logger.log(error);
            res.status(502).json(json_response);
        } else if (results == null) {
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

module.exports = router;