const poolPromise = require("../db");
const ErrorHandler = require('../error');
const logger = require('../logger');

function Airport() {

}
Airport.prototype.getallairport= async function(){
    let query="SELECT * FROM `airport`";
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
Airport.prototype.addairport=async function(airport_req){
    let query= "INSERT INTO `airport` (`location_id`, `name`, `code`) VALUES (?,?,?);";
    return new Promise(async(resolve,reject)=>{
        try {
            let pool = await poolPromise;
            let result = await pool.query(query,[airport_req.location_id,airport_req.name,airport_req.code]);
            resolve(result);
        } catch (e) {
            if(e.sqlState==45000){
                reject(new ErrorHandler(400, "Airport already added"));
            }else{ 
                logger.log(e);
                // console.log(e);
                reject(new ErrorHandler(502, "Internal Server Error"));
            }
        }
    });
}
Airport.prototype.getairportbyid=async function(airport_id){
    let query="select * from airport where airport_id=?";
    return new Promise(async(resolve,reject)=>{
        try {
            let pool = await poolPromise;
            let result=await pool.query(query,[airport_id]);
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
Airport.prototype.updateairport=async function(airport_req){
    let query= "update `airport` set location_id=?,name=?,code=? where airport_id=?";
    return new Promise(async(resolve,reject)=>{
        try {
            let pool = await poolPromise;
            let result = await pool.query(query,[airport_req.location_id,airport_req.name,airport_req.code,airport_req.airport_id]);
            // console.log(result.changedRows);
            if(result.changedRows==0){
                reject(new ErrorHandler(200, "Airportalready updated"));
            }else{ 
                resolve(result);
            }
        } catch (e) {
            logger.log(e);
            // console.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }
    });
}
Airport.prototype.deleteairport=async function(airport_id){
    let delete_query="DELETE FROM airport WHERE airport_id=?";
    return new Promise(async(resolve,reject)=>{
        try{
            let pool = await poolPromise;
            let result=await pool.query(delete_query,[airport_id]); 
            if(result.affectedRows==0){
                reject(new ErrorHandler(404, "Airport not found"));
            }else if(result.affectedRows==1){
                resolve(result);
            }
        }catch(e){
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }
    });
};
module.exports=Airport;