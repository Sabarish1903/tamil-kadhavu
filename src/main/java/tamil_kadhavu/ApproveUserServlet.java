package tamil_kadhavu;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException; // Added missing import

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/ApproveUserServlet")
public class ApproveUserServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String email = request.getParameter("email");
        Connection con = null;
        PreparedStatement ps = null;

        try {
            // DEBUG FIX: Explicitly load the driver to prevent "Driver not found" errors
            Class.forName("com.mysql.cj.jdbc.Driver"); 
            
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/tamil_kadhavu_db", "root", "root");
            ps = con.prepareStatement("UPDATE users SET status='active' WHERE email=?");
            ps.setString(1, email);
            ps.executeUpdate();
            
            // Redirect back to refresh the list
            response.sendRedirect("AdminDashboard.jsp");
            
        } catch (Exception e) { 
            e.printStackTrace();
            // Provide feedback if it fails so you don't just see a white screen
            response.getWriter().println("Error approving user: " + e.getMessage());
        } finally {
            // DEBUG FIX: Always close resources to prevent database locking
            try { if (ps != null) ps.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (con != null) con.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
}