<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<% request.setAttribute("pageTitle", "系统公告"); %>
<%@ include file="template_header.jsp" %>

<div class="c-hero">
    <div class="c-hero-content">
        <h1>系统公告</h1>
        <p>了解系统最新动态和重要通知</p>
    </div>
</div>

<div class="c-container">
    <% List<Map<String,Object>> list = (List<Map<String,Object>>) request.getAttribute("announcements");
       int annIdx = 0;
       if(list != null) for(Map<String,Object> a : list) {
           annIdx++;
           int animIdx = annIdx > 6 ? 6 : annIdx; %>
    <div class="c-card c-reveal c-reveal--<%= animIdx %> c-mb-3" <%= (Boolean)a.get("isTop") ? "style=\"border-left:4px solid #0ea5e9\"" : "" %>>
        <div class="c-card-body">
            <h5 style="margin:0 0 0.5rem 0; font-size:1.05rem;">
                <%= a.get("title") %> <%= (Boolean)a.get("isTop") ? "<span class=\"c-badge c-badge--bad\">置顶</span>" : "" %>
            </h5>
            <p class="c-text-sm c-text-muted" style="margin-bottom:0.75rem;">
                <i class="bi bi-person"></i> <%= a.get("publisher") %> |
                <i class="bi bi-tag"></i> <%= a.get("category") %> |
                <i class="bi bi-eye"></i> <%= a.get("viewCount") %>次阅读 |
                <i class="bi bi-clock"></i> <%= a.get("createTime") %>
            </p>
            <p><%= a.get("content") %></p>
            <% if(a.get("summary") != null) { %><p class="c-text-sm c-text-muted" style="font-style:italic;">摘要：<%= a.get("summary") %></p><% } %>
        </div>
    </div>
    <% } else { %>
    <div class="c-callout c-callout--info">暂无公告</div>
    <% } %>
</div>
<%@ include file="template_footer.jsp" %>