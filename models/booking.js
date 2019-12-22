const poolPromise = require("../db");
const ErrorHandler = require('../error');
const logger = require('../logger');

function Booking() {

}
Booking.prototype.getallbookings= async function(){
    let query="SELECT * FROM `book`";
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
    let query="select * from book where schedule_id=?";
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
module.exports=Booking;