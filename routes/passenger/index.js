let json_response_model = require('../../json_response');  //A function returns an object
const router = require("express").Router();
let passenger = require("../../classes/Passenger");

router.get('/:id', (req, res) => {
    let p = passenger();
    let resp = json_response_model(); //returns a new object
    resp.data.push(p);
    res.json(resp);
});

module.exports = router;

