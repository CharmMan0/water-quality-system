<%--
  聊天智能体悬浮窗（全局片段）
  被 template_header.jsp 静态 include，所有页面右下角自动出现聊天气泡。
  纯前端：fetch 流式调用 FastAPI 聊天服务（默认 http://127.0.0.1:8001/chat）。
  不依赖 Java 后端，不改任何 Servlet。
--%>
<!-- ==================== 聊天悬浮窗 ==================== -->
<style>
  /* 悬浮按钮 */
  #chat-fab {
    position: fixed;
    right: 24px;
    bottom: 24px;
    width: 58px;
    height: 58px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--c-water), var(--c-teal-500));
    color: #fff;
    border: none;
    cursor: pointer;
    box-shadow: 0 8px 24px rgba(14,165,233,0.4);
    z-index: 1050;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.6rem;
    transition: transform var(--duration) var(--ease-out), box-shadow var(--duration) var(--ease-out);
  }
  #chat-fab:hover {
    transform: translateY(-3px) scale(1.05);
    box-shadow: 0 12px 32px rgba(14,165,233,0.5);
  }
  #chat-fab .fab-badge {
    position: absolute;
    top: -2px; right: -2px;
    min-width: 18px; height: 18px;
    background: var(--danger);
    border-radius: 9px;
    font-size: 0.65rem;
    font-weight: 700;
    display: none;
    align-items: center;
    justify-content: center;
    border: 2px solid #fff;
  }

  /* 聊天面板 */
  #chat-panel {
    position: fixed;
    right: 24px;
    bottom: 96px;
    width: 380px;
    max-width: calc(100vw - 32px);
    height: 560px;
    max-height: calc(100vh - 140px);
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: var(--r-lg);
    box-shadow: var(--shadow-xl);
    z-index: 1051;
    display: none;
    flex-direction: column;
    overflow: hidden;
    animation: chatPop 220ms var(--ease-out);
  }
  #chat-panel.open { display: flex; }
  @keyframes chatPop {
    from { opacity: 0; transform: translateY(12px) scale(0.96); }
    to   { opacity: 1; transform: translateY(0) scale(1); }
  }

  /* 标题栏 */
  .chat-header {
    background: linear-gradient(135deg, var(--c-ocean), var(--c-teal-700));
    color: #fff;
    padding: 0.85rem 1rem;
    display: flex;
    align-items: center;
    gap: 0.6rem;
  }
  .chat-header .ch-avatar {
    width: 36px; height: 36px;
    border-radius: 50%;
    background: rgba(255,255,255,0.2);
    display: flex; align-items: center; justify-content: center;
    font-size: 1.1rem;
  }
  .chat-header .ch-title { font-weight: 700; font-size: 0.95rem; line-height: 1.2; }
  .chat-header .ch-sub { font-size: 0.72rem; opacity: 0.85; }
  .chat-header .ch-close {
    margin-left: auto;
    background: none; border: none; color: #fff;
    font-size: 1.3rem; cursor: pointer; line-height: 1;
    opacity: 0.8; padding: 0.2rem;
  }
  .chat-header .ch-close:hover { opacity: 1; }

  /* 消息区 */
  .chat-body {
    flex: 1;
    overflow-y: auto;
    padding: 1rem;
    background: var(--surface-alt);
    display: flex;
    flex-direction: column;
    gap: 0.7rem;
  }
  .chat-msg { display: flex; gap: 0.5rem; max-width: 88%; }
  .chat-msg.user { align-self: flex-end; flex-direction: row-reverse; }
  .chat-msg .bubble {
    padding: 0.55rem 0.85rem;
    border-radius: var(--r-md);
    font-size: 0.88rem;
    line-height: 1.55;
    white-space: pre-wrap;
    word-break: break-word;
  }
  .chat-msg.user .bubble {
    background: var(--c-water);
    color: #fff;
    border-bottom-right-radius: 4px;
  }
  .chat-msg.ai .bubble {
    background: #fff;
    color: var(--text);
    border: 1px solid var(--border);
    border-bottom-left-radius: 4px;
  }
  .chat-msg .avatar {
    width: 30px; height: 30px; border-radius: 50%;
    flex-shrink: 0;
    display: flex; align-items: center; justify-content: center;
    font-size: 0.9rem;
  }
  .chat-msg.user .avatar { background: var(--c-foam); color: var(--c-ocean); }
  .chat-msg.ai .avatar { background: var(--c-teal-100); color: var(--c-teal-700); }

  /* 正在输入指示 */
  .chat-typing { display: flex; gap: 4px; padding: 0.6rem 0.85rem; }
  .chat-typing span {
    width: 7px; height: 7px; border-radius: 50%;
    background: var(--text-muted);
    animation: typingBounce 1.2s infinite ease-in-out;
  }
  .chat-typing span:nth-child(2) { animation-delay: 0.15s; }
  .chat-typing span:nth-child(3) { animation-delay: 0.3s; }
  @keyframes typingBounce {
    0%, 60%, 100% { transform: translateY(0); opacity: 0.4; }
    30% { transform: translateY(-6px); opacity: 1; }
  }

  /* 快捷问题 */
  .chat-quick {
    display: flex; flex-wrap: wrap; gap: 0.4rem;
    padding: 0 1rem 0.6rem; background: var(--surface-alt);
  }
  .chat-quick button {
    background: #fff;
    border: 1px solid var(--border);
    border-radius: var(--r-full);
    padding: 0.3rem 0.7rem;
    font-size: 0.76rem;
    color: var(--c-ocean);
    cursor: pointer;
    transition: all 120ms var(--ease-out);
    font-family: var(--font-body);
  }
  .chat-quick button:hover {
    background: var(--c-foam);
    border-color: var(--c-sky);
  }

  /* 输入区 */
  .chat-input-area {
    border-top: 1px solid var(--border);
    padding: 0.6rem;
    background: #fff;
    display: flex;
    gap: 0.5rem;
    align-items: flex-end;
  }
  .chat-input-area textarea {
    flex: 1;
    border: 1px solid var(--border);
    border-radius: var(--r-md);
    padding: 0.55rem 0.75rem;
    font-size: 0.88rem;
    font-family: var(--font-body);
    resize: none;
    max-height: 100px;
    line-height: 1.5;
    transition: border-color var(--duration) var(--ease-out);
  }
  .chat-input-area textarea:focus {
    outline: none;
    border-color: var(--c-sky);
    box-shadow: 0 0 0 3px rgba(14,165,233,0.1);
  }
  .chat-send {
    background: var(--c-water);
    color: #fff;
    border: none;
    border-radius: var(--r-md);
    width: 42px; height: 42px;
    display: flex; align-items: center; justify-content: center;
    font-size: 1.1rem;
    cursor: pointer;
    transition: background var(--duration) var(--ease-out);
    flex-shrink: 0;
  }
  .chat-send:hover { background: var(--c-ocean); }
  .chat-send:disabled { background: var(--text-muted); cursor: not-allowed; }

  /* 滚动条美化 */
  .chat-body::-webkit-scrollbar { width: 6px; }
  .chat-body::-webkit-scrollbar-thumb { background: var(--border); border-radius: 3px; }

  @media (max-width: 480px) {
    #chat-panel { right: 8px; left: 8px; width: auto; bottom: 88px; }
    #chat-fab { right: 16px; bottom: 16px; }
  }
