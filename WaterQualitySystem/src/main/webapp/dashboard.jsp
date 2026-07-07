<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<% request.setAttribute("pageTitle", "数据仪表盘"); %>
<%@ include file="template_header.jsp" %>

<%
    int total = request.getAttribute("total") != null ? (Integer)request.getAttribute("total") : 0;
    int safe = request.getAttribute("safe") != null ? (Integer)request.getAttribute("safe") : 0;
    int unsafe = request.getAttribute("unsafe") != null ? (Integer)request.getAttribute("unsafe") : 0;
    List<Map<String,Object>> models = (List<Map<String,Object>>) request.getAttribute("models");
    List<Map<String,Object>> dailyTrend = (List<Map<String,Object>>) request.getAttribute("dailyTrend");
    List<Map<String,Object>> sourceStats = (List<Map<String,Object>>) request.getAttribute("sourceStats");
%>

<!-- Hero -->
<section class="c-hero">
  <div class="c-hero-content">
    <h1>数据仪表盘</h1>
    <p>水质分析 AI 系统 — 检测统计与模型评估总览</p>
  </div>
</section>

<div class="c-container">

  <!-- Stat Cards -->
  <div class="c-stat-row c-reveal c-reveal--1">
    <!-- Total -->
    <div class="c-stat">
      <div class="stat-icon-wrap" style="background:#e0f2fe;color:#0369a1;">
        <i class="bi bi-database"></i>
      </div>
      <div class="stat-number"><%= total %></div>
      <div class="stat-desc">总检测数</div>
      <div class="stat-glow" style="background:#0369a1;"></div>
    </div>

    <!-- Safe -->
    <div class="c-stat">
      <div class="stat-icon-wrap" style="background:#d1fae5;color:#065f46;">
        <i class="bi bi-check-circle"></i>
      </div>
      <div class="stat-number"><%= safe %></div>
      <div class="stat-desc">安全水质</div>
      <div class="stat-glow" style="background:#059669;"></div>
    </div>

    <!-- Unsafe -->
    <div class="c-stat">
      <div class="stat-icon-wrap" style="background:#fee2e2;color:#991b1b;">
        <i class="bi bi-x-circle"></i>
      </div>
      <div class="stat-number"><%= unsafe %></div>
      <div class="stat-desc">不安全水质</div>
      <div class="stat-glow" style="background:#dc2626;"></div>
    </div>
  </div>

  <!-- ECharts Pie Chart -->
  <div class="c-card c-mt-4 c-reveal c-reveal--2">
    <div class="c-card-body">
      <div class="c-section-hd">
        <h2>检测结果分布</h2>
        <span class="hd-line"></span>
      </div>
      <div id="pieChart" style="width:100%;height:400px;"></div>
    </div>
  </div>

  <!-- 📈 7-Day Trend Line Chart -->
  <div class="c-card c-mt-4 c-reveal c-reveal--3">
    <div class="c-card-body">
      <div class="c-section-hd">
        <h2>近7天检测趋势</h2>
        <span class="hd-line"></span>
      </div>
      <div id="trendChart" style="width:100%;height:380px;"></div>
    </div>
  </div>

  <!-- 📊 Source Bar Chart -->
  <div class="c-card c-mt-4 c-reveal c-reveal--4">
    <div class="c-card-body">
      <div class="c-section-hd">
        <h2>各水源地检测统计</h2>
        <span class="hd-line"></span>
      </div>
      <div id="sourceChart" style="width:100%;height:380px;"></div>
    </div>
  </div>

  <!-- Model Table -->
  <div class="c-card c-mt-4 c-reveal c-reveal--3">
    <div class="c-card-body">
      <div class="c-section-hd">
        <h2>AI 模型评估信息</h2>
        <span class="hd-line"></span>
      </div>
      <p class="c-text-muted c-text-sm c-mb-2">从数据库读取</p>
      <div class="c-table-wrap">
        <table class="c-table">
          <thead>
            <tr>
              <th>模型名称</th>
              <th>类型</th>
              <th>准确率</th>
              <th>F1</th>
              <th>AUC</th>
              <th>生产模型</th>
            </tr>
          </thead>
          <tbody>
            <% if(models != null) for(Map<String,Object> m : models) { %>
            <tr>
              <td><%= m.get("name") %></td>
              <td><%= m.get("type") %></td>
              <td><%= String.format("%.2f%%", (Double)m.get("accuracy")*100) %></td>
              <td><%= String.format("%.4f", (Double)m.get("f1")) %></td>
              <td><%= String.format("%.4f", (Double)m.get("auc")) %></td>
              <td><%= (Boolean)m.get("isProd") ? "是" : "否" %></td>
            </tr>
            <% } %>
          </tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- Action Buttons -->
  <div class="c-text-center c-mt-4 c-reveal c-reveal--4">
    <a href="index.jsp" class="c-btn c-btn--primary c-btn--lg">
      <i class="bi bi-arrow-repeat"></i> 新检测
    </a>
    <a href="history" class="c-btn c-btn--teal c-btn--lg" style="margin-left:0.75rem;">
      <i class="bi bi-clock-history"></i> 历史记录
    </a>
  </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/echarts/dist/echarts.min.js"></script>
