package tamil_kadhavu;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/ApproveUserServlet")
public class ApproveUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String email = request.getParameter("email");
        
        Connection con = null;
        PreparedStatement ps = null;

        try {
            // FIX 1: Use your new DBConnection class instead of hardcoded localhost
            con = DBConnection.getConnection(); 
            
            // FIX 2: Ensure the query matches your TiDB table structure
            String query = "UPDATE users SET status='active' WHERE email=?";
            ps = con.prepareStatement(query);
            ps.setString(1, email);
            
            int result = ps.executeUpdate();
            
            if (result > 0) {
                // FIX 3: Removed any subfolder prefix if your JSP is in the main webapp folder
                response.sendRedirect("AdminDashboard.jsp?approve=success");
            } else {
                response.sendRedirect("AdminDashboard.jsp?approve=notfound");
            }
            
        } catch (Exception e) { 
            e.printStackTrace();
            // Helpful for debugging on Render logs
            response.getWriter().println("Error approving user: " + e.getMessage());
        } finally {
            // Standard cleanup to prevent TiDB connection leaks
            try { if (ps != null) ps.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (con != null) con.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
}
