let json_response_model = require('../../json_response');  //A function that returns the json response format object
const router = require("express").Router();
const Route = require('../../models/route');
const Joi_schema = require('../../validation/route_schema');
const auth = require('../../middleware/auth');

router.get('/', async (req, res) => {
    let route_obj = new Route();
    let json_response = json_response_model();
    try {
        json_response.data = await route_obj.getAllRoutes();
        json_response.success = true;
        res.status(200).json(json_response);
    } catch (e) {
        json_response.message = e;
        let code = e.statusCode || 502;
        res.status(code).json(json_response);
    }

});
router.post('/', async (req, res) => {
    let route_obj = new Route();
    let json_response = json_response_model();
    let route_req = {
        origin: req.body.origin,
        destination: req.body.destination,
    };
    try {
        await Joi_schema.route_post.validateAsync(route_req);
        json_response.data = await route_obj.addroute(route_req);
        json_response.success = true;
        json_response.message = "Successfully added";
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
router.get('/:route_id', async (req, res) => {
    let route_obj = new Route();
    let route_id = req.params["route_id"];
    let json_response = json_response_model();
    try {
        await Joi_schema.route_id_check.validateAsync({route_id});
        json_response.data = await route_obj.getroutetbyid(route_id);
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
router.put('/:route_id', async (req, res) => {
    let route_obj = new Route();
    let json_response = json_response_model();
    let route_req = {
        route_id: parseInt(req.params['route_id'], 10),
        origin: req.body.origin,
        destination: req.body.destination,
    };
    try {
        await Joi_schema.route_put.validateAsync(route_req);
        json_response.data = await route_obj.updateroute(route_req);
        json_response.success = true;
        json_response.message = "Updated successfully";
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
router.delete('/:route_id', async (req, res) => {
    let route_id = req.params['route_id'];
    let route_obj = new Route();
    let json_response = json_response_model();
    try {
        await Joi_schema.route_id_check.validateAsync({route_id});
        json_response.data = await route_obj.deleteroute(route_id);
        json_response.success = true;
        json_response.message = "Route was deleted!!";
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