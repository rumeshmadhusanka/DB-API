let json_response_model = require('../../json_response');  //A function that returns the json response format object
const router = require("express").Router();
const Schedule = require('../../models/schedule');
//const Joi_schema = require('../../validation/schedule_schema'); //todo implement schema


router.get('/', async (req, res) => {
    let airplane_obj = new Schedule();
    let json_response = json_response_model();
    let origin = req.query.origin;
    let destination = req.query.destination;
    let from_date = req.query.from_date;
    let to_date = req.query.to_date;
    try {

        if (!origin && !destination && !from_date && !to_date) {
            json_response.data = await airplane_obj.getAllSchedules();
            json_response.success = true;
            res.status(200).json(json_response);
        } else {
            json_response.data = await airplane_obj.getRestrictedSchedules(origin, destination, from_date, to_date);
            json_response.success = true;
            res.status(200).json(json_response);
        }
    } catch (e) {
        json_response.message = e;
        let code = e.statusCode || 502;
        res.status(code).json(json_response);
    }
});

module.exports = router;