let json_response_model = require('../../json_response');  //A function that returns the json response format object
const router = require("express").Router();
const Discount = require('../../models/discount');
const Joi_schema = require('../../validation/discount_schema');
const auth = require('../../middleware/auth');

router.get('/:user_id', async (req, res) => {
    let discount_obj = new Discount();
    let user_id = req.params["user_id"];
    let json_response = json_response_model();
    try {
        await Joi_schema.user_id_check.validateAsync({user_id});
        json_response.data = await discount_obj.getdiscountbyid(user_id);
        json_response.success = true;
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