const router = require("express").Router();
// const connection = require("../../db");

router.get('/:id', (req, res) => {
    let id = req.params['id'];
    res.status(200).json({
        "id": id,
        "first_name": "John",
        "last_name": "McCathy",
        "email": "jhon@gmail.com"
    });
});


module.exports = router;

