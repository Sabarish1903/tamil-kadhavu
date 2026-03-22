package tamil_kadhavu;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Get the current session
        HttpSession session = request.getSession(false);
        
        // 2. If a session exists, invalidate (kill) it
        if (session != null) {
            session.invalidate();
        }
        
        // 3. Redirect the user back to the login page with a success message
        response.sendRedirect("Login.html?logout=success");
    }
}