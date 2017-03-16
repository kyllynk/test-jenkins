const express = require("express");

const app = express();


app.get("/", (req, res) => {
	res.send("Welcome!");
})

app.listen(30000, () => console.log("application is running on port 30000"));