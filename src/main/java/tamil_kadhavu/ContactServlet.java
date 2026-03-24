package tamil_kadhavu;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/ContactServlet")
public class ContactServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Get data from the HTML form
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String message = request.getParameter("message");

        Connection con = null;
        PreparedStatement ps = null;

        try {
            // FIX 1: Use the unified cloud-ready connection
            con = DBConnection.getConnection();
            
            // FIX 2: Ensure the query matches the 'contact_inquiries' table you created in TiDB
            String query = "INSERT INTO contact_inquiries (name, email, message) VALUES (?, ?, ?)";
            ps = con.prepareStatement(query);
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, message);
            
            int result = ps.executeUpdate();
            
            if (result > 0) {
                // FIX 3: Redirecting back to index with a success status
                response.sendRedirect("index.html?status=success#contact");
            } else {
                response.sendRedirect("index.html?status=error#contact");
            }
        } catch (Exception e) {
            e.printStackTrace();
            // Redirect to index with error so the user isn't stuck on a blank page
            response.sendRedirect("index.html?status=error#contact");
        } finally {
            // Standard cleanup to keep the connection pool healthy
            try { if (ps != null) ps.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (con != null) con.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
}
