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
        String fileName = filePart.getSubmittedFileName();
        
        // This line finds the actual folder on your computer
        String uploadPath = getServletContext().getRealPath("") + File.separator + "submissions";
        
        // AUTO-CREATE FOLDER: This prevents the error if you forgot to create it!
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs(); 
        }

        try {
            // Write the file to the disk
            filePart.write(uploadPath + File.separator + fileName);
            String dbPath = "submissions/" + fileName;

            // Get User ID from Session
            HttpSession session = request.getSession();
            Object userIdObj = session.getAttribute("userId");
            
            if (userIdObj == null) {
                response.sendRedirect("Login.html");
                return;
            }
            
            int studentId = (Integer) userIdObj;

            // Update Database
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/tamil_kadhavu_db", "root", "root");
            
            PreparedStatement ps = con.prepareStatement("UPDATE users SET submission_link = ? WHERE id = ?");
            ps.setString(1, dbPath);
            ps.setInt(2, studentId);
            ps.executeUpdate();
            
            con.close();
            response.sendRedirect("StudentPortal.jsp?upload=success");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("StudentPortal.jsp?upload=error");
        }
    }
}