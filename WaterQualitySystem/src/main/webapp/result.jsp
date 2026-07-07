<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% request.setAttribute("pageTitle", "检测结果"); %>
<%@ include file="template_header.jsp" %>

<%
    String prediction = (String) request.getAttribute("prediction");
    String probability = (String) request.getAttribute("probability");
    String wqiScore = (String) request.getAttribute("wqiScore");
    String waterGrade = (String) request.getAttribute("waterGrade");
    String standardLevel = (String) request.getAttribute("standardLevel");
    String error = (String) request.getAttribute("error");

    boolean isSafe = prediction != null && prediction.equals("Safe");
    if (prediction == null) { prediction = "Unknown"; probability = "0.0000"; }
%>

<div class="c-container-sm">

  <% if (error != null) { %>
  <!-- Error State -->
  <div class="c-callout c-callout--bad c-reveal c-reveal--1">
    <i class="bi bi-exclamation-circle" style="font-size:1.3rem;"></i>
    <span><%= error %></span>
  </div>
  <div class="c-text-center c-mt-4">
    <a href="index.jsp" class="c-btn c-btn--primary c-btn--lg">
      <i class="bi bi-arrow-repeat"></i> 返回重试
    </a>
  </div>

  <% } else { %>
  <!-- Result Card -->
  <div class="c-card c-reveal c-reveal--1">
    <div class="c-card-body c-result-hero">

      <!-- Icon -->
      <div class="c-result-icon" style="color:<%= isSafe ? "#059669" : "#dc2626" %>;">
        <i class="bi <%= isSafe ? "bi-check-circle-fill" : "bi-x-circle-fill" %>"></i>
      </div>

      <!-- Verdict -->
      <div class="c-result-verdict" style="color:<%= isSafe ? "#059669" : "#dc2626" %>;">
        <%= isSafe ? "SAFE" : "UNSAFE" %>
      </div>
      <p class="c-text-muted">AI 预测结果</p>

      <hr class="c-divider">

      <!-- Metrics -->
      <div class="c-metric-grid c-reveal c-reveal--2">
        <div class="c-metric">
          <div class="metric-label">安全概率</div>
          <div class="metric-value"><%= probability %></div>
        </div>
        <div class="c-metric">
          <div class="metric-label">WQI 指数</div>
          <div class="metric-value"><%= wqiScore != null ? wqiScore : "-" %></div>
        </div>
        <div class="c-metric">
          <div class="metric-label">水质等级</div>
          <div class="metric-value"><%= waterGrade != null ? waterGrade : "-" %></div>
        </div>
      </div>

      <p class="c-text-muted c-text-sm c-mt-3">
        参考标准：<%= standardLevel != null ? standardLevel : "饮用水" %>
      </p>

      <!-- Action Buttons -->
      <div class="c-mt-4 c-reveal c-reveal--3">
        <a href="index.jsp" class="c-btn c-btn--primary c-btn--lg">
          <i class="bi bi-arrow-repeat"></i> 新检测
        </a>
        <a href="history" class="c-btn c-btn--teal c-btn--lg" style="margin-left:0.75rem;">
          <i class="bi bi-clock-history"></i> 历史记录
        </a>
      </div>

    </div>
  </div>
  <% } %>

</div>

<%@ include file="template_footer.jsp" %>
