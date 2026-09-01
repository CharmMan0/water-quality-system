"""
聊天智能体工具层
4 个 LangChain Tool，挂到 create_agent 上，让 LLM 用自然语言操作水质系统
  1. query_records   - 查历史检测记录（支持按结果/水源/条数过滤）
  2. query_alerts    - 查预警日志（支持只看未解决）
  3. predict_water   - 水质预测（9 项指标 → 调用 ai_api.make_prediction）
  4. query_standards - 查水质标准 / 水源信息
所有 SQL 只读 + 参数化查询，工具只暴露「查什么」不暴露「怎么查」
"""
import json
import pymysql
from langchain_core.tools import Tool

from chat_config import DB_CONFIG, PREDICT_COLS, INDICATOR_ALIAS


# ============================================================
# 数据库连接辅助
# ============================================================
def _get_conn():
    """每次查询开一个连接，用完即关，避免长连接状态混乱"""
    return pymysql.connect(**DB_CONFIG)


def _fetch(sql: str, params: tuple = (), limit: int = 20):
    """执行只读 SELECT，返回 list[dict]，最多 limit 条"""
    conn = _get_conn()
    try:
        with conn.cursor(pymysql.cursors.DictCursor) as cur:
            cur.execute(sql, params)
            rows = cur.fetchmany(limit)
        return rows
    finally:
        conn.close()


# ============================================================
# 工具 1：查询历史检测记录
# ============================================================
def _query_records(query: str) -> str:
    """
    查历史检测记录。query 是自然语言描述，这里做关键词路由：
    - 含「不合格/不安全/unsafe」→ 只查 Unsafe
    - 含「合格/安全/safe」→ 只查 Safe
    - 含「最近N条」→ 取最近 N 条
    - 否则取最近 10 条
    """
    q = query.lower()
    base = """
        SELECT d.id, u.username, ws.source_name, d.ph, d.hardness, d.solids,
               d.chloramines, d.sulfate, d.conductivity, d.organic_carbon,
               d.trihalomethanes, d.turbidity, d.prediction,
               ROUND(d.probability,3) AS probability, d.wqi_score,
               d.water_grade, d.standard_level, d.detect_time
        FROM water_detection d
        LEFT JOIN users u ON d.user_id = u.id
        LEFT JOIN water_source_info ws ON d.source_id = ws.id
    """
    where = ""
    params = ()

    if "不合格" in query or "不安全" in q or "unsafe" in q:
        where = "WHERE d.prediction = %s"
        params = ("Unsafe",)
    elif "合格" in query or "安全" in query or "safe" in q:
        where = "WHERE d.prediction = %s"
        params = ("Safe",)

    sql = f"{base} {where} ORDER BY d.detect_time DESC LIMIT %s"
    n = 10
    # 简单解析「最近N条」
    import re
    m = re.search(r"最近\s*(\d+)\s*条", query)
    if m:
        n = min(int(m.group(1)), 50)
    rows = _fetch(sql, params + (n,), limit=n)

    if not rows:
        return "没有查到符合条件的检测记录。"
    # 把 datetime 转字符串，方便序列化
    for r in rows:
        if r.get("detect_time"):
            r["detect_time"] = str(r["detect_time"])
    return f"共 {len(rows)} 条记录：\n" + json.dumps(rows, ensure_ascii=False, indent=2)


