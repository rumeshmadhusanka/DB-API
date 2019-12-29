const poolPromise = require("../db");
const ErrorHandler = require('../error');
const logger = require('../logger');

function Airplane() {
}
Airplane.prototype.getallairplane= async function(){
    let query="SELECT airplane_id,airplane_model.model_name FROM `airplane` NATURAL JOIN airplane_model";
    return new Promise(async(resolve,reject)=>{
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
}
Airplane.prototype.addairplane=async function(airplane_req){
    let query= "INSERT INTO `airplane` (model_id) VALUES (?)";
    return new Promise(async(resolve,reject)=>{
        try {
            let pool = await poolPromise;
            let result = await pool.query(query,[airplane_req.model_id]);
            resolve(result);
        } catch (e) {
            if(e.sqlState==23000){ 
                reject(new ErrorHandler(404, "No airplane model found"));
            }else{
                logger.log(e);
                console.log(e);
                reject(new ErrorHandler(502, "Internal Server Error"));
            }
        }
    });
}
Airplane.prototype.deleteairplane=async function(airplane_id){
    let delete_query="DELETE FROM airplane WHERE airplane_id=?";
    return new Promise(async(resolve,reject)=>{
        try{
            let pool = await poolPromise;
            let result=await pool.query(delete_query,[airplane_id]); 
            if(result.affectedRows==0){
                reject(new ErrorHandler(404, "Airplane not found"));
            }else if(result.affectedRows==1){
                resolve(result);
            }
        }catch(e){
            console.log(e);
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }
    });
};
module.exports=Airplane;