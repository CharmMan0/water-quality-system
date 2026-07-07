package com.example.waterqualitysystem;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

@WebServlet("/predict")
public class PredictServlet extends HttpServlet {

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, java.io.IOException {

        try {
            HttpSession session = request.getSession();
            Object userIdObj = session.getAttribute("userId");
            int userId = 1; // 默认
            if (userIdObj != null) {
                userId = (Integer) userIdObj;
            }

            double pH = Double.parseDouble(request.getParameter("pH"));
            double Hardness = Double.parseDouble(request.getParameter("Hardness"));
            double Solids = Double.parseDouble(request.getParameter("Solids"));
            double Chloramines = Double.parseDouble(request.getParameter("Chloramines"));
            double Sulfate = Double.parseDouble(request.getParameter("Sulfate"));
            double Conductivity = Double.parseDouble(request.getParameter("Conductivity"));
            double Organic_carbon = Double.parseDouble(request.getParameter("Organic_carbon"));
            double Trihalomethanes = Double.parseDouble(request.getParameter("Trihalomethanes"));
            double Turbidity = Double.parseDouble(request.getParameter("Turbidity"));
            String sourceIdStr = request.getParameter("sourceId");
            int sourceId = (sourceIdStr != null && !sourceIdStr.isEmpty()) ? Integer.parseInt(sourceIdStr) : 0;

            // ── 后端参数范围校验（略宽于 API 安全门，仅拦截明显错误）──
            validateRange(pH,           0, 14,   "pH值");
            validateRange(Hardness,       0, 1500, "硬度");
            validateRange(Solids,         0, 5000, "固体含量");
            validateRange(Chloramines,    0, 12,   "氯胺");
            validateRange(Sulfate,        0, 600,  "硫酸盐");
            validateRange(Conductivity,   0, 3000, "电导率");
            validateRange(Organic_carbon, 0, 10,   "有机碳");
            validateRange(Trihalomethanes,0, 200,  "三卤甲烷");
            validateRange(Turbidity,      0, 20,   "浊度");

            // 构建JSON请求
            String jsonInput = String.format(
                    "{\"pH\": %f, \"hardness\": %f, \"solids\": %f, " +
                            "\"chloramines\": %f, \"sulfate\": %f, \"conductivity\": %f, " +
                            "\"organic_carbon\": %f, \"trihalomethanes\": %f, \"turbidity\": %f}",
                    pH, Hardness, Solids, Chloramines, Sulfate,
                    Conductivity, Organic_carbon, Trihalomethanes, Turbidity
            );

            // 调用AI API
            URL url = new URL("http://127.0.0.1:8000/predict/single");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
            conn.setDoOutput(true);
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(5000);

            try (OutputStream os = conn.getOutputStream()) {
                os.write(jsonInput.getBytes("UTF-8"));
            }

            BufferedReader br = new BufferedReader(
                    new InputStreamReader(conn.getInputStream(), "UTF-8"));
            StringBuilder result = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                result.append(line);
            }
            br.close();
            conn.disconnect();

            String aiResult = result.toString();

            // 解析JSON（简单方式，避免引入第三方库）
            String prediction = extractJsonValue(aiResult, "prediction");
            double probability = parseDoubleSafe(extractJsonValue(aiResult, "probability"));
            double wqiScore = parseDoubleSafe(extractJsonValue(aiResult, "wqi_score"));
            String waterGrade = extractJsonValue(aiResult, "water_grade");
            String standardLevel = extractJsonValue(aiResult, "standard_level");

            if (prediction.isEmpty()) {
                if (aiResult.contains("Safe")) prediction = "Safe";
                else prediction = "Unsafe";
            }
            if (probability == 0.0) {
                probability = parseDoubleFromText(aiResult);
            }

            // 保存数据库
            DetectionDAO.saveDetection(
                    userId, sourceId,
                    pH, Hardness, Solids, Chloramines, Sulfate,
                    Conductivity, Organic_carbon, Trihalomethanes, Turbidity,
                    prediction, probability, wqiScore, waterGrade, standardLevel
            );

            // 传递到结果页面
            request.setAttribute("prediction", prediction);
            request.setAttribute("probability", String.format("%.4f", probability));
            request.setAttribute("wqiScore", String.format("%.2f", wqiScore));
            request.setAttribute("waterGrade", waterGrade);
            request.setAttribute("standardLevel", standardLevel);
            request.setAttribute("rawResult", aiResult);

            request.getRequestDispatcher("result.jsp").forward(request, response);

        } catch (java.net.ConnectException e) {
            request.setAttribute("error", "AI预测服务未启动，请先运行Python AI API (端口8000)");
            request.getRequestDispatcher("result.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "预测失败：" + e.getMessage());
            request.getRequestDispatcher("result.jsp").forward(request, response);
        }
    }

    private String extractJsonValue(String json, String key) {
        String searchKey = "\"" + key + "\"";
        int keyIndex = json.indexOf(searchKey);
        if (keyIndex == -1) return "";

        int colonIndex = json.indexOf(":", keyIndex);
        if (colonIndex == -1) return "";

        int startIndex = colonIndex + 1;
        while (startIndex < json.length() && (json.charAt(startIndex) == ' ' || json.charAt(startIndex) == '\"')) {
            startIndex++;
        }

        if (startIndex >= json.length()) return "";

        if (json.charAt(startIndex - 1) == '\"') {
            int endIndex = json.indexOf("\"", startIndex);
            if (endIndex == -1) return "";
            return json.substring(startIndex, endIndex);
        } else {
            int endIndex = startIndex;
            while (endIndex < json.length() &&
                    (Character.isDigit(json.charAt(endIndex)) ||
                            json.charAt(endIndex) == '.' ||
                            json.charAt(endIndex) == '-')) {
                endIndex++;
            }
            return json.substring(startIndex, endIndex);
        }
    }

    private double parseDoubleSafe(String value) {
        if (value == null || value.isEmpty()) return 0.0;
        try {
            return Double.parseDouble(value);
        } catch (NumberFormatException e) {
            return 0.0;
        }
    }

    /** 参数范围校验，超限抛出 IllegalArgumentException */
    private void validateRange(double value, double min, double max, String label) {
        if (value < min || value > max) {
            throw new IllegalArgumentException(
                "⚠️ " + label + " = " + value + "，超出合理范围 [" + min + " ~ " + max + "]，请修正后重新提交。"
            );
        }
    }

    private double parseDoubleFromText(String text) {
        try {
            int start = text.indexOf("probability");
            if (start != -1) {
                String sub = text.substring(start);
                String number = sub.replaceAll("[^0-9.]", "");
                String[] parts = number.split("\\.");
                if (parts.length > 0) {
                    return Double.parseDouble(parts[0] + "." +
                            (parts.length > 1 ? parts[1].substring(0, Math.min(4, parts[1].length())) : "0"));
                }
            }
        } catch (Exception e) {
            // ignore
        }
        return 0.0;
    }
}