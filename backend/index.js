const express = require("express");
const bodyParser = require("body-parser");
const app = express();

let datensaetze = [];
const PORT = 3000;

app.use(bodyParser.json());

app.get("/", (req, res) => {
  res.json(datensaetze);
});

app.post("/", (req, res) => {
  const date = new Date();
  const customTimestamp = `${date.getFullYear()}-${
    date.getMonth() + 1
  }-${date.getDate()} ${date.getHours()}:${date.getMinutes()}:${date.getSeconds()}`;
  const receivedData = req.body;

  datensaetze.push(receivedData);

  console.log(customTimestamp);
  console.log(receivedData, "\n\n");
  res.status(200).send("Daten erhalten");
});

app.listen(PORT, () => {
  console.log(`Server läuft auf http://localhost:${PORT}`);
});
