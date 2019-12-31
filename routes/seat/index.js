let json_response_model = require('../../json_response');  //A function that returns the json response format object
const router = require("express").Router();
const Seat = require('../../models/seat');
const Joi_schema = require('../../validation/seat_schema');
const auth = require('../../middleware/auth');

router.get('/',async(req,res)=>{
    let seat_obj = new Seat(); 
    const {schedule_id, anotherField} = req.query;
    // let model_id=req.params["model_id"];
    let json_response=json_response_model();
    try {
        await Joi_schema.schedule_id_check.validateAsync({schedule_id});
        json_response.data= await seat_obj.getseatbyid(schedule_id);
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
router.get('/free', async (req, res) => {
    let seat_obj = new Seat();
    let schedule_id = req.query["schedule_id"];
    let json_response = json_response_model();
    try {
        await Joi_schema.schedule_id_check.validateAsync({schedule_id});
        json_response.data = await seat_obj.getfreeseatbyid(schedule_id);
        json_response.success = true;
        res.status(200).json(json_response);
    } catch (e) {
        json_response.message = e;
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
router.post('/:model_id',async(req,res)=>{
    let seat_obj = new Seat();
    let json_response = json_response_model();
    let seat_req={
        model_id:req.body.model_id,
        seat_name:req.body.seat_name,
        class:req.body.class,
    };
    try {
        await Joi_schema.seat_post.validateAsync(seat_req);
        json_response.data=await seat_obj.addseat(seat_req);
        json_response.success = true;
        json_response.message = "Successfully added";
        res.status(201).json(json_response);
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
router.delete('/:model_id',async(req,res)=>{
    let model_id=req.params['model_id'];
    let seat_obj=new Seat();
    let json_response = json_response_model();
    try {
        await Joi_schema.model_id_check.validateAsync({model_id});
        json_response.data=await seat_obj.deleteseat(model_id);
        json_response.success=true;
        json_response.message="Seat was deleted!!";
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