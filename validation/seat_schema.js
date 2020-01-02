const Joi = require('@hapi/joi');

const seat_post = Joi.object().keys({
    model_id: Joi.number().integer().required(),
    seat_name: Joi.string().alphanum().min(2).max(100).required(),
    class: Joi.string().alphanum().min(2).max(100).required(),
});

const model_id_check = Joi.object().keys({
    model_id: Joi.number().integer().required(),
});
const schedule_id_check = Joi.object().keys({
    schedule_id: Joi.number().integer().required(),
});
module.exports = {
    seat_post,
    model_id_check,
    schedule_id_check
}