module.exports = function (app) {
    app.use("/reg_user", require("./reg_user"));
    app.use("/book_fight", require("./book_fight"));
    app.use("/airport", require("./airport"));
    app.use("/booking", require("./booking"));
    //Root route-REMOVE this
    app.use("/", (req, res) => {
        res.status(404).json({"message": "Default Route"})
    });
};