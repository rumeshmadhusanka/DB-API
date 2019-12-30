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
            result = result[0];
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

Schedule.prototype.createNewSchedule = async function (date, flight_id, dep_time, arrival_time, gate_id) {
    let query = "INSERT INTO  schedule(date, flight_id, dep_time, arival_time, gate_id) values(?,?,?,?,?)";
    return new Promise(async (resolve, reject) => {
        try {
            let pool = await poolPromise;
            let result = await pool.query(query, [date, flight_id, dep_time, arrival_time, gate_id]);
            resolve(result);
        } catch (e) {
            if (e.sqlState === 23000) {
                reject(new ErrorHandler(404, "Invalid arguments"));
            } else {
                logger.log(e);
                console.log(e);
                reject(new ErrorHandler(502, "Internal Server Error"));
            }
        }
    });

};

Schedule.prototype.updateSchedule = async function (date, flight_id, dep_time, arrival_time, gate_id, schedule_id) {
    //console.log(date, flight_id, dep_time, arrival_time, gate_id,schedule_id);
    let query = "Update schedule set date =?, flight_id=?, dep_time=?, arival_time=?,gate_id = ? where schedule_id=?";
    return new Promise(async (resolve, reject) => {
        try {
            let pool = await poolPromise;
            let result = await pool.query(query, [date, flight_id, dep_time, arrival_time, gate_id, schedule_id]);
            resolve(result);
        } catch (e) {
            if (e.sqlState === 23000) {
                reject(new ErrorHandler(404, "Invalid arguments"));
            } else {
                logger.log(e);
                console.log(e);
                reject(new ErrorHandler(502, "Internal Server Error"));
            }
        }
    });

};


module.exports = Schedule;