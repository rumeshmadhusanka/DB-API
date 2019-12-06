module.exports = function (app) {
    // app.use("/customer", require("./customer"));
    // app.use("/item", require("./item"));
    // app.use("/order", require("./order"));
    // app.use("/shop", require("./shop"));
    app.use("/reg_user", require("./reg_user"));
    app.use("/book_fight", require("./book_fight"));
    //Root route-REMOVE this
    app.use("/", (req, res) => {
        res.json({"message": "Welcome to the API"})
    });
};

