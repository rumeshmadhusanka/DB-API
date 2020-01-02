let json_response_model = require('../../json_response');  //A function that returns the json response format object
const router = require("express").Router();
const Airplane_model = require('../../models/airplane_model');
const Joi_schema = require('../../validation/airplane_model_schema');
const auth = require('../../middleware/auth');

router.get('/', auth.verifyUser, auth.isAdmin, async (req, res) => {
    let airplane_model_obj = new Airplane_model();
    let json_response = json_response_model();
    try {
        json_response.data = await airplane_model_obj.getallairplanemodel();
        json_response.success = true;
        res.status(200).json(json_response);
    } catch (e) {
        json_response.message = e;
        let code = e.statusCode || 502;
        res.status(code).json(json_response);
    }
});
router.post('/', auth.verifyUser, auth.isAdmin, async (req, res) => {
    let airplane_model_obj = new Airplane_model();
    let json_response = json_response_model();
    let airplane_model_req = {
        model_id: req.body.model_id,
        model_name: req.body.model_name,
    };
    try {
        await Joi_schema.airplane_model_post.validateAsync(airplane_model_req);
        json_response.data = await airplane_model_obj.addairplanemodel(airplane_model_req);
        json_response.success = true;
        json_response.message = "Model successfully added";
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
router.delete('/:model_id', auth.verifyUser, auth.isAdmin, async (req, res) => {
    let model_id = req.params['model_id'];
    let airplane_model_obj = new Airplane_model();
    let json_response = json_response_model();
    try {
        await Joi_schema.airplane_model_id_check.validateAsync({model_id});
        json_response.data = await airplane_model_obj.deleteairplanemodel(model_id);
        json_response.success = true;
        json_response.message = "Airplane model was deleted!!";
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