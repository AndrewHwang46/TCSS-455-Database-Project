-- Database Creation
DROP DATABASE IF EXISTS Hwang_Andrew_db;
CREATE DATABASE Hwang_Andrew_db;


USE Hwang_Andrew_db;


-- Table Creation
-- Department Table
CREATE TABLE Department (
    Department_ID INT PRIMARY KEY,
    Department_Name VARCHAR(100) NOT NULL,
    Manager_ID INT NULL
);


-- Employee Table
CREATE TABLE Employee (
    Employee_ID INT PRIMARY KEY,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Role VARCHAR(50) NOT NULL,
    Salary DECIMAL(10, 2) NOT NULL,
    Date_of_Hire DATE NOT NULL,
    Department INT NOT NULL,
    Phone_Number VARCHAR(15) NOT NULL,
    Manager_ID INT NULL,
    Rating DECIMAL(3,2) DEFAULT 0,  -- Added for rating functionality
    FOREIGN KEY (Department) REFERENCES Department(Department_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Manager_ID) REFERENCES Employee(Employee_ID) ON DELETE SET NULL ON UPDATE CASCADE
);


-- Add Manager_ID foreign key to Department after Employee table is created
ALTER TABLE Department
ADD CONSTRAINT FK_Department_Manager
FOREIGN KEY (Manager_ID) REFERENCES Employee(Employee_ID) ON DELETE SET NULL ON UPDATE CASCADE;


-- Supplier Table
CREATE TABLE Supplier (
    Name VARCHAR(100) PRIMARY KEY,
    Price_of_item DECIMAL(10, 2) NOT NULL,
    Contract_start_date DATE NOT NULL,
    Contract_end_date DATE NOT NULL
);


-- Item Table
CREATE TABLE Item (
    Item_ID INT PRIMARY KEY,
    Expiration_Date DATE,
    Stock INT NOT NULL,
    Retail_Price DECIMAL(10, 2) NOT NULL,
    Wholesale_Price DECIMAL(10, 2) NOT NULL,
    Brand VARCHAR(100) NOT NULL,
    Supplier_Name VARCHAR(100),
    Purchase_Frequency INT DEFAULT 0,  -- Added field for tracking purchase frequency
    FOREIGN KEY (Supplier_Name) REFERENCES Supplier(Name) ON DELETE SET NULL ON UPDATE CASCADE
);


-- Inventory Table
CREATE TABLE Inventory (
    Item_ID INT PRIMARY KEY,
    Quantity INT NOT NULL,
    Last_restock_date DATE NOT NULL,
    Location VARCHAR(100) NOT NULL,
    FOREIGN KEY (Item_ID) REFERENCES Item(Item_ID) ON DELETE CASCADE ON UPDATE CASCADE
);


-- Item Promotion Table
CREATE TABLE Item_Promotion (
    Promotion_ID INT PRIMARY KEY,
    Description VARCHAR(255) NOT NULL,
    Start_date DATE NOT NULL,
    End_date DATE NOT NULL,
    Discount_Percentage DECIMAL(5, 2) NOT NULL
);


-- Item_Promotion_Bridge (Junction table)
CREATE TABLE Item_Promotion_Bridge (
    Item_ID INT,
    Promotion_ID INT,
    PRIMARY KEY (Item_ID, Promotion_ID),
    FOREIGN KEY (Item_ID) REFERENCES Item(Item_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Promotion_ID) REFERENCES Item_Promotion(Promotion_ID) ON DELETE CASCADE ON UPDATE CASCADE
);


-- Create a type for shopping choices
CREATE TABLE Shopping_Types (
    Type_ID INT PRIMARY KEY,
    Type_Name VARCHAR(20) NOT NULL
);


-- Insert shopping type values
INSERT INTO Shopping_Types (Type_ID, Type_Name) VALUES 
(1, 'In-Store'),
(2, 'Online'),
(3, 'Both');


-- Create a table for order types
CREATE TABLE Order_Types (
    Type_ID INT PRIMARY KEY,
    Type_Name VARCHAR(20) NOT NULL
);


-- Insert order type values
INSERT INTO Order_Types (Type_ID, Type_Name) VALUES 
(1, 'In-Store'),
(2, 'Delivery');


-- Create a table for shopping methods
CREATE TABLE Shopping_Methods (
    Method_ID INT PRIMARY KEY,
    Method_Name VARCHAR(20) NOT NULL
);


-- Insert shopping method values
INSERT INTO Shopping_Methods (Method_ID, Method_Name) VALUES 
(1, 'In-Store'),
(2, 'Online');


-- Create a table for delivery statuses
CREATE TABLE Delivery_Statuses (
    Status_ID INT PRIMARY KEY,
    Status_Name VARCHAR(20) NOT NULL
);


-- Insert delivery status values
INSERT INTO Delivery_Statuses (Status_ID, Status_Name) VALUES 
(1, 'Processing'),
(2, 'Shipped'),
(3, 'Delivered'),
(4, 'Cancelled');


-- Create a table for return methods
CREATE TABLE Return_Methods (
    Method_ID INT PRIMARY KEY,
    Method_Name VARCHAR(20) NOT NULL
);


