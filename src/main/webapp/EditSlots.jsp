<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%
// Get the student ID from the URL (e.g., EditSlots.jsp?id=3)
String studentId = request.getParameter("id");
if (studentId == null || studentId.isEmpty()) {
	response.sendRedirect("StudentDashboard.jsp");
	return;
}
%>
<!DOCTYPE html>
<html lang="ta">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Edit Class Slots | Teacher Portal</title>
<link rel="icon" type="image/x-icon" href="./images/tamil_kadhavu.jpg">

<style>
body {
	background-color: #000;
	color: #fff;
	font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
	margin: 0;
	display: flex;
	justify-content: center;
	align-items: center;
	min-height: 100vh;
}

.slot-container {
	width: 100%;
	max-width: 600px;
	padding: 40px;
	background: #111;
	border-radius: 12px;
	border-left: 6px solid #FF0000;
	box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
}

h2 {
	margin-top: 0;
	color: #fff;
	font-size: 1.8rem;
}

.subtitle {
	color: #888;
	margin-bottom: 30px;
	font-size: 0.9rem;
}

.slot-row {
	display: flex;
	gap: 15px;
	align-items: center;
	margin-bottom: 20px;
	padding: 15px;
	background: #1a1a1a;
	border-radius: 8px;
	border: 1px solid #333;
}

.sequence-label {
	width: 40px;
	color: #FF0000;
	font-weight: bold;
	font-size: 1.1rem;
}

input[type="time"] {
	flex: 1;
	padding: 10px;
	background: #000;
	border: 1px solid #444;
	color: #fff;
	border-radius: 5px;
	outline: none;
}

input[type="time"]:focus {
	border-color: #FF0000;
}

span.to-text {
	color: #666;
	font-weight: bold;
}

.btn-primary {
	width: 100%;
	padding: 15px;
	background: #FF0000;
	color: white;
	border: none;
	border-radius: 8px;
	font-size: 1rem;
	font-weight: bold;
	cursor: pointer;
	transition: background 0.3s ease;
	margin-top: 10px;
}

.btn-primary:hover {
	background: #cc0000;
}

.back-link {
	display: block;
	text-align: center;
	margin-top: 20px;
	color: #888;
	text-decoration: none;
	font-size: 0.9rem;
}

.back-link:hover {
	color: #fff;
}
</style>
</head>
<body>

	<div class="slot-container">
		<h2>வகுப்பு நேரத்தை மாற்றவும்</h2>
		<p class="subtitle">
			Update teaching slots for Student ID: <strong><%=studentId%></strong>
		</p>

		<form action="UpdateSlotsServlet" method="POST">
			<input type="hidden" name="student_id" value="<%=studentId%>">

			<%
			int count = 1;
			boolean hasSlots = false;
			Connection con = null;
			try {
				Class.forName("com.mysql.cj.jdbc.Driver");
				con = DriverManager.getConnection("jdbc:mysql://localhost:3306/tamil_kadhavu_db", "root", "root");

				String query = "SELECT id, start_time, end_time FROM slots WHERE student_id = ?";
				PreparedStatement ps = con.prepareStatement(query);
				ps.setString(1, studentId);
				ResultSet rs = ps.executeQuery();

				while (rs.next()) {
					hasSlots = true;
			%>
			<div class="slot-row">
				<span class="sequence-label">#<%=count++%></span> <input
					type="hidden" name="slot_ids" value="<%=rs.getInt("id")%>">

				<input type="time" name="start_times"
					value="<%=rs.getTime("start_time")%>" required> <span
					class="to-text">to</span> <input type="time" name="end_times"
					value="<%=rs.getTime("end_time")%>" required>
			</div>
			<%
			}

			// If no slots exist yet, show one empty row for insertion
			if (!hasSlots) {
			%>
			<div class="slot-row">
				<span class="sequence-label">New</span> <input type="time"
					name="new_start_time" value="09:00" required> <span
					class="to-text">to</span> <input type="time" name="new_end_time"
					value="10:00" required>
			</div>
			<p style="color: #FFD700; font-size: 0.8rem; margin-bottom: 15px;">
				* This student has no assigned slots. Saving will create the first
				one.</p>
			<%
			}
			} catch (Exception e) {
			out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
			} finally {
			if (con != null)
			con.close();
			}
			%>

			<button type="submit" class="btn-primary">Save All Changes</button>
		</form>

		<a href="StudentDashboard.jsp" class="back-link">← Return to
			Dashboard</a>
	</div>

</body>
</html>