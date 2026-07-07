<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, com.example.waterqualitysystem.DBUtil" %>
<% request.setAttribute("pageTitle", "水源信息"); %>
<%@ include file="template_header.jsp" %>

<div class="c-hero">
    <div class="c-hero-content">
        <h1>水源信息管理</h1>
        <p>管理监测水源基础信息，掌握水环境概况</p>
    </div>
</div>

<div class="c-container">
    <%
    int srcIdx = 0;
    try (Connection c = DBUtil.getConnection(); Statement s = c.createStatement();
         ResultSet rs = s.executeQuery("SELECT * FROM water_source_info ORDER BY id")) { %>
    <div class="c-grid-2">
    <% while(rs.next()) {
        srcIdx++;
        int animIdx = srcIdx > 6 ? 6 : srcIdx; %>
        <div class="c-card c-reveal c-reveal--<%= animIdx %>">
            <div class="c-card-header"><i class="bi bi-droplet"></i> <%= rs.getString("source_name") %></div>
            <div class="c-card-body">
                <p class="c-mb-2"><span class="c-badge c-badge--info"><%= rs.getString("source_type") %></span></p>
                <p class="c-mb-2"><i class="bi bi-geo"></i> <%= rs.getString("province") %> <%= rs.getString("city") %></p>
                <p class="c-text-sm c-mb-2">纬度：<%= rs.getBigDecimal("latitude") %> | 经度：<%= rs.getBigDecimal("longitude") %></p>
                <p class="c-text-muted c-mb-2"><%= rs.getString("description") %></p>
                <p class="c-text-sm c-text-muted">创建时间：<%= rs.getTimestamp("create_time") %></p>
            </div>
        </div>
    <% } %>
    </div>
    <% } catch(Exception e) { e.printStackTrace(); } %>
</div>
<%@ include file="template_footer.jsp" %>