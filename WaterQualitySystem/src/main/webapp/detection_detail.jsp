<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, com.example.waterqualitysystem.DBUtil" %>
<% String idStr = request.getParameter("id");
   request.setAttribute("pageTitle", "检测详情");
%>
<%@ include file="template_header.jsp" %>

<div class="c-hero">
    <div class="c-hero-content">
        <h1>检测详情<%= idStr != null ? " #"+idStr : "" %></h1>
        <p>查看完整的检测参数与AI分析结果</p>
    </div>
</div>

<div class="c-container">
<%
    if(idStr != null) try (Connection conn = DBUtil.getConnection();
        PreparedStatement ps = conn.prepareStatement(
            "SELECT d.*, u.username, ws.source_name FROM water_detection d " +
            "LEFT JOIN users u ON d.user_id=u.id " +
            "LEFT JOIN water_source_info ws ON d.source_id=ws.id WHERE d.id=?")) {
        ps.setInt(1, Integer.parseInt(idStr));
        ResultSet rs = ps.executeQuery();
        if(rs.next()) { %>
    <div class="c-card c-reveal c-reveal--1">
        <div class="c-card-body">
            <div class="c-table-wrap">
                <table class="c-table">
                    <tbody>
                        <tr>
                            <td style="font-weight:650; width:160px;">检测ID</td>
                            <td><%= rs.getInt("id") %></td>
                        </tr>
                        <tr>
                            <td style="font-weight:650; width:160px;">用户</td>
                            <td><%= rs.getString("username") %></td>
                        </tr>
                        <tr>
                            <td style="font-weight:650; width:160px;">水源</td>
                            <td><%= rs.getString("source_name") != null ? rs.getString("source_name") : "未指定" %></td>
                        </tr>
                        <tr>
                            <td style="font-weight:650; width:160px;">pH值</td>
                            <td><%= rs.getDouble("ph") %></td>
                        </tr>
                        <tr>
                            <td style="font-weight:650; width:160px;">硬度</td>
                            <td><%= rs.getDouble("hardness") %> mg/L</td>
                        </tr>
                        <tr>
                            <td style="font-weight:650; width:160px;">固体含量</td>
                            <td><%= rs.getDouble("solids") %> ppm</td>
                        </tr>
                        <tr>
                            <td style="font-weight:650; width:160px;">氯胺</td>
                            <td><%= rs.getDouble("chloramines") %> ppm</td>
                        </tr>
                        <tr>
                            <td style="font-weight:650; width:160px;">硫酸盐</td>
                            <td><%= rs.getDouble("sulfate") %> mg/L</td>
                        </tr>
                        <tr>
                            <td style="font-weight:650; width:160px;">电导率</td>
                            <td><%= rs.getDouble("conductivity") %> μS/cm</td>
                        </tr>
                        <tr>
                            <td style="font-weight:650; width:160px;">有机碳</td>
                            <td><%= rs.getDouble("organic_carbon") %> ppm</td>
                        </tr>
                        <tr>
                            <td style="font-weight:650; width:160px;">三卤甲烷</td>
                            <td><%= rs.getDouble("trihalomethanes") %> μg/L</td>
                        </tr>
                        <tr>
                            <td style="font-weight:650; width:160px;">浊度</td>
                            <td><%= rs.getDouble("turbidity") %> NTU</td>
                        </tr>
                        <tr>
                            <td style="font-weight:650; width:160px;">AI预测</td>
                            <td><span class="c-badge <%= "Safe".equals(rs.getString("prediction"))?"c-badge--ok":"c-badge--bad" %>"><%= rs.getString("prediction") %></span></td>
                        </tr>
                        <tr>
                            <td style="font-weight:650; width:160px;">安全概率</td>
                            <td><%= rs.getDouble("probability") %></td>
                        </tr>
                        <tr>
                            <td style="font-weight:650; width:160px;">WQI指数</td>
                            <td><%= rs.getDouble("wqi_score") %></td>
                        </tr>
                        <tr>
                            <td style="font-weight:650; width:160px;">水质等级</td>
                            <td><%= rs.getString("water_grade") %></td>
                        </tr>
                        <tr>
                            <td style="font-weight:650; width:160px;">参考标准</td>
                            <td><%= rs.getString("standard_level") %></td>
                        </tr>
                        <tr>
                            <td style="font-weight:650; width:160px;">检测时间</td>
                            <td><%= rs.getTimestamp("detect_time") %></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
<% } else { %>
    <div class="c-callout c-callout--warn">
        <i class="bi bi-exclamation-triangle-fill"></i> 未找到该检测记录
    </div>
<% }
    rs.close();
} catch(Exception e) { %>
    <div class="c-callout c-callout--bad">
        <i class="bi bi-x-circle-fill"></i> 查询失败：<%= e.getMessage() %>
    </div>
<% } else { %>
    <div class="c-callout c-callout--warn">
        <i class="bi bi-exclamation-triangle-fill"></i> 未指定检测ID
    </div>
<% } %>
</div>
<%@ include file="template_footer.jsp" %>
