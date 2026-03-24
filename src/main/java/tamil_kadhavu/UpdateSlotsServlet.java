package tamil_kadhavu;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/UpdateSlotsServlet")
public class UpdateSlotsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String studentId = request.getParameter("student_id");
        String[] slotIds = request.getParameterValues("slot_ids");
        String[] startTimes = request.getParameterValues("start_times");
        String[] endTimes = request.getParameterValues("end_times");

        // For new slots
        String newStart = request.getParameter("new_start_time");
        String newEnd = request.getParameter("new_end_time");

        Connection con = null;
        PreparedStatement psUpdate = null;
        PreparedStatement psInsert = null;
        PreparedStatement psSync = null;

        try {
            // FIX 1: Use cloud-ready connection
            con = DBConnection.getConnection();

            // CASE 1: Update existing slots
            if (slotIds != null && startTimes != null && endTimes != null) {
                String updateQuery = "UPDATE slots SET start_time = ?, end_time = ? WHERE id = ?";
                psUpdate = con.prepareStatement(updateQuery);
                
                for (int i = 0; i < slotIds.length; i++) {
                    psUpdate.setString(1, startTimes[i]);
                    psUpdate.setString(2, endTimes[i]);
                    psUpdate.setString(3, slotIds[i]);
                    psUpdate.executeUpdate();
                }
            }

            // CASE 2: Insert a new slot
            if (newStart != null && !newStart.isEmpty() && newEnd != null && !newEnd.isEmpty()) {
                String insertQuery = "INSERT INTO slots (student_id, start_time, end_time) VALUES (?, ?, ?)";
                psInsert = con.prepareStatement(insertQuery);
                psInsert.setString(1, studentId);
                psInsert.setString(2, newStart);
                psInsert.setString(3, newEnd);
                psInsert.executeUpdate();
            }

            // SUCCESS: Sync the display time in the 'users' table
            String syncQuery = "UPDATE users SET slot_time = ? WHERE id = ?";
            psSync = con.prepareStatement(syncQuery);
            
            String displayTime = "Not Assigned";
            if (startTimes != null && startTimes.length > 0) {
                displayTime = startTimes[0] + " - " + endTimes[0];
            } else if (newStart != null) {
                displayTime = newStart + " - " + newEnd;
            }
            
            psSync.setString(1, displayTime);
            psSync.setString(2, studentId);
            psSync.executeUpdate();

            response.sendRedirect("StudentDashboard.jsp?update=success");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("StudentDashboard.jsp?error=database");
        } finally {
            // FIX 2: Close all PreparedStatements individually
            try { if(psUpdate != null) psUpdate.close(); } catch(SQLException e) {}
            try { if(psInsert != null) psInsert.close(); } catch(SQLException e) {}
            try { if(psSync != null) psSync.close(); } catch(SQLException e) {}
            try { if(con != null) con.close(); } catch(SQLException e) {}
        }
    }
}
