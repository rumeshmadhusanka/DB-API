let json_response_model = require('../../json_response');
const router = require("express").Router();
let Passenger = require("../../classes/Passenger");

router.get('/:id', (req, res) => {
    let p = new Passenger();
    console.log(p);
    res.json(JSON.stringify(p));
});

module.exports = router;

