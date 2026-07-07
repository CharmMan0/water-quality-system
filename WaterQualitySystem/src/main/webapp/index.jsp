<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% request.setAttribute("pageTitle", "AI水质检测"); %>
<%@ include file="template_header.jsp" %>

<!-- Hero -->
<section class="c-hero">
  <div class="c-hero-content">
    <h1>AI 智能水质检测</h1>
    <p>基于集成学习 Voting (RF + SVM + LightGBM)，支持9项水质指标综合评估与WQI指数计算，符合 GB5749-2022 标准</p>
  </div>
</section>

<!-- Form -->
<div class="c-container-sm">
  <div class="c-card c-reveal c-reveal--1">
    <div class="c-card-body">
      <div class="c-section-hd">
        <h2><i class="bi bi-droplet"></i> 请输入水质检测数据</h2>
        <span class="hd-line"></span>
      </div>

      <form action="predict" method="post" onsubmit="return validateForm()">

        <!-- Source Select -->
        <div class="c-field c-reveal c-reveal--1">
          <label class="c-label"><i class="bi bi-geo-alt"></i> 选择水源（可选）</label>
          <select name="sourceId" class="c-select">
            <option value="">-- 不指定水源 --</option>
            <option value="1">钱塘江杭州段 (河流)</option>
            <option value="2">西湖湖区 (湖泊)</option>
            <option value="3">青山湖水库 (水库)</option>
            <option value="4">杭州地下水监测1号井 (地下水)</option>
            <option value="5">杭州自来水厂出水口 (自来水)</option>
          </select>
        </div>

        <hr class="c-divider">

        <!-- Parameters Grid -->
        <div class="c-grid-2">
          <!-- Column 1 -->
          <div>
            <div class="c-field c-reveal c-reveal--2">
              <label class="c-label">pH值</label>
              <input type="number" step="0.1" name="pH" value="7.0" class="c-input" required>
            </div>
            <div class="c-field c-reveal c-reveal--2">
              <label class="c-label">硬度 (mg/L)</label>
              <input type="number" step="0.1" name="Hardness" value="200" class="c-input" required>
            </div>
            <div class="c-field c-reveal c-reveal--3">
              <label class="c-label">固体含量 (ppm)</label>
              <input type="number" step="0.1" name="Solids" value="500" class="c-input" required>
            </div>
            <div class="c-field c-reveal c-reveal--3">
              <label class="c-label">氯胺 (ppm)</label>
              <input type="number" step="0.1" name="Chloramines" value="2" class="c-input" required>
            </div>
            <div class="c-field c-reveal c-reveal--4">
              <label class="c-label">硫酸盐 (mg/L)</label>
              <input type="number" step="0.1" name="Sulfate" value="200" class="c-input" required>
            </div>
          </div>

          <!-- Column 2 -->
          <div>
            <div class="c-field c-reveal c-reveal--4">
              <label class="c-label">电导率 (&mu;S/cm)</label>
              <input type="number" step="0.1" name="Conductivity" value="400" class="c-input" required>
            </div>
            <div class="c-field c-reveal c-reveal--5">
              <label class="c-label">有机碳 (ppm)</label>
              <input type="number" step="0.1" name="Organic_carbon" value="1" class="c-input" required>
            </div>
            <div class="c-field c-reveal c-reveal--5">
              <label class="c-label">三卤甲烷 (&mu;g/L)</label>
              <input type="number" step="0.1" name="Trihalomethanes" value="40" class="c-input" required>
            </div>
            <div class="c-field c-reveal c-reveal--6">
              <label class="c-label">浊度 (NTU)</label>
              <input type="number" step="0.1" name="Turbidity" value="2" class="c-input" required>
            </div>
          </div>
        </div>

        <!-- Submit -->
        <div class="c-reveal c-reveal--6 c-mt-3">
          <button type="submit" class="c-btn c-btn--primary c-btn--lg" style="width:100%;">
            <i class="bi bi-cpu"></i> 开始AI检测
          </button>
        </div>

      </form>
    </div>
  </div>
</div>

<script>
// 前端水质参数范围验证 — 略宽于 API 安全门阈值，仅拦截明显错误（手误/单位错误）
const RANGES = {
    pH:              { min: 0,  max: 14,   label: 'pH值',         unit: '' },
    Hardness:        { min: 0,  max: 1500, label: '硬度',          unit: 'mg/L' },
    Solids:          { min: 0,  max: 5000, label: '固体含量',      unit: 'ppm' },
    Chloramines:     { min: 0,  max: 12,   label: '氯胺',          unit: 'ppm' },
    Sulfate:         { min: 0,  max: 600,  label: '硫酸盐',        unit: 'mg/L' },
    Conductivity:    { min: 0,  max: 3000, label: '电导率',        unit: 'μS/cm' },
    Organic_carbon:  { min: 0,  max: 10,   label: '有机碳',        unit: 'ppm' },
    Trihalomethanes: { min: 0,  max: 200,  label: '三卤甲烷',      unit: 'μg/L' },
    Turbidity:       { min: 0,  max: 20,   label: '浊度',          unit: 'NTU' }
};

function validateForm() {
    let errors = [];
    for (const [name, range] of Object.entries(RANGES)) {
        const input = document.querySelector('[name="' + name + '"]');
        if (!input) continue;
        const val = parseFloat(input.value);
        if (isNaN(val)) {
            errors.push('• ' + range.label + '：请输入有效数值');
            continue;
        }
        if (val < range.min || val > range.max) {
            errors.push('• ' + range.label + '：' + val + ' ' + range.unit +
                '，允许范围 ' + range.min + ' ~ ' + range.max + ' ' + range.unit);
        }
    }
    if (errors.length > 0) {
        alert('⚠️ 参数超出合理范围：\n\n' + errors.join('\n') +
            '\n\n请修正后重新提交。');
        return false;
    }
    return true;
}
</script>

<%@ include file="template_footer.jsp" %>
