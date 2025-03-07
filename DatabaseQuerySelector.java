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
import java.util.List;
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

    // Queries from Lai_Regan_queries.sql
    private static final String[] AVAILABLE_QUERIES = {
            "1. In-Store Shopping",
            "2. Online Shopping through Mobile App",
            "3. Return Items at Physical Location",
            "4. Check Return Policy Compliance",
            "5. Customer Purchase History",
            "6. Items Frequently Purchased",
            "7. Slow-Selling Items with Discount Strategy",
            "8. Employees with Exceptional Comments",
            "9. Grocery Delivery Service Frequency",
            "10. Average Grocery Order Amounts"
    };

    private static final String[] QUERY_STRINGS = {
            // 1. In-Store Shopping
            "SELECT c.Customer_ID, c.First_name + ' ' + c.Last_name AS Customer_Name, " +
                    "st.Type_Name AS Shopping_Type, r.Date_of_purchase, " +
                    "r.Total_purchase_amount, sm.Method_Name AS Shopping_Method " +
                    "FROM Customer c " +
                    "JOIN Shopping_Types st ON c.Shopping_Type_ID = st.Type_ID " +
                    "JOIN Receipt r ON c.Customer_ID = r.Customer_ID " +
                    "JOIN Shopping_Methods sm ON r.Shopping_Method_ID = sm.Method_ID " +
                    "WHERE st.Type_Name = 'In-Store' OR sm.Method_Name = 'In-Store'",

            // 2. Online Shopping through Mobile App
            "SELECT c.Customer_ID, c.First_name + ' ' + c.Last_name AS Customer_Name, " +
                    "g.Date_of_purchase, g.Cart, g.Total_price, g.Pickup_time " +
                    "FROM Grocery_app g " +
                    "JOIN Customer c ON g.Customer_ID = c.Customer_ID",

            // 3. Return Items at Physical Location
            "SELECT c.Customer_ID, c.First_name + ' ' + c.Last_name AS Customer_Name, " +
                    "r.Date_of_Return, i.Brand AS Returned_Item, r.Reason, " +
                    "rm.Method_Name AS Return_Method, cr.Return_Policy_Compliant " +
                    "FROM Returns r " +
                    "JOIN Customer c ON r.Customer_ID = c.Customer_ID " +
                    "JOIN Return_Methods rm ON r.Return_Method_ID = rm.Method_ID " +
                    "JOIN Item i ON r.Item_ID = i.Item_ID " +
                    "JOIN Customer_Return cr ON r.Return_ID = cr.Return_ID " +
                    "WHERE rm.Method_Name = 'In-Store'",

            // 4. Check Return Policy Compliance
            "SELECT r.Return_ID, i.Brand, r.Date_of_Return, " +
                    "CASE WHEN cr.Return_Policy_Compliant = 1 THEN 'Compliant' " +
                    "ELSE 'Non-Compliant' END AS Policy_Status " +
                    "FROM Returns r " +
                    "JOIN Customer_Return cr ON r.Return_ID = cr.Return_ID " +
                    "JOIN Item i ON cr.Item_ID = i.Item_ID",

            // 5. Customer Purchase History
            "SELECT c.Customer_ID, c.First_name + ' ' + c.Last_name AS Customer_Name, " +
                    "i.Brand AS Item_Purchased, ph.Quantity, ph.Price, ph.Purchase_Date " +
                    "FROM Purchase_History ph " +
                    "JOIN Customer c ON ph.Customer_ID = c.Customer_ID " +
                    "JOIN Item i ON ph.Item_ID = i.Item_ID " +
                    "WHERE c.Customer_ID = 1 " +
                    "ORDER BY ph.Purchase_Date DESC",

            // 6. Items Frequently Purchased
            "SELECT TOP 5 I.Item_ID, I.Brand, I.Stock, " +
                    "I.Purchase_Frequency AS Purchase_Frequency, I.Retail_Price " +
                    "FROM Item I " +
                    "ORDER BY I.Purchase_Frequency DESC",

            // 7. Slow-Selling Items with Discount Strategy
            "SELECT TOP 10 I.Item_ID, I.Brand, I.Stock, I.Purchase_Frequency, I.Retail_Price, " +
                    "CASE WHEN I.Purchase_Frequency < 50 THEN 25 " +
                    "WHEN I.Purchase_Frequency < 100 THEN 15 " +
                    "ELSE 10 END AS Suggested_Discount_Percentage, " +
                    "I.Retail_Price * (1 - CASE WHEN I.Purchase_Frequency < 50 THEN 0.25 " +
                    "WHEN I.Purchase_Frequency < 100 THEN 0.15 ELSE 0.10 END) AS Discounted_Price " +
                    "FROM Item I " +
                    "ORDER BY I.Purchase_Frequency ASC",

            // 8. Employees with Exceptional Comments
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

            // 9. Grocery Delivery Service Frequency
            "SELECT o.Order_Type_ID, ot.Type_Name AS Delivery_Type, " +
                    "COUNT(*) AS Delivery_Frequency, " +
                    "ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Orders), 2) AS Delivery_Percentage " +
                    "FROM Orders o " +
                    "JOIN Order_Types ot ON o.Order_Type_ID = ot.Type_ID " +
                    "GROUP BY o.Order_Type_ID, ot.Type_Name",

            // 10. Average Grocery Order Amounts
            "SELECT AVG(Total_amount) AS Average_Order_Amount, " +
                    "MIN(Total_amount) AS Minimum_Order_Amount, " +
                    "MAX(Total_amount) AS Maximum_Order_Amount, " +
                    "COUNT(*) AS Total_Orders, " +
                    "STDEV(Total_amount) AS Order_Amount_Variation, " +
                    "SUM(CASE WHEN Total_amount < 20 THEN 1 ELSE 0 END) AS Small_Orders, " +
                    "SUM(CASE WHEN Total_amount BETWEEN 20 AND 50 THEN 1 ELSE 0 END) AS Medium_Orders, " +
                    "SUM(CASE WHEN Total_amount > 50 THEN 1 ELSE 0 END) AS Large_Orders " +
                    "FROM Orders"
    };

    // Main application frame
    private JFrame frame;
    private JList<String> queryList;
    private JButton executeButton;
    private JTable resultTable;
    private DefaultTableModel tableModel;

    // Constructor
    public DatabaseQuerySelector() {
        initializeComponents();
    }

    // Initialize UI components
    private void initializeComponents() {
        frame = new JFrame("Database Query Selector");
        frame.setSize(800, 600);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setLayout(new BorderLayout());

        // Create query list
        queryList = new JList<>(AVAILABLE_QUERIES);
        queryList.setSelectionMode(ListSelectionModel.MULTIPLE_INTERVAL_SELECTION);
        JScrollPane listScrollPane = new JScrollPane(queryList);
        listScrollPane.setPreferredSize(new Dimension(250, 400));

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
        leftPanel.add(new JLabel("Select Queries (Ctrl+Click for multiple):"), BorderLayout.NORTH);
        leftPanel.add(listScrollPane, BorderLayout.CENTER);
        leftPanel.add(executeButton, BorderLayout.SOUTH);

        frame.add(leftPanel, BorderLayout.WEST);
        frame.add(tableScrollPane, BorderLayout.CENTER);
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
                        tableModel.addRow(new Object[]{"--- " + AVAILABLE_QUERIES[index] + " ---"});
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
        System.out.println(System.getProperty("sun.arch.data.model"));
        // Add this near the start of main()
        java.util.logging.Logger.getLogger("com.microsoft.sqlserver.jdbc").setLevel(java.util.logging.Level.FINEST);
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
