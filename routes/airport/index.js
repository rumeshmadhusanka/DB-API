let json_response_model = require('../../json_response');  //A function that returns the json response format object
const router = require("express").Router();
const Airport = require('../../models/airport');
const Joi_schema = require('../../validation/airport_schema');


router.get('/', async (req, res) => {
    let airport_obj = new Airport();
    let json_response = json_response_model();
    try {
        json_response.data = await airport_obj.getallairport();
        json_response.success = true;
        res.status(200).json(json_response);
    } catch (e) {
        json_response.message = e;
        let code = e.statusCode || 502;
        res.status(code).json(json_response);
    }

});
router.post('/',async(req,res)=>{
    let airport_obj = new Airport();
    let json_response = json_response_model();
    let airport_req={location_id:req.body.location_id,
        name:req.body.name,
        code:req.body.code,
    };
    try {
        //validation required
        await Joi_schema.airport_post.validateAsync(airport_req);
        json_response.data=await airport_obj.addairport(airport_req);
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
router.get('/:airport_id',async(req,res)=>{
    let airport_obj = new Airport(); 
    let airport_id=req.params["airport_id"];
    let json_response=json_response_model();
    try {
        await Joi_schema.airport_id_check.validateAsync({airport_id});
        json_response.data= await airport_obj.getairportbyid(airport_id);
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
router.put('/:airport_id',async(req,res)=>{
    let airport_obj = new Airport();
    let json_response = json_response_model();
    let airport_req={
        airport_id:req.params['airport_id'],
        location_id:req.body.location_id,
        name:req.body.name,
        code:req.body.code,
    };
    try {
        await Joi_schema.airport_id_check.validateAsync({airport_id});
        json_response.data=await airport_obj.updateairport(airport_req);
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
router.delete('/:airport_id',async(req,res)=>{
    let airport_id=req.params['airport_id'];
    let airport_obj=new Airport();
    let json_response = json_response_model();
    try {
        await Joi_schema.airport_id_check.validateAsync({airport_id});
        json_response.data=await airport_obj.deleteairport(airport_id);
        json_response.success=true;
        json_response.message="Airport was deleted!!";
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