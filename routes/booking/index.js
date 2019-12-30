let json_response_model = require('../../json_response');  //A function that returns the json response format object
const router = require("express").Router();
const Booking = require('../../models/booking');
const Joi_schema = require('../../validation/booking_schema');

router.get('/', async (req, res) => {
    let boooking_obj = new Booking();
    let json_response = json_response_model();
    try {
        json_response.data = await boooking_obj.getallbookings();
        json_response.success = true;
        res.status(200).json(json_response);
    } catch (e) {
        json_response.message = e;
        let code = e.statusCode || 502;
        res.status(code).json(json_response);
    }
});
router.get('/:schedule_id',async(req,res)=>{  
    let booking_obj = new Booking(); 
    let schedule_id=req.params["schedule_id"];
    let json_response=json_response_model();
    try {
        await Joi_schema.schedule_id_check.validateAsync({schedule_id});
        json_response.data= await booking_obj.getbookingbyschedule(schedule_id);
        json_response.success = true;
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
router.get('/:schedule_id/:user_id', async (req, res) => {
    let schedule_id=req.params["schedule_id"];
    let user_id=req.params["user_id"];
    let boooking_obj = new Booking();
    let json_response = json_response_model();
    try {
        await Joi_schema.schedule_user_id_check.validateAsync({schedule_id,user_id});
        json_response.data = await boooking_obj.getbookingbyShecduleUser(schedule_id,user_id);
        json_response.success = true;
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
module.exports = router;