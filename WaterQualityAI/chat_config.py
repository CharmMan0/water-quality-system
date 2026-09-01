"""
聊天智能体配置层
集中管理 MySQL 连接 + LLM 配置，改这里就行，不用动其他文件
"""
import os

# ============================================================
# MySQL 连接配置（water_quality_db）
# 改成你本机的用户名/密码；默认 root 无密码
# ============================================================
DB_CONFIG = {
    "host": os.getenv("WQ_DB_HOST", "127.0.0.1"),
    "port": int(os.getenv("WQ_DB_PORT", "3306")),
    "user": os.getenv("WQ_DB_USER", "root"),
    "password": os.getenv("WQ_DB_PASSWORD", ""),
    "database": os.getenv("WQ_DB_NAME", "water_quality_db"),
    "charset": "utf8mb4",
}

# ============================================================
# LLM 配置（复用生产实习的 SiliconFlow + DeepSeek）
# ============================================================
LLM_CONFIG = {
    "api_key": os.getenv(
        "SILICONFLOW_API_KEY",
        "",  # 用环境变量 SILICONFLOW_API_KEY 传入，不写死（仓库公开，避免泄露）
    ),
    "base_url": os.getenv("LLM_BASE_URL", "https://api.siliconflow.cn/v1"),
    "model": os.getenv("LLM_MODEL", "Qwen/Qwen2.5-14B-Instruct"),
    "temperature": float(os.getenv("LLM_TEMPERATURE", "0.7")),
}

# 智能体服务端口（别和 ai_api 的 8000 撞）
CHAT_PORT = int(os.getenv("CHAT_PORT", "8001"))

# 9 项水质指标：模型预测函数 make_prediction 要求的 DataFrame 列名（大小写敏感）
# 数据库里全是小写，模型这里 pH 小写、其余首字母大写
PREDICT_COLS = [
    "ph", "Hardness", "Solids", "Chloramines", "Sulfate",
    "Conductivity", "Organic_carbon", "Trihalomethanes", "Turbidity",
]

# 指标中文名 → 模型列名 的映射（方便 LLM 理解用户自然语言）
INDICATOR_ALIAS = {
    "ph": "ph", "ph值": "ph", "酸碱度": "ph",
    "硬度": "Hardness", "hardness": "Hardness",
    "固体": "Solids", "溶解性固体": "Solids", "solids": "Solids", "固体含量": "Solids",
    "氯胺": "Chloramines", "chloramines": "Chloramines", "余氯": "Chloramines",
    "硫酸盐": "Sulfate", "sulfate": "Sulfate",
    "电导率": "Conductivity", "conductivity": "Conductivity",
    "有机碳": "Organic_carbon", "organic_carbon": "Organic_carbon", "toc": "Organic_carbon",
    "三卤甲烷": "Trihalomethanes", "trihalomethanes": "Trihalomethanes", "thm": "Trihalomethanes",
    "浊度": "Turbidity", "turbidity": "Turbidity",
}
