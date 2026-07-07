<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% request.setAttribute("pageTitle", "关于系统"); %>
<%@ include file="template_header.jsp" %>

<!-- Page Hero -->
<section class="c-hero">
    <div class="c-hero-content">
        <h1>关于系统</h1>
        <p>AI 智能水质检测系统 V2.0</p>
    </div>
</section>

<div class="c-container">

    <!-- Hero System Card -->
    <div class="c-card c-reveal c-reveal--1 c-mb-3" style="text-align:center;">
        <div class="c-card-body">
            <i class="bi bi-droplet-half" style="font-size:80px;color:var(--c-water);display:block;margin-bottom:0.5rem;"></i>
            <h2 style="font-size:1.5rem;font-weight:700;margin:0 0 0.3rem;color:var(--text);">AI 智能水质检测系统 V2.0</h2>
            <p class="c-text-muted" style="font-size:0.95rem;">Water Quality AI Detection System</p>
        </div>
    </div>

    <!-- Section Header -->
    <div class="c-section-hd">
        <h2><i class="bi bi-grid-3x3-gap-fill" style="color:var(--c-water);"></i> 系统详情</h2>
        <span class="hd-line"></span>
    </div>

    <!-- Two-Row, Two-Column Grid: 4 Info Cards -->
    <div class="c-grid-2 c-mb-3">
        <!-- Tech Architecture -->
        <div class="c-card c-reveal c-reveal--2">
            <div class="c-card-header">
                <i class="bi bi-gear-fill" style="color:var(--c-water);"></i> 技术架构
            </div>
            <div class="c-card-body">
                <ul style="margin:0;padding-left:1.25rem;font-size:0.925rem;color:var(--text-secondary);line-height:2;">
                    <li>前端：Jakarta EE (JSP + Servlet + JavaBean)</li>
                    <li>AI微服务：Python FastAPI</li>
                    <li>数据库：MySQL 9.6 + 视图/触发器/存储过程/游标</li>
                    <li>可视化：ECharts + Bootstrap 5</li>
                </ul>
            </div>
        </div>

        <!-- AI Models -->
        <div class="c-card c-reveal c-reveal--3">
            <div class="c-card-header">
                <i class="bi bi-cpu-fill" style="color:var(--c-teal-500);"></i> AI 模型
            </div>
            <div class="c-card-body">
                <ul style="margin:0;padding-left:1.25rem;font-size:0.925rem;color:var(--text-secondary);line-height:2;">
                    <li>集成学习Voting（RF+SVM+LightGBM）</li>
                    <li>XGBoost / LightGBM / 决策树</li>
                    <li>SVM / 梯度提升树</li>
                </ul>
            </div>
        </div>

        <!-- Database Features -->
        <div class="c-card c-reveal c-reveal--4">
            <div class="c-card-header">
                <i class="bi bi-database-fill" style="color:var(--c-amber-600);"></i> 数据库特性
            </div>
            <div class="c-card-body">
                <ul style="margin:0;padding-left:1.25rem;font-size:0.925rem;color:var(--text-secondary);line-height:2;">
                    <li>12张表，满足第三范式</li>
                    <li>4个视图（安全水/日统计/高风险/用户统计）</li>
                    <li>2个存储函数（水质等级/WQI指数）</li>
                    <li>4个存储过程（日报/警告处理/月报/活跃度）</li>
                    <li>4个触发器（警告/历史/标准变更/日志）</li>
                </ul>
            </div>
        </div>

        <!-- Course Applicability -->
        <div class="c-card c-reveal c-reveal--5">
            <div class="c-card-header">
                <i class="bi bi-book-fill" style="color:var(--c-deep);"></i> 课程适用
            </div>
            <div class="c-card-body">
                <ul style="margin:0;padding-left:1.25rem;font-size:0.925rem;color:var(--text-secondary);line-height:2;">
                    <li>Jakarta EE课程设计</li>
                    <li>数据库原理与技术实习A</li>
                    <li>人工智能引论课程设计</li>
                </ul>
            </div>
        </div>
    </div>

    <!-- Version Footer -->
    <div class="c-reveal c-reveal--6 c-text-center c-text-muted c-text-sm" style="padding:1rem 0;">
        <p>版本 2.0 &nbsp;|&nbsp; 2026年5月 &nbsp;|&nbsp; 浙江A&F数学与计算机科学学院</p>
    </div>

</div>

<%@ include file="template_footer.jsp" %>