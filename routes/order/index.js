const fs = require("fs");
const router = require("express").Router();
const connection = require("../../db");
const path = require('path');
let json_response = JSON.parse(fs.readFileSync(path.resolve(__dirname, "../../response_format.json"), 'utf8'));

// Get route to get all orders
router.get('/', (req, res) => {
    let query = "select * from orders order by date_time desc"

    connection.query(query, (error, results) => {
        if (error) {
            console.error("error: ", error);
            json_response['success'] = false;
            json_response['message'] = error;
            json_response['data'] = [];
            res.json(json_response);
        }
        else {
            json_response['data']=[]
            for (let i = 0; i < results.length; i++) {
                json_response['data'].push(results[i]);
            }
            res.json(json_response);
        }
    })
});

// Post route to start a new order
router.post('/', (req, res) => {
    let customerId = req.body.customerId
    let items = req.body.items
    let params = []
    connection.beginTransaction((error) => {
        if (error) {
            console.error("error: ", error);
            json_response['success'] = false;
            json_response['message'] = error;
            json_response['data'] = [];
            res.json(json_response);
        }
        else {
            connection.query("INSERT INTO orders (customer_id) VALUES (?)", customerId, (error, results) => {
                if (error) {
                    console.error("error: ", error);
                    json_response['success'] = false;
                    json_response['message'] = error;
                    json_response['data'] = [];
                    res.json(json_response);
                }
                else {
                    let orderId = results.insertId
                    for (let i = 0; i < items.length; i++) {
                        let query = "INSERT INTO order_details (order_id, item_id, quantity) VALUES (?, ?, ?);"
                        let itemId = items[i].itemId
                        let itemQuantity = items[i].itemQuantity

                        connection.query(query, [orderId, itemId, itemQuantity], (error, results) => {
                            if (error) {
                                console.error("error: ", error);
                                json_response['success'] = false;
                                json_response['message'] = error;
                                json_response['data'] = [];
                                res.json(json_response);
                            }
                            else {
                                if (i == items.length - 1) {
                                    connection.commit((error) => {
                                        if (error) {
                                            connection.rollback()
                                            console.error("error: ", error);
                                            json_response['success'] = false;
                                            json_response['message'] = error;
                                            json_response['data'] = [];
                                            res.json(json_response);
                                        }
                                        else {
                                            res.redirect(`/order/${orderId}`)
                                        }
                                    })
                                }
                            }
                        })
                    }
                }
            })
        }
    })
})

//Get route to get an order by id
router.get('/:id', (req, res) => {
    let orderId = req.params.id

    query = "select * from order_details \
    inner join item on item_id=item.id \
    inner join orders on orders.id=order_id \
    inner join customer on customer_id= customer.id \
    where order_id=?;"

    connection.query(query, orderId, (error, results) => {
        if (error) {
            console.error("error: ", error);
            json_response['success'] = false;
            json_response['message'] = error;
            json_response['data'] = [];
            res.json(json_response);
        }
        else {
            let order = {}
            order.orderId = results[0].order_id
            order.status = results[0].status
            order.customer = {}
            order.customer.customerId = results[0].customer_id
            order.customer.customerName = `${results[0].first_name} ${results[0].last_name}`
            order.dateTime = results[0].date_time
            order.items = []

            for (let i = 0; i < results.length; i++) {
                let item = {}
                item.itemId = results[i].item_id
                item.itemName = results[i].name
                item.itemQuantity = results[i].quantity
                item.itemDescription = results[i].description
                item.itemPrice = results[i].price
                item.itemPhoto = results[i].photo

                order.items.push(item)
            }
            json_response['data']=[]
            json_response.data.push(order)
            res.json(json_response)
        }
    })
})

// Put route to change order status from ongoing to complete
router.put('/:id', (req, res) => {
    let orderId = req.params.id
    let query = "update orders set status='COMPLETED' where id=?"
    connection.query(query, orderId, (error, results) => {
        if (error) {
            console.error("error: ", error);
            json_response['success'] = false;
            json_response['message'] = error;
            json_response['data'] = [];
            res.json(json_response);
        }
        else {
            res.redirect(`/order/${orderId}`)
        }
    })
})

// router.get("/status/:status", (req, res) => {
//     let orderStatus = req.params.status
//     let query = "select * from orders where status=? order by date_time desc"
    
//     //need to add a transaction
//     connection.query(query, orderStatus, (error, results) => {
//         if (error) {
//             console.error("error: ", error);
//             json_response['success'] = false;
//             json_response['message'] = error;
//             json_response['data'] = [];
//             res.json(json_response);
//         }
//         else {
//             for (let i = 0; i < results.length; i++) {
//                 json_response['data'].push(results[i]);

//                 let orderId= results[i].id
//                 query = "update orders set status='ONGOING' where id=? and status='NEW'"
//                 connection.query(query, orderId, (error, result) =>{
//                     if (error){
//                         console.error("error: ", error);
//                     }
//                 })
//             }
//             res.json(json_response);
//         }
//     })
// })

module.exports = router;