module.exports = function (app) {
    app.use("/reg_user", require("./reg_user"));
    //Root route-REMOVE this
    app.use("/", (req, res) => {
        res.status(404).json({"message": "Default Route"})
    });
};