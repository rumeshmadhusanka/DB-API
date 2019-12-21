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
        } catch (error) {
            logger.log(error);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }
    });
}
Airport.prototype.addairport=async function(){
    let query= "INSERT INTO `airport` (`airport_id`, `location_id`, `name`, `code`) VALUES (?,?,?,?);";
    return new Promise(async(resolve,reject)=>{
        
    });
}
module.exports=Airport;