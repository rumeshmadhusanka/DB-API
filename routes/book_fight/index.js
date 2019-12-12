//number of books>5 frequent customer and number of books>10 gold customer 
//check git
let json_response_model = require('../../json_response');  //A function that returns the json response format object
const router = require("express").Router();
const Book_fight = require('../../models/book_fight');
const Joi_schema = require('../../validation/book_fight_schema');

router.get('/', async (req, res) => {
    let book_fight_obj = new Book_fight();
    let json_response = json_response_model();
    try {
        json_response.data = await book_fight_obj.getallfights();
        json_response.success = true;
        res.status(200).json(json_response);
    } catch (e) {
        json_response.message = e;
        let code = e.statusCode || 502;
        res.status(code).json(json_response);
    }

});

router.get('/:id', async (req, res) => {
    let schedule = {"id": req.params['id']};
    let book_fight_obj = new Book_fight();
    let json_response = json_response_model();
    const {user_id, seat_id, anotherField} = req.query;
    let query_string = {user_id, seat_id};
    if (query_string.user_id == null && query_string.seat_id == null) {
        try {
            await Joi_schema.id_schema.validateAsync(schedule);
            let results = await book_fight_obj.getfightsbyid(schedule.id);
            json_response.data.push(results[0]);
            json_response.success = true;
            res.status(200).json(json_response);
        } catch (e) {
            json_response.message = e.details[0].message || e;
            let code = e.statusCode || 502;
            if (e.details[0].message) {
                code = 400;
            }
            res.status(code).json(json_response);
        }
    } else {
        try {
            await Joi_schema.query_string.validateAsync(query_string);
            let results = await book_fight_obj.getpriceseat(user_id, seat_id);
            let result = {};
            result["total_price"] = results[0][Object.keys(results[0])[0]];
            json_response.data = (result);
            json_response.success = true;
            json_response.message = "Seat cost sent";
            res.status(200).json(json_response);
        } catch (e) {
            json_response.message = e.details[0].message || e;
            let code = e.statusCode || 502;
            if (e.details[0].message) {
                code = 400;
            }
            res.status(code).json(json_response);
        }
    }
});
// router.get('/cost',async(req,res)=>{
//     let schedule_id=req.params['id'];
//     // let schedule_id=req.body.schedule_id;
//     const {user_id,seat_id, anotherField} = req.query;
//     let json_response=json_response_model();
//     let book_fight_obj = new book_fight();
//     try {
//         let results = await book_fight_obj.getpriceseat(user_id,seat_id);
//         let result={}
//         result["total_price"]=results[0][Object.keys(results[0])[0]];
//         json_response.data=(result);
//         json_response.success = true;
//         json_response.message = "Seat cost sent";
//         res.status(200).json(json_response);
//     } catch (e) {
//         json_response.message = e;
//         let code = e.statusCode || 502;
//         res.status(code).json(json_response);
//     }
// });

router.post('/:schedule_id', async (req, res) => {
    let schedule_id = req.params['schedule_id'];
    // let schedule_id=req.body.schedule_id;
    let seat_id = req.body.seat_id;
    let user_id = req.body.user_id;
    let post_data = {schedule_id, seat_id, user_id};
    let json_response = json_response_model();
    let book_fight_obj = new Book_fight();
    try {
        await Joi_schema.booke_fight_post_schema.validateAsync(post_data);
        let results = await book_fight_obj.postbookfight(schedule_id, seat_id, user_id);
        json_response.data.push(results[0]);
        json_response.success = true;
        json_response.message = "Successfully booked";
        res.status(201).json(json_response);
    } catch (e) {
        json_response.message = e.details[0].message || e;
        let code = e.statusCode || 502;
        if (e.details[0].message) {
            code = 400;
        }
        res.status(code).json(json_response);
    }
});

router.delete('/:schedule_id', async (req, res) => {
    let schedule_id = req.params['schedule_id'];
    // let schedule_id=req.body.schedule_id;
    let user_id = req.query.user_id;
    let query_string_data = {schedule_id, user_id};
    let json_response = json_response_model();
    let book_fight_obj = new Book_fight();
    try {
        await Joi_schema.query_string_delete_req.validateAsync(query_string_data);
        let results = await book_fight_obj.deletebooked(schedule_id, user_id);
        json_response.data.push(results[0]);
        json_response.success = true;
        json_response.message = "Successfully deleted the booking ";
        res.status(200).json(json_response);
    } catch (e) {
        json_response.message = e.details[0].message || e;
        let code = e.statusCode || 502;
        if (e.details[0].message) {
            code = 400;
        }
        res.status(code).json(json_response);
    }
});
router.put('/', async (req, res) => {
    res.status(502).json("Not yet supported");
});
module.exports = router;