<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<% request.setAttribute("pageTitle", "检测历史"); %>
<%@ include file="template_header.jsp" %>

<% List<Map<String,Object>> historyList = (List<Map<String,Object>>) request.getAttribute("historyList"); %>

<div class="c-hero">
    <div class="c-hero-content">
        <h1>检测历史记录</h1>
        <p>浏览所有水质检测的历史数据与AI分析结果</p>
    </div>
</div>

<div class="c-container">
    <div class="c-card c-mb-4 c-reveal c-reveal--1">
        <div class="c-card-body">
            <h4 class="c-text-center c-mb-3">AI检测统计</h4>
            <div id="pieChart" style="width:100%;height:350px;"></div>
        </div>
    </div>

    <div class="c-card c-reveal c-reveal--2">
        <div class="c-card-body">
            <div class="c-table-wrap">
                <table class="c-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>pH</th>
                            <th>预测</th>
                            <th>概率</th>
                            <th>等级</th>
                            <th>检测时间</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% if(historyList != null) for(Map<String,Object> row : historyList) { String pred = row.get("prediction").toString(); %>
                        <tr>
                            <td><%= row.get("id") %></td>
                            <td><%= row.get("ph") %></td>
                            <td><span class="c-badge <%= pred.equalsIgnoreCase("Safe")?"c-badge--ok":"c-badge--bad" %>"><%= pred %></span></td>
                            <td><%= row.get("probability") %></td>
                            <td><%= row.get("grade") != null ? row.get("grade") : "-" %></td>
                            <td><%= row.get("time") %></td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/echarts/dist/echarts.min.js"></script>
<script>
    var safeC = 0, unsafeC = 0;
    <%
        if(historyList != null) for(Map<String,Object> row : historyList)
            out.println(row.get("prediction").toString().equalsIgnoreCase("Safe") ? "safeC++;" : "unsafeC++;");
    %>
    echarts.init(document.getElementById('pieChart')).setOption({
        tooltip:{trigger:'item'},legend:{bottom:10},
        series:[{name:'Result',type:'pie',radius:'65%',data:[{value:safeC,name:'Safe'},{value:unsafeC,name:'Unsafe'}]}]});
</script>
<%@ include file="template_footer.jsp" %>
