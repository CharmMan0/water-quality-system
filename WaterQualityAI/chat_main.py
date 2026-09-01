"""
聊天智能体 FastAPI 服务
独立运行在 8001 端口，提供 /chat 流式端点
预测能力复用 ai_api.py 的 make_prediction（import 时会加载模型一次）

启动：
    cd WaterQualityAI
    python chat_main.py
访问：
    http://127.0.0.1:8001/docs       Swagger
    POST http://127.0.0.1:8001/chat  流式聊天
"""
import os
import json
from typing import List, Optional

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from pydantic import BaseModel

from chat_config import CHAT_PORT, LLM_CONFIG
from chat_agent import get_chat_response


# 切到脚本目录，确保能找到 .pkl 模型文件（ai_api 加载模型时需要）
os.chdir(os.path.dirname(os.path.abspath(__file__)))

app = FastAPI(
    title="水质系统聊天智能体",
    description="基于 LangChain Agent 的水质系统对话服务，可查库/做预测/查标准",
    version="1.0.0",
)

# CORS：允许 JSP（Tomcat 8080）和 Streamlit（8501）跨域调用
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================
# 请求/响应模型
# ============================================================
class ChatMessage(BaseModel):
    role: str
    content: str


class ChatRequest(BaseModel):
    query: str
    history: Optional[List[ChatMessage]] = None
    model: Optional[str] = None   # 不传用默认模型


# ============================================================
# 健康检查
# ============================================================
@app.get("/")
def health():
    return {
        "status": "online",
        "service": "水质系统聊天智能体",
        "version": "1.0.0",
        "model": LLM_CONFIG["model"],
        "tools": ["query_records", "query_alerts", "predict_water", "query_standards"],
    }


@app.get("/tools")
def list_tools():
    """列出可用工具，方便前端展示"""
    from chat_tools import get_chat_tools
    return {
        "tools": [
            {"name": t.name, "description": t.description}
            for t in get_chat_tools()
        ]
    }


# ============================================================
# /chat 流式端点
# ============================================================
@app.post("/chat")
async def chat(req: ChatRequest):
    """
    流式聊天接口。返回 text/plain 流，前端逐段读取。
    body: {"query": "...", "history": [{"role":"user","content":"..."}], "model": "..."}
    """
    history = [m.model_dump() for m in req.history] if req.history else None

    async def gen():
        try:
            async for chunk in get_chat_response(
                req.query, history, req.model
            ):
                if chunk:
                    yield chunk
        except Exception as e:
            # 流式过程中出错：把错误也吐出去，前端能看到
            yield f"\n\n[智能体出错] {type(e).__name__}: {e}"

    return StreamingResponse(gen(), media_type="text/plain; charset=utf-8")


# ============================================================
# 启动
# ============================================================
if __name__ == "__main__":
    import uvicorn
    print("=" * 55)
    print("  水质系统聊天智能体启动中...")
    print(f"  端口: {CHAT_PORT}")
    print(f"  模型: {LLM_CONFIG['model']}")
    print(f"  Swagger: http://127.0.0.1:{CHAT_PORT}/docs")
    print("  启动后用 Streamlit 前端或 POST /chat 测试")
    print("=" * 55)
    uvicorn.run("chat_main:app", host="127.0.0.1", port=CHAT_PORT, reload=False)
