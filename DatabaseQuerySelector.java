import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.swing.event.ListSelectionListener;
import javax.swing.event.ListSelectionEvent;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.ListSelectionModel;
import javax.swing.SwingUtilities;
import javax.swing.table.DefaultTableModel;

public class DatabaseQuerySelector {
    // Static database connection parameters
    private static final String URL = "jdbc:sqlserver://localhost:1433;databaseName=Hwang_Andrew_db" +
            ";encrypt=true;trustServerCertificate=true;integratedSecurity=true";

    // Updated Queries based on requirements
    private static final String[] AVAILABLE_QUERIES = {
            "1. Frequently Purchased Items and Stock",
            "2. Slow-Selling Items with Discount Strategy",
            "3. Employees with Exceptional Comments",
            "4. Grocery Delivery Service Frequency",
            "5. Average Grocery Order Amounts",
            "6. In-Store Shopping Activity",
            "7. Customer Return Information",
            "8. Membership Registration Status",
            "9. Customer Ratings and Feedback",
            "10. Customer Purchase History",
            "11. Grocery Delivery Orders",
            "12. Currency Exchange Transactions"
    };

    private static final String[] QUERY_STRINGS = {
            // 1. Frequently Purchased Items and Stock
            "SELECT I.Item_ID, I.Brand, I.Stock, " +
                    "I.Purchase_Frequency AS Purchase_Frequency, I.Retail_Price " +
                    "FROM Item I " +
                    "ORDER BY I.Purchase_Frequency DESC",

            // 2. Slow-Selling Items with Discount Strategy
            "SELECT I.Item_ID, I.Brand, I.Stock, I.Purchase_Frequency, I.Retail_Price, " +
                    "CASE WHEN I.Purchase_Frequency < 50 THEN 25 " +
                    "WHEN I.Purchase_Frequency < 100 THEN 15 " +
                    "ELSE 10 END AS Suggested_Discount_Percentage, " +
                    "I.Retail_Price * (1 - CASE WHEN I.Purchase_Frequency < 50 THEN 0.25 " +
                    "WHEN I.Purchase_Frequency < 100 THEN 0.15 ELSE 0.10 END) AS Discounted_Price " +
                    "FROM Item I " +
                    "WHERE I.Purchase_Frequency < 200 " +
                    "ORDER BY I.Purchase_Frequency ASC",

            // 3. Employees with Exceptional Comments
            "SELECT E.Employee_ID, E.First_Name + ' ' + E.Last_Name AS Employee_Name, " +
                    "E.Role, AVG(CF.Rating) AS Average_Rating, " +
                    "COUNT(CF.Feedback_ID) AS Total_Feedback_Count, " +
                    "CAST((SELECT TOP 1 Message FROM Customer_feedback " +
                    "WHERE Employee_ID = E.Employee_ID ORDER BY Rating DESC) AS VARCHAR(MAX)) AS Representative_Comment " +
                    "FROM Employee E " +
                    "JOIN Customer_feedback CF ON E.Employee_ID = CF.Employee_ID " +
                    "GROUP BY E.Employee_ID, E.First_Name, E.Last_Name, E.Role " +
                    "HAVING AVG(CF.Rating) >= 4.5 " +
                    "ORDER BY Average_Rating DESC",

            // 4. Grocery Delivery Service Frequency
            "SELECT o.Order_Type_ID, ot.Type_Name AS Delivery_Type, " +
                    "COUNT(*) AS Delivery_Frequency, " +
                    "ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Orders), 2) AS Delivery_Percentage " +
                    "FROM Orders o " +
                    "JOIN Order_Types ot ON o.Order_Type_ID = ot.Type_ID " +
                    "WHERE ot.Type_Name = 'Delivery' " +
                    "GROUP BY o.Order_Type_ID, ot.Type_Name",

            // 5. Average Grocery Order Amounts
            "SELECT AVG(Total_amount) AS Average_Order_Amount, " +
                    "MIN(Total_amount) AS Minimum_Order_Amount, " +
                    "MAX(Total_amount) AS Maximum_Order_Amount, " +
                    "COUNT(*) AS Total_Orders, " +
                    "STDEV(Total_amount) AS Order_Amount_Variation, " +
                    "SUM(CASE WHEN Total_amount < 20 THEN 1 ELSE 0 END) AS Small_Orders, " +
                    "SUM(CASE WHEN Total_amount BETWEEN 20 AND 50 THEN 1 ELSE 0 END) AS Medium_Orders, " +
                    "SUM(CASE WHEN Total_amount > 50 THEN 1 ELSE 0 END) AS Large_Orders " +
                    "FROM Orders",

            // 6. In-Store Shopping Activity
            "SELECT c.Customer_ID, c.First_name + ' ' + c.Last_name AS Customer_Name, " +
                    "st.Type_Name AS Shopping_Type, r.Date_of_purchase, " +
                    "r.Total_purchase_amount, sm.Method_Name AS Shopping_Method " +
                    "FROM Customer c " +
                    "JOIN Shopping_Types st ON c.Shopping_Type_ID = st.Type_ID " +
                    "JOIN Receipt r ON c.Customer_ID = r.Customer_ID " +
                    "JOIN Shopping_Methods sm ON r.Shopping_Method_ID = sm.Method_ID " +
                    "WHERE st.Type_Name = 'In-Store' OR sm.Method_Name = 'In-Store'",

            // 7. Customer Return Information
            "SELECT c.Customer_ID, c.First_name + ' ' + c.Last_name AS Customer_Name, " +
                    "r.Date_of_Return, i.Brand AS Returned_Item, r.Reason, " +
                    "rm.Method_Name AS Return_Method, cr.Return_Policy_Compliant " +
                    "FROM Returns r " +
                    "JOIN Customer c ON r.Customer_ID = c.Customer_ID " +
                    "JOIN Return_Methods rm ON r.Return_Method_ID = rm.Method_ID " +
                    "JOIN Item i ON r.Item_ID = i.Item_ID " +
                    "JOIN Customer_Return cr ON r.Return_ID = cr.Return_ID",

            // 8. Membership Registration Status
            "SELECT c.Customer_ID, c.First_name + ' ' + c.Last_name AS Customer_Name, " +
                    "c.Email, c.Phone_Number, c.Registration_Date, " +
                    "mt.Type_Name AS Membership_Type, " +
                    "CASE WHEN c.Registration_Date IS NULL THEN 'Not Registered' ELSE 'Registered' END AS Registration_Status " +
                    "FROM Customer c " +
                    "LEFT JOIN Membership_Types mt ON c.Membership_Type_ID = mt.Type_ID " +
                    "ORDER BY c.Registration_Date DESC",

            // 9. Customer Ratings and Feedback
            "SELECT c.Customer_ID, c.First_name + ' ' + c.Last_name AS Customer_Name, " +
                    "e.First_Name + ' ' + e.Last_Name AS Employee_Name, " +
                    "cf.Rating, cf.Message, cf.Date_of_feedback " +
                    "FROM Customer_feedback cf " +
                    "JOIN Customer c ON cf.Customer_ID = c.Customer_ID " +
                    "JOIN Employee e ON cf.Employee_ID = e.Employee_ID " +
                    "ORDER BY cf.Date_of_feedback DESC",

            // 10. Customer Purchase History
            "SELECT c.Customer_ID, c.First_name + ' ' + c.Last_name AS Customer_Name, " +
                    "i.Brand AS Item_Purchased, ph.Quantity, ph.Price, ph.Purchase_Date " +
                    "FROM Purchase_History ph " +
                    "JOIN Customer c ON ph.Customer_ID = c.Customer_ID " +
                    "JOIN Item i ON ph.Item_ID = i.Item_ID " +
                    "ORDER BY ph.Purchase_Date DESC",

            // 11. Grocery Delivery Orders
            "SELECT o.Order_ID, c.First_name + ' ' + c.Last_name AS Customer_Name, " +
                    "o.Total_amount, o.Delivery_Address, " +
                    "o.Delivery_Time, ot.Type_Name AS Order_Type " +
                    "FROM Orders o " +
                    "JOIN Customer c ON o.Customer_ID = c.Customer_ID " +
                    "JOIN Order_Types ot ON o.Order_Type_ID = ot.Type_ID " +
                    "WHERE ot.Type_Name = 'Delivery' AND o.Total_amount >= 50",

            // 12. Currency Exchange Transactions
            "SELECT c.Customer_ID, c.First_name + ' ' + c.Last_name AS Customer_Name, " +
                    "o.Order_ID, o.Total_amount, ot.Type_Name " +
                    "FROM Orders o " +
                    "JOIN Customer c ON o.Customer_ID = c.Customer_ID " +
                    "JOIN Order_Types ot ON o.Order_Type_ID = ot.Type_ID " +
                    "WHERE o.Total_amount > 0 " +
                    "ORDER BY o.Order_ID DESC"
    };

