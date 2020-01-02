const poolPromise = require("../db");
const ErrorHandler = require('../error');
const logger = require('../logger');

function Route() {
}

Route.prototype.getAllRoutes = async function () {
    let query = "SELECT route_id,a.origin,b.destination from (SELECT route.route_id,airport.name as origin FROM `route` LEFT OUTER JOIN `airport`on route.origin=airport.airport_id)a NATURAL JOIN (SELECT route.route_id,airport.name as destination FROM `route` LEFT OUTER JOIN `airport`on route.destination=airport.airport_id)b";
    return new Promise(async (resolve, reject) => {
        try {
            let pool = await poolPromise;
            let result = await pool.query(query);
            if (!result.length) {
                reject(new ErrorHandler(404, "No Route found"));
            } else {
                resolve(result);
            }
        } catch (e) {
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }
    });
}
Route.prototype.addroute = async function (route_req) {
    let query = "INSERT INTO `route` (`origin`, `destination`) VALUES (?,?);";
    return new Promise(async (resolve, reject) => {
        try {
            let pool = await poolPromise;
            let result = await pool.query(query, [route_req.origin, route_req.destination]);
            resolve(result);
        } catch (e) {
            if (e.sqlState == 45000) {
                reject(new ErrorHandler(400, "Route already added"));
            } else if (e.sqlState == 23000) {
                reject(new ErrorHandler(404, "No origine airport or destination airport found"));
            } else {
                logger.log(e);
                // console.log(e);
                reject(new ErrorHandler(502, "Internal Server Error"));
            }
        }
    });
}
Route.prototype.getroutetbyid = async function (route_id) {
    let query = "SELECT route_id,a.origin,b.destination from (SELECT route.route_id,airport.name as origin FROM `route` LEFT OUTER JOIN `airport`on route.origin=airport.airport_id)a NATURAL JOIN (SELECT route.route_id,airport.name as destination FROM `route` LEFT OUTER JOIN `airport`on route.destination=airport.airport_id)b where route_id=?";
    return new Promise(async (resolve, reject) => {
        try {
            let pool = await poolPromise;
            let result = await pool.query(query, [route_id]);
            if (!result.length) {
                reject(new ErrorHandler(404, "No route found"));
            } else {
                resolve(result);
            }
        } catch (e) {
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }
    });
}
Route.prototype.updateroute = async function (route_req) {
    let query = "update `route` set origin=?,destination=? where route_id=?";
    return new Promise(async (resolve, reject) => {
        try {
            let pool = await poolPromise;
            let result = await pool.query(query, [route_req.origin, route_req.destination, route_req.route_id]);
            // console.log(result.changedRows);
            if (result.changedRows == 0 && result.affectedRows == 1) {
                reject(new ErrorHandler(200, "Route already updated"));
            } else if (result.changedRows == 0 && result.affectedRows == 0) {
                reject(new ErrorHandler(404, "No route found"));
            } else {
                resolve(result);
            }
        } catch (e) {
            console.log(e);
            if (e.code == "ER_DUP_ENTRY") {
                reject(new ErrorHandler(400, "That route already exites con't upadate"));
            } else if (e.sqlState == 23000) {
                reject(new ErrorHandler(404, "No origin airport or destination airport found"));
            } else {
                logger.log(e);
                // console.log(e);
                reject(new ErrorHandler(502, "Internal Server Error"));
            }
        }
    });
}
Route.prototype.deleteroute = async function (route_id) {
    let delete_query = "DELETE FROM route WHERE route_id=?";
    return new Promise(async (resolve, reject) => {
        try {
            let pool = await poolPromise;
            let result = await pool.query(delete_query, [route_id]);
            if (result.affectedRows == 0) {
                reject(new ErrorHandler(404, "Route not found"));
            } else if (result.affectedRows == 1) {
                resolve(result);
            }
        } catch (e) {
            if (e.sqlState == 23000) {
                reject(new ErrorHandler(400, "Route can not delete"));
            } else {
                logger.log(e);
                // console.log(e);
                reject(new ErrorHandler(502, "Internal Server Error"));
            }
        }
    });
};
module.exports = Route;

// SELECT d.flight_id,d.origin,d.destination,e.model_name FROM (SELECT flight_id,origin,destination,airplane_id from (SELECT route_id,a.origin,b.destination from (SELECT route.route_id,airport.name as origin FROM `route` LEFT OUTER JOIN `airport`on route.origin=airport.airport_id)a NATURAL JOIN (SELECT route.route_id,airport.name as destination FROM `route` LEFT OUTER JOIN `airport`on route.destination=airport.airport_id)b)c NATURAL join flight)d natural JOIN (SELECT `airplane_id`,model_name FROM `airplane` NATURAL JOIN airplane_model)e

// SELECT `schedule_id`,`date`,origin,destination,model_name,`dep_time`,`arival_time`,gate.name FROM(SELECT `schedule_id`,`date`,origin,destination,model_name,`dep_time`,`arival_time` FROM `schedule` NATURAL JOIN flight_details)ab NATURAL JOIN gate