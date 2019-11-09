const fs = require("fs");
const path = require('path');
const jwt = require('jsonwebtoken')
const connection = require("../db");
const config = JSON.parse(fs.readFileSync(path.resolve(__dirname, "../env.config.json"), 'utf8'));
let json_response = JSON.parse(fs.readFileSync(path.resolve(__dirname, "../response_format.json"), 'utf8'));

module.exports = {

    verifyUser: (req, res, next) => {
        let token = req.headers['x-access-token']
        if (!token) {
            json_response['success'] = false;
            json_response['message'] = "Login to proceed";
            json_response['data'] = []
            json_response['token'] = ''
            return res.json(json_response);
        }

        jwt.verify(token, config.secret, (error, decoded) => {
            if (error) {
                json_response['success'] = false;
                json_response['message'] = "Cannot verify user";
                json_response['data'] = []
                json_response['token'] = ''
                return res.json(json_response);
            }

            if (decoded.customerId) {
                req.userId = decoded.customerId
                req.userType = 1
            }
            else if (decoded.shopId) {
                req.userId = decoded.shopId
                req.userType = 2
            }
            console.log(token)
            next()
        })
    },

    isCustomer: (req, res, next) => {
        if (req.userType === 1) {
            next()
        }
        else {
            json_response['success'] = false;
            json_response['message'] = "Access not authorized";
            json_response['data'] = []
            return res.json(json_response);
        }
    },

    isShop: (req, res, next) => {
        if (req.userType === 2) {
            next()
        }
        else {
            json_response['success'] = false;
            json_response['message'] = "Access not authorized";
            json_response['data'] = []
            return res.json(json_response);
        }
    },

    isSameUser: (req, res, next) => {
        if (req.userId == req.params.id) {
            next()
        }
        else {
            json_response['success'] = false;
            json_response['message'] = "Access not authorized";
            json_response['data'] = []
            return res.json(json_response);
        }
    },

    checkAccessToOrder: (req, res, next) => {
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
                    return res.json(json_response);
                }
                
                let customerId = results[0].customer_id
                if (customerId == userId) {
                    return next()
                }

                json_response['success'] = false;
                json_response['message'] = "Access not authorized";
                json_response['data'] = []
                json_response['token'] = req.headers['x-access-token']
                return res.json(json_response);
            })
        }
        else if (userType === 2) {
            next()
        }
        else {
            json_response['success'] = false;
            json_response['message'] = "Access denied";
            json_response['data'] = []
            return res.json(json_response);
        }

    }
}