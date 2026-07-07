<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<%
    String pageTitle = "系统错误";
    Integer statusCode = (Integer) request.getAttribute("jakarta.servlet.error.status_code");
    String errorMessage = (String) request.getAttribute("jakarta.servlet.error.message");
    String requestUri = (String) request.getAttribute("jakarta.servlet.error.request_uri");
    Throwable exception = (Throwable) request.getAttribute("jakarta.servlet.error.exception");
    String customError = (String) request.getAttribute("error");

    if (statusCode == null) statusCode = 500;
    if (statusCode == 404) pageTitle = "页面未找到";
    else if (statusCode == 403) pageTitle = "无权访问";
    else if (statusCode == 500) pageTitle = "服务器错误";

    String icon, description;
    if (statusCode == 404) {
        icon = "bi bi-question-circle"; description = "您访问的页面不存在或已被移除";
    } else if (statusCode == 403) {
        icon = "bi bi-shield-lock"; description = "您没有访问该页面的权限，请先登录";
    } else if (statusCode == 500) {
        icon = "bi bi-exclamation-triangle"; description = "服务器内部错误，请稍后再试";
    } else {
        icon = "bi bi-exclamation-circle"; description = "发生未知错误";
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %> &mdash; Water Quality AI</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root {
            --c-water: #0ea5e9; --c-ocean: #0369a1; --c-teal: #14b8a6;
            --surface: #ffffff; --text: #0f172a; --text-muted: #94a3b8;
            --r-lg: 20px; --r-full: 9999px;
            --font: "Segoe UI", "PingFang SC", "Microsoft YaHei", system-ui, sans-serif;
            --ease: cubic-bezier(0.16, 1, 0.3, 1);
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: var(--font);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background:
                radial-gradient(ellipse 70% 50% at 50% 0%, rgba(14,165,233,0.1) 0%, transparent 60%),
                linear-gradient(180deg, #f0f7fb 0%, #f8fafc 100%);
            padding: 1.5rem;
        }

        .err-card {
            background: var(--surface);
            border-radius: var(--r-lg);
            box-shadow: 0 20px 60px rgba(15,23,42,0.1), 0 0 0 1px rgba(15,23,42,0.04);
            padding: 2.5rem 2rem;
            text-align: center;
            max-width: 500px;
            width: 100%;
            position: relative;
            overflow: hidden;
        }

        .err-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 3px;
            background: linear-gradient(90deg, var(--c-water), var(--c-teal));
        }

        .err-icon {
            font-size: 3.5rem;
            margin-bottom: 0.5rem;
            background: linear-gradient(135deg, var(--c-water), var(--c-teal));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            line-height: 1.2;
        }

        .err-code {
            font-size: 4rem;
            font-weight: 800;
            letter-spacing: -0.04em;
            color: #e2e8f0;
            line-height: 1;
            margin-bottom: 0.25rem;
        }

        .err-title {
            font-size: 1.35rem;
            font-weight: 700;
            color: var(--text);
            margin-bottom: 0.5rem;
        }

        .err-desc {
            color: var(--text-muted);
            font-size: 0.95rem;
            margin-bottom: 1.25rem;
        }

        .err-detail {
            background: #f8fafc;
            border-radius: 12px;
            padding: 1rem 1.25rem;
            margin-bottom: 1rem;
            text-align: left;
            font-size: 0.8rem;
            color: var(--text-muted);
            word-break: break-all;
            max-height: 120px;
            overflow-y: auto;
        }

        .err-detail strong { color: var(--text); display: block; margin-bottom: 0.15rem; }

        .err-actions {
            display: flex;
            gap: 0.75rem;
            justify-content: center;
            flex-wrap: wrap;
        }

        .btn-err {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            padding: 0.65rem 1.5rem;
            border-radius: var(--r-full);
            font-weight: 600;
            font-size: 0.9rem;
            text-decoration: none;
            transition: all 180ms var(--ease);
            font-family: var(--font);
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--c-water), var(--c-ocean));
            color: #fff;
            box-shadow: 0 2px 10px rgba(14,165,233,0.25);
        }
        .btn-primary:hover { transform: translateY(-1px); box-shadow: 0 4px 16px rgba(14,165,233,0.35); color: #fff; }

        .btn-ghost {
            border: 1.5px solid #e2e8f0;
            background: #fff;
            color: var(--text);
        }
        .btn-ghost:hover { border-color: #cbd5e1; background: #f8fafc; }
    </style>
</head>
<body>
<div class="err-card">
    <div class="err-code"><%= statusCode %></div>
    <div class="err-icon"><i class="<%= icon %>"></i></div>
    <div class="err-title"><%= pageTitle %></div>
    <p class="err-desc"><%= customError != null ? customError : description %></p>

    <% if (statusCode == 500 && (customError != null || exception != null || errorMessage != null)) { %>
    <div class="err-detail">
        <strong>错误详情</strong>
        <% if (customError != null) { %>
            <%= customError %>
        <% } else if (exception != null) { %>
            异常：<%= exception.getClass().getName() %>
        <% } else if (errorMessage != null) { %>
            <%= errorMessage %>
        <% } %>
        <% if (requestUri != null) { %>
            <br>请求路径：<%= requestUri %>
        <% } %>
    </div>
    <% } %>

    <div class="err-actions">
        <a href="dashboard" class="btn-err btn-primary"><i class="bi bi-house"></i> 返回首页</a>
        <a href="javascript:history.back()" class="btn-err btn-ghost"><i class="bi bi-arrow-left"></i> 返回上页</a>
    </div>
</div>
</body>
</html>
