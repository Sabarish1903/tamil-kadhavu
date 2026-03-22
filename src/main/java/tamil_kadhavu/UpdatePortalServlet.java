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

        // Step 1: Define connection outside to ensure closure
        Connection con = null;
        PreparedStatement ps = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/tamil_kadhavu_db", "root", "root");
            
            // Step 2: Use a clean Update query
            String sql = "UPDATE portal_updates SET daily_quiz = ?, quiz_answer = ? WHERE id = 1";
            ps = con.prepareStatement(sql);
            ps.setString(1, newQuiz);
            ps.setString(2, newAns);
            
            int rows = ps.executeUpdate();
            
            // Step 3: If for some reason ID 1 was deleted, re-insert it
            if (rows == 0) {
                PreparedStatement psInsert = con.prepareStatement(
                    "INSERT INTO portal_updates (id, daily_quiz, quiz_answer) VALUES (1, ?, ?)");
                psInsert.setString(1, newQuiz);
                psInsert.setString(2, newAns);
                psInsert.executeUpdate();
            }

            response.sendRedirect("StudentDashboard.jsp?portalUpdate=success");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("StudentDashboard.jsp?portalUpdate=error");
        } finally {
            // Step 4: CRITICAL - Always close connections to allow the "next time" to work
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }
}