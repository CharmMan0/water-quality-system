package com.example.waterqualitysystem;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * 登录权限过滤器 — 统一校验登录状态
 * 替代各 JSP 页面顶部重复的 session 检查代码
 * 未登录用户自动跳转到 login.jsp，放行公开页面
 */
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
                         FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        String path = req.getRequestURI();
        String contextPath = req.getContextPath();

        // 放行公开页面和静态资源
        if (isPublicPath(path, contextPath)) {
            chain.doFilter(request, response);
            return;
        }

        // 检查登录状态
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            res.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        chain.doFilter(request, response);
    }

    /**
     * 判断是否为无需登录即可访问的公开路径
     */
    private boolean isPublicPath(String path, String contextPath) {
        String relativePath = path;
        if (contextPath != null && !contextPath.isEmpty() && path.startsWith(contextPath)) {
            relativePath = path.substring(contextPath.length());
        }

        // 公开页面
        if (relativePath.endsWith("login.jsp") || relativePath.endsWith("register.jsp")) {
            return true;
        }

        // 公开 Servlet
        if (relativePath.endsWith("/login") || relativePath.endsWith("/register")) {
            return true;
        }

        // 静态资源（如果项目中有本地静态文件）
        if (relativePath.contains("/images/")) {
            return true;
        }

        return false;
    }

    @Override
    public void destroy() {
    }
}
