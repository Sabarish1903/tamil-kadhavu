<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="tamil_kadhavu.DBConnection" %> <%-- FIX 1: Import DB Utility --%>
<%
    String role = (String) session.getAttribute("role");
    Integer studentId = (Integer) session.getAttribute("userId");
    String studentName = (String) session.getAttribute("name");

    // Security: Ensure only students can access
    if (role == null || !role.equalsIgnoreCase("student")) {
        response.sendRedirect("Login.html");
        return;
    }

    String activeInstructor = "General Instructor";
    String assignmentLink = null;
    String dailyPuzzle = "இன்றைய புதிர் இன்னும் பதிவேற்றப்படவில்லை (No puzzle today).";
    String puzzleAns = "";

    Connection con = null;
    PreparedStatement psInst = null;
    Statement st = null;
    ResultSet rsInst = null;
    ResultSet rsQ = null;

    try {
        // FIX 2: Use cloud connection
        con = DBConnection.getConnection();
        
        // 1. FETCH ASSIGNMENT & TEACHER
        // Linking the student to the teacher. Updated column name to 'assignment'
        String instQuery = "SELECT u2.name as teacher_name, u1.assignment " +
                           "FROM users u1 JOIN users u2 ON u2.role = 'teacher' " +
                           "WHERE u1.id = ? AND u1.assignment IS NOT NULL LIMIT 1";
        
        psInst = con.prepareStatement(instQuery);
        psInst.setInt(1, studentId);
        rsInst = psInst.executeQuery();
        
        if(rsInst.next()){
            activeInstructor = rsInst.getString("teacher_name");
            assignmentLink = rsInst.getString("assignment");
        }

        // 2. FETCH LATEST QUIZ
        st = con.createStatement();
        rsQ = st.executeQuery("SELECT daily_quiz, quiz_answer FROM portal_updates WHERE id=1");
        if(rsQ.next()){
            dailyPuzzle = rsQ.getString("daily_quiz");
            puzzleAns = rsQ.getString("quiz_answer");
        }
        
    } catch(Exception e) { 
        e.printStackTrace(); 
    } finally {
        // Standard cleanup
        if (rsInst != null) rsInst.close();
        if (rsQ != null) rsQ.close();
        if (psInst != null) psInst.close();
        if (st != null) st.close();
        if (con != null) con.close();
    }
%>
<!DOCTYPE html>
<html lang="ta">
<head>
    <meta charset="UTF-8">
    <title>Student Portal | தமிழ் கதவு</title>
    <link rel="icon" type="image/x-icon" href="./images/tamil_kadhavu.jpg">
    <style>
        :root { --red: #ff0000; --bg: #000; --card: #111; --border: #333; }
        body { background: var(--bg); color: #fff; font-family: 'Segoe UI', sans-serif; margin: 0; }
        header { padding: 15px 40px; border-bottom: 1px solid var(--border); display: flex; justify-content: space-between; align-items: center; }
        .container { display: grid; grid-template-columns: 2fr 1fr; gap: 20px; padding: 40px; max-width: 1200px; margin: auto; }
        .card { background: var(--card); padding: 25px; border-radius: 15px; border: 1px solid #222; margin-bottom: 20px; }
        .btn-join { background: var(--red); color: #fff; padding: 15px 30px; border-radius: 5px; text-decoration: none; font-weight: bold; display: inline-block; transition: 0.3s; }
        .btn-join:hover { background: #cc0000; box-shadow: 0 0 15px var(--red); }
        input[type="text"] { background: #000; color: #fff; border: 1px solid #444; }
        @media (max-width: 850px) { .container { grid-template-columns: 1fr; } }
    </style>
</head>
<body>

<header>
    <div style="font-size: 1.5rem; font-weight: bold; color: var(--red);">தமிழ் <span style="color:white;">கதவு</span></div>
    <div><span>வணக்கம், <%= studentName %></span> | <a href="LogoutServlet" style="color:var(--red); text-decoration:none;">Logout</a></div>
</header>

<div class="container">
    <div class="main-content">
        <div class="card" style="text-align: center; border-top: 4px solid var(--red);">
            <h2>இன்றைய நேரடி வகுப்பு</h2>
            <p style="color: #888;">Live Session is ready for you</p>
            <%-- Redirect to your Jitsi integrated page instead of Google Meet --%>
            <a href="LiveClass.jsp?room=TamilClass_<%= studentId %>" class="btn-join">Join Video Class Now</a>
        </div>

        <div class="card" style="border-left: 4px solid #ffd700;">
            <h3 style="color: #ffd700; margin-top: 0;">இன்றைய புதிர் / செய்தி 🧩</h3>
            <p id="displayQuiz" style="font-size: 1.1rem; line-height: 1.6;"><%= dailyPuzzle %></p>
            <div style="display:flex; gap:10px;">
                <input type="text" id="userAns" style="flex:1; padding:12px; border-radius:5px; outline:none;" placeholder="உங்கள் பதில் (Your answer)...">
                <button onclick="checkAns()" style="padding:10px 20px; border-radius:5px; border:none; background:#444; color:#fff; cursor:pointer; font-weight:bold;">Check</button>
            </div>
            <p id="feedback" style="margin-top:15px; font-weight:bold;"></p>
        </div>
    </div>

    <div class="sidebar">
        <div class="card">
            <p style="color:#888; font-size:0.8rem; text-transform: uppercase;">Assigned Instructor</p>
            <h2 style="color:var(--red); margin: 5px 0;"><%= activeInstructor %></h2>
            <p style="font-size:0.85rem; color:#666;">Is currently managing your session and materials.</p>
        </div>

        <div class="card">
            <h3>பாடங்கள் (Resources)</h3>
            <% if(assignmentLink != null) { %>
                <a href="<%= assignmentLink %>" target="_blank" style="color:#00ff00; text-decoration:none; font-weight:bold; display:block; margin-bottom:10px;">Download Assignment 📄</a>
            <% } else { %>
                <p style="color:#444;">No work uploaded yet.</p>
            <% } %>
            
            <hr style="border:0; border-top:1px solid #222; margin:20px 0;">
            
            <p style="font-size:0.8rem; color:#888; margin-bottom:10px;">Upload Finished Work:</p>
            <form action="StudentUploadServlet" method="POST" enctype="multipart/form-data">
                <input type="file" name="file" required style="font-size:0.7rem; margin-bottom:15px; color: #888;">
                <button type="submit" style="width:100%; background:#222; color:#fff; border:1px solid #444; padding:10px; border-radius:5px; cursor:pointer; font-weight:bold;">SUBMIT WORK</button>
            </form>
        </div>
    </div>
</div>

<script>
    function checkAns() {
        // FIX 3: Handling potential nulls in JS
        const correct = "<%= (puzzleAns != null) ? puzzleAns.toLowerCase().trim() : "" %>";
        const user = document.getElementById("userAns").value.toLowerCase().trim();
        const f = document.getElementById("feedback");
        
        if(user === "") return;
        
        if(user === correct) {
            f.innerHTML = "🎉 Correct! சபாஷ்!"; 
            f.style.color = "#00ff00";
        } else {
            f.innerHTML = "தவறு, மீண்டும் முயற்சிக்கவும்! (Try again!)"; 
            f.style.color = "red";
        }
    }
    
    // Check URL parameters for upload success
    const params = new URLSearchParams(window.location.search);
    if(params.get('upload') === 'success') {
        alert("உங்கள் பாடம் வெற்றிகரமாக சமர்ப்பிக்கப்பட்டது! (Assignment Submitted!)");
    }
</script>

</body>
</html>
