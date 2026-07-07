package com.example.waterqualitysystem;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/warnings")
public class WarningServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(
                     "SELECT w.*, d.ph, d.prediction FROM warning_log w " +
                             "JOIN water_detection d ON w.detection_id=d.id " +
                             "ORDER BY w.is_resolved ASC, w.create_time DESC")) {
            while (rs.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("id", rs.getInt("id"));
                m.put("detectionId", rs.getInt("detection_id"));
                m.put("level", rs.getString("warning_level"));
                m.put("message", rs.getString("warning_message"));
                m.put("isResolved", rs.getBoolean("is_resolved"));
                m.put("createTime", rs.getTimestamp("create_time"));
                m.put("handleTime", rs.getTimestamp("handle_time"));
                m.put("ph", rs.getDouble("ph"));
                m.put("prediction", rs.getString("prediction"));
                list.add(m);
            }
        } catch (Exception e) { e.printStackTrace(); }
        request.setAttribute("warnings", list);
        request.getRequestDispatcher("warnings.jsp").forward(request, response);
    }
}