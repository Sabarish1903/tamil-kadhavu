<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="tamil_kadhavu.DBConnection" %> <%-- FIX 1: Connection Utility --%>
<%
// Security Check
String role = (String) session.getAttribute("role");
String teacherName = (String) session.getAttribute("name");

if (role == null || !role.equals("teacher")) {
	response.sendRedirect("Login.html");
	return;
}

int studentTotal = 0;
Connection con = null;
Statement st = null;
ResultSet rsCount = null;

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
    /* Resetting and setting base styles to match the dark theme in image_12.png */
    body { background: #000; color: #fff; font-family: 'Mukta Malar', sans-serif; margin: 0; }
    
    /* Layout */
    .dashboard-container { display: flex; min-height: 100vh; }
    
    /* Sidebar matching the look in image_12.png */
    .sidebar { width: 260px; background: #0a0a0a; padding: 40px 20px; border-right: 1px solid #1a1a1a; display: flex; flex-direction: column; }
    .logo-container h2 { color: #FF0000; text-align: center; margin-top: 0; }
    .nav-links { list-style: none; padding: 0; margin-top: 50px; flex-grow: 1; }
    .nav-links li { margin-bottom: 15px; }
    .nav-links a { color: #888; text-decoration: none; display: block; padding: 12px; border-radius: 8px; transition: 0.3s; cursor: pointer; }
    .nav-links a:hover, .nav-links a.active { background: #FF0000; color: #fff; font-weight: bold; }
    .logout-box { border-top: 1px solid #1a1a1a; padding-top: 20px; text-align: center; }
    .btn-logout { background: #111; color: #fff; padding: 10px 20px; border-radius: 6px; text-decoration: none; border: 1px solid #444; }

    /* Main Content matching the look in image_12.png */
    .main-content { flex-grow: 1; padding: 60px 50px; }
    .header-section { margin-bottom: 50px; border-left: 4px solid #FF0000; padding-left: 20px; }
    .header-section h1 { font-size: 2.2rem; margin: 0; }
    .header-section p { color: #888; }
    
    /* Glass Card styling to match image_12.png */
    .glass-card { background: #0a0a0a; border: 1px solid #1a1a1a; border-radius: 15px; overflow: hidden; margin-bottom: 40px; }
    .card-header { padding: 15px 20px; margin: 0; background: #111; display: flex; justify-content: space-between; align-items: center; }
    
    /* Table styling to match image_12.png */
    table { width: 100%; border-collapse: collapse; margin-top: 10px; }
    th { text-align: left; color: #666; font-size: 0.85rem; padding: 15px 20px; text-transform: uppercase; }
    td { padding: 15px 20px; border-bottom: 1px solid #1a1a1a; }
    tr:hover { background: #151515; }

    /* Table Actions */
    .btn-action { text-decoration: none; padding: 8px 16px; border-radius: 6px; font-size: 0.85rem; font-weight: bold; }
    .btn-edit { background: #222; color: #fff; border: 1px solid #444; }
    .btn-view { background: #222; color: #aaa; padding: 4px 10px; }
    .btn-start { background: #FF0000; color: #fff; border: none; }
</style>
</head>
<body>

<div class="dashboard-container">
    <nav class="sidebar">
        <div class="logo-container">
            <h2>தமிழ் கதவு</h2>
        </div>
        <ul class="nav-links">
            <li><a href="#" class="active">Student Management</a></li>
            <li><a href="UpdatePuzzle.jsp">Update Daily Puzzle 🧩</a></li>
        </ul>
        <div class="logout-box">
            <a href="LogoutServlet" class="btn-logout">Logout</a>
        </div>
    </nav>

    <main class="main-content">
        <div class="header-section">
            <h1>நிர்வாகத் தளம் (Teacher Admin)</h1>
            <p>வணக்கம், <%= teacherName %>! Manage your students below.</p>
        </div>

        <div class="glass-card">
            <div class="card-header">
                <h3>Registered Students</h3>
                <a href="AddSlot.jsp" style="font-size: 0.9rem; color: #FF0000; text-decoration: none;">+ Add New Slot</a>
            </div>
            <table>
                <thead>
                    <tr>
                        <th>Student Name</th>
                        <th>Slot Timing</th>
                        <th>Assignment Path</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    ResultSet rs = null;
                    try {
                        // FIX 2: Correcting column names to 'assignment' and 'submission' to match your TiDB table.
                        // We also need to get the teacher_id to ensure this is the teacher's correct student
                        String query = "SELECT id, name, slot_time, assignment FROM users WHERE role='student'";
                        rs = st.executeQuery(query);

                        while(rs.next()) {
                            String assignment = rs.getString("assignment");
                    %>
                    <tr>
                        <td><strong><%= rs.getString("name") %></strong></td>
                        <td><%=(rs.getString("slot_time") != null) ? rs.getString("slot_time") : "Not Set"%></td>
                        <td>
                            <form action="UploadServlet" method="POST" enctype="multipart/form-data">
                                <input type="hidden" name="studentId" value="<%= rs.getInt("id") %>">
                                <input type="file" name="file" required style="font-size: 0.7rem; color: #aaa; margin-bottom: 5px;">
                                <button type="submit" class="btn-action btn-edit" style="padding: 4px 10px;">Upload</button>
                            </form> 
                            <% if(assignment != null) { %>
                                <div style="margin-top: 5px;">
                                    <a href="<%= assignment %>" target="_blank" style="color:#00ff00; font-size: 0.75rem;">View Sent 📄</a>
                                </div> 
                            <% } %>
                        </td>
                        <td>
                            <div style="display: flex; gap: 8px;">
                                <a href="LiveClass.jsp?room=TamilClass_<%= rs.getInt("id") %>" class="btn-action btn-start">Start <span>Live</span></a> 
                                <a href="EditSlots.jsp?id=<%= rs.getInt("id") %>" class="btn-action btn-edit">Edit <span>Slot</span></a>
                            </div>
                        </td>
                    </tr>
                    <% 
                        }
                    } catch(Exception e) { 
                        out.println("<tr><td colspan='4'>Error: " + e.getMessage() + "</td></tr>"); 
                    } finally { if(rs != null) rs.close(); }
                    %>
                </tbody>
            </table>
        </div>

        <div class="glass-card" style="border-top: 3px solid #00ff00;">
            <div class="card-header">
                <h3>Completed Work Inbox 📥</h3>
            </div>
            <p style="padding: 0 20px; color: #888;">When students upload finished work, it will appear here.</p>
            <table>
                <thead style="background: #111;">
                    <tr>
                        <th>Student Name</th>
                        <th>Submission</th>
                        <th>Date Received</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    ResultSet rs2 = null;
                    try {
                        // FIX 3: Column name corrected to 'submission'
                        String query2 = "SELECT name, submission FROM users WHERE role='student' AND submission IS NOT NULL";
                        rs2 = st.executeQuery(query2);
                        while(rs2.next()) {
                    %>
                    <tr>
                        <td><%= rs2.getString("name") %></td>
                        <td><a href="<%= rs2.getString("submission") %>" target="_blank" style="color:#00ff00;">Download Student File ⬇️</a></td>
                        <td>Just Now</td>
                    </tr>
                    <%
                        }
                    } catch(Exception e) { } finally { if(rs2 != null) rs2.close(); }
                    %>
                </tbody>
            </table>
        </div>
    </main>
</div>

<%
    // Final cleanup to prevent TiDB leaks
    if(st != null) st.close();
    if(con != null) con.close();
%>
</body>
</html>
