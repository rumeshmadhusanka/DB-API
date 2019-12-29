const poolPromise = require("../db");
const ErrorHandler = require('../error');
const logger = require('../logger');

function Schedule() {

}

Schedule.prototype.getAllSchedules = async function () {
    let query = "call get_all_schedules()";
    return new Promise(async (resolve, reject) => {
        try {
            let pool = await poolPromise;
            let result = await pool.query(query);
            if (!result.length) {
                reject(new ErrorHandler(404, "No airplane found"));
            } else {
                resolve(result);
            }
        } catch (e) {
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }
    });

};

Schedule.prototype.getRestrictedSchedules = async function (origin, destination, from_date, to_date) {
    let query = "call get_schedules_filtered(?,?,?,?)";
    return new Promise(async (resolve, reject) => {
        try {
            let pool = await poolPromise;
            let result = await pool.query(query, [origin, destination, from_date, to_date]);
            result = result[0];
            if (!result.length) {
                reject(new ErrorHandler(404, "No matching schedules found"));
            } else {
                resolve(result);
            }
        } catch (e) {
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }
    });

};


module.exports = Schedule;