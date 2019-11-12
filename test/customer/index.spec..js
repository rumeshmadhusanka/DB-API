const request = require('supertest')
const chai = require('chai')
const app = require('../../../index')
const jwt = require('jsonwebtoken')
const config = require('../../../env.config.json')
const should = chai.should()

let tokenCustomer = jwt.sign({ customerId: 1 }, config.secret, config.options)
let tokenShop = jwt.sign({ shopId: 1 }, config.secret, config.options)

describe('/')