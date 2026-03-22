package tamil_kadhavu;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/UpdateSlotsServlet")
public class UpdateSlotsServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String studentId = request.getParameter("student_id");
        String[] slotIds = request.getParameterValues("slot_ids");
        String[] startTimes = request.getParameterValues("start_times");
        String[] endTimes = request.getParameterValues("end_times");

        // For new slots (if the student had 0 slots)
        String newStart = request.getParameter("new_start_time");
        String newEnd = request.getParameter("new_end_time");

        Connection con = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection("jdbc:mysql://localhost:3306/tamil_kadhavu_db", "root", "root");

            // CASE 1: Update existing slots
            if (slotIds != null) {
                String updateQuery = "UPDATE slots SET start_time = ?, end_time = ? WHERE id = ?";
                PreparedStatement ps = con.prepareStatement(updateQuery);
                
                for (int i = 0; i < slotIds.length; i++) {
                    ps.setString(1, startTimes[i]);
                    ps.setString(2, endTimes[i]);
                    ps.setString(3, slotIds[i]);
                    ps.executeUpdate();
                }
            }

            // CASE 2: Insert a new slot if this is a first-time setup
            if (newStart != null && newEnd != null) {
                String insertQuery = "INSERT INTO slots (student_id, start_time, end_time) VALUES (?, ?, ?)";
                PreparedStatement psInsert = con.prepareStatement(insertQuery);
                psInsert.setString(1, studentId);
                psInsert.setString(2, newStart);
                psInsert.setString(3, newEnd);
                psInsert.executeUpdate();
            }

            // SUCCESS: Also update the main 'users' table so the dashboard shows the timing immediately
            String syncQuery = "UPDATE users SET slot_time = ? WHERE id = ?";
            PreparedStatement psSync = con.prepareStatement(syncQuery);
            // We'll show the first slot time on the main dashboard
            String displayTime = (startTimes != null) ? startTimes[0] + " - " + endTimes[0] : newStart + " - " + newEnd;
            psSync.setString(1, displayTime);
            psSync.setString(2, studentId);
            psSync.executeUpdate();

            // Redirect back to dashboard
            response.sendRedirect("StudentDashboard.jsp?update=success");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("StudentDashboard.jsp?error=database");
        } finally {
            try { if(con != null) con.close(); } catch(SQLException e) { e.printStackTrace(); }
        }
    }
}