# **Database Query Selector**

## **Overview**

Database Query Selector is a Java application that allows users to run predefined SQL queries against a grocery store database. The application provides a simple graphical interface to select and execute queries related to inventory management, customer behavior, employee performance, and order statistics.

## **Features**

* Select and execute up to 5 queries simultaneously  
* View query results in a tabular format  
* Reference 7 business scenarios related to the grocery store operation  
* Analyze frequently purchased items, slow-selling inventory, employee feedback, delivery services, and order amounts

## **Prerequisites**

* Java Development Kit (JDK) 8 or higher  
* Microsoft SQL Server (2016 or newer)  
* Microsoft SQL Server JDBC Driver  
* IntelliJ IDEA (recommended) or another Java IDE

## **Setup Instructions**

### **1\. Download the Repository**

1. Unzip the file and open the DatabaseQuerySelector in a Java IDE (Preferably IntelliJ Ultimate Edition)

### **2\. SQL Server Configuration**

* Ensure the SQL Server is running  
* Verify Windows Authentication is enabled  
* The database `Hwang_Andrew_db` must be created and populated (use the included `Hwang_Andrew_db.sql` script if needed)

### **3\. Project Setup in IntelliJ IDEA**

1. Open the project in IntelliJ IDEA  
2. Verify the project structure:  
   * The `lib` folder should contain:  
     * `mssql-jdbc-12.8.1.jre11.jar` (or compatible version)  
     * `mssql-jdbc_auth-12.8.1.x64.dll` (or compatible version)

### **4\. Configure Run Configuration**

1. Go to Run → Edit Configurations  
2. Click the "+" button to create a new Application Configuration  
3. Set the following:  
   * Name: `DatabaseQuerySelector`  
   * Main class: `DatabaseQuerySelector`  
   * Click "Modify options" and select "VM options"  
   * VM options: `-Djava.library.path=$PROJECT_DIR$/lib`  
   * Working directory: \[Your project root directory\]  
4. Click "Apply" and "OK"

### **6\. Connecting the Database in IntelliJ IDEA**

1. Open IntelliJ IDEA  
2. Go to View \> Tool Windows \> Database, OR  
3. Add a new data source:  
   * Click the "+" icon in the Database tool window  
   * Select "Data Source" \> "Microsoft SQL Server"  
4. Configure the connection:  
   * Name: Hwang\_Andrew\_db (or any descriptive name)  
   * Host: localhost  
   * Port: 1433  
   * Database: Hwang\_Andrew\_db  
   * Authentication: Integrated Security (for Windows authentication) OR  
   * Enter your SQL Server username and password  
5. Test the connection:  
   * Click the "Test Connection" button  
   * If prompted to download missing drivers, click "Download"  
6. Apply the settings:  
   * Click "Apply" and then "OK"  
7. Verify the connection:  
   * The database should appear in the Database tool window  
   * You should see a connection labeled "Hwang\_Andrew\_db@localhost"

## **Running the Application**

1. Locate and run the `DatabaseQuerySelector.java` file  
2. The application window will open showing:  
   * A list of available queries on the left side  
   * A list of business scenarios for reference  
   * A results table on the right side  
3. To execute queries:  
   * Select one or more queries from the list (hold Ctrl to select multiple)  
   * Click the "Execute Selected Queries" button  
   * Results will be displayed in the table on the right

## **Available Queries**

1. **Frequently Purchased Items and Stock**  
   * Shows items with the highest purchase frequency and their current stock levels  
2. **Slow-Selling Items with Discount Strategy**  
   * Identifies slow-moving inventory and suggests appropriate discount percentages  
3. **Employees with Exceptional Comments**  
   * Lists employees who have received high ratings and positive customer feedback  
4. **Grocery Delivery Service Frequency**  
   * Displays statistics on how often customers use the delivery service  
5. **Average Grocery Order Amounts**  
   * Provides analytics on order amounts, including averages and distribution by size  
6. **In-Store Shopping Activity**  
   * Shows details of customer shopping activity at physical store locations  
7. **Customer Return Information**  
   * Lists returned items, reasons for return, and compliance with return policies  
8. **Membership Registration Status (errors)**  
   * Displays customer registration dates and membership types  
9. **Customer Ratings and Feedback (errors)**  
   * Shows all customer ratings and feedback for employees and the store  
10. **Customer Purchase History**  
    * Detailed history of customer purchases, including items, quantities, and prices  
11. **Grocery Delivery Orders (errors)**  
    * Lists delivery orders with addresses, times, and amounts  
12. **Currency Exchange Transactions**  
    * Shows currency exchange transactions at cashier stations

## **Business Scenarios**

1. **Shop At The Grocery Store**  
   * Customers shopping at physical locations, returning items, or using the mobile app  
   * *Linked Queries*: In-Store Shopping Activity  
2. **Return Items**  
   * Customers returning purchased items within the terms of the return policy  
   * *Linked Queries*: Customer Return Information  
3. **Register For Membership Program**  
   * New customers registering for the store's membership system  
   * *Linked Queries*: Membership Registration Status  
4. **Rate Employees/Store**  
   * Customers providing ratings and feedback for employees and the store  
   * *Linked Queries*: Customer Ratings and Feedback, Employees with Exceptional Comments  
5. **History**  
   * Customers viewing summaries of their purchase history  
   * *Linked Queries*: Customer Purchase History  
6. **Request For Grocery Delivery**  
   * Customers ordering delivery with minimum spending requirements  
   * *Linked Queries*: Grocery Delivery Orders, Grocery Delivery Service Frequency  
7. **Exchange Currency**  
   * Customers exchanging or breaking bills at cashier stations  
   * *Linked Queries*: Currency Exchange Transactions

