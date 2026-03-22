<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
// Security Check: Only allow Teachers
String role = (String) session.getAttribute("role");
if (role == null || !role.equals("teacher")) {
	response.sendRedirect("login.html");
}
%>
<!DOCTYPE html>
<html lang="ta">
<head>
<meta charset="UTF-8">
<title>ஆசிரியர் முகப்பு | Teacher Dashboard</title>
<link
	href="https://fonts.googleapis.com/css2?family=Mukta+Malar:wght@300;400;700&display=swap"
	rel="stylesheet">
<link rel="stylesheet" href="style.css">
<link rel="icon" type="image/x-icon" href="./images/tamil_kadhavu.jpg">

<style>
.dashboard-container {
	padding: 40px 6%;
}

.stats-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
	gap: 20px;
	margin-bottom: 40px;
}

.stat-card {
	background: #111;
	padding: 25px;
	border-radius: 10px;
	border-left: 4px solid #FF0000;
	text-align: center;
}

.stat-card h3 {
	color: #888;
	font-size: 14px;
	text-transform: uppercase;
}

.stat-card p {
	font-size: 2rem;
	font-weight: bold;
	color: #fff;
}

.tools-grid {
	display: grid;
	grid-template-columns: 2fr 1fr;
	gap: 30px;
}

.tool-box {
	background: #0a0a0a;
	border: 1px solid #222;
	padding: 30px;
	border-radius: 15px;
}

.tool-box h2 {
	margin-bottom: 20px;
	border-bottom: 1px solid #222;
	padding-bottom: 10px;
}

.slot-list {
	list-style: none;
}

.slot-item {
	display: flex;
	justify-content: space-between;
	padding: 15px;
	background: #151515;
	margin-bottom: 10px;
	border-radius: 5px;
}

.btn-edit-small {
	background: #FF0000;
	color: white;
	padding: 5px 15px;
	text-decoration: none;
	border-radius: 4px;
	font-size: 14px;
}
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
		<h1>
			Welcome,
			<%=session.getAttribute("name")%>!
		</h1>
		<p style="color: #888; margin-bottom: 30px;">Manage your Tamil
			classes and student slots below.</p>

		<div class="stats-grid">
			<div class="stat-card">
				<h3>Active Students</h3>
				<p>12</p>
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
					<li class="slot-item"><span><strong>Morning
								Batch:</strong> 09:00 AM - 10:00 AM</span> <a href="EditSlots.jsp"
						class="btn-edit-small">Edit Slot</a></li>
					<li class="slot-item"><span><strong>Evening
								Batch:</strong> 05:00 PM - 06:00 PM</span> <a href="EditSlots.jsp"
						class="btn-edit-small">Edit Slot</a></li>
				</ul>
				<a href="AddSlot.jsp"
					style="display: inline-block; margin-top: 15px; color: #FF0000; text-decoration: none;">+
					Add New Time Slot</a>
			</div>

			<div class="tool-box">
				<h2>Profile Status</h2>
				<p>
					Status: <span style="color: #00FF00;">Approved</span>
				</p>
				<p style="font-size: 14px; color: #666; margin-top: 10px;">Your
					profile is visible to students looking for intermediate level Tamil
					coaching.</p>
			</div>
		</div>
	</main>

</body>
</html>