const express = require('express');
const path = require('path');
const fs = require('fs');
const cors = require('cors');
const app = express();
const port = process.env.PORT || 3000;

// We'll use mssql for SQL Server
const sql = require('mssql');

// Middleware to parse JSON
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Super verbose logging middleware
app.use((req, res, next) => {
  console.log(`
  ===== NEW REQUEST =====
  Time: ${new Date().toISOString()}
  Method: ${req.method}
  URL: ${req.url}
  Headers: ${JSON.stringify(req.headers, null, 2)}
  `);
  next();
});

// Updated SQL Server Configuration - Using Windows Authentication
const config = {
  server: 'localhost',  // Default instance
  database: 'Hwang_Andrew_db',
  options: {
    encrypt: false,
    trustServerCertificate: true,
    enableArithAbort: true
  },
  authentication: {
    //type: 'default',  // Windows Authentication
    type: 'ntlm', 
    options: {
      trustedConnection: true
    }
  }
};

// Comprehensive CORS configuration
app.use(cors({
  origin: true,  // Reflects the request origin
  methods: ['GET', 'POST', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true
}));

// Serve static files from the current directory
app.use(express.static(__dirname));

// Queries definition (extracted from Lai_Regan_queries.sql)
const queries = {
  'top_purchased_items': {
    title: 'Top 5 Most Frequently Purchased Items',
    query: `
SELECT TOP 5
    I.Item_ID,
    I.Brand,
    I.Stock,
    I.Purchase_Frequency AS Purchase_Frequency,
    I.Retail_Price
FROM
    Item I
ORDER BY
    I.Purchase_Frequency DESC;
    `
  },
  'low_selling_items': {
    title: 'Low Selling Items with Discount Strategy',
    query: `
SELECT TOP 10
    I.Item_ID,
    I.Brand,
    I.Stock,
    I.Purchase_Frequency,
    I.Retail_Price,
    CASE
        WHEN I.Purchase_Frequency < 50 THEN 25
        WHEN I.Purchase_Frequency < 100 THEN 15
        ELSE 10
    END AS Suggested_Discount_Percentage,
    I.Retail_Price * (1 - CASE
        WHEN I.Purchase_Frequency < 50 THEN 0.25
        WHEN I.Purchase_Frequency < 100 THEN 0.15
        ELSE 0.10
    END) AS Discounted_Price
FROM
    Item I
ORDER BY
    I.Purchase_Frequency ASC;
    `
  },
  'top_rated_employees': {
    title: 'Employees with Exceptional Customer Ratings',
    query: `
SELECT
    E.Employee_ID,
    E.First_Name + ' ' + E.Last_Name AS Employee_Name,
    E.Role,
    AVG(CF.Rating) AS Average_Rating,
    COUNT(CF.Feedback_ID) AS Total_Feedback_Count,
    CAST((SELECT TOP 1 Message FROM Customer_feedback 
           WHERE Employee_ID = E.Employee_ID 
           ORDER BY Rating DESC) AS VARCHAR(MAX)) AS Representative_Comment
FROM
    Employee E
    JOIN Customer_feedback CF ON E.Employee_ID = CF.Employee_ID
GROUP BY
    E.Employee_ID,
    E.First_Name,
    E.Last_Name,
    E.Role
HAVING
    AVG(CF.Rating) >= 4.5
ORDER BY
    Average_Rating DESC;
    `
  },
  'delivery_frequency': {
    title: 'Frequency of Grocery Delivery Services',
    query: `
SELECT
    o.Order_Type_ID,
    ot.Type_Name AS Delivery_Type,
    COUNT(*) AS Delivery_Frequency,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Orders), 2) AS Delivery_Percentage
FROM
    Orders o
    JOIN Order_Types ot ON o.Order_Type_ID = ot.Type_ID
GROUP BY
    o.Order_Type_ID,
    ot.Type_Name;
    `
  },
  'order_amount_analysis': {
    title: 'Average Grocery Order Amount Analysis',
    query: `
SELECT
    AVG(Total_amount) AS Average_Order_Amount,
    MIN(Total_amount) AS Minimum_Order_Amount,
    MAX(Total_amount) AS Maximum_Order_Amount,
    COUNT(*) AS Total_Orders,
    STDEV(Total_amount) AS Order_Amount_Variation,
    SUM(CASE WHEN Total_amount < 20 THEN 1 ELSE 0 END) AS Small_Orders,
    SUM(CASE WHEN Total_amount BETWEEN 20 AND 50 THEN 1 ELSE 0 END) AS Medium_Orders,
    SUM(CASE WHEN Total_amount > 50 THEN 1 ELSE 0 END) AS Large_Orders
FROM
    Orders;
    `
  }
};

// Database connection state
let isConnected = false;
let pool = null;

// Connect to database with enhanced error reporting
async function connectToDatabase() {
  try {
    console.log('Testing basic SQL Server connection...');

    // Try a simpler connection first
    const testPool = new sql.ConnectionPool({
      server: 'localhost',
      options: {
        trustServerCertificate: true,
        trustedConnection: true  // Use Windows Authentication
      }
    });

    await testPool.connect();
    console.log('Basic connection test succeeded! Now trying to connect to the database...');
    await testPool.close();
  } catch (err) {
    console.error('Basic connection test failed:', err.message);
    console.error('Database connection error:', {
      message: err.message,
      code: err.code,
      stack: err.stack,
      originalError: err.originalError ? {
        code: err.originalError.code,
        message: err.originalError.message
      } : 'No original error'
    });
    isConnected = false;
    return false;
  }
}

// Execute query with better error handling
async function executeQuery(queryText) {
  try {
    if (!pool || !isConnected) {
      console.log('Reconnecting to database before executing query');
      await connectToDatabase();
    }

    console.log('Executing query:', queryText.substring(0, 100) + '...');
    const request = pool.request();
    const result = await request.query(queryText);
    console.log(`Query executed successfully. Rows returned: ${result.recordset.length}`);
    return result.recordset;
  } catch (err) {
    console.error('Query execution error:', {
      message: err.message,
      query: queryText.substring(0, 100) + '...',
      stack: err.stack
    });
    throw err;
  }
}

// Root endpoint for testing
app.get('/', (req, res) => {
  res.status(200).send(`
    <h1>API Server is running</h1>
    <p>Server time: ${new Date().toISOString()}</p>
    <p>Database connection: ${isConnected ? 'Connected' : 'Not connected'}</p>
    <p>Available endpoints:</p>
    <ul>
      <li><a href="/query-info">/query-info</a> - Get information about available queries</li>
      <li><a href="/test">/test</a> - Test endpoint</li>
    </ul>
  `);
});

// Initial connection attempt on startup
connectToDatabase();

// Detailed query info endpoint
app.get('/query-info', (req, res) => {
  console.log('Query Info Request Received');
  try {
    const enrichedQueries = {};

    Object.entries(queries).forEach(([key, queryObj]) => {
      enrichedQueries[key] = {
        title: queryObj.title,
        query: queryObj.query,
        description: `Query for ${queryObj.title}`
      };
    });

    res.status(200).json({
      queries: enrichedQueries,
      serverTime: new Date().toISOString(),
      databaseStatus: isConnected,
      availableQueries: Object.keys(enrichedQueries)
    });
  } catch (error) {
    console.error('Error in /query-info:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      details: error.message
    });
  }
});

