const poolPromise = require("../db");
const ErrorHandler = require('../error');
const logger = require('../logger');
const bcrypt = require('bcryptjs');

function RegUser() {

}

RegUser.prototype.getUserById = async function (user_id) {
    let query1 = "select * from user inner join registered_user using(user_id) where user.user_id = ?";
    return new Promise((async (resolve, reject) => {
        try {
            let pool = await poolPromise;
            let result = await pool.query(query1, [user_id]);
            if (!result.length) {
                reject(new ErrorHandler(404, "No user found for id: " + user_id));
            } else {
                resolve(result);
            }
        } catch (e) {
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }

    }));
};

RegUser.prototype.addUser = async function (first_name,
                                            second_name,
                                            email,
                                            nic,
                                            passport_id,
                                            birthday,
                                            user_name,
                                            password) {
    function getRandomInt(min, max) {
        min = Math.ceil(min);
        max = Math.floor(max);
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }

    let hashedPassword = bcrypt.hashSync(password, 10);
    let random_user_id = getRandomInt(100000000, 1000000000);
    //let query1 = `start transaction; insert into user(user_id,firstName, secondName, email, nic, passport_id, BirthDay,number_of_bookings,user_type) values('${random_user_id}','${first_name}','${second_name}','${email}','${nic}','${passport_id}','${birthday}',0,'bug');insert into registered_user(user_id, username, password) values('${random_user_id}','${user_name}','${hashedPassword}'); commit`; //; insert into registered_user(user_id, username, password) values(?,?,?);
    let query = "call add_user(?,?,?,?,?,?,?,?,?)";
    return new Promise((async (resolve, reject) => {
        try {
            let pool = await poolPromise;
            let result = await pool.query(query, [first_name, second_name, email, nic, passport_id, birthday, user_name, hashedPassword, random_user_id]);
            console.log(result);
            // if (!result.length) {
            //     reject(new ErrorHandler(404, "No user found for id: " + random_user_id));
            // } else {
            resolve(result);
            // }
        } catch (e) {
            console.log(e);
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }

    }));
};

RegUser.prototype.updateUser = async function (user_id,
                                               first_name,
                                               second_name,
                                               email,
                                               nic,
                                               passport_id,
                                               birthday,
                                               user_name,
                                               password) {
    let hashedPassword = bcrypt.hashSync(password, 10);
    let query = "call update_user(?,?,?,?,?,?,?,?,?)";
    return new Promise((async (resolve, reject) => {
        try {
            let pool = await poolPromise;
            let result = await pool.query(query, [first_name, second_name, email, nic, passport_id, birthday, user_name, hashedPassword, user_id]);
            console.log(result);
            resolve(result);
        } catch (e) {
            console.log(e);
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }
    }));
};


RegUser.prototype.login = async function (email, password) {
    let query = "select user.user_id,\n" +
        "       firstName,\n" +
        "       secondName,\n" +
        "       email,\n" +
        "       nic,\n" +
        "       passport_id,\n" +
        "       BirthDay,\n" +
        "       user_type,\n" +
        "       number_of_bookings,password\n" +
        "from user\n" +
        "         inner join registered_user on user.user_id = registered_user.user_id\n" +
        "where email = ?";
    return new Promise((async (resolve, reject) => {
        try {
            let pool = await poolPromise;
            let result = await pool.query(query, [email]);
            //console.log(email, hashedPassword);
            console.log(result);
            if (!result.length) {
                reject(new ErrorHandler(404, "Invalid credentials"));
            } else {
                let hashedPassword = result[0].password;
                //console.log(hashedPassword,password);
                let isPasswordValid = bcrypt.compareSync(password, hashedPassword);

                if (!isPasswordValid) {
                    reject(new ErrorHandler(400, "Password Mismatch"));
                } else {
                    resolve(result);
                }
            }
        } catch (e) {
            console.log(e);
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }
    }));
};


RegUser.prototype.deleteUser = function () {

};

RegUser.prototype.getBookings = async function (user_id) {
    let query = "select book.user_id,passport_id,book.id,book.date from user inner join book on user.user_id = book.user_id inner join schedule  on book.schedule_id = schedule.schedule_id where book.user_id = ?";
    return new Promise((async (resolve, reject) => {
        try {
            let pool = await poolPromise;
            let result = await pool.query(query, [user_id]);
            console.log(user_id);
            console.log(result);
            if (!result.length) {
                reject(new ErrorHandler(404, "No bookings found"));
            } else {
                resolve(result);
            }
        } catch (e) {
            console.log(e);
            logger.log(e);
            reject(new ErrorHandler(502, "Internal Server Error"));
        }
    }));
};

module.exports = RegUser;
