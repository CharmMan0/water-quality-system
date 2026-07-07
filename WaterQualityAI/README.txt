================================================================================
                          水质AI预测系统
                Water Quality AI Prediction System
                    人工智能引论 课程设计
================================================================================

【项目简介】

  本系统基于机器学习方法，对饮用水水质进行安全性预测（Potable / Not potable）。
  使用 7 种机器学习模型进行对比，最终采用 Voting Ensemble（投票集成）作为
  生产模型，并通过 FastAPI 提供 RESTful API 服务，供前端 Web 系统调用。

  数据集：water_potability.csv（3276条记录，9项水质指标）
  指标：pH值、硬度(Hardness)、固体(Solids)、氯胺(Chloramines)、
        硫酸盐(Sulfate)、电导率(Conductivity)、有机碳(Organic_carbon)、
        三卤甲烷(Trihalomethanes)、浊度(Turbidity)


【文件结构】

  WaterQualityAI/
  ├── ai_api.py              FastAPI 主服务（API 入口）
  ├── model_train.py         模型训练脚本（数据加载→预处理→训练→评估）
  ├── data_preprocess.py     数据预处理（缺失值填充 / 标准化 / 特征选择）
  ├── check_features.py      特征检查调试工具
  ├── water_potability.csv   原始数据集
  ├── model_evaluation.csv   7 个模型评估指标汇总
  ├── requirements.txt       Python 依赖包列表
  ├── README.txt             本文件
  │
  ├── best_model.pkl         训练好的 Voting Ensemble 模型
  ├── best_threshold.pkl     最优决策阈值（0.50）
  ├── scaler.pkl             数据标准化器
  ├── imputer.pkl            缺失值填充器
  ├── selector.pkl           特征选择器
  ├── selected_features.pkl  筛选后的特征列表
  ├── smote.pkl              SMOTE 过采样器
  ├── feature_importance.pkl 特征重要性数据
  │
  ├── model_comparison.png   模型对比图
  ├── feature_importance.png 特征重要性图
  ├── feature_correlation.png特征相关性热力图
  ├── feature_distribution.png特征分布图
  └── 各模型混淆矩阵 + ROC曲线图（14张）


【环境要求】

  - Python 3.11+
  - 依赖包见 requirements.txt


【安装与运行】

  1. 创建并激活虚拟环境（推荐）

     python -m venv venv
     venv\Scripts\activate          # Windows
     # 或 source venv/bin/activate  # macOS/Linux

  2. 安装依赖

     pip install -r requirements.txt

  3. 启动 API 服务

     python ai_api.py

     服务启动后访问：http://127.0.0.1:8000
     API 文档（Swagger UI）：http://127.0.0.1:8000/docs


【API 接口说明】

  端点                             方法    说明
  ─────────────────────────────────────────────────────────
  /                                GET     服务状态检查
  /predict/single                  POST    单条水质预测
  /predict/batch                   POST    批量水质预测
  /model/info                      GET     查询所有模型信息
  /model/explain                   GET     特征重要性解释
  /standards                       GET     饮用水标准参考值
  /analyze                         POST    水样分析（含安全门检测）
  /dashboard/summary               GET     仪表盘汇总统计


【模型列表】

  序号  模型名称        模型类型        准确率
  ──────────────────────────────────────────────────
  1     决策树          传统机器学习    ~53%
  2     随机森林        集成学习        ~57%
  3     SVM             传统机器学习    ~56%
  4     梯度提升树      集成学习        ~57%
  5     XGBoost         集成学习        ~57%
  6     LightGBM        集成学习        ~58%
  7     集成学习Voting  集成学习(生产)  ~59%


【技术要点】

  - 数据预处理：KNN 填补缺失值 → StandardScaler 标准化 → SelectKBest 特征选择
  - 不平衡处理：使用 SMOTE 合成少数类样本
  - 安全门机制：对 9 项水质指标设定安全阈值范围，超出范围直接判定为 Unsafe
  - 模型持久化：使用 joblib 序列化，FastAPI 启动时加载至内存


【注意事项】

  - 首次运行需确保所有 .pkl 文件与 ai_api.py 在同一目录下
  - 如需重新训练模型，运行 python model_train.py
  - 数据集路径默认当前目录，如移动位置需修改代码中的路径变量


【作者】

  水质AI检测团队
  2026年6月
