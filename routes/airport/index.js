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

router.put('/',async(req,res)=>{
    let airport_obj = new Airport();
    try {
        // json_response.data=await 
    } catch (error) {
        
    } 
});



module.exports = router;