<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="tamil_kadhavu.DBConnection" %> <%-- FIX 1: Connection Utility --%>
<%
// Security Check: Only allow Teachers
String role = (String) session.getAttribute("role");
String teacherName = (String) session.getAttribute("name");

if (role == null || !role.equals("teacher")) {
	response.sendRedirect("Login.html");
	return;
}

int studentCount = 0;
Connection con = null;
Statement st = null;
ResultSet rsCount = null;

try {
    con = DBConnection.getConnection();
    
    // Dynamically get the number of students
    st = con.createStatement();
    rsCount = st.executeQuery("SELECT COUNT(*) FROM users WHERE role='student'");
    if(rsCount.next()) {
        studentCount = rsCount.getInt(1);
    }
} catch(Exception e) {
    e.printStackTrace();
}
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
    .dashboard-container { padding: 40px 6%; background: #000; min-height: 100vh; color: #fff; }
    .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 40px; }
    .stat-card { background: #111; padding: 25px; border-radius: 10px; border-left: 4px solid #FF0000; text-align: center; transition: 0.3s; }
    .stat-card:hover { transform: translateY(-5px); border-color: #fff; }
    .stat-card h3 { color: #888; font-size: 14px; text-transform: uppercase; margin: 0; }
    .stat-card p { font-size: 2.5rem; font-weight: bold; color: #fff; margin: 10px 0 0 0; }
    .tools-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 30px; }
    .tool-box { background: #0a0a0a; border: 1px solid #222; padding: 30px; border-radius: 15px; }
    .tool-box h2 { margin-top: 0; border-bottom: 1px solid #222; padding-bottom: 10px; font-size: 1.2rem; }
    .slot-list { list-style: none; padding: 0; }
    .slot-item { display: flex; justify-content: space-between; align-items: center; padding: 15px; background: #151515; margin-bottom: 10px; border-radius: 5px; border: 1px solid #222; }
    .btn-edit-small { background: #FF0000; color: white; padding: 6px 15px; text-decoration: none; border-radius: 4px; font-size: 13px; font-weight: bold; }
    @media (max-width: 900px) { .tools-grid { grid-template-columns: 1fr; } }
</style>
</head>
<body>

	<header class="main-header">
		<nav class="navbar">
			<div class="logo-container">
				<img src="./images/tamil_kadhavu.jpg" alt="Logo" class="nav-logo">
				<div class="logo-text">
					<span class="grey-text">ஆசிரியர்</span> <span class="red-text">Portal</span>
				</div>
			</div>
			<ul class="nav-links">
				<li><a href="index.html">View Site</a></li>
				<li><a href="LogoutServlet" class="btn-login">Logout</a></li>
			</ul>
		</nav>
	</header>

	<main class="dashboard-container">
		<h1>வணக்கம் (Welcome), <%= teacherName %>!</h1>
		<p style="color: #888; margin-bottom: 30px;">Manage your Tamil classes and student slots below.</p>

		<div class="stats-grid">
			<div class="stat-card">
				<h3>Active Students</h3>
				<p><%= studentCount %></p>
			</div>
			<div class="stat-card">
				<h3>Weekly Hours</h3>
				<p>18h</p>
			</div>
			<div class="stat-card">
				<h3>Pending Requests</h3>
				<p>3</p>
			</div>
		</div>

		<div class="tools-grid">
			<div class="tool-box">
				<h2>Manage Teaching Slots</h2>
				<ul class="slot-list">
                    <%
                    ResultSet rsSlots = null;
                    try {
                        // Fetching current batches/slots
                        rsSlots = st.executeQuery("SELECT s.id, s.start_time, s.end_time, u.name FROM slots s JOIN users u ON s.student_id = u.id LIMIT 5");
                        while(rsSlots.next()) {
                    %>
					<li class="slot-item">
                        <span><strong><%= rsSlots.getString("name") %>:</strong> <%= rsSlots.getString("start_time") %> - <%= rsSlots.getString("end_time") %></span> 
                        <a href="EditSlots.jsp?id=<%= rsSlots.getString("id") %>" class="btn-edit-small">Edit Slot</a>
                    </li>
                    <% 
                        }
                    } catch(Exception e) { } finally { if(rsSlots != null) rsSlots.close(); }
                    %>
				</ul>
				<a href="AddSlot.jsp" style="display: inline-block; margin-top: 15px; color: #FF0000; text-decoration: none; font-weight: bold;">+ Add New Time Slot</a>
			</div>

			<div class="tool-box">
				<h2>Profile Status</h2>
				<p>Status: <span style="color: #00FF00; font-weight: bold;">Approved ✅</span></p>
				<p style="font-size: 14px; color: #666; margin-top: 10px; line-height: 1.5;">
					Your profile is currently live. Students can see you listed for **Intermediate Tamil Coaching**. 
				</p>
                <div style="margin-top: 20px; border-top: 1px solid #222; padding-top: 15px;">
                    <a href="TeacherAdmin.jsp" style="color: #fff; font-size: 14px; text-decoration: underline;">Open Student Manager →</a>
                </div>
			</div>
		</div>
	</main>

<%
    // Final cleanup
    if(st != null) st.close();
    if(rsCount != null) rsCount.close();
    if(con != null) con.close();
%>
</body>
</html>
