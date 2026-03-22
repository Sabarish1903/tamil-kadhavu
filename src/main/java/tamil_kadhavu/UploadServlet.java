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
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String studentId = request.getParameter("studentId");
        Part filePart = request.getPart("file"); // Grabs the uploaded file
        
        // 1. Get the original filename to find the extension (.pdf or .jpg)
        String fileName = filePart.getSubmittedFileName();
        String extension = fileName.substring(fileName.lastIndexOf("."));

        // 2. Auto-Rename: StudentID_Date_Time.extension
        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String newFileName = "Assignment_SID" + studentId + "_" + timeStamp + extension;

        // 3. Define the Relative Path (Portable!)
        String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdir(); // Create folder if it doesn't exist

        String savePath = uploadPath + File.separator + newFileName;
        
        try {
            // Save the file to the folder
            filePart.write(savePath);

            // 4. Update Database
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/tamil_kadhavu_db", "root", "root");
            
            // We store the relative link so the browser can find it later
            String dbPath = "uploads/" + newFileName;
            PreparedStatement ps = con.prepareStatement("UPDATE users SET assignment_link = ? WHERE id = ?");
            ps.setString(1, dbPath);
            ps.setString(2, studentId);
            ps.executeUpdate();

            con.close();
            response.sendRedirect("StudentDashboard.jsp?upload=success");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("StudentDashboard.jsp?error=upload_failed");
        }
    }
}