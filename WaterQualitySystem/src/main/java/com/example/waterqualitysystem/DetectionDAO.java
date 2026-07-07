package com.example.waterqualitysystem;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Types;

public class DetectionDAO {

    /**
     * 保存完整检测记录（含 source_id, wqi_score, water_grade, standard_level）。
     * 使用 JDBC 事务：即使只是单条 INSERT，显式 commit/rollback
     * 确保触发器操作（如自动生成警告记录）也在同一事务中原子完成。
     */
    public static void saveDetection(
            int userId, int sourceId,
            double pH, double hardness, double solids,
            double chloramines, double sulfate, double conductivity,
            double organic_carbon, double trihalomethanes, double turbidity,
            String prediction, double probability,
            double wqiScore, String waterGrade, String standardLevel
    ) {
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);                     // ① 关闭自动提交

            String sql =
                    "INSERT INTO water_detection (user_id, source_id, " +
                    "ph, hardness, solids, chloramines, sulfate, conductivity, " +
                    "organic_carbon, trihalomethanes, turbidity, " +
                    "prediction, probability, wqi_score, water_grade, standard_level, detect_time) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";

            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            if (sourceId > 0) {
                ps.setInt(2, sourceId);
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setDouble(3, pH);
            ps.setDouble(4, hardness);
            ps.setDouble(5, solids);
            ps.setDouble(6, chloramines);
            ps.setDouble(7, sulfate);
            ps.setDouble(8, conductivity);
            ps.setDouble(9, organic_carbon);
            ps.setDouble(10, trihalomethanes);
            ps.setDouble(11, turbidity);
            ps.setString(12, prediction);
            ps.setDouble(13, probability);
            ps.setDouble(14, wqiScore);
            ps.setString(15, waterGrade != null ? waterGrade : "");
            ps.setString(16, standardLevel != null ? standardLevel : "");
            ps.executeUpdate();

            conn.commit();                                // ② 成功 → 提交
            System.out.println("检测记录保存成功！用户ID=" + userId + "，结果=" + prediction);

        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); }                  // ③ 失败 → 回滚
                catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();

        } finally {
            // ④ 无论如何都关闭资源、恢复 auto-commit
            try { if (ps != null) ps.close(); }
            catch (SQLException e) { e.printStackTrace(); }
            if (conn != null) {
                try { conn.setAutoCommit(true); }
                catch (SQLException e) { e.printStackTrace(); }
                try { conn.close(); }
                catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
}
