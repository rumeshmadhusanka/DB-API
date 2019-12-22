const poolPromise = require("../db");
const ErrorHandler = require('../error');
const logger = require('../logger');

function Flight() {

}
Flight.prototype.getallflight= async function(){
    let query="SELECT * FROM `flight`";
    return new Promise(async(resolve,reject)=>{
        try {
            let pool = await poolPromise;
            let result = await pool.query(query);
            if (!result.length) {
                reject(new ErrorHandler(404, "No Flight found"));
            } else {
                resolve(result);
            }
        } catch (e) {
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }
    });
}
Flight.prototype.addflight=async function(flight_req){
    let query= "INSERT INTO `flight` (`route_id`, `airplane_id`) VALUES (?,?)";
    return new Promise(async(resolve,reject)=>{
        try {
            let pool = await poolPromise;
            let result = await pool.query(query,[flight_req.route_id,flight_req.airplane_id]);
            resolve(result);
        } catch (e) {
            if(e.sqlState==45000){
                reject(new ErrorHandler(400, "Flight already added"));
            }else if(e.sqlState==23000){ 
                reject(new ErrorHandler(400, "route_id or airplane_id incorrect"));
            }else{
                logger.log(e);
                // console.log(e);
                reject(new ErrorHandler(502, "Internal Server Error"));
            }
        }
    });
}
Flight.prototype.getflightbyid=async function(flight_id){
    let query="select * from flight where flight_id=?";
    return new Promise(async(resolve,reject)=>{
        try {
            let pool = await poolPromise;
            let result=await pool.query(query,[flight_id]);
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
Flight.prototype.updateflight=async function(flight_req){
    let query= "update `flight` set route_id=?,airplane_id=? where flight_id=?";
    return new Promise(async(resolve,reject)=>{
        try {
            let pool = await poolPromise;
            let result = await pool.query(query,[flight_req.route_id,flight_req.airplane_id,flight_req.flight_id]);
            // console.log(result.changedRows);
            if(result.changedRows==0){
                reject(new ErrorHandler(200, "Fight already updated"));
            }else{ 
                resolve(result);
            }
        } catch (e) {
            if(e.sqlState==23000){ 
                reject(new ErrorHandler(400, "route_id or airplane_id incorrect"));
            }else{
                logger.log(e);
                // console.log(e);
                reject(new ErrorHandler(502, "Internal Server Error"));
            }
        }
    });
}
Flight.prototype.deleteflight=async function(flight_id){
    let delete_query="DELETE FROM flight WHERE flight_id=?";
    return new Promise(async(resolve,reject)=>{
        try{
            let pool = await poolPromise;
            let result=await pool.query(delete_query,[flight_id]); 
            if(result.affectedRows==0){
                reject(new ErrorHandler(404, "Flight not found"));
            }else if(result.affectedRows==1){
                resolve(result);
            }
        }catch(e){
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }
    });
};
module.exports=Flight;