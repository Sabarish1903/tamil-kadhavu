package tamil_kadhavu;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    public static Connection getConnection() throws SQLException, ClassNotFoundException {
        // 1. Try to get Cloud Environment Variables from Render
        String url = System.getenv("DB_URL");
        String user = System.getenv("DB_USER");
        String pass = System.getenv("DB_PASSWORD");

        // 2. Fallback to Localhost if Environment Variables are missing (for local testing)
        if (url == null) {
            url = "jdbc:mysql://localhost:3306/tamil_kadhavu_db";
            user = "root";
            pass = "root"; 
        }

        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(url, user, pass);
    }
}
