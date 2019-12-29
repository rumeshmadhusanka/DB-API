const Joi=require('@hapi/joi');

const route_post = Joi.object().keys({
    origin: Joi.number().integer().required(),
    destination: Joi.number().integer().required(),
});

const route_id_check=Joi.object().keys({
    route_id:Joi.number().integer().required(),
});

const route_put = Joi.object().keys({
    route_id:Joi.number().integer().required(),
    origin: Joi.number().integer().required(),
    destination: Joi.number().integer().required(),
});

module.exports={
    route_post,
    route_id_check,
    route_put
}