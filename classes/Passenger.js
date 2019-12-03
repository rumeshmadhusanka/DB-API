// class Passenger {
//     constructor(user_id, first_name, last_name, password, last_login, image) {
//         this._user_id = user_id;
//         this._first_name = first_name;
//         this._last_name = last_name;
//         this._password = password;
//         this._last_login = last_login;
//         this._image = image;
//     }
//
//     get user_id() {
//         return this._user_id;
//     }
//
//     set user_id(value) {
//         this._user_id = value;
//     }
//
//     get first_name() {
//         return this._first_name;
//     }
//
//     set first_name(value) {
//         this._first_name = value;
//     }
//
//     get last_name() {
//         return this._last_name;
//     }
//
//     set last_name(value) {
//         this._last_name = value;
//     }
//
//     get password() {
//         return this._password;
//     }
//
//     set password(value) {
//         this._password = value;
//     }
//
//     get last_login() {
//         return this._last_login;
//     }
//
//     set last_login(value) {
//         this._last_login = value;
//     }
//
//     get image() {
//         return this._image;
//     }
//
//     set image(value) {
//         this._image = value;
//     }
//
//     toJSON() {
//         return {
//             user_id: this._user_id,
//             first_name: this._first_name,
//             last_name: this._last_name,
//             password: this._password,
//             last_login: this._last_login,
//             image: this._image,
//         };
//     }
// }


let passenger = {
    user_id: null,
    first_name: null,
    last_name: null,
    password: null,
    last_login: null,
    image: null,
};

function getPassenger() {
    return JSON.parse(JSON.stringify(passenger)); //new object
}

module.exports = getPassenger;