-- Insert return method values
INSERT INTO Return_Methods (Method_ID, Method_Name) VALUES 
(1, 'In-Store'),
(2, 'Mail');


-- Customer Table
CREATE TABLE Customer (
    Customer_ID INT PRIMARY KEY,
    First_name VARCHAR(50) NOT NULL,
    Last_name VARCHAR(50) NOT NULL,
    Receipt INT NULL,
    Member INT NULL,
    Coupon VARCHAR(50) NULL,  -- Changed to VARCHAR to match Coupon PK
    Giftcard VARCHAR(50) NULL, -- Changed to VARCHAR to match Giftcard PK
    Order_ID INT NULL,
    Shipping_Address INT NULL,
    Customer_Feedback INT NULL,
    Returns INT NULL,
    Grocery_app INT NULL,
    Shopping_Type_ID INT DEFAULT 1,  -- 1 = In-Store, 2 = Online, 3 = Both
    FOREIGN KEY (Shopping_Type_ID) REFERENCES Shopping_Types(Type_ID)
);


-- Orders Table - Created earlier in the script to avoid FK issues
CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    Total_items INT NOT NULL,
    Quantity INT NOT NULL,
    Price_of_individual_item DECIMAL(10, 2) NOT NULL,
    Total_amount DECIMAL(10, 2) NOT NULL,
    Customer_ID INT NOT NULL,
    Order_Type_ID INT DEFAULT 1,  -- 1 = In-Store, 2 = Delivery
    Minimum_Delivery_Amount DECIMAL(10, 2) DEFAULT 25.00,  -- Minimum amount for delivery
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Order_Type_ID) REFERENCES Order_Types(Type_ID)
);


-- Receipt Table
CREATE TABLE Receipt (
    Receipt_ID INT PRIMARY KEY,
    Date_of_purchase DATE NOT NULL,
    Amount_spent DECIMAL(10, 2) NOT NULL,
    Total_number_of_items INT NOT NULL,
    Total_purchase_amount DECIMAL(10, 2) NOT NULL,
    Payment VARCHAR(50) NOT NULL,
    Customer_ID INT NOT NULL,
    Shopping_Method_ID INT DEFAULT 1
);


-- Purchase History Table (for tracking customer purchase history)
-- Added because it was referenced in queries but missing in original schema
CREATE TABLE Purchase_History (
    History_ID INT IDENTITY(1,1) PRIMARY KEY,
    Customer_ID INT NOT NULL,
    Receipt_ID INT NOT NULL,
    Item_ID INT NOT NULL,
    Quantity INT NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    Purchase_Date DATE NOT NULL,
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Receipt_ID) REFERENCES Receipt(Receipt_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Item_ID) REFERENCES Item(Item_ID) ON DELETE CASCADE ON UPDATE CASCADE
);


-- Member Table
CREATE TABLE Member (
    Membership_ID INT PRIMARY KEY,
    First_Name VARCHAR(50) NOT NULL,
    Last_Name VARCHAR(50) NOT NULL,
    Date_of_Birth DATE NOT NULL,
    Credit_Card_Information VARCHAR(255) NOT NULL,
    Join_Date DATE NOT NULL,
    Membership_Level VARCHAR(50) NOT NULL,
    Points INT DEFAULT 0,
    Billing_Date DATE NOT NULL,
    Customer_ID INT NOT NULL,
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID) ON DELETE CASCADE ON UPDATE CASCADE
);


-- Giftcard Table
CREATE TABLE Giftcard (
    Gift_card_number VARCHAR(50) PRIMARY KEY,
    Expiration_date DATE NOT NULL,
    Balance_amount DECIMAL(10, 2) NOT NULL,
    Customer_ID INT NOT NULL,
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID) ON DELETE CASCADE ON UPDATE CASCADE
);


-- Coupon Table
CREATE TABLE Coupon (
    Coupon_code VARCHAR(50) PRIMARY KEY,
    Discount_amount DECIMAL(10, 2) NOT NULL,
    Expiration_date DATE NOT NULL,
    Minimum_purchase_amount DECIMAL(10, 2) NOT NULL,
    Terms_and_conditions TEXT,
    Customer_ID INT NOT NULL,
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID) ON DELETE CASCADE ON UPDATE CASCADE
);


-- Shipments Table
CREATE TABLE Shipments (
    Shipping_ID INT PRIMARY KEY,
    Shipping_company VARCHAR(100) NOT NULL,
    Order_date DATE NOT NULL,
    ETA DATE NOT NULL,
    Departure_time TIME NOT NULL,
    Order_ID INT NOT NULL,
    Delivery_Status_ID INT DEFAULT 1,  -- 1 = Processing
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Delivery_Status_ID) REFERENCES Delivery_Statuses(Status_ID)
);


-- Shipping Address Table
CREATE TABLE Shipping_Address (
    Customer_ID INT PRIMARY KEY,
    Address VARCHAR(255) NOT NULL,
    City VARCHAR(100) NOT NULL,
    Postal_Code VARCHAR(20) NOT NULL,
    Country VARCHAR(100) NOT NULL,
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID) ON DELETE CASCADE ON UPDATE CASCADE
);


