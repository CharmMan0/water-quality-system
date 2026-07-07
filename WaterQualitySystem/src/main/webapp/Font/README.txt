============================================
Font 文件夹说明
============================================
项目名称：AI智能水质检测系统 (WaterQualityAI)
更新时间：2026-06-03

字体使用方案：
  本系统未使用自定义字体文件，采用以下系统默认字体栈：
    - 英文：Segoe UI (Windows 11 系统默认)
    - 中文：Microsoft YaHei (微软雅黑)
    - 图标：Bootstrap Icons 1.11.3 (CDN 加载)
    - 备选：Arial, sans-serif

字体栈定义位置：
  src/main/webapp/template_header.jsp (全局 CSS)

资源目录结构：
  src/main/webapp/
  ├── Font/          ← 字体文件目录（本目录，预留）
  ├── images/        ← 图片资源（ROC曲线图、特征重要性图等）
  ├── WEB-INF/       ← Web 配置文件
  └── *.jsp          ← 页面文件

如需添加自定义字体：
  将 .ttf / .otf / .woff2 字体文件放入此目录，
  并在 template_header.jsp 中通过 @font-face 声明引用。
