const Joi = require('@hapi/joi');

const airport_post = Joi.object().keys({
    location_id: Joi.number().integer().required(),
    name: Joi.string().regex(/^[A-Za-z0-9]+(?:[ _-][A-Za-z0-9]+)*$/).min(3).max(100).required(),
    code: Joi.string().alphanum().min(2).max(30).required(),
});

const airport_id_check = Joi.object().keys({
    airport_id: Joi.number().integer().required(),
});

const airport_put = Joi.object().keys({
    airport_id: Joi.number().integer().required(),
    location_id: Joi.number().integer().required(),
    name: Joi.string().regex(/^[A-Za-z0-9]+(?:[ _-][A-Za-z0-9]+)*$/).min(3).max(100).required(),
    code: Joi.string().alphanum().min(2).max(30).required(),
});

module.exports = {
    airport_post,
    airport_id_check,
    airport_put
}