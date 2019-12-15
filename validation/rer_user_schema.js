
const reg_user_schema = Joi.object().keys({
    first_names: Joi.string().alphanum().min(3).max(30).required(),
    second_name: Joi.string().alphanum().min(3).max(30),
    password: Joi.string().regex(/^[a-zA-Z0-9]{3,30}$/),
    access_token: [Joi.string(), Joi.number()],
    birthyear: Joi.number().integer().min(1900).max(2013),
    email: Joi.string().email({ minDomainAtoms: 2 }).required()
}).with('username', 'birthyear').without('password', 'access_token');

const id_schema=Joi.object().keys({
    id:Joi.number().integer().required()
});

module.exports={reg_user_schema,id_schema}