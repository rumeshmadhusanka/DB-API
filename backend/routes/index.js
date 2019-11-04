module.exports = function (app) {
    app.use("/cart", require("./cart"));
    app.use("/customer", require("./customer"));
    app.use("/item", require("./item"));
    app.use("/order", require("./order"));
    app.use("/product", require("./product"));
    app.use("/shop", require("./shop"));

};
