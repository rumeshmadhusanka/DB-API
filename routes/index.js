module.exports = function (app) {
    app.use("/reg_user", require("./reg_user"));
    app.use("/book_fight", require("./book_fight"));
    app.use("/airport", require("./airport"));
    app.use("/booking", require("./booking"));
    app.use("/airplane_model", require("./airplane_model"));
    app.use("/airplane", require("./airplane"));
    app.use("/flight", require("./flight"));
    app.use("/gate", require("./gate"));
    app.use("/route", require("./route"));
    app.use("/seat", require("./seat"));
    app.use("/schedule", require("./schedule"));
    //Root route-REMOVE this
    app.use("/", (req, res) => {
        res.status(404).json({"message": "Default Route"})
    });
};