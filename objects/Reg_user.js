let reg_user = {
    user_id: null,
    first_name: null,
    second_name: null,
    email: null,
    nic: null,
    passport_id: null,
    password: null,
    user_name: null,
};

function getReg_user() {
    return JSON.parse(JSON.stringify(reg_user)); //new object
}

module.exports = getReg_user;