const Joi = require('@hapi/joi');

const airplane_post = Joi.object().keys({
    model_id: Joi.string().alphanum().min(2).max(100).required()
});
const airplane_id_check = Joi.object().keys({
    airplane_id: Joi.number().integer().required()
});
module.exports = {
    airplane_post,
    airplane_id_check
}