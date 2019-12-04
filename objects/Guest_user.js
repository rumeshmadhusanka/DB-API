let guest_user = {
    user_id: null,
    first_name: null,
    second_name: null,
    email: null,
    nic: null,
    passport_id: null,
};

function getGuest_user() {
    return JSON.parse(JSON.stringify(guest_user)); //new object
}

module.exports = getGuest_user;