    // Added scenario descriptions
    private static final String[] SCENARIOS = {
            "1. Shop At The Grocery Store - In-store shopping, returns, or mobile app shopping",
            "2. Return Items - Return purchased items within return policy terms",
            "3. Register For Membership Program - New customers can register for membership",
            "4. Rate Employees/Store - Customers can rate employees or the store",
            "5. History - View purchase history summary",
            "6. Request For Grocery Delivery - Order delivery with minimum spending",
            "7. Exchange Currency - Break bills or exchange change at cashier"
    };

    // Map scenarios to query indices
    private final Map<Integer, List<Integer>> scenarioToQueryMap = new HashMap<>();

    // Main application frame
    private JFrame frame;
    private JList<String> queryList;
    private JButton executeButton;
    private JTable resultTable;
    private DefaultTableModel tableModel;
    private JList<String> scenarioList; // Added scenario list

    // Constructor
    public DatabaseQuerySelector() {
        initializeScenarioMap();
        initializeComponents();
    }

    // Initialize mapping between scenarios and queries
    private void initializeScenarioMap() {
        // Scenario 1: Shop At The Grocery Store
        List<Integer> shopScenarioQueries = new ArrayList<>();
        shopScenarioQueries.add(5); // In-Store Shopping Activity
        scenarioToQueryMap.put(0, shopScenarioQueries);

        // Scenario 2: Return Items
        List<Integer> returnScenarioQueries = new ArrayList<>();
        returnScenarioQueries.add(6); // Customer Return Information
        scenarioToQueryMap.put(1, returnScenarioQueries);

        // Scenario 3: Register For Membership
        List<Integer> membershipScenarioQueries = new ArrayList<>();
        membershipScenarioQueries.add(7); // Membership Registration Status
        scenarioToQueryMap.put(2, membershipScenarioQueries);

        // Scenario 4: Rate Employees/Store
        List<Integer> ratingScenarioQueries = new ArrayList<>();
        ratingScenarioQueries.add(8); // Customer Ratings and Feedback
        ratingScenarioQueries.add(2); // Employees with Exceptional Comments
        scenarioToQueryMap.put(3, ratingScenarioQueries);

        // Scenario 5: History
        List<Integer> historyScenarioQueries = new ArrayList<>();
        historyScenarioQueries.add(9); // Customer Purchase History
        scenarioToQueryMap.put(4, historyScenarioQueries);

        // Scenario 6: Request For Grocery Delivery
        List<Integer> deliveryScenarioQueries = new ArrayList<>();
        deliveryScenarioQueries.add(10); // Grocery Delivery Orders
        deliveryScenarioQueries.add(3);  // Grocery Delivery Service Frequency
        scenarioToQueryMap.put(5, deliveryScenarioQueries);

        // Scenario 7: Exchange Currency
        List<Integer> currencyScenarioQueries = new ArrayList<>();
        currencyScenarioQueries.add(11); // Currency Exchange Transactions
        scenarioToQueryMap.put(6, currencyScenarioQueries);
    }

