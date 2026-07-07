package com.example.waterqualitysystem;

import java.io.Serializable;

/**
 * 检测记录JavaBean
 * Jakarta EE M层数据Bean，供JSP页面使用
 */
public class DetectionBean implements Serializable {

    private int id;
    private int userId;
    private String username;
    private int sourceId;
    private String sourceName;
    private String sourceType;
    private double ph;
    private double hardness;
    private double solids;
    private double chloramines;
    private double sulfate;
    private double conductivity;
    private double organicCarbon;
    private double trihalomethanes;
    private double turbidity;
    private String prediction;
    private double probability;
    private double wqiScore;
    private String waterGrade;
    private String standardLevel;
    private String detectTime;

    public DetectionBean() {}

    // Full constructor
    public DetectionBean(int id, int userId, String username, int sourceId, String sourceName,
                         double ph, double hardness, double solids, double chloramines,
                         double sulfate, double conductivity, double organicCarbon,
                         double trihalomethanes, double turbidity, String prediction,
                         double probability, double wqiScore, String waterGrade,
                         String standardLevel, String detectTime) {
        this.id = id;
        this.userId = userId;
        this.username = username;
        this.sourceId = sourceId;
        this.sourceName = sourceName;
        this.ph = ph;
        this.hardness = hardness;
        this.solids = solids;
        this.chloramines = chloramines;
        this.sulfate = sulfate;
        this.conductivity = conductivity;
        this.organicCarbon = organicCarbon;
        this.trihalomethanes = trihalomethanes;
        this.turbidity = turbidity;
        this.prediction = prediction;
        this.probability = probability;
        this.wqiScore = wqiScore;
        this.waterGrade = waterGrade;
        this.standardLevel = standardLevel;
        this.detectTime = detectTime;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public int getSourceId() { return sourceId; }
    public void setSourceId(int sourceId) { this.sourceId = sourceId; }

    public String getSourceName() { return sourceName; }
    public void setSourceName(String sourceName) { this.sourceName = sourceName; }

    public String getSourceType() { return sourceType; }
    public void setSourceType(String sourceType) { this.sourceType = sourceType; }

    public double getPh() { return ph; }
    public void setPh(double ph) { this.ph = ph; }

    public double getHardness() { return hardness; }
    public void setHardness(double hardness) { this.hardness = hardness; }

    public double getSolids() { return solids; }
    public void setSolids(double solids) { this.solids = solids; }

    public double getChloramines() { return chloramines; }
    public void setChloramines(double chloramines) { this.chloramines = chloramines; }

    public double getSulfate() { return sulfate; }
    public void setSulfate(double sulfate) { this.sulfate = sulfate; }

    public double getConductivity() { return conductivity; }
    public void setConductivity(double conductivity) { this.conductivity = conductivity; }

    public double getOrganicCarbon() { return organicCarbon; }
    public void setOrganicCarbon(double organicCarbon) { this.organicCarbon = organicCarbon; }

    public double getTrihalomethanes() { return trihalomethanes; }
    public void setTrihalomethanes(double trihalomethanes) { this.trihalomethanes = trihalomethanes; }

    public double getTurbidity() { return turbidity; }
    public void setTurbidity(double turbidity) { this.turbidity = turbidity; }

    public String getPrediction() { return prediction; }
    public void setPrediction(String prediction) { this.prediction = prediction; }

    public double getProbability() { return probability; }
    public void setProbability(double probability) { this.probability = probability; }

    public double getWqiScore() { return wqiScore; }
    public void setWqiScore(double wqiScore) { this.wqiScore = wqiScore; }

    public String getWaterGrade() { return waterGrade; }
    public void setWaterGrade(String waterGrade) { this.waterGrade = waterGrade; }

    public String getStandardLevel() { return standardLevel; }
    public void setStandardLevel(String standardLevel) { this.standardLevel = standardLevel; }

    public String getDetectTime() { return detectTime; }
    public void setDetectTime(String detectTime) { this.detectTime = detectTime; }
}