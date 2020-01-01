const poolPromise = require("../db");
const ErrorHandler = require('../error');
const logger = require('../logger');

function Seat() {
}
//getlocation function eke wada thiyei
Seat.prototype.getseatbyid=async function(schedule_id){
    let query="SELECT * FROM `seat_details_according_to_schedule` where schedule_id=?";
        return new Promise(async(resolve,reject)=>{
        try {
            let pool = await poolPromise;
            let result=await pool.query(query,[schedule_id]);
            if (!result.length){
                reject(new ErrorHandler(404, "No seat found"));
            }else{
                resolve(result);
            }
        }catch (e){
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }
    });
}
Seat.prototype.getfreeseatbyid=async function(schedule_id){
    // let query="select * from seat where model_id=?";
    let query = "SELECT a.seat_id,a.seat_name,a.class,a.price FROM(SELECT seat_id,seat_name,class,price FROM `seat_details_according_to_schedule` WHERE schedule_id = ?) a WHERE seat_id NOT IN(SELECT seat_id FROM book WHERE schedule_id = ?)"
    return new Promise(async(resolve,reject)=>{
        try {
            let pool = await poolPromise;
            let result=await pool.query(query,[schedule_id,schedule_id]);
            if (!result.length){
                reject(new ErrorHandler(404, "No seat found"));
            }else{
                resolve(result);
            }
        }catch (e){
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }
    });
}
Seat.prototype.addseat=async function(seat_req){
    let query= "INSERT INTO `seat` (`model_id`, `seat_name`, `class`) VALUES (?,?,?);";
    return new Promise(async(resolve,reject)=>{
        try {
            let pool = await poolPromise;
            let result = await pool.query(query,[seat_req.model_id,seat_req.seat_name,seat_req.class]);
            resolve(result);
        } catch (e) {
            if(e.code=="ER_DUP_ENTRY"){
                reject(new ErrorHandler(400, "Seat already added"));
            }else{ 
                logger.log(e);
                console.log(e);
                reject(new ErrorHandler(502, "Internal Server Error"));
            }
        }
    });
}
Seat.prototype.deleteseat=async function(model_id){
    let delete_query="DELETE FROM seat WHERE model_id=?";
    return new Promise(async(resolve,reject)=>{
        try{
            let pool = await poolPromise;
            let result=await pool.query(delete_query,[model_id]); 
            if(result.affectedRows==0){
                reject(new ErrorHandler(404, "Seat not found"));
            }else if(result.affectedRows==1){
                resolve(result);
            }
        }catch(e){
            if(e.sqlState==23000){ 
                reject(new ErrorHandler(400, "Seat can not delete"));
            }else{
                logger.log(e);
                // console.log(e);
                reject(new ErrorHandler(502, "Internal Server Error"));
            }
        }
    });
};
module.exports=Seat;
// SELECT a.seat_id,a.seat_name FROM (SELECT seat_id,seat_name from `seat_details_according_to_schedule` where schedule_id=1)a WHERE seat_id not in (SELECT seat_id from book WHERE schedule_id=1)
// SELECT * FROM `schedule` NATURAL JOIN flight NATURAL JOIN seat WHERE schedule_id=1