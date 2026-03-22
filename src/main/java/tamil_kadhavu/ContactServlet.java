package tamil_kadhavu;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/ContactServlet")
public class ContactServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String message = request.getParameter("message");

        String dbUrl = "jdbc:mysql://localhost:3306/tamil_kadhavu_db";
        String dbUser = "root";
        String dbPass = "root"; 

        Connection con = null;
        PreparedStatement ps = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(dbUrl, dbUser, dbPass);
            
            // Ensure this table exists in your DB!
            String query = "INSERT INTO contact_inquiries (name, email, message) VALUES (?, ?, ?)";
            ps = con.prepareStatement(query);
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, message);
            
            int result = ps.executeUpdate();
            if (result > 0) {
                response.sendRedirect("index.html?status=success");
            } else {
                response.sendRedirect("index.html?status=error");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("index.html?status=error");
        } finally {
            // ALWAYS close resources in a finally block
            try { if (ps != null) ps.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (con != null) con.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
}