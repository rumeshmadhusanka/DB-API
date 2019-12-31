const poolPromise = require("../db");
const ErrorHandler = require('../error');
const logger = require('../logger');

function Discount() {

}
Discount.prototype.getdiscountbyid= async function(user_id){
    let query="SELECT user.user_id,discount_percentage.type,discount_percentage.percentage FROM `user` LEFT JOIN discount_percentage on user.user_type= discount_percentage.type WHERE user.user_id=?";
    return new Promise(async(resolve,reject)=>{
        try {
            let pool = await poolPromise;
            let result = await pool.query(query,[user_id]);
            console.log(result[0].type)
            if (!result[0].type) {
                reject(new ErrorHandler(404, "No Discount found"));
            } else {
                resolve(result);
            }
        } catch (e) {
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }
    });
}
module.exports=Discount;