# 水质AI检测系统 · Water Quality AI Detection System

基于机器学习的饮用水水质安全预测系统，融合 **Jakarta EE Web 应用** 与 **Python FastAPI AI 微服务**，支持用户管理、水质预测、数据可视化、数据库备份恢复等完整功能。

> 🎓 人工智能引论 + 数据库原理与技术实习 课程设计

---

## 🏗️ 系统架构

```
┌─────────────────────────────────────────────────────┐
│                   Browser (用户端)                    │
├─────────────────────────────────────────────────────┤
│  Jakarta EE Web (Tomcat 11)                         │
│  ├── 登录/注册 (SHA-256)                             │
│  ├── 水质预测 → 调用 AI API                          │
│  ├── 仪表盘 (ECharts 可视化)                          │
│  ├── 历史记录 / 预警管理                              │
│  └── 数据库备份与恢复 (mysqldump)                     │
├─────────────────────────────────────────────────────┤
│  Python FastAPI (Port 8000)                         │
│  ├── Voting Ensemble 模型推理                        │
│  ├── 安全门规则引擎 (ML + 领域知识)                    │
│  └── 综合分析 / 模型解释                              │
├─────────────────────────────────────────────────────┤
│  MySQL 9.6 (water_quality_db)                       │
└─────────────────────────────────────────────────────┘
```

---

## 🚀 快速启动

### 环境要求

| 组件 | 版本 |
|------|------|
| JDK | 26 |
| Tomcat | 11 |
| Maven | 3.9 |
| Python | 3.11+ |
| MySQL | 9.6 |

### 1. 启动 MySQL

确保 MySQL 服务正在运行（Windows 服务或手动启动）。

### 2. 构建并部署 Jakarta EE Web 应用

```bash
cd WaterQualitySystem
mvn package
# 将 target/*.war 复制到 Tomcat webapps/ 目录
# 重启 Tomcat
```

### 3. 启动 AI API 服务

```bash
cd WaterQualityAI
pip install -r requirements.txt
python ai_api.py
```

访问 [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs) 查看 API 文档。

### 4. 数据库初始化

```bash
mysql -uroot -p < mysql/water_quality_db.sql
```

---

## ✨ 功能特性

| 模块 | 功能 |
|------|------|
| 🔐 用户系统 | 注册、登录（SHA-256 密码哈希）、角色权限管理 |
| 🔮 AI 预测 | 7 种 ML 模型对比，Voting Ensemble 生产推理 |
| 🛡️ 安全门 | 9 项水质指标硬性阈值检测，领域知识 + ML 融合 |
| 📊 仪表盘 | ECharts 可视化：7 日趋势、来源统计、安全率 |
| 📋 历史记录 | 检测记录查询、详情查看、CSV 导出 |
| ⚠️ 预警管理 | 超标自动预警、处理状态跟踪 |
| 💾 备份恢复 | mysqldump 全库备份、快照恢复（仅管理员） |
| 📖 知识库 | 水质标准参考、模型信息对比 |

---

## 📂 项目结构

```
├── WaterQualitySystem/          Jakarta EE Web 应用
│   ├── src/main/java/.../       Servlet + DAO + Filter
│   ├── src/main/webapp/         JSP 前端页面
│   └── pom.xml                  Maven 配置
│
├── WaterQualityAI/              Python AI 微服务
│   ├── ai_api.py                FastAPI 主入口
│   ├── model_train.py           模型训练脚本
│   ├── data_preprocess.py       数据预处理
│   ├── best_model.pkl           生产模型 (Voting Ensemble)
│   └── requirements.txt         Python 依赖
│
├── mysql/                       数据库脚本
│   ├── water_quality_db.sql     建库 + 示例数据
│   └── backup_manual.sql        备份恢复 SQL 手册
│
└── CLAUDE.md                    开发者指南
```

---

## 🔧 技术栈

| 层级 | 技术 |
|------|------|
| 前端 | JSP, ECharts, Crystal Design System |
| 后端 | Jakarta EE 6.0, JDBC, Servlet |
| AI | Python FastAPI, scikit-learn, LightGBM, XGBoost |
| 数据库 | MySQL 9.6 (InnoDB) |
| 安全 | SHA-256 密码哈希, Session 认证, 环境变量管理凭证 |

---

## 🤖 AI 模型

使用 **Voting Ensemble**（RF + SVM + LightGBM Soft Voting）作为生产模型，在 3,276 条水质数据上训练。数据处理流程：

```
原始数据 → KNN 缺失值填充 → StandardScaler 标准化 → SelectKBest 特征选择
→ SMOTE 不平衡处理 → Voting Ensemble 训练 → 阈值优化
```

---

## 📄 许可证

本项目仅用于课程设计学习目的。

---

## 👥 作者

水质AI检测团队 · 2026