-- Grocery App Table
CREATE TABLE Grocery_app (
    Customer_ID INT PRIMARY KEY,
    Date_of_purchase DATE NOT NULL,
    Cart TEXT NOT NULL,
    Item_ID INT,
    Item_Quantity INT NOT NULL,
    Total_price DECIMAL(10, 2) NOT NULL,
    Discount DECIMAL(10, 2) DEFAULT 0,
    Pickup_time TIME,
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Item_ID) REFERENCES Item(Item_ID) ON DELETE SET NULL ON UPDATE CASCADE
);


-- Returns Table
CREATE TABLE Returns (
    Return_ID INT PRIMARY KEY,
    Date_of_Return DATE NOT NULL,
    Total_value_of_return DECIMAL(10, 2) NOT NULL,
    Item_ID INT,
    Reason VARCHAR(255) NOT NULL,
    Customer_ID INT NOT NULL,
    Return_Method_ID INT DEFAULT 1,  -- 1 = In-Store, 2 = Mail
    FOREIGN KEY (Item_ID) REFERENCES Item(Item_ID) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Return_Method_ID) REFERENCES Return_Methods(Method_ID)
);


-- Customer Return Table (for return specific data) - Added because referenced in queries
CREATE TABLE Customer_Return (
    Return_ID INT PRIMARY KEY,
    Item_ID INT NOT NULL,
    Quantity INT NOT NULL,
    Amount_refunded DECIMAL(10, 2) NOT NULL,
    Return_Policy_Compliant TINYINT DEFAULT 1,  -- 0=false, 1=true
    FOREIGN KEY (Return_ID) REFERENCES Returns(Return_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Item_ID) REFERENCES Item(Item_ID) ON DELETE NO ACTION ON UPDATE CASCADE
);


-- Customer Feedback Table - Added because referenced in queries
CREATE TABLE Customer_feedback (
    Feedback_ID INT PRIMARY KEY,
    Message TEXT NOT NULL,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),  -- Added for rating values 1-5
    Employee_ID INT NULL,  -- Added to link feedback to specific employees
    Store_Rating INT CHECK (Store_Rating BETWEEN 1 AND 5),  -- Added for store rating
    Customer_ID INT NOT NULL,
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID) ON DELETE SET NULL ON UPDATE CASCADE
);


-- Payment Table
CREATE TABLE Payment (
    Payment_ID INT PRIMARY KEY,
    Payment_method VARCHAR(50) NOT NULL,
    Payment_amount DECIMAL(10, 2) NOT NULL,
    Payment_date DATE NOT NULL,
    Payment_status VARCHAR(20) NOT NULL CHECK (Payment_status IN ('success', 'fail')),
    Currency_Exchange TINYINT DEFAULT 0,  -- 0=false, 1=true
    Exchange_Details VARCHAR(255) NULL,  -- Details of currency exchange
    Customer_ID INT NOT NULL,
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID) ON DELETE CASCADE ON UPDATE CASCADE
);


-- Waste Table
CREATE TABLE Waste (
    Waste_ID INT PRIMARY KEY,
    Reason VARCHAR(255) NOT NULL,
    Quantity INT NOT NULL,
    Date DATE NOT NULL,
    Item INT,
    Amount_lost DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (Item) REFERENCES Item(Item_ID) ON DELETE SET NULL ON UPDATE CASCADE
);


-- Update Customer table with foreign keys after all referenced tables are created
ALTER TABLE Customer
ADD CONSTRAINT FK_Customer_Order
FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID) ON DELETE SET NULL ON UPDATE CASCADE;


ALTER TABLE Customer
ADD CONSTRAINT FK_Customer_Receipt
FOREIGN KEY (Receipt) REFERENCES Receipt(Receipt_ID) ON DELETE SET NULL ON UPDATE CASCADE;


ALTER TABLE Customer
ADD CONSTRAINT FK_Customer_Member
FOREIGN KEY (Member) REFERENCES Member(Membership_ID) ON DELETE SET NULL ON UPDATE CASCADE;


ALTER TABLE Customer
ADD CONSTRAINT FK_Customer_Coupon
FOREIGN KEY (Coupon) REFERENCES Coupon(Coupon_code) ON DELETE SET NULL ON UPDATE CASCADE;


ALTER TABLE Customer
ADD CONSTRAINT FK_Customer_Giftcard
FOREIGN KEY (Giftcard) REFERENCES Giftcard(Gift_card_number) ON DELETE SET NULL ON UPDATE CASCADE;


ALTER TABLE Customer
ADD CONSTRAINT FK_Customer_Shipping_Address
FOREIGN KEY (Shipping_Address) REFERENCES Shipping_Address(Customer_ID) ON DELETE SET NULL ON UPDATE CASCADE;


ALTER TABLE Customer
ADD CONSTRAINT FK_Customer_Feedback
FOREIGN KEY (Customer_Feedback) REFERENCES Customer_feedback(Feedback_ID) ON DELETE SET NULL ON UPDATE CASCADE;


ALTER TABLE Customer
ADD CONSTRAINT FK_Customer_Returns
FOREIGN KEY (Returns) REFERENCES Returns(Return_ID) ON DELETE SET NULL ON UPDATE CASCADE;


