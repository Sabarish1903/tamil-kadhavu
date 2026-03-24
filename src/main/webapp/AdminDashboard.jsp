<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="tamil_kadhavu.DBConnection" %> <%-- FIX 1: Import your Connection Class --%>
<!DOCTYPE html>
<html lang="ta">
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard | தமிழ் கதவு</title>
    <link rel="stylesheet" href="Register.css">
    <link rel="icon" type="image/x-icon" href="./images/tamil_kadhavu.jpg">
    <style>
        body { background-color: #000; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        .admin-container { padding: 50px; color: white; max-width: 1000px; margin: auto; }
        h2 { border-bottom: 2px solid #ff0000; padding-bottom: 10px; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; background: #111; box-shadow: 0 0 20px rgba(255, 0, 0, 0.2); }
        th, td { padding: 15px; border: 1px solid #333; text-align: left; }
        th { background: #ff0000; color: white; text-transform: uppercase; letter-spacing: 1px; }
        tr:hover { background-color: #1a1a1a; }
        .approve-btn { background-color: #28a745; color: white; padding: 8px 15px; text-decoration: none; border-radius: 4px; font-weight: bold; display: inline-block; transition: background 0.3s; }
        .approve-btn:hover { background-color: #218838; }
        .no-data { text-align: center; padding: 20px; color: #888; }
        .alert-success { color: #28a745; padding: 10px; border: 1px solid #28a745; margin-bottom: 10px; }
    </style>
</head>
<body>
    <div class="admin-container">
        <h2>நிர்வாகி டாஷ்போர்டு (Admin Dashboard)</h2>

        <%-- Check for success message from ApproveUserServlet --%>
        <% if("success".equals(request.getParameter("approve"))) { %>
            <div class="alert-success">பயனர் வெற்றிகரமாக அங்கீகரிக்கப்பட்டார்! (User Approved Successfully!)</div>
        <% } %>

        <p>ஆசிரியர் ஒப்புதல்கள் (Pending Teacher Approvals):</p>

        <table>
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Experience</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <%
                Connection con = null;
                PreparedStatement ps = null; // Use PreparedStatement for better performance
                ResultSet rs = null;
                try {
                    // FIX 2: Use cloud connection class
                    con = DBConnection.getConnection();

                    // FIX 3: Ensure query matches your TiDB structure exactly
                    String query = "SELECT name, email, experience FROM users WHERE LOWER(role)='teacher' AND LOWER(status)='pending'";
                    ps = con.prepareStatement(query);
                    rs = ps.executeQuery();

                    boolean found = false;
                    while (rs.next()) {
                        found = true;
                        String teacherName = rs.getString("name");
                        String teacherEmail = rs.getString("email");
                        String exp = rs.getString("experience");

                        if (exp == null || exp.trim().isEmpty()) {
                            exp = "Not Specified";
                        }
                %>
                <tr>
                    <td><%= teacherName %></td>
                    <td><%= teacherEmail %></td>
                    <td><%= exp %></td>
                    <td>
                        <a href="ApproveUserServlet?email=<%= teacherEmail %>" class="approve-btn"> Approve </a>
                    </td>
                </tr>
                <%
                    }
                    if (!found) {
                %>
                <tr>
                    <td colspan="4" class="no-data">தற்போது நிலுவையில் உள்ள கோரிக்கைகள் எதுவுமில்லை (No pending approvals).</td>
                </tr>
                <%
                    }
                } catch (Exception e) {
                    out.println("<tr><td colspan='4' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
                    e.printStackTrace();
                } finally {
                    // Standard cleanup
                    if (rs != null) rs.close();
                    if (ps != null) ps.close();
                    if (con != null) con.close();
                }
                %>
            </tbody>
        </table>

        <div style="margin-top: 30px;">
            <a href="LogoutServlet" style="color: #ccc; text-decoration: none;">Logout</a>
        </div>
    </div>
</body>
</html>
