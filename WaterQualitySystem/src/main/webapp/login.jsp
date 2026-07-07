<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>登录 &mdash; Water Quality AI</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root {
            --c-deep: #0c4a6e; --c-ocean: #0369a1; --c-water: #0ea5e9;
            --surface: #ffffff; --text: #0f172a; --text-muted: #94a3b8;
            --border: #e2e8f0; --danger: #dc2626; --danger-bg: #fee2e2;
            --r-md: 12px; --r-lg: 16px;
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
                radial-gradient(ellipse 80% 60% at 30% 20%, rgba(14,165,233,0.12) 0%, transparent 60%),
                radial-gradient(ellipse 60% 50% at 70% 80%, rgba(20,184,166,0.10) 0%, transparent 60%),
                linear-gradient(180deg, #f0f7fb 0%, #e8f4f8 100%);
            padding: 1.5rem;
        }

        /* Background decoration */
        body::before {
            content: '';
            position: fixed;
            width: 400px; height: 400px;
            border-radius: 50%;
            border: 1px solid rgba(14,165,233,0.08);
            top: -150px; right: -100px;
            pointer-events: none;
        }

        body::after {
            content: '';
            position: fixed;
            width: 250px; height: 250px;
            border-radius: 50%;
            border: 1px solid rgba(20,184,166,0.08);
            bottom: -80px; left: -60px;
            pointer-events: none;
        }

        .auth-card {
            width: 100%;
            max-width: 440px;
            background: var(--surface);
            border-radius: var(--r-lg);
            box-shadow: 0 20px 60px rgba(15,23,42,0.1), 0 0 0 1px rgba(15,23,42,0.05);
            padding: 2.25rem 2rem;
            position: relative;
            overflow: hidden;
        }

        .auth-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 3px;
            background: linear-gradient(90deg, var(--c-water), #14b8a6, #0ea5e9);
        }

        .auth-logo {
            width: 56px; height: 56px;
            border-radius: 14px;
            background: linear-gradient(135deg, var(--c-water), #14b8a6);
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-size: 1.6rem;
            margin: 0 auto 0.85rem;
            box-shadow: 0 4px 16px rgba(14,165,233,0.3);
        }

        .auth-title {
            text-align: center;
            font-size: 1.6rem;
            font-weight: 800;
            color: var(--c-deep);
            letter-spacing: -0.02em;
            margin-bottom: 0.25rem;
        }

        .auth-subtitle {
            text-align: center;
            font-size: 0.9rem;
            color: var(--text-muted);
            margin-bottom: 1.5rem;
        }

        .field {
            margin-bottom: 1rem;
        }

        .field label {
            display: block;
            font-weight: 600;
            font-size: 0.85rem;
            color: var(--text);
            margin-bottom: 0.35rem;
            letter-spacing: 0.01em;
        }

        .field input {
            width: 100%;
            padding: 0.7rem 0.9rem;
            border: 1.5px solid var(--border);
            border-radius: var(--r-md);
            font-size: 0.95rem;
            font-family: var(--font);
            background: #f8fafc;
            transition: all 180ms var(--ease);
        }

        .field input:focus {
            outline: none;
            border-color: var(--c-water);
            box-shadow: 0 0 0 3px rgba(14,165,233,0.1);
            background: #fff;
        }

        .btn-login {
            width: 100%;
            padding: 0.75rem;
            border: none;
            border-radius: var(--r-md);
            background: linear-gradient(135deg, var(--c-water), var(--c-ocean));
            color: #fff;
            font-weight: 650;
            font-size: 1rem;
            cursor: pointer;
            transition: all 180ms var(--ease);
            font-family: var(--font);
            letter-spacing: 0.01em;
            box-shadow: 0 2px 10px rgba(14,165,233,0.25);
            margin-top: 0.5rem;
        }

        .btn-login:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 18px rgba(14,165,233,0.35);
        }

        .auth-error {
            background: var(--danger-bg);
            color: var(--danger);
            padding: 0.65rem 1rem;
            border-radius: var(--r-md);
            font-size: 0.875rem;
            font-weight: 500;
            text-align: center;
            margin-top: 1rem;
        }

        .auth-link {
            text-align: center;
            margin-top: 1rem;
            font-size: 0.9rem;
            color: var(--text-muted);
        }

        .auth-link a {
            color: var(--c-water);
            text-decoration: none;
            font-weight: 600;
        }

        .auth-link a:hover { text-decoration: underline; }

        .auth-footer {
            text-align: center;
            margin-top: 1rem;
            font-size: 0.75rem;
            color: var(--text-muted);
            line-height: 1.6;
        }
    </style>
</head>
<body>
<div class="auth-card">
    <div class="auth-logo"><i class="bi bi-droplet-half"></i></div>
    <div class="auth-title">Water AI</div>
    <div class="auth-subtitle">AI 智能水质检测系统</div>

    <form action="login" method="post">
        <div class="field">
            <label>用户名</label>
            <input type="text" name="username" placeholder="请输入用户名" required autofocus>
        </div>
        <div class="field">
            <label>密码</label>
            <input type="password" name="password" placeholder="请输入密码" required>
        </div>
        <button type="submit" class="btn-login">
            <i class="bi bi-box-arrow-in-right"></i> 登 录
        </button>
    </form>

    <% String msg = (String) request.getAttribute("msg");
       if (msg != null && !msg.isEmpty()) { %>
    <div class="auth-error"><i class="bi bi-exclamation-circle"></i> <%= msg %></div>
    <% } %>

    <div class="auth-link">还没有账号？<a href="register.jsp">立即注册</a></div>

    <div class="auth-footer">
        本系统用于课程教学演示
    </div>
</div>
</body>
</html>
