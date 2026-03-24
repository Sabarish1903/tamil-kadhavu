<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="tamil_kadhavu.DBConnection" %>
<%
// Security Check
String role = (String) session.getAttribute("role");
String teacherName = (String) session.getAttribute("name");

if (role == null || !role.equals("teacher")) {
	response.sendRedirect("Login.html");
	return;
}

Connection con = null;
Statement st = null;
ResultSet rsCount = null;
int studentTotal = 0;

try {
    con = DBConnection.getConnection();
    st = con.createStatement();
    rsCount = st.executeQuery("SELECT COUNT(*) FROM users WHERE role='student'");
    if(rsCount.next()) studentTotal = rsCount.getInt(1);
} catch(Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="ta">
<head>
<meta charset="UTF-8">
<title>ஆசிரியர் முகப்பு | Teacher Dashboard</title>
<link href="https://fonts.googleapis.com/css2?family=Mukta+Malar:wght@300;400;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="style.css">
<link rel="icon" type="image/x-icon" href="./images/tamil_kadhavu.jpg">

<style>
    :root { --red: #FF0000; --dark-card: #111; --border: #222; }
    body { background: #000; color: #fff; font-family: 'Mukta Malar', sans-serif; margin: 0; }
    .dashboard-container { padding: 40px 6%; }
    
    /* Stats Section */
    .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 40px; }
    .stat-card { background: var(--dark-card); padding: 20px; border-radius: 10px; border-left: 4px solid var(--red); text-align: center; }
    .stat-card h3 { color: #888; font-size: 14px; text-transform: uppercase; margin: 0; }
    .stat-card p { font-size: 2rem; font-weight: bold; margin: 10px 0 0 0; }

    /* Management Table Section */
    .management-section { background: var(--dark-card); border: 1px solid var(--border); border-radius: 15px; padding: 30px; overflow-x: auto; }
    h2 { margin-top: 0; border-bottom: 1px solid var(--border); padding-bottom: 15px; display: flex; justify-content: space-between; align-items: center; }
    
    table { width: 100%; border-collapse: collapse; margin-top: 10px; }
    th { text-align: left; color: #888; font-weight: 300; padding: 15px; border-bottom: 2px solid var(--border); }
    td { padding: 15px; border-bottom: 1px solid var(--border); font-size: 0.95rem; }
    tr:hover { background: #181818; }

    /* Action Buttons */
    .btn-action { text-decoration: none; padding: 6px 12px; border-radius: 4px; font-size: 0.85rem; font-weight: bold; transition: 0.3s; }
    .btn-edit { background: #444; color: #fff; }
    .btn-view { background: var(--red); color: #fff; }
    .btn-start { background: #00ff00; color: #000; }
    .btn-action:hover { opacity: 0.8; }

    .status-badge { padding: 4px 8px; border-radius: 12px; font-size: 0.75rem; background: #222; color: #00ff00; border: 1px solid #00ff00; }
</style>
</head>
<body>

<header class="main-header">
    <nav class="navbar">
        <div class="logo-container">
            <img src="./images/tamil_kadhavu.jpg" alt="Logo" class="nav-logo">
            <div class="logo-text"><span class="grey-text">ஆசிரியர்</span> <span class="red-text">Portal</span></div>
        </div>
        <ul class="nav-links">
            <li><a href="index.html">View Site</a></li>
            <li><a href="LogoutServlet" class="btn-login">Logout</a></li>
        </ul>
    </nav>
</header>

<main class="dashboard-container">
    <h1>வணக்கம், <%= teacherName %>!</h1>
    
    <div class="stats-grid">
        <div class="stat-card"><h3>Total Students</h3><p><%= studentTotal %></p></div>
        <div class="stat-card"><h3>Today's Classes</h3><p>4</p></div>
        <div class="stat-card"><h3>Assignments Pending</h3><p>7</p></div>
    </div>

    <div class="management-section">
        <h2>
            மாணவர் மேலாண்மை (Student Management)
            <a href="AddSlot.jsp" style="font-size: 0.9rem; color: var(--red); text-decoration: none;">+ Add New Slot</a>
        </h2>
        
        <table>
            <thead>
                <tr>
                    <th>Student Name</th>
                    <th>Slot Timing</th>
                    <th>Assignments</th>
                    <th>Submissions</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <%
                ResultSet rs = null;
                try {
                    // Integrated Query: Fetching student details and file paths directly from 'users'
                    rs = st.executeQuery("SELECT id, name, slot_time, assignment, submission FROM users WHERE role='student'");
                    while(rs.next()) {
                        String assignment = rs.getString("assignment");
                        String submission = rs.getString("submission");
                %>
                <tr>
                    <td>
                        <strong><%= rs.getString("name") %></strong><br>
                        <span class="status-badge">Active</span>
                    </td>
                    <td><%= rs.getString("slot_time") %></td>
                    <td>
                        <% if(assignment != null) { %>
                            <a href="<%= assignment %>" target="_blank" style="color:#aaa; font-size: 0.8rem;">View Current 📄</a>
                        <% } else { %>
                            <span style="color:#444;">No file</span>
                        <% } %>
                    </td>
                    <td>
                        <% if(submission != null) { %>
                            <a href="<%= submission %>" target="_blank" style="color:var(--red); font-weight: bold;">Download 📥</a>
                        <% } else { %>
                            <span style="color:#444;">Pending</span>
                        <% } %>
                    </td>
                    <td>
                        <div style="display: flex; gap: 8px;">
                            <a href="LiveClass.jsp?room=TamilClass_<%= rs.getInt("id") %>" class="btn-action btn-start">Start</a>
                            <a href="EditSlots.jsp?id=<%= rs.getInt("id") %>" class="btn-action btn-edit">Edit Slot</a>
                            <a href="UploadAssignment.jsp?studentId=<%= rs.getInt("id") %>" class="btn-action btn-view">Upload</a>
                        </div>
                    </td>
                </tr>
                <% 
                    }
                } catch(Exception e) { e.printStackTrace(); } 
                finally { if(rs != null) rs.close(); }
                %>
            </tbody>
        </table>
    </div>
</main>

<%
    if(st != null) st.close();
    if(con != null) con.close();
%>
</body>
</html>
