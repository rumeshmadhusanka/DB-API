//number of books>5 frequent customer and number of books>10 gold customer 

let json_response_model = require('../../json_response');  //A function that returns the json response format object
const router = require("express").Router();
const path = require('path');
const connection = require("../../db");
const logger = require("../../logger");

router.get('/all', (req, res) => {
    // let id = req.params['id'];
    let query = "SELECT * from schedule WHERE `date`> CURDATE()";
    connection.query(query,(error, results) => {
        let json_response = json_response_model();//returns a new object
        // console.log(typeof(results.lenght));
        if (error) {
            json_response.success = false;
            json_response.message = "Internal server error";
            console.log(error);
            logger.log(error);
            res.status(502).json(json_response);
        } else if (typeof(results[0])=='undefined') {
            json_response.success = false;
            json_response.message = "No fight found";
            res.status(404).json(json_response);
        } else {
            json_response.success = true;
            json_response.message = "";
            json_response.data=results;
            // console.log(results);
            res.status(200).json(json_response);
        }


    })


});

router.get('/:id', (req, res) => {
    let id = req.params['id'];
    let json_response = json_response_model(); //returns a new object
    if(!isNaN(id)){
    let query = "SELECT * FROM schedule WHERE schedule_id=?";
    connection.query(query,id,(error, results,field) => {
        if (error) {
            json_response.success = false;
            json_response.message = "Internal server error";
            console.log(error);
            logger.log(error);
            res.status(502).json(json_response);
        } else if (typeof(results[0])=='undefined') {
            json_response.success = false;
            json_response.message = "No fight found";
            res.status(404).json(json_response);
        } else {
            json_response.success = true;
            json_response.message = "";
            json_response.data=results; 
            res.status(200).json(json_response);
        }
    })
    }else{
        json_response.success = false;
        json_response.message = "Bad request";
        res.status(400).json(json_response);
    }
    });

    router.post('/:id',(req,res)=>{ //autentification if register user
        let id = req.params['id'];
        // let customer_Id = req.userId;
        let schedule_id=req.body.schedule_id;
        let seat_id=req.body.seat_id;
        let user_id=req.body.user_id;
        let json_response = json_response_model(); //Json response object created
        // console.log(id,schedule_id,seat_id,user_id);
        connection.beginTransaction((error) => {
            if(error){
            json_response['success'] = false;
            json_response['message'] = error;
            res.status(501).json(json_response);
            }else{
                var todaydate = new Date().toISOString().slice(0,10);
                //console.log(todaydate)
                let query="INSERT INTO `book` (`id`, `date`, `schedule_id`, `seat_id`, `user_id`) VALUES (?,?,?,?,?)";
                connection.query(query,[null,todaydate,schedule_id,seat_id,user_id],(error,results)=>{
                    // console.log(todaydate);
                    // let error_code=200;
                    if(error){
                        if(error.sqlState == 45000){
                            error['sqlMessage']="Seat already booked"
                            json_response['success'] = false;
                            json_response['message'] = error['sqlMessage'];
                            res.status(400).json(json_response);
                        }else{
                            json_response['success'] = false;
                            json_response['message'] = error;
                            res.status(501).json(json_response);
                        }
                    }else{
                        let price_query="SELECT get_Total_price_with_discount("+user_id+","+seat_id+")"
                        connection.query(price_query,(error,result)=>{
                            let error_code;
                            if(error){
                                error_code=501;
                            }else{
                                connection.commit((error) => {
                                    if (error) {
                                        connection.rollback();
                                        json_response['success'] = false;
                                        json_response['message'] = error;
                                        res.status(400).json(json_response);
                                    }else if (error_code==501){
                                        connection.rollback();
                                        json_response['success'] = false;
                                        json_response['message'] = error;
                                        res.status(error_code).json(json_response);
                                    }else {
                                        json_response['success'] = true;
                                        json_response['message'] = "Successully book seat";
                                        results["total_price"]=result[0][Object.keys(result[0])[0]];
                                        json_response["data"]=results;
                                        // console.log(result[0][Object.keys(result[0])[0]]);
                                        res.status(200).json(json_response);
                                    }
                                
                                });
                            }
                        });
                        
                    }
                });
            
            }
        });

    });
module.exports = router;