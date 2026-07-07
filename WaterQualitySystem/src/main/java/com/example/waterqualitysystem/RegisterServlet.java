package com.example.waterqualitysystem;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // 两次密码不一致
        if (!password.equals(confirmPassword)) {
            response.sendRedirect("register.jsp?error=password");
            return;
        }

        Connection conn = null;
        PreparedStatement checkUserPs = null;
        PreparedStatement checkEmailPs = null;
        PreparedStatement insertPs = null;
        ResultSet rs1 = null;
        ResultSet rs2 = null;

        try {
            // ============================================================
            //  事务开始 — 关掉自动提交，保证 检查→检查→插入 三步原子性
            // ============================================================
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);          // ① 关闭自动提交

            // ② 检查用户名是否已存在
            checkUserPs = conn.prepareStatement(
                    "SELECT id FROM users WHERE username=? FOR UPDATE");
            checkUserPs.setString(1, username);
            rs1 = checkUserPs.executeQuery();
            if (rs1.next()) {
                conn.rollback();               // ③ 失败 → 回滚
                response.sendRedirect("register.jsp?error=exist");
                return;
            }

            // ② 检查邮箱是否已存在
            checkEmailPs = conn.prepareStatement(
                    "SELECT id FROM users WHERE email=? FOR UPDATE");
            checkEmailPs.setString(1, email);
            rs2 = checkEmailPs.executeQuery();
            if (rs2.next()) {
                conn.rollback();               // ③ 失败 → 回滚
                response.sendRedirect("register.jsp?error=email");
                return;
            }

            // ② 插入用户
            insertPs = conn.prepareStatement(
                    "INSERT INTO users(username, password, email, role_id, create_time, status) " +
                    "VALUES (?, ?, ?, ?, NOW(), 1)");
            insertPs.setString(1, username);
            insertPs.setString(2, DBUtil.sha256(password));
            insertPs.setString(3, email);
            insertPs.setInt(4, 2);  // 角色=普通用户
            insertPs.executeUpdate();

            conn.commit();                     // ④ 全部成功 → 提交

            response.sendRedirect("login.jsp");

        } catch (Exception e) {
            // ⑤ 任何异常 → 回滚所有操作
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            response.sendRedirect("register.jsp?error=server");

        } finally {
            // ⑥ 无论如何都要关闭资源、恢复 auto-commit
            try { if (rs1 != null) rs1.close(); } catch (Exception e) { }
            try { if (rs2 != null) rs2.close(); } catch (Exception e) { }
            try { if (checkUserPs != null) checkUserPs.close(); } catch (Exception e) { }
            try { if (checkEmailPs != null) checkEmailPs.close(); } catch (Exception e) { }
            try { if (insertPs != null) insertPs.close(); } catch (Exception e) { }
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException e) { }
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
}
