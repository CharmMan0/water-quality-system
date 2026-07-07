<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, com.example.waterqualitysystem.DBUtil" %>
<% Integer userId = (Integer) session.getAttribute("userId");
    String username = (String) session.getAttribute("username");

    String phone = "", qq = "", email = "", realName = "", roleName = "", createTime = "", lastLogin = "";
    String majorClass = "", bio = "";
    int detectionCount = 0;
    try (Connection conn = DBUtil.getConnection()) {
        PreparedStatement ps = conn.prepareStatement(
            "SELECT u.*, r.role_name FROM users u JOIN roles r ON u.role_id=r.id WHERE u.id=?");
        ps.setInt(1, userId != null ? userId : 1);
        ResultSet rs = ps.executeQuery();
        if(rs.next()){
            phone = rs.getString("phone") != null ? rs.getString("phone") : "未设置";
            qq = rs.getString("qq") != null ? rs.getString("qq") : "未设置";
            email = rs.getString("email");
            realName = rs.getString("real_name") != null ? rs.getString("real_name") : username;
            majorClass = rs.getString("major_class") != null ? rs.getString("major_class") : "未设置";
            bio = rs.getString("bio") != null ? rs.getString("bio") : "";
            roleName = rs.getString("role_name");
            createTime = rs.getString("create_time");
            lastLogin = rs.getString("last_login_time") != null ? rs.getString("last_login_time") : "首次登录";
        }
        rs.close(); ps.close();

        PreparedStatement ps2 = conn.prepareStatement("SELECT COUNT(*) FROM water_detection WHERE user_id=?");
        ps2.setInt(1, userId != null ? userId : 1);
        ResultSet rs2 = ps2.executeQuery();
        if(rs2.next()) detectionCount = rs2.getInt(1);
        rs2.close(); ps2.close();
    } catch(Exception e) { e.printStackTrace(); }

    request.setAttribute("pageTitle", "个人简介 - " + realName);
%>
<%@ include file="template_header.jsp" %>

<!-- Page Hero -->
<section class="c-hero">
    <div class="c-hero-content">
        <h1><%= realName %></h1>
        <p>个人简介与账号信息</p>
    </div>
</section>

