let json_response_model = require('../../json_response');  //A function that returns the json response format object
const router = require("express").Router();
const Airplane = require('../../models/airplane');
const Joi_schema = require('../../validation/airplane_schema');
const auth = require('../../middleware/auth');

router.get('/', auth.verifyUser, auth.isAdmin, async (req, res) => {
    let airplane_obj = new Airplane();
    let json_response = json_response_model();
    try {
        json_response.data = await airplane_obj.getallairplane();
        json_response.success = true;
        res.status(200).json(json_response);
    } catch (e) {
        json_response.message = e;
        let code = e.statusCode || 502;
        res.status(code).json(json_response);
    }
});
router.post('/', auth.verifyUser, auth.isAdmin, async (req, res) => {
    let airplane_obj = new Airplane();
    let json_response = json_response_model();
    let airplane_req = {
        model_id: req.body.model_id,
    };
    try {
        await Joi_schema.airplane_post.validateAsync(airplane_req);
        json_response.data = await airplane_obj.addairplane(airplane_req);
        json_response.success = true;
        json_response.message = "Airplane successfully added";
        res.status(201).json(json_response);
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
router.delete('/:airplane_id', auth.verifyUser, auth.isAdmin, async (req, res) => {
    let airplane_id = req.params['airplane_id'];
    let airplane_obj = new Airplane();
    let json_response = json_response_model();
    try {
        await Joi_schema.airplane_id_check.validateAsync({airplane_id});
        json_response.data = await airplane_obj.deleteairplane(airplane_id);
        json_response.success = true;
        json_response.message = "Airplane was deleted!!";
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