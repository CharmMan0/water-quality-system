<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*,com.example.waterqualitysystem.DBUtil" %>
<% request.setAttribute("pageTitle", "AI模型信息");
%>
<%@ include file="template_header.jsp" %>
<%
// 收集所有模型数据用于表格 + 图表
List<Map<String,Object>> mlData = new ArrayList<>();
try (Connection conn = DBUtil.getConnection();
     Statement stmt = conn.createStatement();
     ResultSet rs = stmt.executeQuery("SELECT * FROM ai_model_info ORDER BY id")) {
    while (rs.next()) {
        Map<String,Object> m = new LinkedHashMap<>();
        m.put("name", rs.getString("model_name"));
        m.put("type", rs.getString("model_type"));
        m.put("accuracy", rs.getDouble("accuracy"));
        m.put("f1", rs.getDouble("f1_score"));
        m.put("auc", rs.getDouble("auc"));
        m.put("precision", rs.getDouble("precision_score"));
        m.put("recall", rs.getDouble("recall_score"));
        m.put("cvF1", rs.getDouble("cv_f1_mean"));
        m.put("threshold", rs.getDouble("best_threshold"));
        m.put("isProd", rs.getBoolean("is_production"));
        mlData.add(m);
    }
} catch (Exception e) { e.printStackTrace(); }
%>

<!-- Page Hero -->
<section class="c-hero">
    <div class="c-hero-content">
        <h1><i class="bi bi-cpu-fill"></i> AI 模型评估信息</h1>
        <p>多模型性能指标对比与前沿技术说明</p>
    </div>
</section>

<div class="c-container">

    <!-- Section Header -->
    <div class="c-section-hd">
        <h2><i class="bi bi-bar-chart-fill" style="color:var(--c-water);"></i> 模型性能总览</h2>
        <span class="hd-line"></span>
    </div>

    <!-- Model Performance Table -->
    <div class="c-card c-reveal c-reveal--1 c-mb-3">
        <div class="c-card-body" style="padding:0;">
            <div class="c-table-wrap" style="border:none;border-radius:0;">
                <table class="c-table">
                    <thead>
                        <tr>
                            <th>模型名称</th>
                            <th>类型</th>
                            <th>准确率</th>
                            <th>F1-Score</th>
                            <th>AUC</th>
                            <th>交叉验证F1</th>
                            <th>状态</th>
                        </tr>
                    </thead>
                    <tbody>
