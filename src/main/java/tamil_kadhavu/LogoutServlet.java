package tamil_kadhavu;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Get the current session if it exists (don't create a new one)
        HttpSession session = request.getSession(false);
        
        // 2. If a session exists, invalidate (kill) it to clear user data
        if (session != null) {
            session.invalidate();
        }
        
        // 3. Redirect back to Login with a success parameter
        // This allows Login.html to show a "You have successfully logged out" message
        response.sendRedirect("Login.html?logout=success");
    }
}
