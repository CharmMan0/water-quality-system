package com.example.waterqualitysystem;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.*;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * 数据库备份与恢复管理（仅管理员可操作）。
 *
 * GET          — 无 action → 返回备份列表（JSON 或转发 JSP）
 * GET &action=download&file=xxx.sql → 下载备份文件
 * GET &action=delete&file=xxx.sql  → 删除备份文件
 * POST &action=backup               → 创建新备份
 * POST &action=restore&file=xxx.sql → 从备份恢复（恢复前自动保存快照）
 */
@WebServlet("/backup")
public class BackupServlet extends HttpServlet {

    private static final String BACKUP_DIR = System.getProperty("user.home") + File.separator + "water_quality_backups";
    private static final String DB_PASSWORD = System.getenv().getOrDefault("DB_PASSWORD", "");
    private static final String MYSQLDUMP = "mysqldump";
    private static final String MYSQL     = "mysql";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isAdmin(req)) { resp.sendRedirect("dashboard"); return; }

        String action = req.getParameter("action");
        String file  = req.getParameter("file");

        if ("download".equals(action) && file != null) {
            downloadBackup(resp, file);
        } else if ("delete".equals(action) && file != null) {
            deleteBackup(req, resp, file);
        } else {
            // 默认：显示备份管理页面
            listBackups(req);
            req.getRequestDispatcher("backup.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isAdmin(req)) { resp.sendRedirect("dashboard"); return; }

        String action = req.getParameter("action");
        String file   = req.getParameter("file");

        if ("backup".equals(action)) {
            createBackup(req, resp);
        } else if ("restore".equals(action) && file != null) {
            restoreBackup(req, resp, file);
        } else {
            resp.sendRedirect("backup");
        }
    }

    // ============================================================
    //  核心操作
    // ============================================================

    /** 创建备份 — 调用 mysqldump */
    private void createBackup(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        ensureBackupDir();

        String timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String fileName  = "water_quality_db_" + timestamp + ".sql";
        File   backupFile = new File(BACKUP_DIR, fileName);

        // ── mysqldump 命令 ──
        String[] cmd = {
            MYSQLDUMP,
            "-uroot", "-p" + DB_PASSWORD,
            "--single-transaction",      // 不锁表，适合 InnoDB
            "--routines",                // 导出存储过程/函数
            "--triggers",                // 导出触发器
            "--set-gtid-purged=OFF",     // 不导出 GTID，避免恢复时冲突
            "--add-drop-database",
            "--databases", "water_quality_db",
            "--result-file=" + backupFile.getAbsolutePath()
        };

        try {
            Process p = new ProcessBuilder(cmd).redirectErrorStream(true).start();
            String output = readStream(p.getInputStream());
            int exitCode = p.waitFor();

            if (exitCode == 0) {
                long size = backupFile.length();
                req.setAttribute("msg", "备份成功！" + fileName + " (" + formatSize(size) + ")");
                req.setAttribute("msgType", "ok");
            } else {
                req.setAttribute("msg", "备份失败（mysqldump 退出码=" + exitCode + "）：" + output);
                req.setAttribute("msgType", "bad");
            }
        } catch (Exception e) {
            req.setAttribute("msg", "备份异常：" + e.getMessage());
            req.setAttribute("msgType", "bad");
        }

        listBackups(req);
        req.getRequestDispatcher("backup.jsp").forward(req, resp);
    }

    /** 恢复备份 — 调用 mysql，恢复前自动创建快照 */
    private void restoreBackup(HttpServletRequest req, HttpServletResponse resp, String fileName)
            throws ServletException, IOException {
        File backupFile = new File(BACKUP_DIR, fileName);
        if (!backupFile.exists()) {
            req.setAttribute("msg", "备份文件不存在：" + fileName);
            req.setAttribute("msgType", "bad");
            listBackups(req);
            req.getRequestDispatcher("backup.jsp").forward(req, resp);
            return;
        }

        // ── ① 恢复前自动创建快照 ──
        String snapName = "water_quality_db_BEFORE_RESTORE_" +
                new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date()) + ".sql";
        File snapFile = new File(BACKUP_DIR, snapName);
        String[] snapCmd = {
            MYSQLDUMP, "-uroot", "-p" + DB_PASSWORD,
            "--single-transaction", "--routines", "--triggers",
            "--set-gtid-purged=OFF",
            "--add-drop-database", "--databases", "water_quality_db",
            "--result-file=" + snapFile.getAbsolutePath()
        };
        try {
            Process snapP = new ProcessBuilder(snapCmd).redirectErrorStream(true).start();
            snapP.waitFor();
        } catch (Exception e) {
            req.setAttribute("msg", "恢复前的自动快照失败，操作已中止：" + e.getMessage());
            req.setAttribute("msgType", "bad");
            listBackups(req);
            req.getRequestDispatcher("backup.jsp").forward(req, resp);
            return;
        }

        // ── ② 执行恢复（ProcessBuilder.redirectInput 从文件读取）──
        try {
            ProcessBuilder pb = new ProcessBuilder(MYSQL, "-uroot", "-p" + DB_PASSWORD);
            pb.redirectInput(backupFile);          // 原生文件→stdin，比手动管道可靠
            pb.redirectErrorStream(true);
            Process p = pb.start();

            String output = readStream(p.getInputStream());
            int exitCode = p.waitFor();

            if (exitCode == 0) {
                req.setAttribute("msg", "恢复成功！已从 " + fileName + " 恢复数据。恢复前快照：" + snapName);
                req.setAttribute("msgType", "ok");
            } else {
                req.setAttribute("msg", "恢复失败（mysql 退出码=" + exitCode + "）：" + output);
                req.setAttribute("msgType", "bad");
            }
        } catch (Exception e) {
            req.setAttribute("msg", "恢复异常：" + e.getMessage());
            req.setAttribute("msgType", "bad");
        }

        listBackups(req);
        req.getRequestDispatcher("backup.jsp").forward(req, resp);
    }

    /** 下载备份文件 */
    private void downloadBackup(HttpServletResponse resp, String fileName) throws IOException {
        File file = new File(BACKUP_DIR, fileName);
        if (!file.exists()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "文件不存在");
            return;
        }

        resp.setContentType("application/octet-stream");
        resp.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
        resp.setContentLengthLong(file.length());

        try (OutputStream os = resp.getOutputStream();
             FileInputStream fis = new FileInputStream(file)) {
            byte[] buf = new byte[8192];
            int len;
            while ((len = fis.read(buf)) != -1) {
                os.write(buf, 0, len);
            }
        }
    }

    /** 删除备份文件 */
    private void deleteBackup(HttpServletRequest req, HttpServletResponse resp, String fileName)
            throws ServletException, IOException {
        File file = new File(BACKUP_DIR, fileName);
        if (file.exists() && file.delete()) {
            req.setAttribute("msg", "已删除 " + fileName);
            req.setAttribute("msgType", "ok");
        } else {
            req.setAttribute("msg", "删除失败：" + fileName);
            req.setAttribute("msgType", "bad");
        }
        listBackups(req);
        req.getRequestDispatcher("backup.jsp").forward(req, resp);
    }

    // ============================================================
    //  工具方法
    // ============================================================

    /** 列出备份文件并按时间倒序存入 request */
    private void listBackups(HttpServletRequest req) {
        ensureBackupDir();
        File dir = new File(BACKUP_DIR);
        File[] files = dir.listFiles((d, name) -> name.endsWith(".sql"));
        List<Map<String, Object>> list = new ArrayList<>();

        if (files != null) {
            Arrays.sort(files, (a, b) -> Long.compare(b.lastModified(), a.lastModified()));
            for (File f : files) {
                Map<String, Object> m = new HashMap<>();
                m.put("name", f.getName());
                m.put("size", formatSize(f.length()));
                m.put("sizeBytes", f.length());
                m.put("time", new Date(f.lastModified()));
                list.add(m);
            }
        }
        req.setAttribute("backups", list);
    }

    private void ensureBackupDir() {
        File dir = new File(BACKUP_DIR);
        if (!dir.exists()) dir.mkdirs();
    }

    private String formatSize(long bytes) {
        if (bytes < 1024) return bytes + " B";
        if (bytes < 1024 * 1024) return String.format("%.1f KB", bytes / 1024.0);
        return String.format("%.1f MB", bytes / (1024.0 * 1024.0));
    }

    private String readStream(InputStream is) throws IOException {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new InputStreamReader(is, "UTF-8"))) {
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line).append("\n");
            }
        }
        return sb.toString();
    }

    /** 仅管理员（admin）可操作 */
    private boolean isAdmin(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return false;
        Object username = session.getAttribute("username");
        return username != null && "admin".equals(username.toString());
    }
}