ALTER TABLE Customer
ADD CONSTRAINT FK_Customer_Grocery_app
FOREIGN KEY (Grocery_app) REFERENCES Grocery_app(Customer_ID) ON DELETE SET NULL ON UPDATE CASCADE;


-- ========================================
-- SAMPLE DATA INSERTION
-- ========================================

-- Department Data
INSERT INTO Department (Department_ID, Department_Name, Manager_ID) VALUES 
(1, 'Produce', NULL),
(2, 'Bakery', NULL),
(3, 'Meat & Seafood', NULL),
(4, 'Dairy', NULL),
(5, 'Grocery', NULL);


-- Employee Data
INSERT INTO Employee (Employee_ID, First_Name, Last_Name, Role, Salary, Date_of_Hire, Department, Phone_Number, Manager_ID, Rating) VALUES 
(1, 'John', 'Smith', 'Manager', 75000.00, '2020-01-15', 1, '555-123-4567', NULL, 4.5),
(2, 'Emily', 'Johnson', 'Assistant Manager', 60000.00, '2020-03-20', 1, '555-234-5678', 1, 4.8),
(3, 'Michael', 'Williams', 'Manager', 78000.00, '2019-11-10', 2, '555-345-6789', NULL, 4.2),
(4, 'Jessica', 'Brown', 'Clerk', 42000.00, '2021-02-05', 2, '555-456-7890', 3, 3.9),
(5, 'David', 'Jones', 'Manager', 76000.00, '2019-10-25', 3, '555-567-8901', NULL, 4.7),
(6, 'Sarah', 'Miller', 'Cashier', 38000.00, '2021-05-15', 5, '555-678-9012', NULL, 4.1),
(7, 'Robert', 'Taylor', 'Stocker', 35000.00, '2021-07-10', 5, '555-789-0123', NULL, 3.8),
(8, 'Jennifer', 'Anderson', 'Deli Clerk', 40000.00, '2021-04-20', 3, '555-890-1234', 5, 4.3),
(9, 'Christopher', 'Thomas', 'Bakery Assistant', 39000.00, '2021-06-12', 2, '555-901-2345', 3, 4.0),
(10, 'Lisa', 'White', 'Produce Clerk', 37000.00, '2021-08-05', 1, '555-012-3456', 1, 4.2);


-- Update Department with Manager IDs
UPDATE Department SET Manager_ID = 1 WHERE Department_ID = 1;
UPDATE Department SET Manager_ID = 3 WHERE Department_ID = 2;
UPDATE Department SET Manager_ID = 5 WHERE Department_ID = 3;


-- Supplier Data
INSERT INTO Supplier (Name, Price_of_item, Contract_start_date, Contract_end_date) VALUES
('Fresh Farms', 1.50, '2023-01-01', '2024-12-31'),
('Bakery Supplies Inc', 2.25, '2023-02-15', '2024-12-31'),
('Premium Meats', 5.75, '2023-01-10', '2024-06-30'),
('Dairy Delights', 2.00, '2023-03-01', '2024-12-31'),
('Grocery Wholesalers', 1.25, '2023-01-01', '2025-12-31'),
('Organic Producers', 2.75, '2023-04-15', '2024-12-31'),
('Farm Fresh Eggs', 1.85, '2023-02-10', '2024-10-31'),
('Quality Seafood', 7.50, '2023-01-20', '2024-06-30'),
('Global Imports', 3.25, '2023-03-10', '2025-06-30'),
('Local Farmers Co-op', 2.10, '2023-05-01', '2024-12-31');


-- Item Data
INSERT INTO Item (Item_ID, Expiration_Date, Stock, Retail_Price, Wholesale_Price, Brand, Supplier_Name, Purchase_Frequency) VALUES
(1, '2023-12-31', 100, 3.99, 1.50, 'Organic Greens', 'Fresh Farms', 120),
(2, '2023-12-15', 150, 5.49, 2.25, 'Fresh Bread', 'Bakery Supplies Inc', 95),
(3, '2023-12-20', 75, 12.99, 5.75, 'Premium Beef', 'Premium Meats', 50),
(4, '2023-12-25', 200, 4.49, 2.00, 'Dairy Fresh Milk', 'Dairy Delights', 180),
(5, '2024-06-30', 300, 2.99, 1.25, 'Everyday Essentials Rice', 'Grocery Wholesalers', 25),
(6, '2023-12-18', 120, 6.99, 2.75, 'Organic Berries', 'Organic Producers', 110),
(7, '2023-12-22', 180, 3.99, 1.85, 'Farm Fresh Eggs', 'Farm Fresh Eggs', 85),
(8, '2023-12-19', 60, 15.99, 7.50, 'Wild Salmon', 'Quality Seafood', 35),
(9, '2024-05-30', 250, 7.49, 3.25, 'Imported Pasta', 'Global Imports', 40),
(10, '2023-12-27', 90, 4.99, 2.10, 'Local Honey', 'Local Farmers Co-op', 65),
(11, '2023-12-31', 110, 3.49, 1.50, 'Fresh Spinach', 'Fresh Farms', 70),
(12, '2023-12-16', 140, 4.99, 2.25, 'Artisan Rolls', 'Bakery Supplies Inc', 60),
(13, '2023-12-21', 85, 10.99, 5.75, 'Organic Chicken', 'Premium Meats', 75),
(14, '2023-12-26', 220, 3.99, 2.00, 'Dairy Fresh Yogurt', 'Dairy Delights', 130),
(15, '2024-06-28', 320, 3.49, 1.25, 'Everyday Essentials Pasta', 'Grocery Wholesalers', 20);


