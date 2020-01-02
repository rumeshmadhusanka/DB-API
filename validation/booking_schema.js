const Joi = require('@hapi/joi');

const schedule_id_check = Joi.object().keys({
    schedule_id: Joi.number().integer().required(),
});
const schedule_user_id_check = Joi.object().keys({
    schedule_id: Joi.number().integer().required(),
    user_id: Joi.number().integer().required(),
});
module.exports = {schedule_id_check, schedule_user_id_check}