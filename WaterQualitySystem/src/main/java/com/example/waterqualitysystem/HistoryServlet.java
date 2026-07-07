package com.example.waterqualitysystem;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/history")
public class HistoryServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Map<String, Object>> historyList = new ArrayList<>();
        String sql = "SELECT id, ph, prediction, probability, water_grade, detect_time " +
                     "FROM water_detection ORDER BY detect_time DESC LIMIT 100";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getInt("id"));
                row.put("ph", rs.getDouble("ph"));
                row.put("prediction", rs.getString("prediction"));
                row.put("probability", rs.getDouble("probability"));
                row.put("grade", rs.getString("water_grade") != null ? rs.getString("water_grade") : "-");
                row.put("time", rs.getTimestamp("detect_time"));
                historyList.add(row);
            }
        } catch (Exception e) { e.printStackTrace(); }
        request.setAttribute("historyList", historyList);
        request.getRequestDispatcher("history.jsp").forward(request, response);
    }
}