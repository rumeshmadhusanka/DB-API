const Joi=require('@hapi/joi');

const gate_post = Joi.object().keys({
    airport_id: Joi.number().integer().required(),
    name: Joi.string().regex(/^[A-Za-z0-9]+(?:[ _-][A-Za-z0-9]+)*$/).min(3).max(100).required(),
});

const gate_id_check=Joi.object().keys({
    gate_id:Joi.number().integer().required(),
});
const flight_id_check=Joi.object().keys({
    flight_id:Joi.number().integer().required(),
});

const gate_put = Joi.object().keys({
    gate_id:Joi.number().integer().required(),
    airport_id: Joi.number().integer().required(),
    name: Joi.string().regex(/^[A-Za-z0-9]+(?:[ _-][A-Za-z0-9]+)*$/).min(3).max(100).required(),
});

module.exports={
    gate_post,
    gate_id_check,
    gate_put,
    flight_id_check
}