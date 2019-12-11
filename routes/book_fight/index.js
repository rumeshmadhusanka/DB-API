//number of books>5 frequent customer and number of books>10 gold customer 
//check git
let json_response_model = require('../../json_response');  //A function that returns the json response format object
const router = require("express").Router();
const path = require('path');
const connection = require("../../db");
const logger = require("../../logger");
const book_fight = require('../../models/book_fight');

router.get('/', async(req, res) => {
    let book_fight_obj = new book_fight();
    let json_response = json_response_model();
    try {
        let results = await book_fight_obj.getallfights();
        json_response.data=results;
        json_response.success = true;
        res.status(200).json(json_response);
    } catch (e) {
        json_response.message = e;
        let code = e.statusCode || 502;
        res.status(code).json(json_response);
    }

});

router.get('/:id', async(req, res) => {
    let schedule_id= req.params['id'];
    let book_fight_obj = new book_fight();
    let json_response = json_response_model();
    const {user_id,seat_id, anotherField} = req.query;
    if(user_id==null && seat_id==null){
        try {
            let results = await book_fight_obj.getfightsbyid(schedule_id);;
            json_response.data.push(results[0]);
            json_response.success = true;
            res.status(200).json(json_response);
        } catch (e) {
            json_response.message = e;
            let code = e.statusCode || 502;
            res.status(code).json(json_response);
        }
    }else{
        try {
            let results = await book_fight_obj.getpriceseat(user_id,seat_id);
            let result={}
            result["total_price"]=results[0][Object.keys(results[0])[0]];
            json_response.data=(result);
            json_response.success = true;
            json_response.message = "Seat cost sent";
            res.status(200).json(json_response);
        } catch (e) {
            json_response.message = e;
            let code = e.statusCode || 502;
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

router.post('/:id',async(req,res)=>{
    let schedule_id=req.params['id'];
    // let schedule_id=req.body.schedule_id;
    let seat_id=req.body.seat_id;
    let user_id=req.body.user_id; 
    let json_response=json_response_model();
    let book_fight_obj = new book_fight();
    try {
        let results = await book_fight_obj.postbookfight(schedule_id, seat_id,user_id);
        json_response.data.push(results[0]);
        json_response.success = true;
        json_response.message = "Successfully booked ";
        res.status(201).json(json_response);
    } catch (e) {
        json_response.message = e;
        let code = e.statusCode || 502;
        res.status(code).json(json_response);
    }
});

router.delete('/:schedule_id',async(req,res)=>{
    let schedule_id=req.params['schedule_id'];
    // let schedule_id=req.body.schedule_id;
    let user_id=req.query.user_id;
    let json_response=json_response_model();
    let book_fight_obj = new book_fight();
    try {
        let results = await book_fight_obj.deletebooked(schedule_id,user_id);
        json_response.data.push(results[0]);
        json_response.success = true;
        json_response.message = "Successfully delet booked ";
        res.status(200).json(json_response);
    } catch (e) {
        json_response.message = e;
        let code = e.statusCode || 502;
        res.status(code).json(json_response);
    }
});
router.put('/',async(req,res)=>{
    res.status(502).json("Api not support");
});
module.exports = router;