</style>

<!-- 悬浮按钮 -->
<button id="chat-fab" onclick="toggleChat()" title="智能助手">
  <i class="bi bi-chat-dots-fill"></i>
  <span class="fab-badge" id="chat-badge">1</span>
</button>

<!-- 聊天面板 -->
<div id="chat-panel">
  <div class="chat-header">
    <div class="ch-avatar"><i class="bi bi-droplet-half"></i></div>
    <div>
      <div class="ch-title">水质智能助手</div>
      <div class="ch-sub">可查库 · 做预测 · 查标准</div>
    </div>
    <button class="ch-close" onclick="toggleChat()">&times;</button>
  </div>

  <div class="chat-body" id="chat-body">
    <div class="chat-msg ai">
      <div class="avatar"><i class="bi bi-robot"></i></div>
      <div class="bubble">你好！我是水质安全智能助手。可以问我：<br>· 最近有哪些不合格的水样<br>· 饮用水 pH 标准范围是多少<br>· 帮我预测 ph=7.2 硬度150 浊度2.3 ... 的水质<br>· 有哪些未处理的预警</div>
    </div>
  </div>

  <div class="chat-quick">
    <button onclick="quickAsk('最近有哪些不合格的水样？')">最近不合格水样</button>
    <button onclick="quickAsk('饮用水各项指标的标准范围？')">饮用水标准</button>
    <button onclick="quickAsk('有哪些未处理的预警？')">未处理预警</button>
    <button onclick="quickAsk('系统里有哪些采样水源？')">采样水源</button>
  </div>

  <div class="chat-input-area">
    <textarea id="chat-input" rows="1" placeholder="输入问题，Enter 发送，Shift+Enter 换行"
              onkeydown="onChatKey(event)" oninput="autoGrow(this)"></textarea>
    <button class="chat-send" id="chat-send" onclick="sendChat()" title="发送">
      <i class="bi bi-send-fill"></i>
    </button>
  </div>
