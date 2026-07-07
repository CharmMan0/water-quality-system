<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, com.example.waterqualitysystem.DBUtil" %>
<% request.setAttribute("pageTitle", "检测报告"); %>
<%@ include file="template_header.jsp" %>

<div class="c-hero">
    <div class="c-hero-content">
        <h1>检测统计报告</h1>
        <p>水质检测数据的汇总统计与趋势分析</p>
    </div>
</div>

<div class="c-container">
<%
try (Connection c = DBUtil.getConnection()) {
    PreparedStatement ps;
    ResultSet rs;

    // 总览
    ps = c.prepareStatement("SELECT COUNT(*) total, ROUND(AVG(probability),4) avg_p, ROUND(AVG(wqi_score),2) avg_wqi, SUM(CASE WHEN prediction='Safe' THEN 1 ELSE 0 END) safe_count FROM water_detection");
    rs = ps.executeQuery();
    if(rs.next()) {
        int total = rs.getInt("total");
        double avgP = rs.getDouble("avg_p");
        double avgWqi = rs.getDouble("avg_wqi");
        int safeCount = rs.getInt("safe_count");
        double safeRate = total > 0 ? safeCount * 100.0 / total : 0;
%>
    <div class="c-stat-row c-mb-4 c-reveal c-reveal--1">
        <div class="c-stat">
            <div class="stat-icon-wrap" style="background:#eff6ff; color:#3b82f6;"><i class="bi bi-clipboard-data"></i></div>
            <div class="stat-number"><%= total %></div>
            <div class="stat-desc">总检测数</div>
            <div class="stat-glow" style="background:#3b82f6;"></div>
        </div>
        <div class="c-stat">
            <div class="stat-icon-wrap" style="background:#ccfbf1; color:#14b8a6;"><i class="bi bi-shield-check"></i></div>
            <div class="stat-number"><%= String.format("%.4f", avgP) %></div>
            <div class="stat-desc">平均安全概率</div>
            <div class="stat-glow" style="background:#14b8a6;"></div>
        </div>
        <div class="c-stat">
            <div class="stat-icon-wrap" style="background:#ecfdf5; color:#10b981;"><i class="bi bi-droplet"></i></div>
            <div class="stat-number"><%= String.format("%.2f", avgWqi) %></div>
            <div class="stat-desc">平均WQI指数</div>
            <div class="stat-glow" style="background:#10b981;"></div>
        </div>
        <div class="c-stat">
            <div class="stat-icon-wrap" style="background:#f5f3ff; color:#8b5cf6;"><i class="bi bi-check-circle"></i></div>
            <div class="stat-number"><%= String.format("%.1f%%", safeRate) %></div>
            <div class="stat-desc">安全率</div>
            <div class="stat-glow" style="background:#8b5cf6;"></div>
        </div>
    </div>
<% } rs.close(); ps.close();

    // 按日统计
    ps = c.prepareStatement(
        "SELECT DATE(detect_time) dt, COUNT(*) cnt, ROUND(AVG(probability),4) ap, " +
        "SUM(CASE WHEN prediction='Safe' THEN 1 ELSE 0 END) sc " +
        "FROM water_detection GROUP BY DATE(detect_time) ORDER BY dt DESC LIMIT 30");
    rs = ps.executeQuery(); %>

    <div class="c-section-hd c-reveal c-reveal--2">
        <h2>每日检测统计</h2>
        <div class="hd-line"></div>
    </div>

    <div class="c-card c-reveal c-reveal--3">
        <div class="c-card-body">
            <div class="c-table-wrap">
                <table class="c-table">
                    <thead>
                        <tr>
                            <th>日期</th>
                            <th>检测数</th>
                            <th>平均概率</th>
                            <th>安全数</th>
                            <th>安全率</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% while(rs.next()) { int cnt = rs.getInt("cnt"); int sc = rs.getInt("sc");
                       double rate = cnt>0 ? sc*100.0/cnt : 0; %>
                        <tr>
                            <td><%= rs.getDate("dt") %></td>
                            <td><%= cnt %></td>
                            <td><%= String.format("%.4f", rs.getDouble("ap")) %></td>
                            <td><%= sc %></td>
                            <td><span class="c-badge <%= rate>=80?"c-badge--ok":(rate>=50?"c-badge--warn":"c-badge--bad") %>"><%= String.format("%.1f%%", rate) %></span></td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
<% rs.close(); ps.close();
} catch(Exception e) { e.printStackTrace(); } %>
</div>
<%@ include file="template_footer.jsp" %>
