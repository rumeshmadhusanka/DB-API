const Joi = require('@hapi/joi');

const flight_post = Joi.object().keys({
    route_id: Joi.number().integer().required(),
    airplane_id: Joi.number().integer().required(),
});
const flight_id_check = Joi.object().keys({
    flight_id: Joi.number().integer().required(),
});
const flight_put = Joi.object().keys({
    flight_id: Joi.number().integer().required(),
    route_id: Joi.number().integer().required(),
    airplane_id: Joi.number().integer().required(),
});
module.exports = {
    flight_post,
    flight_id_check,
    flight_put
}