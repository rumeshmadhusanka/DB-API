let json_response_model = require('../../json_response');  //A function that returns the json response format object
const router = require("express").Router();
const Airport = require('../../models/airport');
// const Joi_schema = require('../../validation/airport_schema');


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
    try {
        //validation required
        let airport_req={location_id:req.body.location_id,
                    name:req.body.name,
                    code:req.body.code,
        }
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



module.exports = router;