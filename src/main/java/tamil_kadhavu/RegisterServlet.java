package tamil_kadhavu;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Get data from the HTML form
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("user_type"); // 'student' or 'teacher'
        
        // 2. Logic: Students are active, Teachers are pending
        String status = "active";
        if ("teacher".equalsIgnoreCase(role)) {
            status = "pending";
        }

        // 3. Database Connection Details
        // // 3. Database Connection Details (REPLACE YOUR OLD LINES 27-29)
        String dbUrl = System.getenv("DB_URL");
        String dbUser = System.getenv("DB_USER");
        String dbPass = System.getenv("DB_PASSWORD");// Ensure this matches your MySQL password

        Connection con = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            
            // 4. SQL Query (Matching your newly altered table)
            String query = "INSERT INTO users (name, email, password, role, status) VALUES (?, ?, ?, ?, ?)";
            PreparedStatement ps = con.prepareStatement(query);
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, password);
            ps.setString(4, role);
            ps.setString(5, status);
            
         // ... inside RegisterServlet.java doPost ...

            int result = ps.executeUpdate();

            if (result > 0) {
                if ("teacher".equalsIgnoreCase(role)) {
                    // Teachers go to a "Please Wait" page
                    response.sendRedirect("PendingVerification.html");
                } else {
                    // Students go straight to Login
                    response.sendRedirect("Login.html?register=success");
                }
            } else {
                response.sendRedirect("Register.html?error=failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("Register.html?error=server");
        } finally {
            try { if(con != null) con.close(); } catch(SQLException se) { se.printStackTrace(); }
        }
    }
}
