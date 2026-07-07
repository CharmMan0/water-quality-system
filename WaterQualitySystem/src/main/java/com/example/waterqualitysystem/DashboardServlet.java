package com.example.waterqualitysystem;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int total = 0, safe = 0, unsafe = 0;
        List<Map<String, Object>> models = new ArrayList<>();
        List<Map<String, Object>> dailyTrend = new ArrayList<>();
        List<Map<String, Object>> sourceStats = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection()) {
            // 统计
            PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM water_detection");
            ResultSet rs = ps.executeQuery();
            if (rs.next()) total = rs.getInt(1);
            rs.close(); ps.close();

            ps = conn.prepareStatement("SELECT COUNT(*) FROM water_detection WHERE prediction='Safe'");
            rs = ps.executeQuery();
            if (rs.next()) safe = rs.getInt(1);
            rs.close(); ps.close();

            ps = conn.prepareStatement("SELECT COUNT(*) FROM water_detection WHERE prediction='Unsafe'");
            rs = ps.executeQuery();
            if (rs.next()) unsafe = rs.getInt(1);
            rs.close(); ps.close();

            // AI模型信息
            ps = conn.prepareStatement("SELECT * FROM ai_model_info ORDER BY id");
            rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("name", rs.getString("model_name"));
                m.put("type", rs.getString("model_type"));
                m.put("accuracy", rs.getDouble("accuracy"));
                m.put("f1", rs.getDouble("f1_score"));
                m.put("auc", rs.getDouble("auc"));
                m.put("isProd", rs.getBoolean("is_production"));
                models.add(m);
            }
            rs.close(); ps.close();

            // 🌊 近7天每日 Safe/Unsafe 趋势
            ps = conn.prepareStatement(
                "SELECT DATE(detect_time) as day, " +
                "SUM(CASE WHEN prediction='Safe' THEN 1 ELSE 0 END) as safe_count, " +
                "SUM(CASE WHEN prediction='Unsafe' THEN 1 ELSE 0 END) as unsafe_count " +
                "FROM water_detection " +
                "WHERE detect_time >= DATE_SUB(CURDATE(), INTERVAL 7 DAY) " +
                "GROUP BY DATE(detect_time) ORDER BY day");
            rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("day", rs.getString("day"));
                row.put("safe", rs.getInt("safe_count"));
                row.put("unsafe", rs.getInt("unsafe_count"));
                dailyTrend.add(row);
            }
            rs.close(); ps.close();

            // 🏞️ 水源地检测统计
            ps = conn.prepareStatement(
                "SELECT s.source_name, COUNT(d.id) as cnt, " +
                "SUM(CASE WHEN d.prediction='Safe' THEN 1 ELSE 0 END) as safe_cnt " +
                "FROM water_source_info s " +
                "LEFT JOIN water_detection d ON s.id = d.source_id " +
                "GROUP BY s.id, s.source_name ORDER BY cnt DESC");
            rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("name", rs.getString("source_name"));
                int cnt = rs.getInt("cnt");
                int safeCnt = rs.getInt("safe_cnt");
                row.put("total", cnt);
                row.put("safe", safeCnt);
                row.put("rate", cnt > 0 ? Math.round(safeCnt * 100.0 / cnt) : 0);
                sourceStats.add(row);
            }
            rs.close(); ps.close();
        } catch (Exception e) { e.printStackTrace(); }

        request.setAttribute("total", total);
        request.setAttribute("safe", safe);
        request.setAttribute("unsafe", unsafe);
        request.setAttribute("models", models);
        request.setAttribute("dailyTrend", dailyTrend);
        request.setAttribute("sourceStats", sourceStats);
        request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
    }
}