const logger = require('./logger');


class ErrorHandler extends Error {
    constructor(statusCode, message, ...param) {
        super();
        this._statusCode = statusCode;
        this._message = message;
        this._param = param;
        if (Error.captureStackTrace) {
            Error.captureStackTrace(this, ErrorHandler);
        }
    }

    get statusCode() {
        return this._statusCode;
    }

    set statusCode(value) {
        this._statusCode = value;
    }

    get message() {
        return this._message;
    }

    set message(value) {
        this._message = value;
    }
}


module.exports = ErrorHandler;