    // Initialize UI components
    private void initializeComponents() {
        frame = new JFrame("Database Query Selector");
        frame.setSize(1000, 700);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setLayout(new BorderLayout());

        // Create query list
        queryList = new JList<>(AVAILABLE_QUERIES);
        queryList.setSelectionMode(ListSelectionModel.MULTIPLE_INTERVAL_SELECTION);
        JScrollPane listScrollPane = new JScrollPane(queryList);
        listScrollPane.setPreferredSize(new Dimension(280, 200));

        // Create scenario list with selection listener
        scenarioList = new JList<>(SCENARIOS);
        scenarioList.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        scenarioList.addListSelectionListener(e -> {
            if (!e.getValueIsAdjusting()) {
                int selectedIndex = scenarioList.getSelectedIndex();
                if (selectedIndex != -1) {
                    loadScenarioQueries(selectedIndex);
                }
            }
        });
        JScrollPane scenarioScrollPane = new JScrollPane(scenarioList);
        scenarioScrollPane.setPreferredSize(new Dimension(280, 200));

        // Create execute button
        executeButton = new JButton("Execute Selected Queries");
        executeButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                executeSelectedQueries();
            }
        });

        // Create result table
        tableModel = new DefaultTableModel();
        resultTable = new JTable(tableModel);
        JScrollPane tableScrollPane = new JScrollPane(resultTable);

        // Layout components
        JPanel leftPanel = new JPanel(new BorderLayout());
        JPanel selectionPanel = new JPanel(new BorderLayout());

        selectionPanel.add(new JLabel("Select Queries (Ctrl+Click for multiple):"), BorderLayout.NORTH);
        selectionPanel.add(listScrollPane, BorderLayout.CENTER);

        JPanel scenarioPanel = new JPanel(new BorderLayout());
        scenarioPanel.add(new JLabel("Available Scenarios (Click to load related queries):"), BorderLayout.NORTH);
        scenarioPanel.add(scenarioScrollPane, BorderLayout.CENTER);

        leftPanel.add(selectionPanel, BorderLayout.NORTH);
        leftPanel.add(scenarioPanel, BorderLayout.CENTER);
        leftPanel.add(executeButton, BorderLayout.SOUTH);

        frame.add(leftPanel, BorderLayout.WEST);
        frame.add(tableScrollPane, BorderLayout.CENTER);
    }

    // Load queries related to selected scenario
    private void loadScenarioQueries(int scenarioIndex) {
        if (scenarioToQueryMap.containsKey(scenarioIndex)) {
            // Clear current selection
            queryList.clearSelection();

            // Get queries for the selected scenario
            List<Integer> queryIndices = scenarioToQueryMap.get(scenarioIndex);

            // Select those queries in the list
            for (int index : queryIndices) {
                queryList.addSelectionInterval(index, index);
            }

            // Notify user
            JOptionPane.showMessageDialog(frame,
                    "Loaded queries for: " + SCENARIOS[scenarioIndex],
                    "Scenario Loaded",
                    JOptionPane.INFORMATION_MESSAGE);
        }
    }

    // Execute selected queries
    private void executeSelectedQueries() {
        // Get selected indices
        List<Integer> selectedIndices = new ArrayList<>();
        int[] selections = queryList.getSelectedIndices();
        for (int index : selections) {
            selectedIndices.add(index);
        }

        // Validate selection
        if (selectedIndices.isEmpty() || selectedIndices.size() > 5) {
            JOptionPane.showMessageDialog(frame,
                    "Please select between 1 and 5 queries.",
                    "Selection Error",
                    JOptionPane.ERROR_MESSAGE);
            return;
        }

        // Clear previous results
        tableModel.setRowCount(0);
        tableModel.setColumnCount(0);

        // Connect to database and execute queries
        try (Connection conn = DriverManager.getConnection(URL)) {
            // Iterate through selected queries
            for (int index : selectedIndices) {
                try (Statement stmt = conn.createStatement();
                     ResultSet rs = stmt.executeQuery(QUERY_STRINGS[index])) {

                    // Get metadata
                    ResultSetMetaData metaData = rs.getMetaData();
                    int columnCount = metaData.getColumnCount();

                    // Set column names if first query or different columns
                    if (tableModel.getColumnCount() == 0) {
                        String[] columnNames = new String[columnCount];
                        for (int i = 1; i <= columnCount; i++) {
                            columnNames[i-1] = metaData.getColumnName(i);
                        }
                        tableModel.setColumnIdentifiers(columnNames);
                    }

                    // Add query name as a separator
                    if (tableModel.getRowCount() > 0) {
                        Object[] separatorRow = new Object[tableModel.getColumnCount()];
                        separatorRow[0] = "--- " + AVAILABLE_QUERIES[index] + " ---";
                        tableModel.addRow(separatorRow);
                    }

                    // Populate rows
                    while (rs.next()) {
                        Object[] row = new Object[columnCount];
                        for (int i = 1; i <= columnCount; i++) {
                            row[i-1] = rs.getObject(i);
                        }
                        tableModel.addRow(row);
                    }
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(frame,
                    "Database error: " + ex.getMessage(),
                    "Error",
                    JOptionPane.ERROR_MESSAGE);
        }
    }

    // Main method to run the application
    public static void main(String[] args) {
        // Ensure database driver is loaded
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            System.err.println("SQL Server JDBC Driver not found");
            e.printStackTrace();
            return;
        }

        // Run the application
        SwingUtilities.invokeLater(new Runnable() {
            @Override
            public void run() {
                DatabaseQuerySelector app = new DatabaseQuerySelector();
                app.frame.setVisible(true);
            }
        });
    }
}