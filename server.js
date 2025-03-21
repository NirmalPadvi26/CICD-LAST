const express = require("express");
const app = express();

const PORT = 8080;
const HOST = "0.0.0.0"; // Ensure this is set

app.get("/", (req, res) => {
  res.send("Hello, Toshal infotech learning CICD pipeline this is a test!");
});

app.listen(PORT, HOST, () => {
  console.log(`Server running on http://${HOST}:${PORT}`);
});
