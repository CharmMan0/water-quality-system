# Water Quality AI System — Project Guide

## Stack
- WaterQualitySystem/ — Jakarta EE 6.0 WAR (Tomcat 11, JDK 26, Maven 3.9)
- WaterQualityAI/ — Python FastAPI on port 8000
- MySQL 9.6 on localhost:3306, db=water_quality_db, root/<your_db_password>

## Quick Start
```bash
# 1. Start MySQL (should already be running as Windows service)

# 2. Build & deploy Jakarta EE WAR
cd WaterQualitySystem
mvn package
# Copy target/*.war to <tomcat>/webapps/
# Restart Tomcat: <tomcat>/bin/shutdown.bat && <tomcat>/bin/startup.bat

# 3. Start AI API
cd WaterQualityAI
water_ai_env\Scripts\python ai_api.py
# API docs: http://127.0.0.1:8000/docs
```

## Key Files
| File | Purpose |
|------|---------|
| `LoginServlet.java` | User login + `sha256()` password verify + last login time update |
| `RegisterServlet.java` | User registration with JDBC transaction (`FOR UPDATE` lock) |
| `PredictServlet.java` | Core: parse 9 params → call AI API → parse JSON → save to DB |
| `DashboardServlet.java` | Dashboard stats (total/safe/unsafe) + 7-day trend + source stats |
| `BackupServlet.java` | Admin-only DB backup/restore (mysqldump + mysql via ProcessBuilder) |
| `AuthFilter.java` | Session check filter — redirects to login.jsp for protected paths |
| `EncodingFilter.java` | UTF-8 encoding filter for all requests |
| `DetectionDAO.java` | Insert detection record with explicit JDBC transaction |
| `DBUtil.java` | DB connection pool + SHA-256 hash utility |
| `web.xml` | Filter chain order: EncodingFilter → AuthFilter |
| `ai_api.py` | FastAPI: 5 endpoints, ML pipeline + safety gate + WQI calculation |
| `dashboard.jsp` | ECharts line chart (7-day trend) + bar chart (source stats) |
| `model_info.jsp` | ECharts radar chart (model comparison) + bar chart (accuracy rank) |

## Environment
- JAVA_HOME: `<your_jdk_path>`
- MAVEN_HOME: `<your_maven_path>`
- Tomcat: `<your_tomcat_path>`
- MySQL: `<your_mysql_path>`
- Python venv: `WaterQualityAI\water_ai_env\`

## Recent changes (2026-06-14)
- `665d9ba` fix: 最后登录时间更新改用 `UPDATE users SET last_login_time=NOW()`，Copyright 年份改为 2016-2017
- `f33d9bb` fix: 回退到 `insideTop` + 均值线去掉标签文字（遵循 ECharts 约定）
- `cccbbbd` fix: 均值从 markLine 标签移到卡片标题显示——**markLine text label 在 bar chart 上必然裁切**

## Before editing code
- For risky changes, branch first: `git checkout -b <name>` → work → merge back → delete branch
- User prefers: explain the design plan first, then implement after approval

## JSP conventions
- All pages use `template_header.jsp` + `template_footer.jsp` (Crystal design system, CSS prefix `c-`)
- `sendRedirect()` must be followed by `return` in JSP scriptlets
- Navigation dropdown hover fix: use `::before` pseudo-element on the menu itself, NOT `::after` + `pointer-events:none` on the parent

## JDBC conventions
- Transaction pattern: `conn.setAutoCommit(false)` → operations → `conn.commit()` or `conn.rollback()` → finally restore auto-commit and close all resources
- Password storage: `DBUtil.sha256()` — never store plaintext
- `SELECT ... FOR UPDATE` for row-level locking when checking+inserting

## Database backup
- `mysqldump -uroot -p<your_password> --single-transaction --routines --triggers --set-gtid-purged=OFF --databases water_quality_db --result-file=<path>`
- `mysql -uroot -p<your_password> water_quality_db < <file>` (feed via stdin with ProcessBuilder, NOT redirection)
- **Must include `--set-gtid-purged=OFF`** — otherwise restore fails with MySQL ERROR 3546 (GTID conflict)

## Deploy workflow
- **JSP only changes**: may auto-compile via Tomcat hot-deploy (timestamp detection)
- **Java changes** (Servlet, etc): MUST run `mvn package` in `WaterQualitySystem/`, copy WAR to Tomcat `webapps/`, restart Tomcat
- Changing both: always full deploy

## Testing
- `WaterQualityAI/test_api.py` — Quick API endpoint tests (single predict, batch predict, model info)
- `WaterQualityAI/generate_test_data.py` — Generate CSV test data for batch testing
- `WaterQualityAI/test_data_50samples.csv` / `test_results_50samples.csv` — Pre-generated test data and results
- Manual testing: 3 sample groups (safe / borderline / severely polluted) to verify safety gate behavior

## Frontend conventions
- **Form validation**: dual-layer — JS `onsubmit` (instant feedback) + Java backend `validateRange()` (anti-bypass)
  - Frontend ranges should be slightly wider than API safety gate thresholds (catch obvious typos only)
- **All AI API 9 water quality indicators already have safety gate thresholds** — no additional backend gates needed
- **ECharts**: bar chart labels use `position:'insideTop'` with `distance:8` to prevent clipping; use `yAxis.max` slightly above highest value
  - **Never use markLine with text labels** on bar charts — text always clips on the right; use a dashed line without label instead
- **Never fabricate data**: all displayed metrics must exist in the database; don't introduce hidden fields not shown in tables

## Git (user is a beginner)
- Key commands: status, add, commit, log, checkout -b, merge, reflog
- Each improvement commit message format: "feat: <description>" or "fix: <description>"
- `git checkout <commit-hash>` to go back to any historical version
