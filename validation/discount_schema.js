const Joi=require('@hapi/joi');

const user_id_check=Joi.object().keys({
    user_id:Joi.number().integer().required(),
});
module.exports= {user_id_check}