<script>
    // ── 饼图：Safe/Unsafe 分布 ──
    var pie = echarts.init(document.getElementById('pieChart'));
    pie.setOption({
        tooltip: {trigger:'item'}, legend:{bottom:10},
        color: ['#10b981', '#ef4444'],
        series:[{name:'Result', type:'pie', radius:['40%','70%'],
            data:[{value:<%= safe %>, name:'Safe'}, {value:<%= unsafe %>, name:'Unsafe'}]}]});

    // ── 折线图：近7天趋势 ──
    <%
    StringBuilder days = new StringBuilder("[");
    StringBuilder s1 = new StringBuilder("[");
    StringBuilder s2 = new StringBuilder("[");
    if (dailyTrend != null) {
        for (int i = 0; i < dailyTrend.size(); i++) {
            if (i > 0) { days.append(","); s1.append(","); s2.append(","); }
            days.append("'").append(((Map)dailyTrend.get(i)).get("day")).append("'");
            s1.append(((Map)dailyTrend.get(i)).get("safe"));
            s2.append(((Map)dailyTrend.get(i)).get("unsafe"));
        }
    }
    days.append("]"); s1.append("]"); s2.append("]");
    %>
    var trend = echarts.init(document.getElementById('trendChart'));
    trend.setOption({
        tooltip: {trigger:'axis'},
        legend: {bottom:0, data:['Safe','Unsafe']},
        color: ['#10b981','#ef4444'],
        grid: {left:'3%',right:'4%',bottom:'12%',top:'8%',containLabel:true},
        xAxis: {type:'category', data:<%= days %>},
        yAxis: {type:'value', minInterval:1},
        series: [
            {name:'Safe', type:'line', smooth:true, data:<%= s1 %>,
                areaStyle:{color:'rgba(16,185,129,0.15)'}, lineStyle:{width:3}},
            {name:'Unsafe', type:'line', smooth:true, data:<%= s2 %>,
                areaStyle:{color:'rgba(239,68,68,0.15)'}, lineStyle:{width:3}}
        ]
    });

    // ── 柱状图：水源地统计 ──
    <%
    StringBuilder srcNames = new StringBuilder("[");
    StringBuilder srcTotals = new StringBuilder("[");
    StringBuilder srcRates = new StringBuilder("[");
    if (sourceStats != null) {
        for (int i = 0; i < sourceStats.size(); i++) {
            if (i > 0) { srcNames.append(","); srcTotals.append(","); srcRates.append(","); }
            srcNames.append("'").append(((Map)sourceStats.get(i)).get("name")).append("'");
            srcTotals.append(((Map)sourceStats.get(i)).get("total"));
            srcRates.append(((Map)sourceStats.get(i)).get("rate"));
        }
    }
    srcNames.append("]"); srcTotals.append("]"); srcRates.append("]");
    %>
    var src = echarts.init(document.getElementById('sourceChart'));
    src.setOption({
        tooltip: {trigger:'axis',
            formatter: function(p) {
                var idx = p[0].dataIndex;
                return p[0].name + '<br/>检测数: ' + p[0].value + '<br/>合格率: ' +
                    <%= srcRates %>[idx] + '%';
            }},
        legend: {bottom:0},
        grid: {left:'3%',right:'4%',bottom:'12%',top:'8%',containLabel:true},
        xAxis: {type:'category', data:<%= srcNames %>,
            axisLabel:{rotate:15, interval:0}},
        yAxis: {type:'value', name:'检测次数', minInterval:1},
        series: [{name:'检测次数', type:'bar', data:<%= srcTotals %>,
            itemStyle:{color: new echarts.graphic.LinearGradient(0,0,0,1,[
                {offset:0,color:'#0ea5e9'},{offset:1,color:'#0369a1'}])},
            barMaxWidth:50,
            label:{show:true,position:'top',
                formatter:function(p){return p.value + ' (' +
                    <%= srcRates %>[p.dataIndex] + '%)';}}}
        ]
    });
</script>
<%@ include file="template_footer.jsp" %>
