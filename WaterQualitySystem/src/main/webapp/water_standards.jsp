<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, com.example.waterqualitysystem.DBUtil" %>
<% request.setAttribute("pageTitle", "水质标准参考"); %>
<%@ include file="template_header.jsp" %>

<div class="c-hero">
    <div class="c-hero-content">
        <h1>水质标准参考体系</h1>
        <p>基于国家标准的水质评价体系，科学评估水体质量</p>
    </div>
</div>

<div class="c-container">
    <%
    String[] levels = {"饮用水", "地表水I类", "地表水II类", "污水排放"};
    String[] cardStyles = {"background:#dbeafe;color:#1e40af", "background:#d1fae5;color:#065f46", "background:#fef3c7;color:#92400e", "background:#fee2e2;color:#991b1b"};
    String[] names = {"GB5749-2022", "GB3838-2002", "GB3838-2002", "GB8978-1996"};
    for (int i = 0; i < levels.length; i++) { %>
    <div class="c-card c-reveal c-reveal--<%= i+1 %> c-mb-4">
        <div class="c-card-header" style="<%= cardStyles[i] %>"><h5 style="margin:0;"><%= levels[i] %> - <%= names[i] %></h5></div>
        <div class="c-card-body">
            <div class="c-table-wrap">
                <table class="c-table">
                    <thead><tr><th>指标</th><th>最小值</th><th>最大值</th><th>单位</th></tr></thead>
                    <tbody>
                    <%
                    try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(
                            "SELECT * FROM water_standard WHERE standard_level=? ORDER BY id")) {
                        ps.setString(1, levels[i]);
                        ResultSet rs = ps.executeQuery();
                        while (rs.next()) {
                    %>
                    <tr><td><%= rs.getString("indicator_name") %></td>
                        <td><%= rs.getObject("min_value") %></td>
                        <td><%= rs.getObject("max_value") %></td>
                        <td><%= rs.getString("unit") %></td></tr>
                    <% } rs.close(); } catch(Exception e) { e.printStackTrace(); } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <% } %>
</div>
<%@ include file="template_footer.jsp" %>