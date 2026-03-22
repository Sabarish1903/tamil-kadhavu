package tamil_kadhavu;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;

@WebServlet("/login")
public class tamil_kadhavu extends GenericServlet{
	@Override
	public void service(ServletRequest req, ServletResponse res) throws IOException,ServletException{
		String username = req.getParameter("username");
		String password = req.getParameter("password");
		PrintWriter out = res.getWriter();
		System.out.println("final line of servlet");
		
		Connection c = null;
		
		try {
			Class.forName("com.mysql.cj.jdbc.Driver");
			c = DriverManager.getConnection("jdbc:mysql://localhost:3306/tamil_kadhavu", "root", "root");
			PreparedStatement ps = c.prepareStatement("INSERT INTO tamil_kadhavu_tb(username,password) VALUES (?,?);");
			ps.setString(1, username);
			ps.setString(2, password);
			int result = ps.executeUpdate(); 

	        if (result > 0) {
	            out.print("<h1>Data successfully saved to database!</h1>");
	        } else {
	            out.print("<h1>Data not saved. Check table constraints.</h1>");
	        }
		}catch(ClassNotFoundException | SQLException e) {
			e.printStackTrace();
		}finally {
			try {
				
				c.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
}
