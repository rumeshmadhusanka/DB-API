const poolPromise = require("../db");
const ErrorHandler = require('../error');
const logger = require('../logger');

function Gate() {
}

Gate.prototype.getallgate = async function () {
    let query = "SELECT * FROM `gate`";
    return new Promise(async (resolve, reject) => {
        try {
            let pool = await poolPromise;
            let result = await pool.query(query);
            if (!result.length) {
                reject(new ErrorHandler(404, "No gate found"));
            } else {
                resolve(result);
            }
        } catch (e) {
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }
    });
}
Gate.prototype.addgate = async function (gate_req) {
    let query = "INSERT INTO `gate` (`airport_id`, `name`) VALUES (?,?)";
    return new Promise(async (resolve, reject) => {
        try {
            let pool = await poolPromise;
            let result = await pool.query(query, [gate_req.airport_id, gate_req.name]);
            resolve(result);
        } catch (e) {
            if (e.sqlState == 45000) {
                reject(new ErrorHandler(400, "Gate already added"));
            } else if (e.sqlState == 23000) {
                reject(new ErrorHandler(404, "No airportn_id found"));
            } else {
                logger.log(e);
                // console.log(e);
                reject(new ErrorHandler(502, "Internal Server Error"));
            }
        }
    });
}
Gate.prototype.getgatebyid = async function (gate_id) {
    let query = "select * from gate where gate_id=?";
    return new Promise(async (resolve, reject) => {
        try {
            let pool = await poolPromise;
            let result = await pool.query(query, [gate_id]);
            if (!result.length) {
                reject(new ErrorHandler(404, "No gate found"));
            } else {
                resolve(result);
            }
        } catch (e) {
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }
    });
}
Gate.prototype.getflightbyid = async function (flight_id) {
    let query = "call get_gate_id_for_given_flight_id(?)";
    return new Promise(async (resolve, reject) => {
        try {
            let pool = await poolPromise;
            let result = await pool.query(query, [flight_id]);
            // console.log(result[0])
            if (!result[0].length) {
                reject(new ErrorHandler(404, "No gate found"));
            } else {
                resolve(result[0]);
            }
        } catch (e) {
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }
    });
}
Gate.prototype.updategate = async function (gate_req) {
    let query = "update `gate` set airport_id=?,name=? where gate_id=?";
    return new Promise(async (resolve, reject) => {
        try {
            let pool = await poolPromise;
            let result = await pool.query(query, [gate_req.airport_id, gate_req.name, gate_req.gate_id]);
            console.log(result);
            if (result.changedRows == 0 && result.affectedRows == 1) {
                reject(new ErrorHandler(200, "Gate already updated"));
            } else if (result.changedRows == 0 && result.affectedRows == 0) {
                reject(new ErrorHandler(404, "No gate found"));
            } else {
                resolve(result);
            }
        } catch (e) {
            if (e.code == "ER_DUP_ENTRY") {
                reject(new ErrorHandler(400, "That gate already exites con't upadate"));
            } else if (e.sqlState == 23000) {
                reject(new ErrorHandler(404, "No airport_id found"));
            } else {
                logger.log(e);
                // console.log(e);
                reject(new ErrorHandler(502, "Internal Server Error"));
            }
        }
    });
}
Gate.prototype.deletegate = async function (gate_id) {
    let delete_query = "DELETE FROM gate WHERE gate_id=?";
    return new Promise(async (resolve, reject) => {
        try {
            let pool = await poolPromise;
            let result = await pool.query(delete_query, [gate_id]);
            if (result.affectedRows == 0) {
                reject(new ErrorHandler(404, "Gate not found"));
            } else if (result.affectedRows == 1) {
                resolve(result);
            }
        } catch (e) {
            if (e.sqlState == 23000) {
                reject(new ErrorHandler(400, "Gate can not delete"));
            } else {
                logger.log(e);
                // console.log(e);
                reject(new ErrorHandler(502, "Internal Server Error"));
            }
        }
    });
};
module.exports = Gate;