app.get('/test', (req, res) => {
  res.status(200).json({
    message: 'Server is running',
    time: new Date().toISOString(),
    databaseStatus: isConnected
  });
});

// Query execution endpoint
app.post('/execute-query', async (req, res) => {
  const { queryKey } = req.body;

  if (!queryKey || !queries[queryKey]) {
    return res.status(400).json({ error: 'Invalid query key' });
  }

  try {
    const queryResults = await executeQuery(queries[queryKey].query);
    res.json(queryResults);
  } catch (error) {
    console.error('Query execution error:', error);
    res.status(500).json({
      error: 'Query execution failed',
      details: error.message
    });
  }
});

// Start the server
const server = app.listen(port, '0.0.0.0', () => {
  console.log(`
  ===== SERVER STARTED =====
  Time: ${new Date().toISOString()}
  Port: ${port}
  Environment: ${process.env.NODE_ENV || 'development'}
  
  Access URLs:
  - Local:      http://localhost:${port}
  - Network:    http://0.0.0.0:${port}
  `);
});

// Improved error handling
server.on('error', (error) => {
  console.error('Server startup error:', {
    name: error.name,
    message: error.message,
    code: error.code,
    stack: error.stack
  });

  if (error.code === 'EADDRINUSE') {
    console.error(`Port ${port} is already in use`);
  }
});

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('Received shutdown signal');
  try {
    if (pool) {
      await pool.close();
      console.log('Database connection closed');
    }
    server.close(() => {
      console.log('Server shut down');
      process.exit(0);
    });
  } catch (err) {
    console.error('Error during shutdown:', err);
    process.exit(1);
  }
});