const poolPromise = require("../db");
const ErrorHandler = require('../error');
const logger = require('../logger');
const bcrypt = require('bcryptjs');

function Admin() {

}

Admin.prototype.login = async function (email, password) {
    let query = "select * from admin where email = ?";
    // let hashedPassword = bcrypt.hashSync(password, 10);
    // console.log(hashedPassword);
    return new Promise((async (resolve, reject) => {
        try {
            let pool = await poolPromise;
            let result = await pool.query(query, [email]);
            //console.log(email, hashedPassword);
            console.log(result);
            if (!result.length) {
                reject(new ErrorHandler(404, "Invalid credentials"));
            } else {
                let hashedPassword = result[0].password;
                //console.log(hashedPassword,password);
                let isPasswordValid = bcrypt.compareSync(password, hashedPassword);

                if (!isPasswordValid) {
                    reject(new ErrorHandler(400, "Password Mismatch"));
                } else {
                    resolve(result);
                }
            }
        } catch (e) {
            console.log(e);
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }
    }));
};


module.exports = Admin;