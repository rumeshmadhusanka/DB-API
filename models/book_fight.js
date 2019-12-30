const poolPromise = require("../db");
const ErrorHandler = require('../error');
const logger = require('../logger');

function book_fight() {

}
book_fight.prototype.getallfights = async function () {
    let query1 = "SELECT `schedule_id`,`date`,origin,destination,model_name,`dep_time`,`arival_time`,gate.name FROM(SELECT `schedule_id`,`date`,origin,destination,model_name,`dep_time`,`arival_time`,gate_id FROM `schedule` NATURAL JOIN flight_details)ab NATURAL JOIN gate WHERE `date`> CURDATE()";
    return new Promise((async (resolve, reject) => {
        try {
            let pool = await poolPromise;
            let result = await pool.query(query1);
            if (!result.length) {
                reject(new ErrorHandler(404, "No fight found"));
            } else {
                resolve(result);
            }
        } catch (e) {
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }

    }));
};
book_fight.prototype.getfightsbyid = async function (schedule_id) {
    let query1 = "SELECT `schedule_id`,`date`,origin,destination,model_name,`dep_time`,`arival_time`,gate.name FROM(SELECT `schedule_id`,`date`,origin,destination,model_name,`dep_time`,`arival_time`,gate_id FROM `schedule` NATURAL JOIN flight_details)ab NATURAL JOIN gate where schedule_id=?";
    return new Promise((async (resolve, reject) => {
        try {
            let pool = await poolPromise;
            let result = await pool.query(query1,[schedule_id]);
            if (!result.length) {
                reject(new ErrorHandler(404, "No fight with found shechdule id "+schedule_id));
            } else {
                resolve(result);
            }
        } catch (e) {
            console.log(e);
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }

    }));
};
book_fight.prototype.postbookfight = async function (schedule_id, seat_id,user_id) {
    let query1 = "INSERT INTO `book` ( `date`, `schedule_id`, `seat_id`, `user_id`) VLUES (?,?,?,?)";
    return new Promise(async (resolve, reject) => {
        try {
            let pool = await poolPromise;
            var todaydate = new Date().toISOString().slice(0,10);
            let result = await pool.query(query1,[todaydate, schedule_id, seat_id,user_id]);
            resolve(result);
        } catch (e) {
            if(e.sqlState==45000){
                reject(new ErrorHandler(400, "Seat already booked"));
            }else{ 
                logger.log(e);
                reject(new ErrorHandler(502, "Internal Server Error"));
            }
        }
    });
};
book_fight.prototype.getpriceseat=async function(user_id,seat_id){
    let price_query="SELECT get_Total_price_with_discount(?,?)";
    return new Promise(async(resolve,reject)=>{
        try{
            let pool = await poolPromise;
            let result=await pool.query(price_query,[user_id,seat_id]);
            if(result[0][Object.keys(result[0])[0]]){
                resolve(result);
            }else{
               reject(new ErrorHandler(404, "Seat not found"));
            }
        }catch(e){
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }
    });
};
book_fight.prototype.deletebooked=async function(schedule_id,user_id){
    let delete_query="DELETE FROM book WHERE schedule_id=? and user_id=?";
    return new Promise(async(resolve,reject)=>{
        try{
            let pool = await poolPromise;
            let result=await pool.query(delete_query,[schedule_id,user_id]); 
            if(result.affectedRows==0){
                reject(new ErrorHandler(404, "Seat not found"));
            }else if(result.affectedRows==1){
                resolve(result);
            }
        }catch(e){
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }
    });
};
module.exports = book_fight;