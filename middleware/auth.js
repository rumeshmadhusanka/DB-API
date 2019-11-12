const fs = require("fs");
const path = require('path');
const jwt = require('jsonwebtoken')
const connection = require("../db");
const config = JSON.parse(fs.readFileSync(path.resolve(__dirname, "../env.config.json"), 'utf8'));
const json_response_model = JSON.parse(fs.readFileSync(path.resolve(__dirname, "../response_format.json"), 'utf8'));

module.exports = {

    verifyUser: (req, res, next) => {
        let json_response = Object.create(json_response_model)

        let token = req.headers['x-access-token']
        if (!token) {
            json_response['success'] = false;
            json_response['message'] = "Login to proceed";
            json_response['data'] = []
            json_response['token'] = ''
            return res.status(403).json(json_response);
        }

        jwt.verify(token, config.secret, (error, decoded) => {
            if (error) {
                json_response['success'] = false;
                json_response['message'] = "Cannot verify user";
                json_response['data'] = []
                json_response['token'] = ''
                return res.status(403).json(json_response);
            }

            if (typeof (decoded.customerId) !== 'undefined') {
                req.userId = decoded.customerId
                req.userType = 1
            }
            else if (typeof (decoded.shopId) !=='undefined') {
                req.userId = decoded.shopId
                req.userType = 2
            }
            next()
        })
    },

    isCustomer: (req, res, next) => {
        let json_response = Object.create(json_response_model)

        if (req.userType === 1) {
            next()
        }
        else {
            json_response['success'] = false;
            json_response['message'] = "Access not authorized";
            json_response['data'] = []
            json_response['token'] = req.headers['x-access-token']
            return res.status(401).json(json_response);
        }
    },

    isShop: (req, res, next) => {
        let json_response = Object.create(json_response_model)

        if (req.userType === 2) {
            next()
        }
        else {
            json_response['success'] = false;
            json_response['message'] = "Access not authorized";
            json_response['data'] = []
            json_response['token'] =  req.headers['x-access-token']
            return res.status(401).json(json_response);
        }
    },

    isSameUser: (req, res, next) => {
        let json_response = Object.create(json_response_model)
    
        if (req.userId == req.params.id) {
            next()
        }
        else {
            json_response['success'] = false;
            json_response['message'] = "Access not authorized";
            json_response['data'] = []
            json_response['token'] =  req.headers['x-access-token']
            return res.status(401).json(json_response);
        }
    },

    checkAccessToOrder: (req, res, next) => {
        let json_response = Object.create(json_response_model)
      
        let orderId = req.params.id
        let userId = req.userId
        let userType = req.userType

        if (userType === 1) {
            connection.query("select customer_id from orders where id=?", orderId, (error, results) => {
                if (error) {
                    json_response['success'] = false;
                    json_response['message'] = "Access failed";
                    json_response['data'] = []
                    json_response['token'] = req.headers['x-access-token']
                    return res.status(503).json(json_response);
                }
                else if (results.length === 0){
                    json_response['success'] = false;
                    json_response['message'] = "Order does not exist";
                    json_response['data'] = []
                    json_response['token'] = req.headers['x-access-token']
                    return res.status(400).json(json_response);
                }
                let customerId = results[0].customer_id
                if (customerId == userId) {
                    return next()
                }
                json_response['success'] = false;
                json_response['message'] = "Access not authorized";
                json_response['data'] = []
                json_response['token'] = req.headers['x-access-token']
                return res.status(401).json(json_response);
            })
        }
        else if (userType === 2) {
            next()
        }
    }
}