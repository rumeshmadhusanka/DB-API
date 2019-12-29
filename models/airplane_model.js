const poolPromise = require("../db");
const ErrorHandler = require('../error');
const logger = require('../logger');

function Airplane_model() {

}
Airplane_model.prototype.getallairplanemodel= async function(){
    let query = "SELECT airplane_model.model_id, airplane_model.model_name, a.airplane_id  FROM `airplane_model` inner join airplane a on airplane_model.model_id = a.model_id";
    return new Promise(async(resolve,reject)=>{
        try {
            let pool = await poolPromise;
            let result = await pool.query(query);
            if (!result.length) {
                reject(new ErrorHandler(404, "No airplane model found"));
            } else {
                resolve(result);
            }
        } catch (e) {
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }
    });
}
Airplane_model.prototype.addairplanemodel=async function(airplane_model_req){
    let query= "INSERT INTO `airplane_model` (model_id,model_name) VALUES (?,?)";
    return new Promise(async(resolve,reject)=>{
        try {
            let pool = await poolPromise;
            let result = await pool.query(query,[airplane_model_req.model_id,airplane_model_req.model_name]);
            resolve(result);
        } catch (e) {
            if(e.sqlState==45000){
                reject(new ErrorHandler(400, "Airplane model already added"));
            }else{ 
                logger.log(e);
                console.log(e);
                reject(new ErrorHandler(502, "Internal Server Error"));
            }
        }
    });
}
Airplane_model.prototype.deleteairplanemodel=async function(model_id){
    let delete_query="DELETE FROM airplane_model WHERE model_id=?";
    return new Promise(async(resolve,reject)=>{
        try{
            let pool = await poolPromise;
            let result=await pool.query(delete_query,[model_id]); 
            if(result.affectedRows==0){
                reject(new ErrorHandler(404, "Airplane_model not found"));
            }else if(result.affectedRows==1){
                resolve(result);
            }
        }catch(e){
            if(e.sqlState==23000){ 
                reject(new ErrorHandler(400, "Airplane model can not delete"));
            }else{
                logger.log(e);
                // console.log(e);
                reject(new ErrorHandler(502, "Internal Server Error"));
            }
        }
    });
};
module.exports=Airplane_model;