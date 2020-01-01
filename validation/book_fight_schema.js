const Joi=require('@hapi/joi');

// const user_schema = Joi.object().keys({
//     username: Joi.string().alphanum().min(3).max(30).required(),
//     password: Joi.string().regex(/^[a-zA-Z0-9]{3,30}$/),
//     access_token: [Joi.string(), Joi.number()],
//     birthyear: Joi.number().integer().min(1900).max(2013),
//     email: Joi.string().email({ minDomainAtoms: 2 })
// }).with('username', 'birthyear').without('password', 'access_token');
const query_string = Joi.object().keys({
        user_id: Joi.number().integer().required(),
        seat_id:Joi.number().integer().required(),
    });

const book_fight_post_schema = Joi.object().keys({
    user_id: Joi.number().integer().required(),
    first_name: Joi.string().min(3).max(30).required(),
    last_name: Joi.string().min(3).max(30).required(),
    birthday: Joi.date().min('1-1-1900').iso().required(),
    passport_id: Joi.string().alphanum().min(3).max(30).required(),
    seat_id: Joi.number().integer().required(),
    schedule_id: Joi.number().integer().required(),
});

const query_string_delete_req = Joi.object().keys({
    user_id: Joi.number().integer().required(),
    schedule_id:Joi.number().integer().required(),
});

const id_schema=Joi.object().keys({
    id:Joi.number().integer().required()
});
module.exports= {
    id_schema,
    query_string,
    book_fight_post_schema,
    query_string_delete_req
}