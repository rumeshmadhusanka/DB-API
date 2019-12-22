const Joi=require('@hapi/joi');

const schedule_id_check=Joi.object().keys({
    schedule_id:Joi.number().integer().required(),
});
module.exports={schedule_id_check}