-- Inventory Data
INSERT INTO Inventory (Item_ID, Quantity, Last_restock_date, Location) VALUES
(1, 100, '2023-11-01', 'Aisle A1'),
(2, 150, '2023-11-05', 'Aisle B2'),
(3, 75, '2023-11-10', 'Aisle C3'),
(4, 200, '2023-11-15', 'Aisle D4'),
(5, 300, '2023-11-20', 'Aisle E5'),
(6, 120, '2023-11-03', 'Aisle A2'),
(7, 180, '2023-11-07', 'Aisle B1'),
(8, 60, '2023-11-12', 'Aisle C4'),
(9, 250, '2023-11-18', 'Aisle D2'),
(10, 90, '2023-11-22', 'Aisle A3'),
(11, 110, '2023-11-02', 'Aisle A4'),
(12, 140, '2023-11-06', 'Aisle B3'),
(13, 85, '2023-11-11', 'Aisle C2'),
(14, 220, '2023-11-16', 'Aisle D1'),
(15, 320, '2023-11-21', 'Aisle E3');


-- Item Promotion Data
INSERT INTO Item_Promotion (Promotion_ID, Description, Start_date, End_date, Discount_Percentage) VALUES
(1, 'Holiday Sale', '2023-12-01', '2023-12-31', 10.00),
(2, 'Weekend Special', '2023-12-08', '2023-12-10', 15.00),
(3, 'Clearance', '2023-12-15', '2023-12-31', 25.00),
(4, 'New Year Sale', '2023-12-26', '2024-01-05', 20.00),
(5, 'Member Exclusive', '2023-12-01', '2023-12-31', 5.00),
(6, 'Flash Sale', '2023-12-05', '2023-12-07', 30.00),
(7, 'Buy One Get One', '2023-12-10', '2023-12-20', 50.00),
(8, 'Seasonal Items', '2023-12-01', '2023-12-25', 15.00);


-- Item Promotion Bridge Data
INSERT INTO Item_Promotion_Bridge (Item_ID, Promotion_ID) VALUES
(1, 1), (2, 1), (3, 2), (4, 3), (5, 4),
(1, 5), (3, 5), (6, 1), (7, 2), (8, 3),
(9, 4), (10, 5), (11, 6), (12, 7), (13, 8),
(14, 6), (15, 7), (2, 8), (4, 8), (6, 8);


-- Customer Data (initial without foreign keys)
INSERT INTO Customer (Customer_ID, First_name, Last_name, Shopping_Type_ID) VALUES
(1, 'Alice', 'Anderson', 3), -- Both
(2, 'Bob', 'Baker', 1),      -- In-Store
(3, 'Charlie', 'Clark', 2),  -- Online
(4, 'Diana', 'Davis', 1),    -- In-Store
(5, 'Edward', 'Evans', 3),   -- Both
(6, 'Fiona', 'Foster', 2),   -- Online
(7, 'George', 'Garcia', 1),  -- In-Store
(8, 'Hannah', 'Hill', 3),    -- Both
(9, 'Ian', 'Irwin', 1),      -- In-Store
(10, 'Julia', 'Jones', 2);   -- Online


-- Insert Orders data
INSERT INTO Orders (Order_ID, Total_items, Quantity, Price_of_individual_item, Total_amount, Customer_ID, Order_Type_ID) VALUES
(1, 5, 5, 9.19, 45.97, 1, 1),
(2, 3, 3, 10.83, 32.48, 2, 1),
(3, 8, 8, 9.87, 78.95, 3, 2),
(4, 2, 2, 13.00, 25.99, 4, 1),
(5, 6, 6, 9.25, 55.48, 5, 2),
(6, 2, 2, 9.50, 18.99, 6, 2),
(7, 7, 7, 9.69, 67.85, 7, 1),
(8, 4, 4, 10.69, 42.75, 8, 1),
(9, 3, 3, 11.16, 33.49, 9, 1),
(10, 5, 5, 11.99, 59.97, 10, 2);


