package tamil_kadhavu;

import java.io.*;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/UploadServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class UploadServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String studentId = request.getParameter("studentId");
        Part filePart = request.getPart("file"); 
        
        if (filePart == null || filePart.getSize() == 0) {
            response.sendRedirect("StudentDashboard.jsp?error=no_file");
            return;
        }
        
        // 1. Get extension safely
        String fileName = filePart.getSubmittedFileName();
        String extension = "";
        int i = fileName.lastIndexOf('.');
        if (i > 0) {
            extension = fileName.substring(i);
        }

        // 2. Auto-Rename: Assignment_SID1_20260324_200000.pdf
        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String newFileName = "Assignment_SID" + studentId + "_" + timeStamp + extension;

        // 3. Define the Relative Path (Render-friendly)
        String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs(); 

        String savePath = uploadPath + File.separator + newFileName;
        
        Connection con = null;
        PreparedStatement ps = null;
        
        try {
            // Save file to disk
            filePart.write(savePath);

            // 4. Update Database using cloud connection
            con = DBConnection.getConnection();
            
            // Link relative path for browser access
            String dbPath = "uploads/" + newFileName;
            
            // FIX: Changed 'assignment_link' to 'assignment' to match your TiDB table structure
            String query = "UPDATE users SET assignment = ? WHERE id = ?";
            ps = con.prepareStatement(query);
            ps.setString(1, dbPath);
            ps.setString(2, studentId);
            ps.executeUpdate();

            response.sendRedirect("StudentDashboard.jsp?upload=success");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("StudentDashboard.jsp?error=upload_failed");
        } finally {
            // Standard cleanup
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (con != null) con.close(); } catch (SQLException e) {}
        }
    }
}