<%
    for (Map<String,Object> m : mlData) {
        String name = (String) m.get("name");
        String type = (String) m.get("type");
        double acc = (Double) m.get("accuracy");
        double f1 = (Double) m.get("f1");
        double auc = (Double) m.get("auc");
        double cvf1 = (Double) m.get("cvF1");
        boolean prod = (Boolean) m.get("isProd");
%>
                    <tr>
                        <td><strong><%= name %></strong></td>
                        <td><span class="c-badge c-badge--info"><%= type %></span></td>
                        <td><%= String.format("%.2f%%", acc*100) %></td>
                        <td><%= String.format("%.4f", f1) %></td>
                        <td><%= String.format("%.4f", auc) %></td>
                        <td><%= String.format("%.4f", cvf1) %></td>
                        <td><%= prod ? "<span class='c-badge c-badge--ok'>生产模型</span>" : "<span class='c-badge c-badge--ghost'>候选</span>" %></td>
                    </tr>
<% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- International Tech Description Callout -->
    <div class="c-callout c-callout--info c-reveal c-reveal--2 c-mb-3">
        <div>
            <h5 style="margin:0 0 0.35rem;font-size:0.95rem;font-weight:700;"><i class="bi bi-globe2"></i> 国际前沿技术说明（AI引论课程要求）</h5>
            <p style="margin:0;font-size:0.9rem;line-height:1.7;">本系统集成7种传统机器学习模型（决策树、随机森林、SVM、梯度提升树、XGBoost、LightGBM、集成学习Voting），采用Soft Voting集成策略进行综合预测。模型融合(Gartner预测2025年70%环境AI系统将采用)和多模态分析是当前水质AI国际研究热点。</p>
        </div>
    </div>

    <!-- Section Header for Charts -->
    <div class="c-section-hd">
        <h2><i class="bi bi-image-fill" style="color:var(--c-teal-500);"></i> 可视化分析</h2>
        <span class="hd-line"></span>
    </div>

    <!-- ECharts 互动图表 -->
    <div class="c-grid-2 c-mb-3">
        <!-- Radar: 多维度对比 (Top 5 模型) -->
        <div class="c-card c-reveal c-reveal--3">
            <div class="c-card-header">
                <i class="bi bi-star-fill" style="color:var(--c-water);"></i> 多维度雷达对比
            </div>
            <div class="c-card-body">
                <div id="radarChart" style="width:100%;height:420px;"></div>
            </div>
        </div>
        <!-- Bar: 准确率对比 (全部模型) -->
        <div class="c-card c-reveal c-reveal--4">
            <div class="c-card-header">
                <i class="bi bi-bar-chart-line-fill" style="color:var(--c-teal-500);"></i> 模型准确率对比
            </div>
            <div class="c-card-body">
                <div id="barChart" style="width:100%;height:420px;"></div>
            </div>
        </div>
    </div>

    <!-- Two-Column Image Cards -->
    <div class="c-grid-2 c-mb-3">
        <div class="c-card c-reveal c-reveal--3">
            <div class="c-card-header">
                <i class="bi bi-bar-chart-line-fill" style="color:var(--c-water);"></i> 模型对比图
            </div>
            <div class="c-card-body c-text-center">
                <img src="images/model_comparison.png" class="img-fluid rounded" alt="模型对比" style="max-width:100%;border-radius:var(--r-sm);">
            </div>
        </div>
        <div class="c-card c-reveal c-reveal--4">
            <div class="c-card-header">
                <i class="bi bi-graph-up" style="color:var(--c-teal-500);"></i> 特征重要性
            </div>
            <div class="c-card-body c-text-center">
                <img src="images/feature_importance.png" class="img-fluid rounded" alt="特征重要性" style="max-width:100%;border-radius:var(--r-sm);">
            </div>
        </div>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/echarts/dist/echarts.min.js"></script>
<script>
// ── 准备模型数据 (由 JSP 写入 JS) ──
var models = [
<% for (int i = 0; i < mlData.size(); i++) {
    Map<String,Object> m = mlData.get(i);
    if (i > 0) out.print(",");
%>{name:'<%= m.get("name") %>',accuracy:<%= m.get("accuracy") %>,f1:<%= m.get("f1") %>,
  auc:<%= m.get("auc") %>,cvF1:<%= m.get("cvF1") %>}<%
} %>
];

// ── 雷达图：按准确率取前5 ──
var top5 = models.slice().sort(function(a,b){return b.accuracy-a.accuracy;}).slice(0,5);
var radar = echarts.init(document.getElementById('radarChart'));
radar.setOption({
    tooltip: {},
    legend: {bottom:0, data: top5.map(function(m){return m.name;})},
    radar: {
        center:['50%','50%'], radius:'60%',
        indicator: [
            {name:'准确率', max:1},
            {name:'F1', max:1},
            {name:'AUC', max:1},
            {name:'交叉验证F1', max:1}
        ]
    },
    series: [{
        type:'radar',
        data: top5.map(function(m){
            return {name:m.name, value:[m.accuracy, m.f1, m.auc, m.cvF1]};
        })
    }]
});

// ── 柱状图：全部模型准确率 ──
var bar = echarts.init(document.getElementById('barChart'));
bar.setOption({
    tooltip: {trigger:'axis',
        formatter: function(p){return p[0].name + '<br/>准确率: ' + (p[0].value*100).toFixed(2)+'%';}},
    grid: {left:'3%',right:'14%',bottom:'15%',top:'8%',containLabel:true},
    xAxis: {type:'category',
        data: models.map(function(m){return m.name;}),
        axisLabel:{rotate:25, interval:0, fontSize:10}},
    yAxis: {type:'value', name:'准确率', min:0.4, max:0.72,
        axisLabel:{formatter:function(v){return (v*100).toFixed(0)+'%';}}},
    series: [{
        type:'bar',
        data: models.map(function(m, i){
            return {value:m.accuracy,
                itemStyle:{color: i===2 ? '#0369a1' : '#93c5fd'}};
        }),
        barMaxWidth:40,
        label:{show:true,position:'insideTop',distance:8,
            formatter:function(p){return (p.value*100).toFixed(1)+'%';}},
        markLine:{silent:true, symbol:'none',
            data:[{yAxis:models.reduce(function(s,m){return s+m.accuracy;},0)/models.length}]}
    }]
});
</script>

<%@ include file="template_footer.jsp" %>