const Joi = require('@hapi/joi');

const airplane_model_post = Joi.object().keys({
    model_id: Joi.string().alphanum().min(2).max(100).required(),
    model_name: Joi.string().regex(/^[A-Za-z0-9]+(?:[ _-][A-Za-z0-9]+)*$/).min(3).max(100).required(),
});
const airplane_model_id_check = Joi.object().keys({
    model_id: Joi.string().alphanum().min(2).max(100).required()
});
module.exports = {
    airplane_model_post,
    airplane_model_id_check
}