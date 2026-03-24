package tamil_kadhavu;

import java.io.*;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.*;
import javax.servlet.http.*;

@WebServlet("/StudentUploadServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, maxFileSize = 1024 * 1024 * 10)
public class StudentUploadServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Part filePart = request.getPart("file");
        if (filePart == null || filePart.getSize() == 0) {
            response.sendRedirect("StudentPortal.jsp?upload=nofile");
            return;
        }

        String fileName = filePart.getSubmittedFileName();
        
        // This finds the path on the Render server
        String uploadPath = getServletContext().getRealPath("") + File.separator + "submissions";
        
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs(); 
        }

        Connection con = null;
        PreparedStatement ps = null;

        try {
            // 1. Write the file to the server disk
            filePart.write(uploadPath + File.separator + fileName);
            String dbPath = "submissions/" + fileName;

            // 2. Get User ID from Session
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("userId") == null) {
                response.sendRedirect("Login.html");
                return;
            }
            
            int studentId = (Integer) session.getAttribute("userId");

            // 3. Update Database using cloud connection
            con = DBConnection.getConnection();
            
            // FIX: Changed 'submission_link' to 'submission' to match your DESCRIBE screenshot
            String query = "UPDATE users SET submission = ? WHERE id = ?";
            ps = con.prepareStatement(query);
            ps.setString(1, dbPath);
            ps.setInt(2, studentId);
            ps.executeUpdate();
            
            response.sendRedirect("StudentPortal.jsp?upload=success");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("StudentPortal.jsp?upload=error");
        } finally {
            // Clean up resources
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (con != null) con.close(); } catch (SQLException e) {}
        }
    }
}
