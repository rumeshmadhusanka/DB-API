const request = require('supertest')
const assert = require('assert');
const app = require('../../routes/order');

describe('GET /order', ()=>{
    it('should have status of 200', (done) =>{
        request(app)
            .get('/order')
            .end((error, res)=>{
                if (error){
                    return done(error)
                }
                done()
            })
    })
})