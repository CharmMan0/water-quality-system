package com.example.waterqualitysystem;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try {

            Connection conn = DBUtil.getConnection();

            // 先查用户（不再在 SQL 中比较明文字段，改为 Java 层 SHA-256 比较）
            String sql = "SELECT * FROM users WHERE username=? AND status=1";

            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setString(1, username);

            ResultSet rs = ps.executeQuery();

            if(rs.next()){

                // SHA-256 密码哈希比对
                String storedHash = rs.getString("password");
                String inputHash = DBUtil.sha256(password);

                if (inputHash.equals(storedHash)) {

                    HttpSession session = request.getSession();

                    session.setAttribute("username", username);
                    session.setAttribute("userId", rs.getInt("id"));

                    // 更新最后登录时间
                    PreparedStatement updatePs = conn.prepareStatement(
                        "UPDATE users SET last_login_time = NOW() WHERE id = ?");
                    updatePs.setInt(1, rs.getInt("id"));
                    updatePs.executeUpdate();
                    updatePs.close();

                    response.sendRedirect("dashboard");

                } else {

                    request.setAttribute("msg", "密码错误");
                    request.getRequestDispatcher("login.jsp")
                            .forward(request, response);
                }

            }else{

                request.setAttribute("msg", "用户不存在或已被禁用");
                request.getRequestDispatcher("login.jsp")
                        .forward(request,response);
            }

            rs.close();
            ps.close();
            conn.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}