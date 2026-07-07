<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<% request.setAttribute("pageTitle", "警告列表"); %>
<%@ include file="template_header.jsp" %>

<div class="c-hero">
    <div class="c-hero-content">
        <h1>水质警告列表</h1>
        <p>实时监控水质异常，及时处理预警信息</p>
    </div>
</div>

<div class="c-container">
    <% List<Map<String,Object>> list = (List<Map<String,Object>>) request.getAttribute("warnings");
       int warnIdx = 0;
       if(list != null) for(Map<String,Object> w : list) {
           warnIdx++;
           String level = (String) w.get("level");
           String borderColor = level.equals("高") ? "#dc2626" : level.equals("中") ? "#f59e0b" : "#3b82f6";
           String levelIcon = level.equals("高") ? "&#128308;" : level.equals("中") ? "&#128993;" : "&#128994;";
           int animIdx = warnIdx > 6 ? 6 : warnIdx; %>
    <div class="c-card c-reveal c-reveal--<%= animIdx %> c-mb-3" style="border-left:4px solid <%= borderColor %>">
        <div class="c-card-body">
            <div style="display:flex; justify-content:space-between; align-items:flex-start; gap:1rem;">
                <h5 style="margin:0; font-size:1.05rem;">
                    <%= levelIcon %> [<%= level %>] <%= w.get("message") %>
                </h5>
                <span class="c-badge <%= (Boolean)w.get("isResolved") ? "c-badge--ok" : "c-badge--bad" %>">
                    <%= (Boolean)w.get("isResolved") ? "已解决" : "未解决" %>
                </span>
            </div>
            <p class="c-text-sm c-text-muted c-mt-2" style="margin-bottom:0;">
                检测ID: <%= w.get("detectionId") %> |
                pH: <%= w.get("ph") %> |
                预测: <%= w.get("prediction") %> |
                创建: <%= w.get("createTime") %>
                <% if(w.get("handleTime") != null) { %> | 处理: <%= w.get("handleTime") %><% } %>
            </p>
        </div>
    </div>
    <% } else { %>
    <div class="c-callout c-callout--info">暂无警告记录</div>
    <% } %>
</div>
<%@ include file="template_footer.jsp" %>