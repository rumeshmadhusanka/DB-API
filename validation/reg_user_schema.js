const Joi=require('@hapi/joi');

const reg_user_schema = Joi.object().keys({
    first_name: Joi.string().min(3).max(30).required(),
    second_name: Joi.string().min(3).max(30).required(),
    password: Joi.string().regex(/^[a-zA-Z0-9]{3,30}$/).required(),
    nic: Joi.string().regex(/^([0-9]{9}[x|X|v|V]|[0-9]{12})$/).required(),
    birthday: Joi.date().max('1-1-1900').iso().required(),
    email: Joi.string().email().max(256).required(),
    username: Joi.string().min(3).max(100).required(),
    passport_id: Joi.string().alphanum().min(3).max(30).required(),
});
const log_in_schema =Joi.object().keys({
    email: Joi.string().email().max(256).required(),
    password: Joi.string().regex(/^[a-zA-Z0-9]{3,30}$/).required(),
});
const id_check=Joi.object().keys({
    id:Joi.number().integer().required(),
});
// reg_user_schema,
module.exports={id_check,reg_user_schema,log_in_schema} 