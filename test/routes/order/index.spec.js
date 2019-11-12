const request = require('supertest')
const chai = require('chai')
const app = require('../../../index')
const jwt = require('jsonwebtoken')
const config = require('../../../env.config.json')
const should = chai.should()

let tokenCustomer = jwt.sign({ customerId: 1 }, config.secret, config.options)
let tokenShop = jwt.sign({ shopId: 1 }, config.secret, config.options)

describe("GET /order", () => {
    it("should send status 401 when customer access", (done) => {
        request(app)
            .get('/order')
            .set('Accept', 'application/json')
            .set('x-access-token', tokenCustomer)
            .expect('Content-Type', /json/)
            .expect(401)
            .end((error, res) => {
                if (error) { return done(error) }
                done()
            })
    })
    it("should send status 403 when not logged in user access", (done) => {
        request(app)
            .get('/order')
            .set('Accept', 'application/json')
            .expect('Content-Type', /json/)
            .expect(403)
            .end((error, res) => {
                if (error) { return done(error) }
                done()
            })
    })
    it("should send status 200 and array of orders when shop access", (done) => {
        request(app)
            .get('/order')
            .set('Accept', 'application/json')
            .set('x-access-token', tokenShop)
            .expect('Content-Type', /json/)
            .expect(200)
            .end((error, res) => {
                if (error) { return done(error) }
                done()
            })
    })

})

describe("POST /order", () => {
    it("should send status 401 when shop access", (done) => {
        request(app)
            .post('/order')
            .set('Accept', 'application/json')
            .set('x-access-token', tokenShop)
            .expect('Content-Type', /json/)
            .expect(401)
            .end((error, res) => {
                if (error) { return done(error) }
                done()
            })
    })
    it("should send status 403 when not logged in user acess", (done) => {
        request(app)
            .post('/order')
            .set('Accept', 'application/json')
            .expect('Content-Type', /json/)
            .expect(403)
            .end((error, res) => {
                if (error) { return done(error) }
                done()
            })
    })
    it("should send status 302 when customer access with correct item ids", (done) => {
        request(app)
            .post('/order')
            .set('Accept', 'application/json')
            .set('x-access-token', tokenCustomer)
            .send({items: [{ itemId: 1, itemQuantity: 4 }, { itemId: 2, itemQuantity: 6 }] })
            .expect(302)
            .end((error, res) => {
                if (error) { return done(error) }
                done()
            })
    })
    it("should send status 400 when customer sends with items that does not exist", (done) => {
        request(app)
            .post('/order')
            .set('Accept', 'application/json')
            .set('x-access-token', tokenCustomer)
            .send({items: [{ itemId: 100, itemQuantity: 4 }, { itemId: 2, itemQuantity: 6 }] })
            .expect(400)
            .end((error, res) => {
                if (error) { return done(error) }
                done()
            })
    })
})

describe("GET /order/:id", () => {
    it("should send status and order details 200 when shop access", (done) => {
        request(app)
            .get('/order/1')
            .set('Accept', 'application/json')
            .set('x-access-token', tokenShop)
            .expect('Content-Type', /json/)
            .expect(200)
            .end((error, res) => {
                if (error) { return done(error) }
                done()
            })
    })
    it("should send status 200 and order details when customer who created the order access", (done) => {
        request(app)
            .get('/order/1')
            .set('Accept', 'application/json')
            .set('x-access-token', tokenCustomer)
            .expect('Content-Type', /json/)
            .expect(200)
            .end((error, res) => {
                if (error) { return done(error) }
                done()
            })
    })
    it("should send status 401 when customer who did not create the order acess", (done) => {
        request(app)
            .get('/order/3')
            .set('Accept', 'application/json')
            .set('x-access-token', tokenCustomer)
            .expect(401)
            .end((error, res) => {
                if (error) { return done(error) }
                done()
            })
    })
    it("should send status 403 when not logged in user access", (done) => {
        request(app)
            .get('/order/1')
            .set('Accept', 'application/json')
            .expect('Content-Type', /json/)
            .expect(403)
            .end((error, res) => {
                if (error) { return done(error) }
                done()
            })
    })
    it("should send status 400 when order does not exist", (done) => {
        request(app)
            .get('/order/500')
            .set('Accept', 'application/json')
            .set('x-access-token', tokenShop)
            .expect('Content-Type', /json/)
            .expect(400)
            .end((error, res) => {
                if (error) { return done(error) }
                done()
            })
    })
})

describe("PUT /order/:id", () => {
    it("should send status 302 the order status when shop tries to mark order as completed", (done) => {
        request(app)
            .put('/order/11')
            .set('Accept', 'application/json')
            .set('x-access-token', tokenShop)
            .expect(302)
            .end((error, res) => {
                if (error) { return done(error) }
                done()
            })
    })
    it("should send status 401 when customer tries to mark order as completed", (done) => {
        request(app)
            .put('/order/9')
            .set('Accept', 'application/json')
            .set('x-access-token', tokenCustomer)
            .expect('Content-Type', /json/)
            .expect(401)
            .end((error, res) => {
                if (error) { return done(error) }
                done()
            })
    })
    it("should send status 403 when not logged in user access", (done) => {
        request(app)
            .put('/order/1')
            .set('Accept', 'application/json')
            .expect('Content-Type', /json/)
            .expect(403)
            .end((error, res) => {
                if (error) { return done(error) }
                done()
            })
    })
    it("should send status 400 when order does not exist", (done) => {
        request(app)
            .put('/order/500')
            .set('Accept', 'application/json')
            .set('x-access-token', tokenShop)
            .expect('Content-Type', /json/)
            .expect(400)
            .end((error, res) => {
                if (error) { return done(error) }
                done()
            })
    })
    it("should send status 400 when order is already completed", (done) => {
        request(app)
            .put('/order/7')
            .set('Accept', 'application/json')
            .set('x-access-token', tokenShop)
            .expect('Content-Type', /json/)
            .expect(400)
            .end((error, res) => {
                if (error) { return done(error) }
                done()
            })
    })
})

