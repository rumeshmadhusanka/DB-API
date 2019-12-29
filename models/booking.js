const poolPromise = require("../db");
const ErrorHandler = require('../error');
const logger = require('../logger');

function Booking() {

}
Booking.prototype.getallbookings= async function(){
    let query="SELECT * FROM `book_details`";
    return new Promise(async(resolve,reject)=>{
        try {
            let pool = await poolPromise;
            let result = await pool.query(query);
            if (!result.length) {
                reject(new ErrorHandler(404, "No Airport found"));
            } else {
                resolve(result);
            }
        } catch (e) {
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }
    });
}
Booking.prototype.getbookingbyschedule=async function(schedule_id){
    let query="select * from book_details where schedule_id=?";
    return new Promise(async(resolve,reject)=>{
        try {
            let pool = await poolPromise;
            let result=await pool.query(query,[schedule_id]);
            if (!result.length) {
                reject(new ErrorHandler(404, "No booking yet!!"));
            } else {
                resolve(result);
            }
        } catch (e) {
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }
    });
}
Booking.prototype.getbookingbyShecduleUser=async function(schedule_id,user_id){
    let query="select * from book_details where schedule_id=? and user_id=?";
    return new Promise(async(resolve,reject)=>{
        try {
            let pool = await poolPromise;
            let result=await pool.query(query,[schedule_id,user_id]);
            if (!result.length) {
                reject(new ErrorHandler(404, "No booking yet!!"));
            } else {
                resolve(result);
            }
        } catch (e) {
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }
    });
}
module.exports=Booking;

// (SELECT id,book.date,seat_id,user_id,schedule_details.date as scheduled_date,origin,destination,model_name as airplane_model,dep_time,arival_time,schedule_details.name as gate_name FROM `book` JOIN schedule_details on book.schedule_id=schedule_details.schedule_id)
// SELECT id,a.date,user_id,a.scheduled_date,origin,destination,a.airplane_model,dep_time,arival_time,a.gate_name, seat_name,b.seat_class from (SELECT id,book.date,seat_id,user_id,schedule_details.date as scheduled_date,origin,destination,model_name as airplane_model,dep_time,arival_time,schedule_details.name as gate_name FROM `book` JOIN schedule_details on book.schedule_id=schedule_details.schedule_id)a natural JOIN (SELECT id,seat_name,class as seat_class FROM `book` natural JOIN seat)b