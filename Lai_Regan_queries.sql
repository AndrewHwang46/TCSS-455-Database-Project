USE Hwang_Andrew_db;

-- Scenario 1: Shop At The Grocery Store

-- 1.1 In-Store Shopping
SELECT
    c.Customer_ID,
    c.First_name + ' ' + c.Last_name AS Customer_Name,
    st.Type_Name AS Shopping_Type,
    r.Date_of_purchase,
    r.Total_purchase_amount,
    sm.Method_Name AS Shopping_Method
FROM
    Customer c
    JOIN Shopping_Types st ON c.Shopping_Type_ID = st.Type_ID
    JOIN Receipt r ON c.Customer_ID = r.Customer_ID
    JOIN Shopping_Methods sm ON r.Shopping_Method_ID = sm.Method_ID
WHERE
    st.Type_Name = 'In-Store' OR sm.Method_Name = 'In-Store';

-- 1.2 Online Shopping through Mobile App
SELECT
    c.Customer_ID,
    c.First_name + ' ' + c.Last_name AS Customer_Name,
    g.Date_of_purchase,
    g.Cart,
    g.Total_price,
    g.Pickup_time
FROM
    Grocery_app g
    JOIN Customer c ON g.Customer_ID = c.Customer_ID;

-- Scenario 2: Return Items

-- 2.1 Return Items at Physical Location
SELECT
    c.Customer_ID,
    c.First_name + ' ' + c.Last_name AS Customer_Name,
    r.Date_of_Return,
    i.Brand AS Returned_Item,
    r.Reason,
    rm.Method_Name AS Return_Method,
    cr.Return_Policy_Compliant
FROM
    Returns r
    JOIN Customer c ON r.Customer_ID = c.Customer_ID
    JOIN Return_Methods rm ON r.Return_Method_ID = rm.Method_ID
    JOIN Item i ON r.Item_ID = i.Item_ID
    JOIN Customer_Return cr ON r.Return_ID = cr.Return_ID
WHERE
    rm.Method_Name = 'In-Store';

-- 2.2 Check Return Policy Compliance
SELECT
    r.Return_ID,
    i.Brand,
    r.Date_of_Return,
    CASE
        WHEN cr.Return_Policy_Compliant = 1 THEN 'Compliant'
        ELSE 'Non-Compliant'
    END AS Policy_Status
FROM
    Returns r
    JOIN Customer_Return cr ON r.Return_ID = cr.Return_ID
    JOIN Item i ON cr.Item_ID = i.Item_ID;

-- Scenario 3: Register for Membership Program

-- 3.1 Register New Member
-- Check if procedure exists before creating it
IF OBJECT_ID('RegisterNewMember', 'P') IS NOT NULL
    DROP PROCEDURE RegisterNewMember;
GO

CREATE PROCEDURE RegisterNewMember
    @CustomerID INT,
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @DateOfBirth DATE,
    @CreditCardInfo NVARCHAR(255)
AS
BEGIN
    DECLARE @MembershipID INT;

    -- Generate next membership ID
    SELECT @MembershipID = ISNULL(MAX(Membership_ID), 0) + 1
    FROM Member;

    INSERT INTO Member (
        Membership_ID,
        First_Name,
        Last_Name,
        Date_of_Birth,
        Credit_Card_Information,
        Join_Date,
        Membership_Level,
        Points,
        Billing_Date,
        Customer_ID
    )
    VALUES (
        @MembershipID,
        @FirstName,
        @LastName,
        @DateOfBirth,
        @CreditCardInfo,
        GETDATE(),
        'Bronze',  -- Default initial level
        0,         -- Starting points
        DATEADD(MONTH, 1, GETDATE()),  -- First billing date
        @CustomerID
    );
END;
GO

-- Scenario 4: Rate Employees/Store

-- 4.1 Rate Employees
INSERT INTO Customer_feedback (
    Feedback_ID,
    Message,
    Rating,
    Employee_ID,
    Store_Rating,
    Customer_ID
)
VALUES (
    (SELECT ISNULL(MAX(Feedback_ID), 0) + 1 FROM Customer_feedback),
    'Helpful and courteous service',
    5,  -- Rating
    7,  -- Employee ID
    NULL,  -- No store rating
    1   -- Customer ID
);

-- 4.2 Rate Store (Anonymous/Not Anonymous)
-- Modified to use a valid customer ID since NULL is not allowed
INSERT INTO Customer_feedback (
    Feedback_ID,
    Message,
    Rating,
    Employee_ID,
    Store_Rating,
    Customer_ID
)
VALUES (
    (SELECT ISNULL(MAX(Feedback_ID), 0) + 1 FROM Customer_feedback),
    'Great overall shopping experience',
    NULL,  -- No employee rating
    NULL,  -- No specific employee
    5,  -- Store Rating
    1   -- Using a valid Customer ID instead of NULL
);

-- Scenario 5: Purchase History

-- 5.1 Customer Purchase History
SELECT
    c.Customer_ID,
    c.First_name + ' ' + c.Last_name AS Customer_Name,
    i.Brand AS Item_Purchased,
    ph.Quantity,
    ph.Price,
    ph.Purchase_Date
FROM
    Purchase_History ph
    JOIN Customer c ON ph.Customer_ID = c.Customer_ID
    JOIN Item i ON ph.Item_ID = i.Item_ID
