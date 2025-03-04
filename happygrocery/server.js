const express = require('express');
const mysql = require('mysql2');
const cors = require('cors'); // Add CORS support
const app = express();
const port = 3000;

// Create a connection to the database
const db = mysql.createConnection({
  host: 'localhost', // Replace with your database host
  user: 'root',      // Replace with your database username
  password: 'password', // Replace with your database password
  database: 'Hwang_Andrew_db' // Replace with your database name
});

// Connect to the database
db.connect((err) => {
  if (err) {
    console.error('Error connecting to the database:', err);
    return;
  }
  console.log('Connected to the database');
});

// Middleware to parse JSON and enable CORS
app.use(express.json());
app.use(cors());

// API endpoint to handle queries
app.post('/query', (req, res) => {
  const { queryType } = req.body;
  console.log('Received query type:', queryType);

  let sqlQuery;
  switch (queryType) {
    case 'least':
      sqlQuery = `
        SELECT Item_ID, Brand, Stock
        FROM Item
        ORDER BY Stock ASC
        LIMIT 10;
      `;
      break;
    case 'returns':
      sqlQuery = `
        SELECT i.Item_ID, i.Brand, COUNT(r.Item_ID) AS Return_Count
        FROM Item i
        JOIN Returns r ON i.Item_ID = r.Item_ID
        GROUP BY i.Item_ID, i.Brand
        ORDER BY Return_Count DESC
        LIMIT 10;
      `;
      break;
    case 'average':
      sqlQuery = `
        SELECT AVG(Total_amount) AS Average_Amount_Spent
        FROM Orders;
      `;
      break;
    case 'promotions':
      sqlQuery = `
        SELECT i.Item_ID, i.Brand, ip.Discount_Percentage
        FROM Item i
        JOIN Item_Promotion_Bridge ipb ON i.Item_ID = ipb.Item_ID
        JOIN Item_Promotion ip ON ipb.Promotion_ID = ip.Promotion_ID
        WHERE CURDATE() BETWEEN ip.Start_date AND ip.End_date;
      `;
      break;
    case 'deliveries':
      sqlQuery = `
        SELECT COUNT(*) AS Delivery_Requests_This_Month
        FROM Orders
        WHERE Order_Type_ID = 2
        AND MONTH(Order_Date) = MONTH(CURDATE())
        AND YEAR(Order_Date) = YEAR(CURDATE());
      `;
      break;
    default:
      return res.status(400).json({ error: 'Invalid query type' });
  }

  console.log('Executing query:', sqlQuery);

  db.query(sqlQuery, (err, results) => {
    if (err) {
      console.error('Error executing query:', err);
      return res.status(500).json({ error: 'Database error' });
    }
    console.log('Query results:', results);
    res.json(results);
  });
});

// Start the server
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});