# ============================================================
# 工具 2：查询预警日志
# ============================================================
def _query_alerts(query: str) -> str:
    """查预警日志。query 含「未解决/未处理」→ 只看 is_resolved=0"""
    base = """
        SELECT w.id, w.warning_level, w.warning_message, w.is_resolved,
               w.create_time, w.handle_time, d.id AS detection_id,
               d.prediction, ROUND(d.probability,3) AS probability,
               ws.source_name
        FROM warning_log w
        JOIN water_detection d ON w.detection_id = d.id
        LEFT JOIN water_source_info ws ON d.source_id = ws.id
    """
    q = query.lower()
    if "未解决" in query or "未处理" in query or "unresolved" in q:
        sql = f"{base} WHERE w.is_resolved = 0 ORDER BY w.create_time DESC LIMIT %s"
        rows = _fetch(sql, (20,), limit=20)
    else:
        sql = f"{base} ORDER BY w.create_time DESC LIMIT %s"
        rows = _fetch(sql, (20,), limit=20)

    if not rows:
        return "当前没有预警记录。"
    for r in rows:
        if r.get("create_time"):
            r["create_time"] = str(r["create_time"])
        if r.get("handle_time"):
            r["handle_time"] = str(r["handle_time"])
    return f"共 {len(rows)} 条预警：\n" + json.dumps(rows, ensure_ascii=False, indent=2)


# ============================================================
# 工具 3：水质预测（调用现有模型）
# ============================================================
def _predict_water(query: str) -> str:
    """
    解析出 9 项指标做预测。query 是自然语言，期望含类似
    "ph=7.2, 硬度150, 浊度2.3" 的描述。
    """
    import re
    import pandas as pd
    # 延迟 import，避免 chat_tools 被 import 时就触发模型加载
    try:
        from ai_api import make_prediction
    except Exception as e:
        return (
            "预测功能暂时不可用：水质模型依赖未就绪（"
            + type(e).__name__ + ": " + str(e).split("\n")[0]
            + "）。请先在 WaterQualityAI 目录安装完整依赖"
            "（pip install -r requirements.txt）并确保 .pkl 模型文件存在。"
            "其他功能（查记录/查预警/查标准）不受影响。"
        )

    found = {}
    # 先按指标中文名/英文名在 query 里找「指标 值」或「指标=值」或「指标:值」
    text = query
    # 统一全角符号
    text = text.replace("：", ":").replace("＝", "=").replace("，", ",")
    for alias, col in INDICATOR_ALIAS.items():
        # 匹配：别名 + 可选空格/=:号 + 数字（支持小数）
        pat = rf"{re.escape(alias)}\s*[:=]?\s*([0-9]+\.?[0-9]*)"
        m = re.search(pat, text)
        if m:
            found[col] = float(m.group(1))

    # 9 项必须齐
    missing = [c for c in PREDICT_COLS if c not in found]
    if missing:
        return (
            "做水质预测需要 9 项指标，当前缺少："
            + "、".join(missing)
            + "。\n请补充完整指标，例如：ph=7.2, 硬度=150, 固体=320, "
            "氯胺=2.1, 硫酸盐=180, 电导率=450, 有机碳=1.2, "
            "三卤甲烷=25, 浊度=2.3"
        )

    # 构造模型要求的 DataFrame（列名严格匹配）
    df = pd.DataFrame([{c: found[c] for c in PREDICT_COLS}])
    result = make_prediction(df)
    return "预测结果：\n" + json.dumps(result, ensure_ascii=False, indent=2)


