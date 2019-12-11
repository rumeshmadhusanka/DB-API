const poolPromise = require("../db");
const ErrorHandler = require('../error');
const logger = require('../logger');

function RegUser() {

}

RegUser.prototype.getUserById = async function (user_id) {
    let query1 = "select * from user inner join registered_user using(user_id) where user.user_id = ?";
    return new Promise((async (resolve, reject) => {
        try {
            let pool = await poolPromise;
            let result = await pool.query(query1, [user_id]);
            if (!result.length) {
                reject(new ErrorHandler(404, "No user found for id: " + user_id));
            } else {
                resolve(result);
            }
        } catch (e) {
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }

    }));
};

RegUser.prototype.addUser = function (first_name,
                                      second_name,
                                      email,
                                      nic,
                                      passport_id,
                                      password,
                                      user_name) {


};

RegUser.prototype.bookFlight = function () {

};

RegUser.prototype.updateUser = function () {

};

RegUser.prototype.deleteUser = function () {

};

module.exports = RegUser;
