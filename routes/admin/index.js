let json_response_model = require('../../json_response');  //A function that returns the json response format object
const router = require("express").Router();
const path = require('path');
const Admin = require('../../models/admin');
const jwt = require('jsonwebtoken');
const fs = require('fs');
const config = JSON.parse(fs.readFileSync(path.resolve(__dirname, '../../env.config.json'), 'utf8'));

router.post('/login', async (req, res) => {
    let email = req.body.email;
    let password = req.body.password;
    let admin = new Admin();
    let json_response = json_response_model();
    try {
        let results = await admin.login(email, password);
        json_response.success = true;
        let send_results = results[0];
        let admin_id = send_results["admin_id"];
        //console.log(send_results);
        //console.log();
        json_response.message = "Login Success";
        let token = jwt.sign({"admin_id": admin_id}, config.secret, config.options);
        res.header('x-access-token', token).status(200).json(json_response);
    } catch (e) {
        console.log(e);
        json_response.message = e;
        let code = e.statusCode || 502;
        if (e._message == null && e.details[0].message) {
            code = 400;
            json_response.data =
                json_response.message = e.details[0].message;
            res.status(code).json(json_response);
        } else {

            res.status(code).json(json_response);
        }
        res.status(502).send();
    }
});


module.exports = router;