<div class="c-container">

    <!-- Profile Overview Card -->
    <div class="c-card c-reveal c-reveal--1 c-mb-3" style="text-align:center;">
        <div class="c-card-body">
            <i class="bi bi-person-circle" style="font-size:80px;color:var(--c-water);display:block;margin-bottom:0.5rem;"></i>
            <h2 style="font-size:1.5rem;font-weight:700;margin:0 0 0.35rem;color:var(--text);"><%= realName %></h2>
            <div style="display:flex;align-items:center;justify-content:center;gap:0.6rem;flex-wrap:wrap;">
                <span class="c-badge c-badge--info"><i class="bi bi-shield-check"></i> <%= roleName %></span>
                <span class="c-badge c-badge--teal"><i class="bi bi-droplet"></i> 检测次数: <strong><%= detectionCount %></strong></span>
            </div>
        </div>
    </div>

    <!-- Two-Column Grid: Basic Info + Contact -->
    <div class="c-grid-2 c-mb-3">
        <!-- Left: Basic Info -->
        <div class="c-card c-reveal c-reveal--2">
            <div class="c-card-header">
                <i class="bi bi-person-vcard" style="color:var(--c-water);"></i> 基本信息
            </div>
            <div class="c-card-body">
                <table style="width:100%;border-collapse:collapse;font-size:0.925rem;">
                    <tr>
                        <td style="padding:0.55rem 0;color:var(--text-secondary);font-weight:600;width:90px;">用户名</td>
                        <td style="padding:0.55rem 0;color:var(--text);"><%= username %></td>
                    </tr>
                    <tr>
                        <td style="padding:0.55rem 0;color:var(--text-secondary);font-weight:600;">真实姓名</td>
                        <td style="padding:0.55rem 0;color:var(--text);"><%= realName %></td>
                    </tr>
                    <tr>
                        <td style="padding:0.55rem 0;color:var(--text-secondary);font-weight:600;">专业班级</td>
                        <td style="padding:0.55rem 0;color:var(--text);"><%= majorClass %></td>
                    </tr>
                    <tr>
                        <td style="padding:0.55rem 0;color:var(--text-secondary);font-weight:600;">角色</td>
                        <td style="padding:0.55rem 0;"><span class="c-badge c-badge--info"><%= roleName %></span></td>
                    </tr>
                    <tr>
                        <td style="padding:0.55rem 0;color:var(--text-secondary);font-weight:600;">注册时间</td>
                        <td style="padding:0.55rem 0;color:var(--text);"><%= createTime %></td>
                    </tr>
                    <tr>
                        <td style="padding:0.55rem 0;color:var(--text-secondary);font-weight:600;border:none;">最后登录</td>
                        <td style="padding:0.55rem 0;color:var(--text);border:none;"><%= lastLogin %></td>
                    </tr>
                </table>
            </div>
        </div>

        <!-- Right: Contact Info -->
        <div class="c-card c-reveal c-reveal--3">
            <div class="c-card-header">
                <i class="bi bi-telephone" style="color:var(--c-teal-500);"></i> 联系方式
            </div>
            <div class="c-card-body">
                <div style="display:flex;align-items:center;gap:0.75rem;padding:0.65rem 0;border-bottom:1px solid var(--border-light);">
                    <i class="bi bi-envelope-fill" style="font-size:1.1rem;color:var(--c-water);width:24px;text-align:center;"></i>
                    <div>
                        <div style="font-size:0.78rem;color:var(--text-muted);font-weight:600;text-transform:uppercase;letter-spacing:0.04em;">邮箱</div>
                        <div style="color:var(--text);font-weight:500;"><%= email %></div>
                    </div>
                </div>
                <div style="display:flex;align-items:center;gap:0.75rem;padding:0.65rem 0;border-bottom:1px solid var(--border-light);">
                    <i class="bi bi-phone-fill" style="font-size:1.1rem;color:var(--c-teal-500);width:24px;text-align:center;"></i>
                    <div>
                        <div style="font-size:0.78rem;color:var(--text-muted);font-weight:600;text-transform:uppercase;letter-spacing:0.04em;">手机号</div>
                        <div style="color:var(--text);font-weight:500;"><%= phone %></div>
                    </div>
                </div>
                <div style="display:flex;align-items:center;gap:0.75rem;padding:0.65rem 0;">
                    <i class="bi bi-chat-dots-fill" style="font-size:1.1rem;color:var(--c-amber-400);width:24px;text-align:center;"></i>
                    <div>
                        <div style="font-size:0.78rem;color:var(--text-muted);font-weight:600;text-transform:uppercase;letter-spacing:0.04em;">QQ号</div>
                        <div style="color:var(--text);font-weight:500;"><%= qq %></div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bio / Self-Intro Full-Width Card -->
    <div class="c-card c-reveal c-reveal--4">
        <div class="c-card-header">
            <i class="bi bi-person-lines-fill" style="color:var(--c-deep);"></i> 自我介绍
        </div>
        <div class="c-card-body">
            <% if (bio != null && !bio.isEmpty()) { %>
                <p style="font-size:0.95rem;line-height:1.75;color:var(--text);"><strong><%= realName %></strong>，<%= majorClass %>，技能栈：<%= bio %>。</p>
            <% } else { %>
                <p style="font-size:0.95rem;line-height:1.75;color:var(--text);">我是<strong><%= realName %></strong>，来自<%= majorClass %>。</p>
            <% } %>
            <p style="font-size:0.95rem;line-height:1.75;color:var(--text-secondary);">通过本系统，我可以利用AI技术快速检测水质安全状况。系统基于多个机器学习模型（随机森林、SVM、LightGBM、XGBoost等）和集成学习Voting模型进行综合预测，为水质安全提供科学依据。</p>
            <p style="font-size:0.95rem;line-height:1.75;color:var(--text-secondary);">本系统采用<strong>Jakarta EE + FastAPI + MySQL</strong>技术栈，前端使用JSP+Servlet+JavaBean+ECharts构建交互式数据仪表盘，后端通过AI微服务提供实时预测能力。</p>
            <hr class="c-divider">
            <p class="c-text-muted c-text-sm"><i class="bi bi-info-circle"></i> 此项为Jakarta EE课程设计个人介绍页面（含QQ号、手机号等个人信息）</p>
        </div>
    </div>

</div>

<%@ include file="template_footer.jsp" %>