# ============================================================
# 工具 4：查询水质标准 / 水源信息
# ============================================================
def _query_standards(query: str) -> str:
    """
    query 含「水源/采样点」→ 查 water_source_info
    query 含「标准/限值」→ 查 water_standard（可按等级过滤）
    query 含「饮用水/地表水/污水」→ 查对应等级标准
    否则返回水源列表
    """
    q = query.lower()
    if "水源" in query or "采样点" in query or "source" in q:
        # 先看 water_source_info 表是否建了（早期版本库可能没有）
        exists = _fetch(
            "SELECT COUNT(*) AS c FROM information_schema.tables "
            "WHERE table_schema=%s AND table_name='water_source_info'",
            (DB_CONFIG["database"],), limit=1,
        )
        if not exists or not exists[0]["c"]:
            # 退化：water_detection 是否有 source_id 列
            has_sid = _fetch(
                "SELECT COUNT(*) AS c FROM information_schema.columns "
                "WHERE table_schema=%s AND table_name='water_detection' "
                "AND column_name='source_id'",
                (DB_CONFIG["database"],), limit=1,
            )
            if has_sid and has_sid[0]["c"]:
                rows = _fetch(
                    "SELECT source_id, COUNT(*) AS cnt FROM water_detection "
                    "WHERE source_id IS NOT NULL GROUP BY source_id "
                    "ORDER BY cnt DESC",
                    (), limit=20,
                )
                if rows:
                    return (
                        "本地库未建 water_source_info 水源信息表。"
                        "从检测记录看，出现过以下 source_id：\n"
                        + json.dumps(rows, ensure_ascii=False, indent=2)
                    )
            return (
                "本地库未建 water_source_info 水源信息表，"
                "且 water_detection 也没有 source_id 列（早期版本库结构），"
                "暂无法查询水源信息。可改用「最近检测记录」了解检测情况。"
            )
        rows = _fetch(
            "SELECT id, source_name, source_type, province, city, "
            "description, status FROM water_source_info WHERE status=1 "
            "ORDER BY id",
            (), limit=50,
        )
        return f"水源信息（{len(rows)} 条）：\n" + json.dumps(
            rows, ensure_ascii=False, indent=2
        )

    # 标准查询
    level = None
    for lv in ["饮用水", "地表水I类", "地表水II类", "污水排放"]:
        if lv in query:
            level = lv
            break
    if level:
        rows = _fetch(
            "SELECT indicator_name, min_value, max_value, unit, "
            "standard_level, standard_name FROM water_standard "
            "WHERE standard_level=%s ORDER BY id",
            (level,), limit=20,
        )
        return f"{level} 标准（{len(rows)} 项）：\n" + json.dumps(
            rows, ensure_ascii=False, indent=2
        )

    # 默认：返回饮用水标准（最常用）
    rows = _fetch(
        "SELECT indicator_name, min_value, max_value, unit, "
        "standard_level, standard_name FROM water_standard "
        "WHERE standard_level='饮用水' ORDER BY id",
        (), limit=20,
    )
    return f"饮用水标准（GB5749-2022，共 {len(rows)} 项）：\n" + json.dumps(
        rows, ensure_ascii=False, indent=2
    )


# ============================================================
# 包装成 LangChain Tool 列表
# ============================================================
def get_chat_tools() -> list:
    """返回 4 个 LangChain Tool，供 create_agent 挂载"""
    return [
        Tool(
            name="query_records",
            description=(
                "查询系统中的历史水质检测记录。"
                "当用户问『最近有几条检测』『有哪些不合格的水样』"
                "『某水源的检测情况』时用这个工具。"
                "输入参数 query：用户的自然语言描述。"
            ),
            func=_query_records,
        ),
        Tool(
            name="query_alerts",
            description=(
                "查询水质预警日志。当用户问『有哪些预警』"
                "『未处理的警告』『高危记录』时用这个工具。"
                "输入参数 query：用户的自然语言描述。"
            ),
            func=_query_alerts,
        ),
        Tool(
            name="predict_water",
            description=(
                "对一组水质指标做 AI 预测，判断安全/不安全、水质等级。"
                "当用户给出 pH、硬度、浊度等数值想判断水质时用这个工具。"
                "需要 9 项指标：ph、硬度、固体、氯胺、硫酸盐、电导率、"
                "有机碳、三卤甲烷、浊度。"
                "输入参数 query：包含 9 项指标数值的自然语言，"
                "如『ph=7.2, 硬度=150, 浊度=2.3 ...』。"
            ),
            func=_predict_water,
        ),
        Tool(
            name="query_standards",
            description=(
                "查询水质标准限值或水源信息。当用户问『pH 国标范围是多少』"
                "『饮用水标准』『有哪些采样点/水源』时用这个工具。"
                "输入参数 query：用户的自然语言描述。"
            ),
            func=_query_standards,
        ),
    ]
