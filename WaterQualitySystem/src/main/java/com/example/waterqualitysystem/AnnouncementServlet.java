package com.example.waterqualitysystem;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/announcements")
public class AnnouncementServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(
                     "SELECT a.*, u.username FROM announcement a " +
                             "JOIN users u ON a.publisher_id=u.id ORDER BY a.is_top DESC, a.create_time DESC")) {
            while (rs.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("id", rs.getInt("id"));
                m.put("title", rs.getString("title"));
                m.put("content", rs.getString("content"));
                m.put("summary", rs.getString("summary"));
                m.put("category", rs.getString("category"));
                m.put("publisher", rs.getString("username"));
                m.put("isTop", rs.getBoolean("is_top"));
                m.put("viewCount", rs.getInt("view_count"));
                m.put("createTime", rs.getTimestamp("create_time"));
                list.add(m);
            }
        } catch (Exception e) { e.printStackTrace(); }
        request.setAttribute("announcements", list);
        request.getRequestDispatcher("announcements.jsp").forward(request, response);
    }
}