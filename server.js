const express = require('express');
const path = require('path');

const app = express();
const port = process.env.PORT || 3000;

// Serve the static web assets
app.use(express.static(path.join(__dirname, 'build', 'web')));

// Handle all other requests by serving the index.html file
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'build', 'web', 'index.html'));
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
