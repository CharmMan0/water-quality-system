"""
聊天智能体层（核心）
LangChain create_agent + astream_events 流式输出
架构复用生产实习项目，针对水质系统定制 system prompt
"""
from langchain_openai import ChatOpenAI
from langchain.agents import create_agent
from langchain_core.messages import HumanMessage, AIMessage

from chat_config import LLM_CONFIG
from chat_tools import get_chat_tools


# ============================================================
# 系统提示词：定义智能体的角色和行为边界
# ============================================================
SYSTEM_PROMPT = """你是一个「水质安全智能助手」，集成在某大学的水质AI检测系统中。
你可以通过工具查询系统的 MySQL 数据库、调用 AI 模型做水质预测。

你能做的事（必须通过工具）：
1. 查询历史检测记录（query_records）
2. 查询水质预警日志（query_alerts）
3. 对 9 项水质指标做 AI 预测（predict_water）
4. 查询水质标准限值 / 水源信息（query_standards）

回答规范：
- 用户问的是数据/查询 → 调对应工具，把工具返回的关键信息整理成简洁中文，别原样贴 JSON。
- 用户给了水质数值想做预测 → 调 predict_water，把结果用通俗语言解释（安全/不安全、概率、等级、建议）。
- 用户问标准 → 调 query_standards，用表格或列表呈现指标范围。
- 用户闲聊或问系统能力 → 友好介绍你能做什么，举几个例子。
- 涉及「安全」结论要谨慎，给出概率和等级，必要时建议复查或深度处理。
- 回答用简体中文，专业术语保留英文对照。"""


# ============================================================
# LLM 与 Agent 实例（按模型名缓存）
# ============================================================
_llm_cache = {}
_agent_cache = {}


def _get_llm(model: str = None, temperature: float = None) -> ChatOpenAI:
    """构建 LLM，按 model 缓存"""
    m = model or LLM_CONFIG["model"]
    t = temperature if temperature is not None else LLM_CONFIG["temperature"]
    key = (m, t)
    if key not in _llm_cache:
        _llm_cache[key] = ChatOpenAI(
            model=m,
            temperature=t,
            api_key=LLM_CONFIG["api_key"],
            base_url=LLM_CONFIG["base_url"],
            streaming=True,
        )
    return _llm_cache[key]


def _get_agent(model: str = None):
    """构建 agent，按 model 缓存（agent 绑定工具）"""
    m = model or LLM_CONFIG["model"]
    if m not in _agent_cache:
        llm = _get_llm(m)
        tools = get_chat_tools()
        _agent_cache[m] = create_agent(
            model=llm,
            tools=tools,
            system_prompt=SYSTEM_PROMPT,
        )
    return _agent_cache[m]


# ============================================================
# 流式输出主函数：供 FastAPI /chat 调用
# ============================================================
async def get_chat_response(
    query: str,
    history: list = None,
    model: str = None,
):
    """
    流式生成器：逐段 yield 文本片段。
    history: [{"role":"user","content":"..."},{"role":"assistant","content":"..."}]
    用 astream_events v2 抓 on_chat_model 流式 token + on_tool_end 工具结果。
    """
    agent = _get_agent(model)

    # 把历史消息转成 LangChain 消息格式
    messages = []
    if history:
        for h in history:
            role = h.get("role")
            content = h.get("content", "")
            if role == "user":
                messages.append(HumanMessage(content=content))
            elif role == "assistant":
                messages.append(AIMessage(content=content))

    # 当前问题
    messages.append(HumanMessage(content=query))

    # astream + stream_mode="messages" 直接流式输出 AI 消息
    # 比 astream_events v2 轻量得多（不需要遍历整条链的所有事件）
    # 工具调用时 LLM 会自动消化工具结果再总结，用户只看到最终文字
    async for msg, meta in agent.astream(
        {"messages": messages}, stream_mode="messages"
    ):
        content = getattr(msg, "content", "")
        # 只输出 AI 模型节点的流式 token（node="model"），跳过工具消息和空 chunk
        if content and meta.get("langgraph_node") == "model":
            yield content


# ============================================================
# 非流式调用（备用，给调试或前端非流式场景）
# ============================================================
async def get_chat_response_sync(query: str, history: list = None, model: str = None) -> str:
    """一次性返回完整文本"""
    buf = ""
    async for chunk in get_chat_response(query, history, model):
        buf += chunk
    return buf
