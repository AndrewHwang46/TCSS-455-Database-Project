USE Hwang_Andrew_db;

-- customers who shopped in-store
SELECT 
    c.Customer_ID, 
    c.First_name, 
    c.Last_name, 
    s.Type_Name AS Shopping_Type, 
    r.Date_of_purchase, 
    r.Total_purchase_amount

-- customers who returned items at the physical location
SELECT 
    c.Customer_ID, 
    c.First_name, 
    c.Last_name, 
    r.Date_of_Return, 
    r.Total_value_of_return, 
    rm.Method_Name AS Return_Method
FROM 
    Returns r
JOIN 
    Customer c ON r.Customer_ID = c.Customer_ID
JOIN 
    Return_Methods rm ON r.Return_Method_ID = rm.Method_ID
WHERE 
    rm.Method_Name = 'In-Store';

-- customers who shopped online through the mobile app
SELECT 
    g.Customer_ID, 
    c.First_name, 
    c.Last_name, 
    g.Date_of_purchase, 
    g.Cart, 
    g.Total_price, 
    g.Pickup_time
FROM 
    Grocery_app g
JOIN 
    Customer c ON g.Customer_ID = c.Customer_ID;

-- show all customer returns along with product details and value
SELECT 
    c.Customer_ID,
    c.First_name,
    c.Last_name,
    r.Date_of_Return,
    r.Total_value_of_return,
    p.Product_ID,
    p.Product_name,
    p.Price,
    rp.Policy_ID,
    rp.Policy_Description
FROM 
    Returns r
JOIN 
    Customer c ON r.Customer_ID = c.Customer_ID
JOIN 
    Returned_Items ri ON r.Return_ID = ri.Return_ID
JOIN 
    Product p ON ri.Product_ID = p.Product_ID
LEFT JOIN 
    Return_Policy rp ON p.Policy_ID = rp.Policy_ID;

-- check if the customer already exists (based on phone number or email, or some unique identifier)
SELECT * 
FROM Customer
WHERE Email = 'newcustomer@email.com'
   OR Phone = '123-456-7890';

-- if no matching record exists, insert the new customer (registration)
INSERT INTO Customer (First_name, Last_name, Email, Phone, Address, City, State, Zip_Code, Date_of_birth, Membership_Status)
VALUES ('Andrew', 'Hwang', 'newcustomer@email.com', '123-456-7890', '123 Main St', 'Seattle', 'WA', '98101', '2000-02-28', 'Active');

-- rating for the Store (anonymous)
INSERT INTO Ratings (Customer_ID, Employee_ID, Rating_Target, Rating_Score, Rating_Comments)
VALUES (NULL, NULL, 'Store', 5, 'Great service and fresh produce!');

-- rating for a specific Employee by a Customer
INSERT INTO Ratings (Customer_ID, Employee_ID, Rating_Target, Rating_Score, Rating_Comments)
VALUES (101, 7, 'Employee', 4, 'The cashier was super helpful!');

SELECT 
    C.Customer_ID,
    CONCAT(C.First_name, ' ', C.Last_name) AS Customer_Name,
    O.Order_ID,
    O.Order_Date,
    P.Product_Name,
    OI.Quantity,
    OI.Price AS Price_Per_Unit,
    (OI.Quantity * OI.Price) AS Total_Item_Cost
FROM 
    Customer C
JOIN 
    Orders O ON C.Customer_ID = O.Customer_ID
JOIN 
    Order_Item OI ON O.Order_ID = OI.Order_ID
JOIN 
    Product P ON OI.Product_ID = P.Product_ID
WHERE 
    C.Customer_ID = 101  -- example customer 
ORDER BY 
    O.Order_Date DESC;

DELIMITER $$

-- customers may request a delivery service
CREATE PROCEDURE RequestDelivery(
    IN orderID INT, 
    OUT deliveryEligible BOOLEAN
)
BEGIN
    DECLARE totalAmount DECIMAL(10, 2);

    SELECT SUM(OI.Quantity * OI.Price)
    INTO totalAmount
    FROM Order_Item OI
    WHERE OI.Order_ID = orderID;

    -- check if eligible for delivery (minimum $50 requirement)
    IF totalAmount >= 50.00 THEN
        UPDATE Orders
        SET DeliveryRequested = TRUE
        WHERE Order_ID = orderID;

        SET deliveryEligible = TRUE;
    ELSE
        SET deliveryEligible = FALSE;
    END IF;
END$$

DELIMITER ;

-- table to track bill exchange requests
CREATE TABLE Bill_Exchange (
    Transaction_ID INT PRIMARY KEY AUTO_INCREMENT,
    Customer_ID INT NOT NULL,
    Request_Amount DECIMAL(10, 2) NOT NULL, 
    Action_Type VARCHAR(50) NOT NULL, 
    Amount_Given DECIMAL(10, 2) NOT NULL,  
    Cashier_ID INT NOT NULL,  
    Request_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID) ON DELETE CASCADE,
    FOREIGN KEY (Cashier_ID) REFERENCES Employee(Employee_ID) ON DELETE CASCADE
);

-- request to break a bill into smaller denominations 
INSERT INTO Bill_Exchange (Customer_ID, Request_Amount, Action_Type, Amount_Given, Cashier_ID)
VALUES (101, 100.00, 'Break Bill', 100.00, 2001);

-- Analytical queries 
-- #1 Finds the top 5 items that are frequently purchased and their stock.
SELECT TOP 5
    I.Item_ID,
    I.Brand,
    I.Stock,
    COUNT(PH.Item_ID) AS Purchase_Frequency
FROM
    Purchase_History PH
JOIN
    Item I ON PH.Item_ID = I.Item_ID
GROUP BY
    I.Item_ID, I.Brand, I.Stock
ORDER BY
    Purchase_Frequency DESC;

-- #2 Find items that are not selling as well as expected(may adjust the Top x number count)
SELECT TOP 3
    Item_ID,
    Brand,
    Stock
FROM 
    Item
ORDER BY 
    Stock DESC;

-- #3 Find employees who have received comments (feedback) from customers
SELECT 
    E.Employee_ID,
    E.First_Name,
    E.Last_Name,
    CF.Message AS Customer_Comment
FROM 
    Employee E
JOIN 
    Customer_feedback CF ON E.Employee_ID = CF.Employee_ID;

-- #4 Find the frequency of customers requesting grocery delivery services
SELECT COUNT(*) AS Delivery_Frequency
FROM Orders
WHERE Order_Type_ID = 2;

-- #5 Find the average amount spent on grocery orders
SELECT AVG(Total_amount) AS Average_Amount_Spent
FROM Orders;