</div>

<script>
  // ==================== 配置 ====================
  // 聊天服务地址（FastAPI chat_main，默认 8001）
  const CHAT_BASE = window.location.hostname === 'localhost'
      ? 'http://127.0.0.1:8001' : 'http://' + window.location.hostname + ':8001';

  // ==================== 状态 ====================
  let chatHistory = [];      // [{role, content}]
  let chatSending = false;   // 防止并发发送

  // ==================== UI 控制 ====================
  function toggleChat() {
    const panel = document.getElementById('chat-panel');
    const fab = document.getElementById('chat-fab');
    const open = panel.classList.toggle('open');
    fab.querySelector('i').className = open ? 'bi bi-x-lg' : 'bi bi-chat-dots-fill';
    if (open) {
      document.getElementById('chat-badge').style.display = 'none';
      setTimeout(() => document.getElementById('chat-input').focus(), 100);
    }
  }

  function autoGrow(el) {
    el.style.height = 'auto';
    el.style.height = Math.min(el.scrollHeight, 100) + 'px';
  }

  function onChatKey(e) {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      sendChat();
    }
  }

  function quickAsk(q) {
    document.getElementById('chat-input').value = q;
    sendChat();
  }

  // ==================== 消息渲染 ====================
  function appendUser(text) {
    const body = document.getElementById('chat-body');
    const div = document.createElement('div');
    div.className = 'chat-msg user';
    div.innerHTML = '<div class="avatar"><i class="bi bi-person-fill"></i></div>'
                  + '<div class="bubble"></div>';
    div.querySelector('.bubble').textContent = text;
    body.appendChild(div);
    scrollChatBottom();
  }

  function appendAIBubble() {
    const body = document.getElementById('chat-body');
    const div = document.createElement('div');
    div.className = 'chat-msg ai';
    div.innerHTML = '<div class="avatar"><i class="bi bi-robot"></i></div>'
                  + '<div class="bubble"></div>';
    body.appendChild(div);
    scrollChatBottom();
    return div.querySelector('.bubble');
  }

  function showTyping() {
    const body = document.getElementById('chat-body');
    const div = document.createElement('div');
    div.className = 'chat-msg ai';
    div.id = 'chat-typing-msg';
    div.innerHTML = '<div class="avatar"><i class="bi bi-robot"></i></div>'
                  + '<div class="chat-typing"><span></span><span></span><span></span></div>';
    body.appendChild(div);
    scrollChatBottom();
  }
  function removeTyping() {
    const el = document.getElementById('chat-typing-msg');
    if (el) el.remove();
  }

  function scrollChatBottom() {
    const body = document.getElementById('chat-body');
    body.scrollTop = body.scrollHeight;
  }

  // ==================== 发送 + 流式接收 ====================
  async function sendChat() {
    if (chatSending) return;
    const input = document.getElementById('chat-input');
    const text = input.value.trim();
    if (!text) return;

    appendUser(text);
    chatHistory.push({ role: 'user', content: text });
    input.value = '';
    input.style.height = 'auto';

    setSending(true);
    showTyping();

    try {
      const resp = await fetch(CHAT_BASE + '/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          query: text,
          history: chatHistory.slice(-10)   // 只带最近 10 条，避免上下文太长
        })
      });

      if (!resp.ok) throw new Error('HTTP ' + resp.status);

      removeTyping();
      const bubble = appendAIBubble();

      // 流式读取
      const reader = resp.body.getReader();
      const decoder = new TextDecoder('utf-8');
      let full = '';
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        const chunk = decoder.decode(value, { stream: true });
        full += chunk;
        bubble.textContent = full;
        scrollChatBottom();
      }
      // 入历史
      chatHistory.push({ role: 'assistant', content: full });

    } catch (err) {
      removeTyping();
      const bubble = appendAIBubble();
      bubble.textContent = '连接失败：' + err.message
          + '\n\n请确认聊天服务已启动（python chat_main.py，端口 8001）。';
      bubble.style.color = 'var(--danger)';
    } finally {
      setSending(false);
    }
  }

  function setSending(v) {
    chatSending = v;
    document.getElementById('chat-send').disabled = v;
  }

  // ==================== 首次提示徽章 ====================
  (function() {
    if (!sessionStorage.getItem('chatSeen')) {
      const b = document.getElementById('chat-badge');
      b.style.display = 'flex';
      sessionStorage.setItem('chatSeen', '1');
    }
  })();
</script>
<!-- ==================== /聊天悬浮窗 ==================== -->
