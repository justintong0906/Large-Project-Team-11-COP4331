//---setup---//
import express from "express";
//const express = require("express");
const app = express();

//---api calls---//

//print notes
app.get("/api/notes", (req, res) => {
    res.status(200).send("you got 9 notes"); //".status(200)" optional bc its default
});

app.listen(5001, () => {
    console.log("Server is running on port 5001");
});