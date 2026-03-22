<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%
// 1. SESSION & SECURITY
String role = (String) session.getAttribute("role");
String teacherName = (String) session.getAttribute("name");

if (role == null || !role.equalsIgnoreCase("teacher")) {
	response.sendRedirect("Login.html"); // Redirecting to your actual HTML file
	return;
}
%>
<!DOCTYPE html>
<html lang="ta">
<head>
<meta charset="UTF-8">
<title>Teacher Dashboard | தமிழ் கதவு</title>
<link rel="icon" type="image/x-icon" href="./images/tamil_kadhavu.jpg">

<style>
:root {
	--red: #ff0000;
	--bg: #000;
	--card: #111;
	--border: #333;
	--gray: #888;
	--green: #00ff00;
}

body {
	background: var(--bg);
	color: #fff;
	font-family: 'Segoe UI', sans-serif;
	margin: 0;
	display: flex;
}

/* Sidebar */
.sidebar {
	width: 260px;
	height: 100vh;
	background: var(--card);
	padding: 30px 20px;
	border-right: 1px solid var(--border);
	position: fixed;
}

.logo-box h2 {
	color: var(--red);
	text-align: center;
	letter-spacing: 2px;
}

.nav-links {
	list-style: none;
	padding: 0;
	margin-top: 50px;
}

.nav-links li {
	margin-bottom: 15px;
}

.nav-links a {
	color: var(--gray);
	text-decoration: none;
	display: block;
	padding: 12px;
	border-radius: 8px;
	transition: 0.3s;
	cursor: pointer;
}

.nav-links a:hover, .nav-links a.active {
	background: var(--red);
	color: #fff;
}

/* Main Workspace */
.main-content {
	margin-left: 300px;
	padding: 40px;
	width: calc(100% - 300px);
}

.section-title {
	border-left: 4px solid var(--red);
	padding-left: 15px;
	margin-bottom: 30px;
}

/* Table Styling */
.glass-card {
	background: var(--card);
	border: 1px solid var(--border);
	border-radius: 15px;
	overflow: hidden;
	margin-bottom: 40px;
}

table {
	width: 100%;
	border-collapse: collapse;
}

th {
	background: #1a1a1a;
	padding: 15px;
	text-align: left;
	color: var(--gray);
	font-size: 0.85rem;
	text-transform: uppercase;
}

td {
	padding: 15px;
	border-bottom: 1px solid #222;
	vertical-align: middle;
}

/* Buttons */
.btn-action {
	background: #222;
	color: #fff;
	border: 1px solid #444;
	padding: 8px 16px;
	border-radius: 6px;
	cursor: pointer;
	text-decoration: none;
	font-size: 0.9rem;
}

.btn-action:hover {
	background: var(--red);
	border-color: var(--red);
}

.btn-start {
	background: var(--red);
	border: none;
	font-weight: bold;
}

/* Hidden Puzzle Section */
#puzzle-panel {
	display: none;
	background: #1a1a1a;
	padding: 30px;
	border-radius: 15px;
	border: 2px solid #ffd700;
	margin-top: 20px;
	animation: slideDown 0.4s ease-out;
}

@
keyframes slideDown {from { opacity:0;
	transform: translateY(-20px);
}

to {
	opacity: 1;
	transform: translateY(0);
}

}
.input-dark {
	background: #000;
	color: #fff;
	border: 1px solid #444;
	padding: 12px;
	border-radius: 8px;
	width: 100%;
	margin-bottom: 15px;
	box-sizing: border-box;
}

