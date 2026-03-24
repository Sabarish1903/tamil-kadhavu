package tamil_kadhavu;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/UpdatePortalServlet")
public class UpdatePortalServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String newQuiz = request.getParameter("newQuiz");
        String newAns = request.getParameter("newAns");

        Connection con = null;
        PreparedStatement ps = null;
        PreparedStatement psInsert = null;

        try {
            // FIX 1: Use the cloud-ready connection
            con = DBConnection.getConnection();
            
            // Step 2: Update the existing quiz record
            String sql = "UPDATE portal_updates SET daily_quiz = ?, quiz_answer = ? WHERE id = 1";
            ps = con.prepareStatement(sql);
            ps.setString(1, newQuiz);
            ps.setString(2, newAns);
            
            int rows = ps.executeUpdate();
            
            // Step 3: If ID 1 doesn't exist (e.g., first time using TiDB), create it
            if (rows == 0) {
                psInsert = con.prepareStatement(
                    "INSERT INTO portal_updates (id, daily_quiz, quiz_answer) VALUES (1, ?, ?)");
                psInsert.setString(1, newQuiz);
                psInsert.setString(2, newAns);
                psInsert.executeUpdate();
            }

            // Redirect back to the dashboard with success
            response.sendRedirect("StudentDashboard.jsp?portalUpdate=success");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("StudentDashboard.jsp?portalUpdate=error");
        } finally {
            // Step 4: Close all resources to prevent TiDB connection leaks
            try { if (psInsert != null) psInsert.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }
}