-- Receipt Data
INSERT INTO Receipt (Receipt_ID, Date_of_purchase, Amount_spent, Total_number_of_items, Total_purchase_amount, Payment, Customer_ID, Shopping_Method_ID) VALUES
(1, '2023-11-05', 45.97, 5, 45.97, 'Credit Card', 1, 1), -- In-Store
(2, '2023-11-10', 32.48, 3, 32.48, 'Cash', 2, 1),        -- In-Store
(3, '2023-11-15', 78.95, 8, 78.95, 'Credit Card', 3, 2), -- Online
(4, '2023-11-20', 25.99, 2, 25.99, 'Debit Card', 4, 1),  -- In-Store
(5, '2023-11-25', 55.48, 6, 55.48, 'Credit Card', 5, 2), -- Online
(6, '2023-11-07', 18.99, 2, 18.99, 'Credit Card', 6, 2), -- Online
(7, '2023-11-12', 67.85, 7, 67.85, 'Cash', 7, 1),        -- In-Store
(8, '2023-11-18', 42.75, 4, 42.75, 'Debit Card', 8, 1),  -- In-Store
(9, '2023-11-22', 33.49, 3, 33.49, 'Credit Card', 9, 1), -- In-Store
(10, '2023-11-28', 59.97, 5, 59.97, 'Credit Card', 10, 2), -- Online
(11, '2023-11-06', 29.98, 3, 29.98, 'Debit Card', 1, 2),   -- Online
(12, '2023-11-11', 45.47, 4, 45.47, 'Credit Card', 2, 1),  -- In-Store
(13, '2023-11-16', 15.98, 2, 15.98, 'Cash', 3, 2),         -- Online
(14, '2023-11-21', 88.96, 9, 88.96, 'Credit Card', 4, 1),  -- In-Store
(15, '2023-11-26', 37.49, 4, 37.49, 'Debit Card', 5, 2);   -- Online


-- Insert data for Purchase_History
INSERT INTO Purchase_History (Customer_ID, Receipt_ID, Item_ID, Quantity, Price, Purchase_Date) VALUES
(1, 1, 1, 2, 7.98, '2023-11-05'),
(1, 1, 6, 3, 20.97, '2023-11-05'),
(2, 2, 2, 2, 10.98, '2023-11-10'),
(2, 2, 7, 1, 3.99, '2023-11-10'),
(3, 3, 3, 1, 12.99, '2023-11-15'),
(3, 3, 8, 2, 31.98, '2023-11-15'),
(4, 4, 4, 2, 8.98, '2023-11-20'),
(5, 5, 5, 3, 8.97, '2023-11-25'),
(5, 5, 9, 2, 14.98, '2023-11-25');


-- Add some sample data for Customer_feedback
INSERT INTO Customer_feedback (Feedback_ID, Message, Rating, Employee_ID, Store_Rating, Customer_ID) VALUES
(1, 'Great service in Produce department!', 5, 1, 5, 1),
(2, 'Bakery items were fresh and delicious', 4, 3, 4, 2),
(3, 'Meat counter service was excellent', 5, 5, 5, 3),
(4, 'Waited too long at checkout', 2, 6, 3, 4),
(5, 'Very helpful staff in finding items', 4, 7, 4, 5),
(6, 'Online ordering was seamless', 5, NULL, 5, 6),
(7, 'Store was clean and well organized', 4, NULL, 4, 7);


-- Returns data with careful attention to IDs
INSERT INTO Returns (Return_ID, Date_of_Return, Total_value_of_return, Item_ID, Reason, Customer_ID, Return_Method_ID) VALUES
(1, '2023-11-08', 3.99, 1, 'Poor quality', 1, 1),          -- In-Store
(2, '2023-11-12', 5.49, 2, 'Wrong item', 2, 1),            -- In-Store
(3, '2023-11-18', 12.99, 3, 'Not satisfied', 3, 2),        -- Mail
(4, '2023-11-22', 4.49, 4, 'Expired product', 4, 1),       -- In-Store
(5, '2023-11-26', 6.99, 6, 'Damaged packaging', 5, 1),     -- In-Store
(6, '2023-11-09', 15.99, 8, 'Wrong flavor', 6, 2),         -- Mail
(7, '2023-11-14', 3.99, 7, 'Bad taste', 7, 1);             -- In-Store


-- Customer Return data
INSERT INTO Customer_Return (Return_ID, Item_ID, Quantity, Amount_refunded, Return_Policy_Compliant) VALUES
(1, 1, 1, 3.99, 1),
(2, 2, 1, 5.49, 1),
(3, 3, 1, 12.99, 0),
(4, 4, 1, 4.49, 1),
(5, 6, 1, 6.99, 1),
(6, 8, 1, 15.99, 0),
(7, 7, 1, 3.99, 1);


-- Giftcard Data
INSERT INTO Giftcard (Gift_card_number, Expiration_date, Balance_amount, Customer_ID) VALUES
('GC-12345', '2024-12-31', 50.00, 1),
('GC-23456', '2024-12-31', 100.00, 2),
('GC-34567', '2024-12-31', 25.00, 3),
('GC-45678', '2024-12-31', 75.00, 4),
('GC-56789', '2024-12-31', 30.00, 5),
('GC-67890', '2024-12-31', 60.00, 6),
('GC-78901', '2024-12-31', 40.00, 7);


