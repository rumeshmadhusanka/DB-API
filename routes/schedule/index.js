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


router.post('/', async (req, res) => {
    let airplane_obj = new Schedule();
    let json_response = json_response_model();
    let schedule_req = {

        date: req.body.date,
        flight_id: req.body.flight_id,
        dep_time: req.body.dep_time,
        arrival_time: req.body.arrival_time,
        gate_id: req.body.gate_id
    };
    try {
        // await Joi_schema.airplane_post.validateAsync(airplane_req); todo add validation
        await airplane_obj.createNewSchedule(schedule_req.date,
            schedule_req.flight_id, schedule_req.dep_time,
            schedule_req.arrival_time, schedule_req.gate_id);
        json_response.success = true;
        json_response.message = "Schedule successfully added";
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
    }
});

router.put('/:schedule_id', async (req, res) => {
    let airplane_obj = new Schedule();
    let json_response = json_response_model();
    let schedule_id = req.params.schedule_id;
    let schedule_req = {
        date: req.body.date,
        flight_id: req.body.flight_id,
        dep_time: req.body.dep_time,
        arrival_time: req.body.arrival_time,
        gate_id: req.body.gate_id,
        schedule_id: schedule_id
    };
    try {
        // await Joi_schema.airplane_post.validateAsync(airplane_req); todo add validation
        await airplane_obj.updateSchedule(schedule_req.date,
            schedule_req.flight_id, schedule_req.dep_time,
            schedule_req.arrival_time, schedule_req.gate_id, schedule_id);
        json_response.success = true;
        json_response.message = "Schedule successfully updated";
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
    }
});


module.exports = router;