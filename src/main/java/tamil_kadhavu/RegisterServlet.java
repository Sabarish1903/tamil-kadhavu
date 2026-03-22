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

        Connection con = null;
        try {
            // Use the new DBConnection class instead of hardcoding strings here
            con = DBConnection.getConnection();
            
            // 3. SQL Query (Ensure column names match your TiDB table)
            String query = "INSERT INTO users (name, email, password, role, status) VALUES (?, ?, ?, ?, ?)";
            PreparedStatement ps = con.prepareStatement(query);
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, password);
            ps.setString(4, role);
            ps.setString(5, status);
            
            int result = ps.executeUpdate();

            if (result > 0) {
                if ("teacher".equalsIgnoreCase(role)) {
                    // Added "pages/" prefix so Render finds the file
                    response.sendRedirect("pages/PendingVerification.html");
                } else {
                    // Added "pages/" prefix so Render finds the file
                    response.sendRedirect("pages/Login.html?register=success");
                }
            } else {
                response.sendRedirect("Register.html?error=failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            // If the database fails, we stay on the Register page with an error
            response.sendRedirect("Register.html?error=server");
        } finally {
            try { if(con != null) con.close(); } catch(SQLException se) { se.printStackTrace(); }
        }
    }
}