-- Coupon Data
INSERT INTO Coupon (Coupon_code, Discount_amount, Expiration_date, Minimum_purchase_amount, Terms_and_conditions, Customer_ID) VALUES
('HOLIDAY10', 10.00, '2023-12-31', 50.00, 'Valid on all purchases', 1),
('WEEKEND15', 15.00, '2023-12-10', 75.00, 'Valid only on weekends', 2),
('NEWYEAR20', 20.00, '2024-01-05', 100.00, 'Valid on all purchases', 3),
('WELCOME5', 5.00, '2023-12-31', 25.00, 'New customer welcome offer', 4),
('BIRTHDAY25', 25.00, '2023-12-31', 75.00, 'Valid during birthday month', 5),
('LOYAL10', 10.00, '2023-12-31', 50.00, 'For members over 6 months', 6),
('SEASONAL15', 15.00, '2023-12-25', 60.00, 'Valid on seasonal items only', 7);


-- Shipments Data
INSERT INTO Shipments (Shipping_ID, Shipping_company, Order_date, ETA, Departure_time, Order_ID, Delivery_Status_ID) VALUES
(1, 'Express Delivery', '2023-11-05', '2023-11-07', '10:00:00', 1, 3), -- Delivered
(2, 'Fast Shipping', '2023-11-10', '2023-11-12', '11:00:00', 2, 1),    -- Processing
(3, 'Express Delivery', '2023-11-15', '2023-11-17', '09:00:00', 3, 2), -- Shipped
(4, 'Standard Shipping', '2023-11-20', '2023-11-23', '14:00:00', 4, 1), -- Processing
(5, 'Fast Shipping', '2023-11-25', '2023-11-27', '13:00:00', 5, 3),     -- Delivered
(6, 'Standard Shipping', '2023-11-07', '2023-11-10', '15:00:00', 6, 2), -- Shipped
(7, 'Express Delivery', '2023-11-12', '2023-11-14', '10:30:00', 7, 1),  -- Processing
(8, 'Fast Shipping', '2023-11-18', '2023-11-20', '11:30:00', 8, 3),     -- Delivered
(9, 'Express Delivery', '2023-11-22', '2023-11-24', '09:30:00', 9, 2),  -- Shipped
(10, 'Standard Shipping', '2023-11-28', '2023-12-01', '14:30:00', 10, 1); -- Processing


-- Shipping Address Data
INSERT INTO Shipping_Address (Customer_ID, Address, City, Postal_Code, Country) VALUES
(1, '123 Main St', 'New York', '10001', 'USA'),
(2, '456 Maple Ave', 'Los Angeles', '90001', 'USA'),
(3, '789 Oak Blvd', 'Chica', '60601', 'USA'),
(4, '321 Pine St', 'Houston', '77001', 'USA'),
(5, '654 Cedar Rd', 'Miami', '33101', 'USA'),
(6, '987 Birch Ave', 'Seattle', '98101', 'USA'),
(7, '159 Walnut St', 'Boston', '02101', 'USA'),
(8, '753 Elm Dr', 'Denver', '80201', 'USA'),
(9, '246 Cherry Ln', 'Atlanta', '30301', 'USA'),
(10, '864 Spruce Way', 'San Francisco', '94101', 'USA');


-- Grocery App Data
INSERT INTO Grocery_app (Customer_ID, Date_of_purchase, Cart, Item_ID, Item_Quantity, Total_price, Discount, Pickup_time) VALUES
(1, '2023-11-05', 'Organic Greens, Fresh Bread', 1, 2, 9.48, 0, '15:30:00'),
(2, '2023-11-10', 'Premium Beef, Farm Fresh Eggs', 3, 1, 16.98, 0, '16:45:00'),
(3, '2023-11-15', 'Dairy Fresh Milk, Wild Salmon', 4, 2, 20.48, 0, NULL),
(4, '2023-11-20', 'Local Honey, Organic Berries', 10, 1, 11.98, 0, '14:15:00'),
(5, '2023-11-25', 'Artisan Rolls, Fresh Spinach', 12, 2, 8.48, 0, NULL),
(6, '2023-11-07', 'Organic Chicken, Imported Pasta', 13, 1, 18.48, 0, NULL),
(7, '2023-11-12', 'Dairy Fresh Yogurt, Rice', 14, 3, 11.97, 0, '17:30:00');


-- Member Data
INSERT INTO Member (Membership_ID, First_Name, Last_Name, Date_of_Birth, Credit_Card_Information, Join_Date, Membership_Level, Points, Billing_Date, Customer_ID) VALUES
(1, 'Alice', 'Anderson', '1985-05-15', 'XXXX-XXXX-XXXX-1234', '2022-01-10', 'ld', 500, '2023-12-10', 1),
(2, 'Bob', 'Baker', '1990-07-20', 'XXXX-XXXX-XXXX-5678', '2022-02-15', 'Silver', 300, '2023-12-15', 2),
(3, 'Charlie', 'Clark', '1988-03-25', 'XXXX-XXXX-XXXX-9012', '2022-03-20', 'Bronze', 150, '2023-12-20', 3),
(4, 'Diana', 'Davis', '1992-08-10', 'XXXX-XXXX-XXXX-3456', '2022-04-05', 'Bronze', 100, '2023-12-05', 4),
(5, 'Edward', 'Evans', '1980-11-30', 'XXXX-XXXX-XXXX-7890', '2022-05-12', 'Silver', 250, '2023-12-12', 5),
(6, 'Fiona', 'Foster', '1995-02-18', 'XXXX-XXXX-XXXX-1357', '2022-06-20', 'Bronze', 50, '2023-12-20', 6),
(7, 'George', 'Garcia', '1982-09-05', 'XXXX-XXXX-XXXX-2468', '2022-07-15', 'ld', 650, '2023-12-15', 7)

