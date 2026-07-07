<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>
<%
    // 服务端鉴权 — 非管理员直接踢回仪表盘
    String cu = (String) session.getAttribute("username");
    if (cu == null || !"admin".equals(cu)) {
        response.sendRedirect("dashboard");
        return;  // 必须 return，否则后面代码仍会执行
    }
    request.setAttribute("pageTitle", "数据备份管理");
%>
<%@ include file="template_header.jsp" %>

<%
    String msg = (String) request.getAttribute("msg");
    String msgType = (String) request.getAttribute("msgType");
    List<Map<String,Object>> backups = (List<Map<String,Object>>) request.getAttribute("backups");
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
%>

<section class="c-hero">
    <div class="c-hero-content">
        <h1>数据备份管理</h1>
        <p>数据库备份、恢复与历史管理（管理员专用）</p>
    </div>
</section>

<div class="c-container">

    <% if (msg != null) { %>
    <div class="c-callout c-callout--<%= "ok".equals(msgType) ? "ok" : "bad" %> c-mb-3 c-reveal c-reveal--1">
        <i class="bi bi-<%= "ok".equals(msgType) ? "check-circle" : "exclamation-circle" %>" style="font-size:1.2rem;"></i>
        <span><%= msg %></span>
    </div>
    <% } %>

    <!-- 操作区 -->
    <div class="c-card c-mb-4 c-reveal c-reveal--1">
        <div class="c-card-body">
            <div style="display:flex;align-items:center;gap:1rem;flex-wrap:wrap;">
                <!-- 创建备份 -->
                <form method="post" action="backup" style="margin:0;">
                    <input type="hidden" name="action" value="backup">
                    <button type="submit" class="c-btn c-btn--primary">
                        <i class="bi bi-database-add"></i> 立即备份
                    </button>
                </form>

                <span class="c-text-muted c-text-sm">
                    <i class="bi bi-info-circle"></i>
                    备份使用 mysqldump，包含全部表+视图+存储过程+触发器。恢复前会自动创建快照。
                </span>
            </div>
        </div>
    </div>

    <!-- 备份列表 -->
    <div class="c-card c-reveal c-reveal--2">
        <div class="c-card-header">
            <i class="bi bi-archive" style="color:var(--c-water);"></i> 备份历史
            <% if (backups != null) { %>
            <span class="c-badge c-badge--ghost" style="margin-left:0.5rem;"><%= backups.size() %> 份</span>
            <% } %>
        </div>
        <div class="c-card-body">
            <% if (backups == null || backups.isEmpty()) { %>
            <p class="c-text-muted c-text-center"><i class="bi bi-folder2-open"></i> 暂无备份文件。点击上方"立即备份"创建第一份。</p>
            <% } else { %>
            <div class="c-table-wrap">
                <table class="c-table">
                    <thead>
                        <tr>
                            <th>文件名</th>
                            <th>大小</th>
                            <th>备份时间</th>
                            <th style="text-align:center;">操作</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% for (Map<String,Object> b : backups) {
                        String name = (String) b.get("name");
                        boolean isSnap = name.contains("BEFORE_RESTORE");
                    %>
                        <tr <%= isSnap ? "style='background:#fefce8;'" : "" %>>
                            <td>
                                <i class="bi bi-<%= isSnap ? "shield-check" : "filetype-sql" %>"
                                   style="color:<%= isSnap ? "#d97706" : "var(--c-water)" %>;"></i>
                                <%= name %>
                                <% if (isSnap) { %><span class="c-badge c-badge--warn" style="margin-left:0.4rem;">恢复前快照</span><% } %>
                            </td>
                            <td><%= b.get("size") %></td>
                            <td class="c-text-sm c-text-muted"><%= sdf.format((Date) b.get("time")) %></td>
                            <td style="text-align:center;">
                                <div style="display:inline-flex;gap:0.35rem;">
                                    <!-- 下载 -->
                                    <a href="backup?action=download&file=<%= name %>"
                                       class="c-btn c-btn--outline c-btn--sm" title="下载">
                                        <i class="bi bi-download"></i> 下载
                                    </a>
                                    <!-- 恢复（高危，需确认） -->
                                    <form method="post" action="backup" style="margin:0;display:inline;"
                                          onsubmit="return confirmRestore('<%= name %>','<%= b.get("size") %>')">
                                        <input type="hidden" name="action" value="restore">
                                        <input type="hidden" name="file" value="<%= name %>">
                                        <button type="submit" class="c-btn c-btn--outline c-btn--sm"
                                                style="color:#d97706;border-color:#fbbf24;"
                                                title="恢复此备份（会覆盖当前所有数据）">
                                            <i class="bi bi-arrow-clockwise"></i> 恢复
                                        </button>
                                    </form>
                                    <!-- 删除 -->
                                    <a href="backup?action=delete&file=<%= name %>"
                                       class="c-btn c-btn--outline c-btn--sm"
                                       style="color:#dc2626;border-color:#fca5a5;"
                                       onclick="return confirm('确定要删除 <%= name %> 吗？此操作不可撤销。')"
                                       title="删除">
                                        <i class="bi bi-trash"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>
        </div>
    </div>

    <!-- 注意事项 -->
    <div class="c-callout c-callout--info c-mt-4 c-reveal c-reveal--3">
        <i class="bi bi-lightbulb" style="font-size:1.2rem;"></i>
        <div>
            <strong>使用说明</strong><br>
            <span class="c-text-sm">• <strong>备份</strong>：将整个数据库导出为 .sql 文件，保存在服务器 backups 目录<br>
            • <strong>恢复</strong>：用选定的备份文件覆盖数据库。恢复前会自动创建一个快照以防操作失误<br>
            • <strong>下载</strong>：将备份文件下载到本地保存<br>
            • <strong>删除</strong>：删除服务器上的备份文件</span>
        </div>
    </div>

</div>

<script>
    function confirmRestore(name, size) {
        return confirm(
            '══════════════════════════════\n' +
            '⚠️  高危操作 — 数据恢复\n' +
            '══════════════════════════════\n\n' +
            '即将从以下备份覆盖所有现有数据：\n' +
            '  ' + name + ' (' + size + ')\n\n' +
            '系统会在恢复前自动创建快照，\n' +
            '但仍建议您确认无误后再继续。\n\n' +
            '确定要继续吗？'
        );
    }
</script>

<%@ include file="template_footer.jsp" %>
