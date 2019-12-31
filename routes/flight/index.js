let json_response_model = require('../../json_response');  //A function that returns the json response format object
const router = require("express").Router();
const Flight = require('../../models/flight');
const Joi_schema = require('../../validation/flight_schema');
const auth = require('../../middleware/auth');

router.get('/', async (req, res) => {
    let flight_obj = new Flight();
    let json_response = json_response_model();
    try {
        json_response.data = await flight_obj.getallflight();
        json_response.success = true;
        res.status(200).json(json_response);
    } catch (e) {
        json_response.message = e;
        let code = e.statusCode || 502;
        res.status(code).json(json_response);
    }

});
router.post('/',async(req,res)=>{
    let flight_obj = new Flight();
    let json_response = json_response_model();
    let flight_req={
        route_id:req.body.route_id,
        airplane_id:req.body.airplane_id, 
    };
    try {
        await Joi_schema.flight_post.validateAsync(flight_req);
        json_response.data=await flight_obj.addflight(flight_req);
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
router.get('/:flight_id',async(req,res)=>{
    let flight_obj = new Flight(); 
    let flight_id=req.params["flight_id"];
    let json_response=json_response_model();
    try {
        await Joi_schema.flight_id_check.validateAsync({flight_id});
        json_response.data= await flight_obj.getflightbyid(flight_id);
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
router.put('/:flight_id',async(req,res)=>{
    let flight_obj = new Flight();
    let json_response = json_response_model();
    let flight_req={
        flight_id:parseInt(req.params["flight_id"],10),
        route_id:req.body.route_id,
        airplane_id:req.body.airplane_id, 
    };
    try {
        await Joi_schema.flight_put.validateAsync(flight_req);
        json_response.data=await flight_obj.updateflight(flight_req);
        json_response.success = true;
        json_response.message = "Updated successfully";
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
router.delete('/:flight_id',async(req,res)=>{
    let flight_id=req.params['flight_id'];
    let flight_obj=new Flight();
    let json_response = json_response_model();
    try {
        await Joi_schema.flight_id_check.validateAsync({flight_id});
        json_response.data=await flight_obj.deleteflight(flight_id);
        json_response.success=true;
        json_response.message="Flight was deleted!!";
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