-- Payment Data
INSERT INTO Payment (Payment_ID, Payment_method, Payment_amount, Payment_date, Payment_status, Currency_Exchange, Exchange_Details, Customer_ID) VALUES
(1, 'Credit Card', 45.97, '2023-11-05', 'success', 0, NULL, 1),
(2, 'Cash', 32.48, '2023-11-10', 'success', 1, 'Exchanged $50 bill for smaller denominations', 2),
(3, 'Credit Card', 78.95, '2023-11-15', 'success', 0, NULL, 3),
(4, 'Debit Card', 25.99, '2023-11-20', 'success', 0, NULL, 4),
(5, 'Credit Card', 55.48, '2023-11-25', 'success', 1, 'Exchanged coins for $10 bill', 5),
(6, 'Credit Card', 18.99, '2023-11-07', 'success', 0, NULL, 6),
(7, 'Cash', 67.85, '2023-11-12', 'success', 1, 'Exchanged $100 bill for smaller bills', 7),
(8, 'Debit Card', 42.75, '2023-11-18', 'success', 0, NULL, 8),
(9, 'Credit Card', 33.49, '2023-11-22', 'success', 0, NULL, 9),
(10, 'Credit Card', 59.97, '2023-11-28', 'success', 0, NULL, 10),
(11, 'Debit Card', 29.98, '2023-11-06', 'success', 0, NULL, 1),
(12, 'Credit Card', 45.47, '2023-11-11', 'success', 0, NULL, 2),
(13, 'Cash', 15.98, '2023-11-16', 'success', 1, 'Exchanged $20 bill for coins', 3),
(14, 'Credit Card', 88.96, '2023-11-21', 'success', 0, NULL, 4),
(15, 'Debit Card', 37.49, '2023-11-26', 'success', 0, NULL, 5);


-- Waste Data
INSERT INTO Waste (Waste_ID, Reason, Quantity, Date, Item, Amount_lost) VALUES
(1, 'Expired', 5, '2023-11-02', 1, 7.50),
(2, 'Damaged', 3, '2023-11-05', 2, 6.75),
(3, 'Spoiled', 2, '2023-11-08', 3, 11.50),
(4, 'Expired', 4, '2023-11-12', 4, 8.00),
(5, 'Damaged', 2, '2023-11-15', 6, 5.50),
(6, 'Expired', 5, '2023-11-18', 7, 9.25),
(7, 'Damaged', 1, '2023-11-22', 8, 7.50);


-- Update Customer table with foreign keys
UPDATE Customer
SET 
    Member = 1,
    Receipt = 1,
    Giftcard = 'GC-12345',
    Coupon = 'HOLIDAY10',
    Order_ID = 1,
    Shipping_Address = 1,
    Customer_Feedback = 1,
    Returns = 1,
    Grocery_app = 1
WHERE Customer_ID = 1;


UPDATE Customer
SET 
    Member = 2,
    Receipt = 2,
    Giftcard = 'GC-23456',
    Coupon = 'WEEKEND15',
    Order_ID = 2,
    Shipping_Address = 2,
    Customer_Feedback = 2,
    Returns = 2,
    Grocery_app = 2
WHERE Customer_ID = 2;


UPDATE Customer
SET 
    Member = 3,
    Receipt = 3,
    Giftcard = 'GC-34567',
    Coupon = 'NEWYEAR20',
    Order_ID = 3,
    Shipping_Address = 3,
    Customer_Feedback = 3,
    Returns = 3,
    Grocery_app = 3
WHERE Customer_ID = 3;


UPDATE Customer
SET 
    Member = 4,
    Receipt = 4,
    Giftcard = 'GC-45678',
    Coupon = 'WELCOME5',
    Order_ID = 4,
    Shipping_Address = 4,
    Customer_Feedback = 4,
    Returns = 4,
    Grocery_app = 4
WHERE Customer_ID = 4;


UPDATE Customer
SET 
    Member = 5,
    Receipt = 5,
    Giftcard = 'GC-56789',
    Coupon = 'BIRTHDAY25',
    Order_ID = 5,
    Shipping_Address = 5,
    Customer_Feedback = 5,
    Returns = 5,
    Grocery_app = 5
WHERE Customer_ID = 5;


UPDATE Customer
SET 
    Member = 6,
    Receipt = 6,
    Giftcard = 'GC-67890',
    Coupon = 'LOYAL10',
    Order_ID = 6,
    Shipping_Address = 6,
    Customer_Feedback = 6,
    Returns = 6,
    Grocery_app = 6
WHERE Customer_ID = 6;


UPDATE Customer
SET 
    Member = 7,
    Receipt = 7,
    Giftcard = 'GC-78901',
    Coupon = 'SEASONAL15',
    Order_ID = 7,
    Shipping_Address = 7,
    Customer_Feedback = 7,
    Returns = 7,
    Grocery_app = 7
WHERE Customer_ID = 7;
