const poolPromise = require("../db");
const ErrorHandler = require('../error');
const logger = require('../logger');

function Schedule() {

}

Schedule.prototype.getAllSchedules = async function () {
    let query = "SELECT schedule.schedule_id,schedule.date, schedule.flight_id, route.route_id, ori.name as origin,des.name as destination, airplane.airplane_id as airplane_id ,airplane_model.model_name as airplane_model,schedule.dep_time, schedule.arival_time as arrival_time, gate.name as gate_name from schedule inner join flight  on schedule.flight_id = flight.flight_id inner join airplane  on airplane.airplane_id = flight.airplane_id inner join airplane_model  on airplane_model.model_id = airplane.model_id inner join route on route.route_id = flight.route_id inner join gate  on schedule.gate_id = gate.gate_id inner join airport ori on ori.airport_id = route.origin inner join airport des on des.airport_id  = route.destination";
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

Schedule.prototype.getRestrictedSchedule = async function (origin, destination, from_date, to_date) {


};


module.exports = Schedule;