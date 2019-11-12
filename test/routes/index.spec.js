const request = require('supertest')
const app = require('../../index')

describe("GET /", () => {
    it("should send a welcome message", (done)=>{
        request(app)
            .get('/')
            .expect('Content-Type', /json/)
            .expect({"message": "Welcome to the API"})
            .end((error, res) =>{
                if (error){
                    return done(error)
                }
                done()
            })
    })
})