@media ( max-width : 992px) {
	/* Stack buttons vertically in the table so they don't hit each other */
	td:last-child {
		display: flex;
		flex-direction: column;
		gap: 8px;
		min-width: 100px;
	}
	.btn-action {
		width: 100%; /* Buttons take full width of the cell */
		text-align: center;
		font-size: 0.7rem;
		padding: 6px;
	}
}
</style>
</head>
<body>

	<nav class="sidebar">
		<div class="logo-box">
			<h2>தமிழ் கதவு</h2>
		</div>
		<ul class="nav-links">
			<li><a href="StudentDashboard.jsp" class="active">Student
					Management</a></li>
			<li><a onclick="showPuzzle()">Update Daily Puzzle 🧩</a></li>
			<li><a href="LogoutServlet"
				style="margin-top: 100px; color: var(--red); border: 1px solid var(--red); text-align: center;">Logout</a></li>
		</ul>
	</nav>

	<main class="main-content">
		<div class="section-title">
			<h1>நிர்வாகத் தளம் (Teacher Admin)</h1>
			<p style="color: var(--gray);">
				வணக்கம்,
				<%=teacherName%>! Manage your students below.
			</p>
		</div>

		<div class="glass-card">
			<h3 style="padding: 15px 20px; margin: 0; background: #1a1a1a;">Registered
				Students</h3>
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
					try {
						Class.forName("com.mysql.cj.jdbc.Driver");
						Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/tamil_kadhavu_db", "root", "root");

						// Query to get student details and their current assignment
						String query = "SELECT id, name, slot_time, assignment_link, submission_link FROM users WHERE role='student'";
						Statement st = con.createStatement();
						ResultSet rs = st.executeQuery(query);

						while (rs.next()) {
							String sid = rs.getString("id");
							String sLink = rs.getString("assignment_link");
					%>
					<tr>
						<td><strong><%=rs.getString("name")%></strong></td>
						<td><%=(rs.getString("slot_time") != null) ? rs.getString("slot_time") : "Not Set"%></td>
						<td>
							<form action="UploadServlet" method="POST"
								enctype="multipart/form-data">
								<input type="hidden" name="studentId" value="<%=sid%>">
								<input type="file" name="file" required
									style="font-size: 0.7rem; color: var(--gray);">
								<button type="submit" class="btn-action"
									style="padding: 4px 10px;">Upload</button>
							</form> <%
 if (sLink != null) {
 %>
							<div style="margin-top: 5px;">
								<a href="<%=sLink%>" target="_blank"
									style="color: var(--green); font-size: 0.75rem;">View
									Current 📄</a>
							</div> <%
 }
 %>
						</td>
						<td><a href="https://meet.google.com/new" target="_blank"
							class="btn-action btn-start">Start <span>Live</span></a> <a
							href="EditSlots.jsp?id=<%=sid%>" class="btn-action"
							style="margin-left: 5px;">Edit <span>Slot</span></a></td>
					</tr>
					<%
					}
					con.close();
					} catch (Exception e) {
					out.println("Error: " + e.getMessage());
					}
					%>
				</tbody>
			</table>
		</div>

		<div id="puzzle-panel">
			<h3 style="color: #ffd700; margin-top: 0;">இன்றைய புதிர் (Daily
				Puzzle)</h3>
			<form action="UpdatePortalServlet" method="POST">
				<label style="font-size: 0.8rem; color: var(--gray);">Riddle/Question:</label>
				<textarea name="newQuiz" class="input-dark" style="height: 80px;"
					placeholder="Ex: I have wings but I'm not a bird..."></textarea>

				<label style="font-size: 0.8rem; color: var(--gray);">Correct
					Answer:</label> <input type="text" name="newAns" class="input-dark"
					placeholder="Ex: Aeroplane">

				<button type="submit" class="btn-action"
					style="background: var(--red); border: none; width: 100%; padding: 12px; font-weight: bold;">PUBLISH
					TO PORTAL</button>
			</form>
		</div>

		<div class="glass-card"
			style="margin-top: 30px; border-top: 3px solid var(--green);">
			<h3 style="padding: 15px 20px; margin: 0;">Completed Work Inbox
				📥</h3>
			<p style="padding: 0 20px; color: var(--gray); font-size: 0.8rem;">When
				students upload finished work, it will appear here.</p>
			<table>
				<thead style="background: #121212;">
					<tr>
						<th>Student Name</th>
						<th>Submission</th>
						<th>Date Received</th>
					</tr>
				</thead>
				<tbody>
					<%
					// This uses a simple check for submission_link
					// Re-opening connection for the second table
					try {
						Connection con2 = DriverManager.getConnection("jdbc:mysql://localhost:3306/tamil_kadhavu_db", "root", "root");
						String query2 = "SELECT name, submission_link FROM users WHERE submission_link IS NOT NULL";
						ResultSet rs2 = con2.createStatement().executeQuery(query2);
						while (rs2.next()) {
					%>
					<tr>
						<td><%=rs2.getString("name")%></td>
						<td><a href="<%=rs2.getString("submission_link")%>"
							target="_blank" style="color: var(--green);">Download Student
								File ⬇️</a></td>
						<td>Just Now</td>
					</tr>
					<%
					}
					con2.close();
					} catch (Exception e) {
					}
					%>
				</tbody>
			</table>
		</div>
	</main>

	<script>
		function showPuzzle() {
			var panel = document.getElementById("puzzle-panel");
			if (panel.style.display === "block") {
				panel.style.display = "none";
			} else {
				panel.style.display = "block";
				panel.scrollIntoView({
					behavior : 'smooth'
				});
			}
		}

		// Handle Success Alerts
		const params = new URLSearchParams(window.location.search);
		if (params.get('portalUpdate') === 'success')
			alert("Portal Updated Successfully! 🎉");
		if (params.get('upload') === 'success')
			alert("Assignment Sent to Student! ✅");
	</script>
</body>
</html>