const fs = require("fs");
const path = require('path');
const jwt = require('jsonwebtoken');
const poolPromise = require("../db");
const config = JSON.parse(fs.readFileSync(path.resolve(__dirname, "../env.config.json"), 'utf8'));
//const json_response_model = JSON.parse(fs.readFileSync(path.resolve(__dirname, "../response_format.json"), 'utf8'));
let json_response_model = require('../json_response');
module.exports = {

    verifyUser: async (req, res, next) => {
        //let json_response = Object.create(json_response_model)
        let json_response = json_response_model();
        let token = req.headers['x-access-token'];
        if (!token) {
            json_response['success'] = false;
            json_response['message'] = "Login to proceed";
            json_response['data'] = [];
            json_response['token'] = '';
            return res.status(403).json(json_response);
        }

        jwt.verify(token, config.secret, (error, decoded) => {
            if (error) {
                json_response['success'] = false;
                json_response['message'] = "Cannot verify user";
                json_response['data'] = [];
                json_response['token'] = '';
                return res.status(403).json(json_response);
            }

            if (typeof (decoded.user_id) !== 'undefined') {
                req.userId = decoded.user_id;
                req.userType = 'REG_USER';
            } else if (typeof (decoded.admin_id) !== 'undefined') {
                req.userId = decoded.admin_id;
                req.userType = 'ADMIN';
            }
            next()
        })
    },

    isAdmin: async (req, res, next) => {
        // let json_response = Object.create(json_response_model)
        let json_response = json_response_model();
        if (req.userType === 'ADMIN') {
            next()
        } else {
            json_response['success'] = false;
            json_response['message'] = "Access not authorized";
            json_response['data'] = [];
            json_response['token'] = req.headers['x-access-token'];
            return res.status(401).json(json_response);
        }
    },

    isRegUser: (req, res, next) => {
        //let json_response = Object.create(json_response_model)
        let json_response = json_response_model();
        if (req.userType === 'REG_USER') {
            next()
        } else {
            json_response['success'] = false;
            json_response['message'] = "Access not authorized";
            json_response['data'] = [];
            json_response['token'] = req.headers['x-access-token'];
            return res.status(401).json(json_response);
        }
    },

    isSameRegUser: async (req, res, next) => {
        //let json_response = Object.create(json_response_model)
        let json_response = json_response_model();
        if (req.userId === req.params.user_id || req.userId === req.query.user_id) {
            next()
        } else {
            json_response['success'] = false;
            json_response['message'] = "Access not authorized";
            json_response['data'] = [];
            json_response['token'] = req.headers['x-access-token'];
            return res.status(401).json(json_response);
        }
    },

    checkAccessToOrder: async (req, res, next) => {
        let json_response = Object.create(json_response_model);

        let orderId = req.params.id;
        let userId = req.userId;
        let userType = req.userType;

        if (userType === 1) {
            connection.query("select customer_id from orders where id=?", orderId, (error, results) => {
                if (error) {
                    json_response['success'] = false;
                    json_response['message'] = "Access failed";
                    json_response['data'] = [];
                    json_response['token'] = req.headers['x-access-token'];
                    return res.status(503).json(json_response);
                } else if (results.length === 0) {
                    json_response['success'] = false;
                    json_response['message'] = "Order does not exist";
                    json_response['data'] = [];
                    json_response['token'] = req.headers['x-access-token'];
                    return res.status(400).json(json_response);
                }
                let customerId = results[0].customer_id;
                if (customerId === userId) {
                    return next()
                }
                json_response['success'] = false;
                json_response['message'] = "Access not authorized";
                json_response['data'] = [];
                json_response['token'] = req.headers['x-access-token'];
                return res.status(401).json(json_response);
            })
        } else if (userType === 2) {
            next()
        }
    }
};