WHERE
    c.Customer_ID = 1  -- Example customer
ORDER BY
    ph.Purchase_Date DESC;

-- Scenario 6: Grocery Delivery Request

-- 6.1 Check Delivery Eligibility
-- Check if procedure exists before creating it
IF OBJECT_ID('CheckDeliveryEligibility', 'P') IS NOT NULL
    DROP PROCEDURE CheckDeliveryEligibility;
GO

CREATE PROCEDURE CheckDeliveryEligibility
    @OrderID INT,
    @DeliveryEligible BIT OUTPUT
AS
BEGIN
    DECLARE @TotalAmount DECIMAL(10,2);

    SELECT @TotalAmount = Total_amount
    FROM Orders
    WHERE Order_ID = @OrderID;

    IF @TotalAmount >= 25.00  -- Minimum delivery amount
    BEGIN
        UPDATE Orders
        SET Order_Type_ID = 2  -- Set to Delivery
        WHERE Order_ID = @OrderID;

        SET @DeliveryEligible = 1;
    END
    ELSE
    BEGIN
        SET @DeliveryEligible = 0;
    END
END;
GO

-- Scenario 7: Currency Exchange

-- 7.1 Create Bill Exchange Tracking Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Bill_Exchange')
BEGIN
    CREATE TABLE Bill_Exchange (
        Transaction_ID INT IDENTITY(1,1) PRIMARY KEY,
        Customer_ID INT,
        Employee_ID INT,
        Request_Amount DECIMAL(10,2),
        Amount_Exchanged DECIMAL(10,2),
        Exchange_Type NVARCHAR(50),  -- 'Break Bill', 'Coin to Bill', etc.
        Exchange_Date DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID),
        FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID)
    );
END
GO

-- 7.2 Log Bill Exchange Transaction
IF NOT EXISTS (SELECT * FROM Bill_Exchange WHERE Customer_ID = 1 AND Employee_ID = 6 AND Exchange_Type = 'Break Bill')
BEGIN
    INSERT INTO Bill_Exchange (
        Customer_ID,
        Employee_ID,
        Request_Amount,
        Amount_Exchanged,
        Exchange_Type
    )
    VALUES (
        1,  -- Customer ID
        6,  -- Cashier Employee ID
        100.00,  -- Requested amount
        100.00,  -- Exchanged amount
        'Break Bill'  -- Exchange type
    );
END
GO

-- 7.3 Bill Exchange History
SELECT
    be.Transaction_ID,
    c.First_name + ' ' + c.Last_name AS Customer_Name,
    e.First_Name + ' ' + e.Last_Name AS Cashier_Name,
    be.Request_Amount,
    be.Amount_Exchanged,
    be.Exchange_Type,
    be.Exchange_Date
FROM
    Bill_Exchange be
    JOIN Customer c ON be.Customer_ID = c.Customer_ID
    JOIN Employee e ON be.Employee_ID = e.Employee_ID;

-- 1. Find items that are frequently purchased and their stock
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

-- 2. Find items that are not selling as well as expected and potential discount strategy
SELECT TOP 10
    I.Item_ID,
    I.Brand,
    I.Stock,
    I.Purchase_Frequency,
    I.Retail_Price,
    -- Calculate potential discount percentage
    CASE
        WHEN I.Purchase_Frequency < 50 THEN 25  -- High discount for very slow items
        WHEN I.Purchase_Frequency < 100 THEN 15 -- Medium discount
        ELSE 10  -- Low discount
    END AS Suggested_Discount_Percentage,
    -- Calculate discounted price
    I.Retail_Price * (1 - CASE
        WHEN I.Purchase_Frequency < 50 THEN 0.25  -- High discount for very slow items
        WHEN I.Purchase_Frequency < 100 THEN 0.15 -- Medium discount
        ELSE 0.10  -- Low discount
    END) AS Discounted_Price
FROM
    Item I
ORDER BY
    I.Purchase_Frequency ASC;

-- 3. Find employees with exceptional comments from customers
-- Fixed STRING_AGG function usage with proper data type
SELECT
    E.Employee_ID,
    E.First_Name + ' ' + E.Last_Name AS Employee_Name,
    E.Role,
    AVG(CF.Rating) AS Average_Rating,
    COUNT(CF.Feedback_ID) AS Total_Feedback_Count,
    -- Convert TEXT to VARCHAR to use with STRING_AGG
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

-- 4. Find the frequency of customers requesting grocery delivery services
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

-- 5. Find the average amount spent on grocery orders with additional insights
SELECT
    AVG(Total_amount) AS Average_Order_Amount,
    MIN(Total_amount) AS Minimum_Order_Amount,
    MAX(Total_amount) AS Maximum_Order_Amount,
    COUNT(*) AS Total_Orders,
    STDEV(Total_amount) AS Order_Amount_Variation,
    -- Categorize order sizes
    SUM(CASE WHEN Total_amount < 20 THEN 1 ELSE 0 END) AS Small_Orders,
    SUM(CASE WHEN Total_amount BETWEEN 20 AND 50 THEN 1 ELSE 0 END) AS Medium_Orders,
    SUM(CASE WHEN Total_amount > 50 THEN 1 ELSE 0 END) AS Large_Orders
FROM
    Orders;