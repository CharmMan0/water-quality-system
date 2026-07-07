<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% request.setAttribute("pageTitle", "用户反馈"); %>
<%@ include file="template_header.jsp" %>

<div class="c-hero">
    <div class="c-hero-content">
        <h1>用户反馈</h1>
        <p>帮助我们改进系统，提交您的宝贵意见</p>
    </div>
</div>

<div class="c-container-sm">
    <div class="c-card c-mb-4">
        <div class="c-card-body">
            <form action="submitFeedback" method="post">
                <div class="c-field">
                    <label class="c-label">反馈标题</label>
                    <input type="text" name="title" class="c-input" placeholder="请输入反馈标题" required>
                </div>
                <div class="c-field">
                    <label class="c-label">反馈类型</label>
                    <select name="type" class="c-select">
                        <option value="suggestion">意见建议</option>
                        <option value="bug">问题报告</option>
                        <option value="complaint">投诉</option>
                    </select>
                </div>
                <div class="c-field">
                    <label class="c-label">反馈内容</label>
                    <textarea name="content" class="c-textarea" rows="5" placeholder="请详细描述您的反馈" required></textarea>
                </div>
                <button type="submit" class="c-btn c-btn--primary"><i class="bi bi-send"></i> 提交反馈</button>
            </form>
        </div>
    </div>
</div>

<div class="c-container">
    <div class="c-section-hd">
        <h2>历史反馈</h2>
        <div class="hd-line"></div>
    </div>
    <div class="c-card">
        <div class="c-card-body">
            <%@ page import="java.sql.*, com.example.waterqualitysystem.DBUtil" %>
            <div class="c-table-wrap">
                <table class="c-table">
                    <thead><tr><th>标题</th><th>类型</th><th>状态</th><th>时间</th></tr></thead>
                    <tbody>
                    <% try (Connection c = DBUtil.getConnection(); Statement s = c.createStatement();
                        ResultSet rs = s.executeQuery("SELECT * FROM feedback ORDER BY create_time DESC LIMIT 20")) {
                        while(rs.next()) { %>
                    <tr><td><%= rs.getString("title") %></td>
                        <td><%= rs.getString("feedback_type") %></td>
                        <td><span class="c-badge <%= rs.getInt("status")==0?"c-badge--warn":rs.getInt("status")==1?"c-badge--info":"c-badge--ok" %>"><%= rs.getInt("status")==0?"未处理":rs.getInt("status")==1?"已读":"已回复" %></span></td>
                        <td><%= rs.getTimestamp("create_time") %></td></tr>
                    <% } } catch(Exception e) { e.printStackTrace(); } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
<%@ include file="template_footer.jsp" %>