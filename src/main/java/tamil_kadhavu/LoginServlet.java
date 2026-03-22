package tamil_kadhavu;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String pass = request.getParameter("password");

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            // FIX 1: Use the cloud-ready connection class
            con = DBConnection.getConnection();
            
            // FIX 2: Added 'status' to selection for verification logic
            ps = con.prepareStatement("SELECT id, name, role, status FROM users WHERE email=? AND password=?");
            ps.setString(1, email);
            ps.setString(2, pass);
            
            rs = ps.executeQuery();
            
            if (rs.next()) {
                String status = rs.getString("status");
                
                if ("pending".equalsIgnoreCase(status)) {
                    // FIX 3: Removed "/pages/" prefix
                    response.sendRedirect("Login.html?error=pending");
                    return; 
                }

                HttpSession session = request.getSession();
                session.setAttribute("userId", rs.getInt("id"));
                session.setAttribute("name", rs.getString("name"));
                session.setAttribute("role", rs.getString("role"));

                String userRole = rs.getString("role");

                // FIX 4: Corrected destination pages for roles
                if ("teacher".equalsIgnoreCase(userRole)) {
                    response.sendRedirect("TeacherDashboard.jsp"); 
                } else if ("student".equalsIgnoreCase(userRole)) {
                    response.sendRedirect("StudentPortal.jsp");
                } else {
                    response.sendRedirect("index.html");
                }
            } else {
                response.sendRedirect("Login.html?error=invalid");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("Login.html?error=db_error");
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }
}
