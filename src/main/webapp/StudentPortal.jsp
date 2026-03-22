<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String role = (String) session.getAttribute("role");
    Integer studentId = (Integer) session.getAttribute("userId");
    String studentName = (String) session.getAttribute("name");

    if (role == null || !role.equalsIgnoreCase("student")) {
        response.sendRedirect("login.jsp");
        return;
    }

    String activeInstructor = null;
    String assignmentLink = null;
    String dailyPuzzle = "Loading puzzle...";
    String puzzleAns = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/tamil_kadhavu_db", "root", "root");
        
        // 1. FETCH ASSIGNMENT & TEACHER (Linking student to the teacher who uploaded the work)
        // This assumes your 'users' table or an 'assignments' table tracks which teacher ID uploaded it.
        // For now, we will fetch the teacher role name if an assignment exists.
        PreparedStatement psInst = con.prepareStatement(
            "SELECT u2.name as teacher_name, u1.assignment_link " +
            "FROM users u1 JOIN users u2 ON u2.role = 'teacher' " +
            "WHERE u1.id = ? AND u1.assignment_link IS NOT NULL LIMIT 1");
        psInst.setInt(1, studentId);
        ResultSet rsInst = psInst.executeQuery();
        if(rsInst.next()){
            activeInstructor = rsInst.getString("teacher_name");
            assignmentLink = rsInst.getString("assignment_link");
        }

        // 2. FETCH LATEST QUIZ/NEWS FROM TEACHER
        Statement st = con.createStatement();
        ResultSet rsQ = st.executeQuery("SELECT daily_quiz, quiz_answer FROM portal_updates WHERE id=1");
        if(rsQ.next()){
            dailyPuzzle = rsQ.getString("daily_quiz");
            puzzleAns = rsQ.getString("quiz_answer");
        }
        con.close();
    } catch(Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="ta">
<head>
    <meta charset="UTF-8">
    <title>Student Portal | தமிழ் கதவு</title>
    <style>
        :root { --red: #ff0000; --bg: #000; --card: #111; }
        body { background: var(--bg); color: #fff; font-family: sans-serif; margin: 0; }
        header { padding: 15px 40px; border-bottom: 1px solid #333; display: flex; justify-content: space-between; align-items: center; }
        .container { display: grid; grid-template-columns: 2fr 1fr; gap: 20px; padding: 40px; max-width: 1200px; margin: auto; }
        .card { background: var(--card); padding: 25px; border-radius: 15px; border: 1px solid #222; margin-bottom: 20px; }
        .btn-join { background: var(--red); color: #fff; padding: 15px 30px; border-radius: 5px; text-decoration: none; font-weight: bold; display: inline-block; }
    </style>
    <link rel="icon" type="image/x-icon" href="./images/tamil_kadhavu.jpg">
</head>
<body>

<header>
    <div style="font-size: 1.5rem; font-weight: bold;">தமிழ் <span>கதவு</span></div>
    <div><span>வணக்கம், <%= studentName %></span> | <a href="LogoutServlet" style="color:var(--red); text-decoration:none;">Logout</a></div>
</header>

<div class="container">
    <div class="main-content">
        <div class="card" style="text-align: center; border-top: 4px solid var(--red);">
            <h2>இன்றைய நேரடி வகுப்பு</h2>
            <p style="color: #888;">Live Session is ready for you</p>
            <a href="https://meet.google.com/new" target="_blank" class="btn-join">Join Video Class Now</a>
        </div>

        <div class="card" style="border-left: 4px solid #ffd700;">
            <h3 style="color: #ffd700; margin-top: 0;">இன்றைய புதிர் / செய்தி 🧩</h3>
            <p id="displayQuiz"><%= dailyPuzzle %></p>
            <div style="display:flex; gap:10px;">
                <input type="text" id="userAns" style="flex:1; padding:10px; border-radius:5px; border:none;" placeholder="Your answer...">
                <button onclick="checkAns()" style="padding:10px 20px; border-radius:5px; border:none; background:#444; color:#fff; cursor:pointer;">Check</button>
            </div>
            <p id="feedback" style="margin-top:10px;"></p>
        </div>
    </div>

    <div class="sidebar">
        <% if(activeInstructor != null) { %>
        <div class="card">
            <p style="color:#888; font-size:0.8rem;">Assigned Instructor</p>
            <h2 style="color:var(--red); margin: 5px 0;"><%= activeInstructor %></h2>
            <p style="font-size:0.85rem; color:#666;">Is currently managing your session.</p>
        </div>
        <% } %>

        <div class="card">
            <h3>Resources</h3>
            <% if(assignmentLink != null) { %>
                <a href="<%= assignmentLink %>" target="_blank" style="color:#00ff00; text-decoration:none;">Download Assignment 📄</a>
            <% } else { %>
                <p style="color:#444;">No work uploaded yet.</p>
            <% } %>
            
            <hr style="border:0; border-top:1px solid #222; margin:20px 0;">
            
            <p style="font-size:0.8rem; color:#888;">Upload Finished Work:</p>
            <form action="StudentUploadServlet" method="POST" enctype="multipart/form-data">
                <input type="file" name="file" required style="font-size:0.7rem; margin-bottom:10px;">
                <button type="submit" style="width:100%; background:#222; color:#fff; border:1px solid #444; padding:5px; border-radius:5px;">Upload</button>
            </form>
        </div>
    </div>
</div>

<script>
    function checkAns() {
        const correct = "<%= puzzleAns.toLowerCase() %>";
        const user = document.getElementById("userAns").value.toLowerCase();
        const f = document.getElementById("feedback");
        if(user === correct) {
            f.innerHTML = "🎉 Correct! சபாஷ்!"; f.style.color = "#00ff00";
        } else {
            f.innerHTML = "Try again!"; f.style.color = "red";
        }
    }
</script>

</body>
</html>