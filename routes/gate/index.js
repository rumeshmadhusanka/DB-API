let json_response_model = require('../../json_response');  //A function that returns the json response format object
const router = require("express").Router();
const Gate = require('../../models/gate');
const Joi_schema = require('../../validation/gate_schema');
const auth = require('../../middleware/auth');

router.get('/', async (req, res) => {
    let gate_obj = new Gate();
    let json_response = json_response_model();
    try {
        json_response.data = await gate_obj.getallgate();
        json_response.success = true;
        res.status(200).json(json_response);
    } catch (e) {
        json_response.message = e;
        let code = e.statusCode || 502;
        res.status(code).json(json_response);
    }

});
router.post('/',async(req,res)=>{
    let gate_obj = new Gate();
    let json_response = json_response_model();
    let gate_req={
        airport_id:req.body.airport_id,
        name:req.body.name,
    };
    try {
        await Joi_schema.gate_post.validateAsync(gate_req);
        json_response.data=await gate_obj.addgate(gate_req);
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
router.get('/:gate_id',async(req,res)=>{
    let gate_obj = new Gate(); 
    let gate_id=req.params["gate_id"];
    let json_response=json_response_model();
    try {
        await Joi_schema.gate_id_check.validateAsync({gate_id});
        json_response.data= await gate_obj.getgatebyid(gate_id);
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
router.put('/:gate_id',async(req,res)=>{ 
    let gate_obj = new Gate();
    let json_response = json_response_model();
    let gate_req={
        gate_id:parseInt(req.params['gate_id'],10),
        airport_id:req.body.airport_id,
        name:req.body.name,
    };
    try {
        await Joi_schema.gate_put.validateAsync(gate_req);
        json_response.data=await gate_obj.updategate(gate_req);
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
router.delete('/:gate_id',async(req,res)=>{
    let gate_id=req.params['gate_id'];
    let gate_obj=new Gate();
    let json_response = json_response_model();
    try {
        await Joi_schema.gate_id_check.validateAsync({gate_id});
        json_response.data=await gate_obj.deletegate(gate_id);
        json_response.success=true;
        json_response.message="Gate was deleted!!";
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