<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    String pageTitle = (String) request.getAttribute("pageTitle");
    if (pageTitle == null) pageTitle = "AI智能水质检测系统";
    String currentUser = (String) session.getAttribute("username");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %> &mdash; Water Quality AI</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        /* ============================================================
           CRYSTAL — Design System for Water Quality AI
           A refined, water-inspired interface blending scientific
           precision with the fluid elegance of pristine water.
           ============================================================ */

        /* ----- Design Tokens ----- */
        :root {
            /* Primary: Deep Water Blues */
            --c-deep:    #0c4a6e;
            --c-ocean:   #0369a1;
            --c-water:   #0ea5e9;
            --c-sky:     #38bdf8;
            --c-mist:    #bae6fd;
            --c-foam:    #e0f2fe;

            /* Secondary: Mineral Teals */
            --c-teal-900:#134e4a;
            --c-teal-700:#0f766e;
            --c-teal-500:#14b8a6;
            --c-teal-300:#5eead4;
            --c-teal-100:#ccfbf1;

            /* Accent: Warm Sunlight */
            --c-amber-600:#d97706;
            --c-amber-400:#fbbf24;
            --c-amber-100:#fef3c7;

            /* Surfaces */
            --surface:       #ffffff;
            --surface-alt:   #f8fafc;
            --surface-hover: #f1f5f9;
            --bg:            #f0f7fb;

            /* Text */
            --text:          #0f172a;
            --text-secondary:#475569;
            --text-muted:    #94a3b8;

            /* Borders */
            --border:        #e2e8f0;
            --border-light:  #f1f5f9;

            /* Semantic */
            --success:       #059669;
            --success-bg:    #d1fae5;
            --danger:        #dc2626;
            --danger-bg:     #fee2e2;
            --warning:       #d97706;
            --warning-bg:    #fef3c7;

            /* Shadows — water-soft, not harsh */
            --shadow-xs:  0 1px 2px rgba(15,23,42,0.04);
            --shadow-sm:  0 1px 3px rgba(15,23,42,0.06), 0 1px 2px rgba(15,23,42,0.04);
            --shadow-md:  0 4px 12px rgba(15,23,42,0.06), 0 2px 4px rgba(15,23,42,0.04);
            --shadow-lg:  0 12px 28px rgba(15,23,42,0.08), 0 4px 8px rgba(15,23,42,0.04);
            --shadow-xl:  0 20px 48px rgba(15,23,42,0.1), 0 8px 16px rgba(15,23,42,0.04);

            /* Radii */
            --r-sm:   8px;
            --r-md:   12px;
            --r-lg:   16px;
            --r-xl:   20px;
            --r-full: 9999px;

            /* Typography */
            --font-body:  "Segoe UI", "PingFang SC", "Microsoft YaHei", "Noto Sans SC", system-ui, -apple-system, sans-serif;

            /* Motion */
            --ease-out:  cubic-bezier(0.16, 1, 0.3, 1);
            --ease-in-out:cubic-bezier(0.65, 0, 0.35, 1);
            --duration:  200ms;
        }

        /* ----- Reset & Base ----- */
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: var(--font-body);
            background: var(--bg);
            color: var(--text);
            min-height: 100vh;
            line-height: 1.6;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
            background-image:
                radial-gradient(ellipse 80% 60% at 50% -10%, rgba(14,165,233,0.06) 0%, transparent 70%),
                radial-gradient(ellipse 60% 40% at 90% 90%, rgba(20,184,166,0.04) 0%, transparent 70%);
            background-attachment: fixed;
        }

        ::selection {
            background: rgba(14,165,233,0.18);
            color: var(--c-deep);
        }

        /* ----- Navigation ----- */
        .c-nav {
            position: sticky;
            top: 0;
            z-index: 1030;
            background: rgba(255,255,255,0.85);
            backdrop-filter: saturate(180%) blur(20px);
            -webkit-backdrop-filter: saturate(180%) blur(20px);
            border-bottom: 1px solid var(--border);
        }

        .c-nav-inner {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            align-items: center;
            height: 60px;
            padding: 0 1.5rem;
        }

        .c-brand {
            display: flex;
            align-items: center;
            gap: 0.6rem;
            text-decoration: none;
            font-weight: 700;
            font-size: 1.15rem;
            color: var(--c-deep);
            letter-spacing: -0.01em;
            white-space: nowrap;
        }

        .c-brand-mark {
            width: 34px;
            height: 34px;
            border-radius: 10px;
            background: linear-gradient(135deg, var(--c-water), var(--c-teal-500));
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-size: 1.1rem;
            box-shadow: 0 2px 8px rgba(14,165,233,0.3);
        }

        .c-nav-links {
            display: flex;
            align-items: center;
            gap: 0.15rem;
            margin-left: 2rem;
            list-style: none;
            padding: 0;
            margin-bottom: 0;
        }

        .c-nav-item {
            position: relative;
        }

        .c-nav-link {
            text-decoration: none;
            color: var(--text-secondary);
            padding: 0.45rem 0.75rem;
            border-radius: var(--r-sm);
            font-size: 0.9rem;
            font-weight: 500;
            transition: all var(--duration) var(--ease-out);
            display: flex;
            align-items: center;
            gap: 0.35rem;
            white-space: nowrap;
            cursor: pointer;
        }

        .c-nav-link:hover {
            color: var(--c-ocean);
            background: var(--c-foam);
        }

        .c-nav-link i {
            font-size: 0.95rem;
        }

        /* Dropdown */
        .c-drop {
            position: relative;
        }

        .c-drop-menu {
            display: none;
            position: absolute;
            top: 100%;
            left: 0;
            margin-top: 6px;             /* visual gap */
            background: #fff;
            border: 1px solid var(--border);
            border-radius: var(--r-md);
            box-shadow: var(--shadow-lg);
            min-width: 190px;
            padding: 0.4rem;
            z-index: 1040;
        }

        /* Invisible hit-area bridge linking trigger → menu.
           A child element of .c-drop, so :hover survives the gap. */
        .c-drop-menu::before {
            content: '';
            position: absolute;
            top: -12px;
            left: 0;
            width: 100%;
            height: 12px;
            z-index: -1;
        }

        .c-drop:hover .c-drop-menu {
            display: block;
            animation: dropIn 150ms var(--ease-out);
        }

        @keyframes dropIn {
            from { opacity: 0; transform: translateY(-6px) scale(0.97); }
            to   { opacity: 1; transform: translateY(0) scale(1); }
        }

        .c-drop-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.55rem 0.75rem;
            text-decoration: none;
            color: var(--text-secondary);
            border-radius: var(--r-sm);
            font-size: 0.875rem;
            transition: all 120ms var(--ease-out);
        }

        .c-drop-item:hover {
            background: var(--c-foam);
            color: var(--c-ocean);
        }

        .c-drop-item i { font-size: 0.9rem; width: 18px; text-align: center; }

        /* Nav Right */
        .c-nav-right {
            margin-left: auto;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .c-user-pill {
            display: flex;
            align-items: center;
            gap: 0.4rem;
            padding: 0.3rem 0.75rem;
            background: var(--c-foam);
            border-radius: var(--r-full);
            font-size: 0.85rem;
            font-weight: 500;
            color: var(--c-ocean);
        }

        .c-btn-logout {
            padding: 0.35rem 0.9rem;
            border-radius: var(--r-full);
            font-size: 0.85rem;
            font-weight: 500;
            border: 1.5px solid var(--border);
            background: #fff;
            color: var(--text-secondary);
            transition: all var(--duration) var(--ease-out);
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
        }

        .c-btn-logout:hover {
            border-color: var(--danger);
            color: var(--danger);
            background: var(--danger-bg);
        }

        /* Mobile Nav */
        .c-menu-btn {
            display: none;
            background: none;
            border: none;
            font-size: 1.4rem;
            color: var(--text);
            cursor: pointer;
            padding: 0.35rem;
            line-height: 1;
        }

        /* ----- Page Hero ----- */
        .c-hero {
            background: linear-gradient(160deg, #075985 0%, #0e7490 35%, #0f766e 70%, #0d9488 100%);
            padding: 2.5rem 1.5rem 2rem;
            text-align: center;
            color: #fff;
            position: relative;
            overflow: hidden;
        }

        .c-hero::before {
            content: '';
            position: absolute;
            inset: 0;
            background:
                radial-gradient(ellipse 60% 50% at 20% 30%, rgba(56,189,248,0.25) 0%, transparent 60%),
                radial-gradient(ellipse 40% 40% at 80% 70%, rgba(94,234,212,0.18) 0%, transparent 60%),
                radial-gradient(ellipse 30% 50% at 50% 100%, rgba(255,255,255,0.06) 0%, transparent 70%);
        }

        /* Subtle water caustic pattern */
        .c-hero::after {
            content: '';
            position: absolute;
            inset: -50%;
            background:
                repeating-linear-gradient(0deg, transparent, transparent 40px, rgba(255,255,255,0.015) 40px, rgba(255,255,255,0.015) 42px),
                repeating-linear-gradient(90deg, transparent, transparent 60px, rgba(255,255,255,0.01) 60px, rgba(255,255,255,0.01) 62px);
            opacity: 0.5;
            animation: causticShift 20s linear infinite;
        }

        @keyframes causticShift {
            0%   { transform: translate(0, 0) rotate(0deg); }
            100% { transform: translate(2%, 1%) rotate(1deg); }
        }

        .c-hero-content {
            position: relative;
            z-index: 1;
        }

        .c-hero h1 {
            font-size: 2.2rem;
            font-weight: 800;
            letter-spacing: -0.03em;
            margin-bottom: 0.5rem;
        }

        .c-hero p {
            font-size: 1.05rem;
            opacity: 0.85;
            max-width: 650px;
            margin: 0 auto;
            font-weight: 400;
        }

        /* ----- Container ----- */
        .c-container {
            max-width: 1280px;
            margin: 0 auto;
            padding: 1.5rem 1.5rem 2rem;
        }

        .c-container-sm {
            max-width: 900px;
            margin: 0 auto;
            padding: 1.5rem 1.5rem 2rem;
        }

        /* ----- Cards ----- */
        .c-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--r-lg);
            box-shadow: var(--shadow-xs);
            overflow: hidden;
            transition: box-shadow 300ms var(--ease-out), border-color 300ms var(--ease-out);
        }

        .c-card:hover {
            box-shadow: var(--shadow-md);
            border-color: #cbd5e1;
        }

        .c-card-body  { padding: 1.25rem; }
        .c-card-header {
            padding: 1rem 1.25rem;
            border-bottom: 1px solid var(--border-light);
            font-weight: 650;
            font-size: 0.95rem;
            letter-spacing: 0.01em;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: var(--text);
        }

        /* Stat Cards */
        .c-stat-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 1rem;
        }

        .c-stat {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--r-lg);
            padding: 1rem 1.25rem;
            position: relative;
            overflow: hidden;
            transition: all 300ms var(--ease-out);
        }

        .c-stat:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-lg);
            border-color: #cbd5e1;
        }

        .c-stat .stat-icon-wrap {
            width: 42px;
            height: 42px;
            border-radius: var(--r-sm);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.25rem;
            margin-bottom: 0.75rem;
        }

        .c-stat .stat-number {
            font-size: 2.25rem;
            font-weight: 800;
            letter-spacing: -0.03em;
            line-height: 1;
            margin-bottom: 0.2rem;
        }

        .c-stat .stat-desc {
            font-size: 0.85rem;
            color: var(--text-muted);
            font-weight: 500;
        }

        .c-stat .stat-glow {
            position: absolute;
            top: -35px;
            right: -35px;
            width: 100px;
            height: 100px;
            border-radius: 50%;
            opacity: 0.07;
            pointer-events: none;
        }

        /* ----- Buttons ----- */
        .c-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.45rem;
            padding: 0.55rem 1.2rem;
            border-radius: var(--r-md);
            font-weight: 600;
            font-size: 0.9rem;
            border: none;
            cursor: pointer;
            transition: all 180ms var(--ease-out);
            text-decoration: none;
            letter-spacing: 0.01em;
            white-space: nowrap;
            font-family: var(--font-body);
        }

        .c-btn--primary {
            background: var(--c-water);
            color: #fff;
            box-shadow: 0 2px 8px rgba(14,165,233,0.25);
        }
        .c-btn--primary:hover {
            background: var(--c-ocean);
            box-shadow: 0 4px 14px rgba(14,165,233,0.35);
            transform: translateY(-1px);
            color: #fff;
        }

        .c-btn--teal {
            background: var(--c-teal-500);
            color: #fff;
        }
        .c-btn--teal:hover {
            background: var(--c-teal-700);
            color: #fff;
            transform: translateY(-1px);
        }

        .c-btn--outline {
            border: 2px solid var(--border);
            background: #fff;
            color: var(--text-secondary);
        }
        .c-btn--outline:hover {
            border-color: var(--c-sky);
            color: var(--c-ocean);
            background: var(--c-foam);
        }

        .c-btn--lg {
            padding: 0.7rem 1.6rem;
            font-size: 0.95rem;
            border-radius: var(--r-lg);
        }

        .c-btn--sm {
            padding: 0.4rem 1rem;
            font-size: 0.825rem;
            border-radius: var(--r-sm);
        }

        /* ----- Forms ----- */
        .c-field {
            margin-bottom: 0.9rem;
        }

        .c-label {
            display: block;
            font-weight: 650;
            font-size: 0.85rem;
            color: var(--text);
            margin-bottom: 0.4rem;
            letter-spacing: 0.01em;
        }

        .c-input,
        .c-select,
        .c-textarea {
            width: 100%;
            padding: 0.65rem 0.9rem;
            border: 1.5px solid var(--border);
            border-radius: var(--r-md);
            font-size: 0.925rem;
            font-family: var(--font-body);
            background: var(--surface-alt);
            transition: all var(--duration) var(--ease-out);
            color: var(--text);
            line-height: 1.5;
        }

        .c-input:focus,
        .c-select:focus,
        .c-textarea:focus {
            outline: none;
            border-color: var(--c-sky);
            box-shadow: 0 0 0 3px rgba(14,165,233,0.1);
            background: #fff;
        }

        .c-input::placeholder { color: var(--text-muted); }

        .c-select {
            cursor: pointer;
            appearance: none;
            -webkit-appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath d='M6 7.5L1.5 3h9z' fill='%2394a3b8'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 0.9rem center;
            padding-right: 2.5rem;
        }

        .c-textarea {
            resize: vertical;
            min-height: 100px;
        }

        /* ----- Tables ----- */
        .c-table-wrap {
            overflow-x: auto;
            border-radius: var(--r-md);
            border: 1px solid var(--border);
        }

        .c-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.9rem;
        }

        .c-table thead th {
            background: #f1f5f9;
            color: var(--c-deep);
            font-weight: 650;
            font-size: 0.8rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            padding: 0.6rem 0.85rem;
            text-align: left;
            border-bottom: 2px solid #cbd5e1;
            white-space: nowrap;
        }

        .c-table tbody td {
            padding: 0.55rem 0.85rem;
            border-bottom: 1px solid var(--border-light);
            vertical-align: middle;
        }

        .c-table tbody tr:last-child td {
            border-bottom: none;
        }

        .c-table tbody tr {
            transition: background 150ms var(--ease-out);
        }

        .c-table tbody tr:hover {
            background: #f8fafc;
        }

        .c-table--striped tbody tr:nth-child(even) {
            background: #fafbfc;
        }

        /* ----- Badges ----- */
        .c-badge {
            display: inline-flex;
            align-items: center;
            padding: 0.25rem 0.7rem;
            border-radius: var(--r-full);
            font-size: 0.78rem;
            font-weight: 650;
            letter-spacing: 0.02em;
            white-space: nowrap;
        }

        .c-badge--ok     { background: var(--success-bg); color: #065f46; }
        .c-badge--bad    { background: var(--danger-bg);  color: #991b1b; }
        .c-badge--warn   { background: var(--warning-bg); color: #92400e; }
        .c-badge--info   { background: var(--c-foam);     color: #075985; }
        .c-badge--teal   { background: var(--c-teal-100); color: #115e59; }
        .c-badge--ghost  { background: #f1f5f9;          color: var(--text-secondary); }

        /* ----- Alerts / Callouts ----- */
        .c-callout {
            padding: 0.85rem 1rem;
            border-radius: var(--r-md);
            display: flex;
            align-items: flex-start;
            gap: 0.65rem;
            font-weight: 500;
            font-size: 0.9rem;
            border: 1px solid transparent;
        }

        .c-callout--ok    { background: #ecfdf5; color: #065f46; border-color: #a7f3d0; }
        .c-callout--bad   { background: #fef2f2; color: #991b1b; border-color: #fecaca; }
        .c-callout--warn  { background: #fffbeb; color: #92400e; border-color: #fde68a; }
        .c-callout--info  { background: #f0f9ff; color: #075985; border-color: #bae6fd; }

        /* ----- Section Header ----- */
        .c-section-hd {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            margin-bottom: 0.85rem;
        }

        .c-section-hd h2 {
            font-size: 1.35rem;
            font-weight: 700;
            margin: 0;
            white-space: nowrap;
        }

        .c-section-hd .hd-line {
            flex: 1;
            height: 1px;
            background: var(--border);
        }

        /* ----- Footer ----- */
        .c-footer {
            border-top: 1px solid var(--border);
            background: #fff;
            padding: 1.5rem 1.5rem;
            margin-top: 1.5rem;
            text-align: center;
            color: var(--text-muted);
            font-size: 0.85rem;
        }

        .c-footer-inner {
            max-width: 900px;
            margin: 0 auto;
        }

        .c-footer h5 {
            color: var(--text);
            font-weight: 700;
            margin-bottom: 0.35rem;
        }

        .c-footer .footer-meta {
            display: flex;
            justify-content: center;
            gap: 1.25rem;
            flex-wrap: wrap;
            margin: 0.5rem 0 0.75rem;
            font-size: 0.8rem;
        }

        .c-footer .footer-meta span { color: var(--text-muted); }

        .c-footer .footer-copy {
            font-size: 0.78rem;
            color: var(--text-muted);
            margin-top: 0.25rem;
        }

        /* ----- Result Hero ----- */
        .c-result-hero {
            text-align: center;
            padding: 1.75rem 1.5rem;
        }

        .c-result-icon {
            font-size: 5rem;
            margin-bottom: 0.75rem;
            line-height: 1;
        }

        .c-result-verdict {
            font-size: 2.75rem;
            font-weight: 800;
            letter-spacing: -0.03em;
            margin-bottom: 0.25rem;
        }

        .c-metric-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1rem;
            margin-top: 1.25rem;
        }

        .c-metric {
            background: #f8fafc;
            border: 1px solid var(--border-light);
            padding: 0.9rem 0.85rem;
            border-radius: var(--r-md);
            text-align: center;
        }

        .c-metric .metric-label {
            font-size: 0.75rem;
            color: var(--text-muted);
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            margin-bottom: 0.3rem;
        }

        .c-metric .metric-value {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--text);
        }

        /* ----- Animations ----- */
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .c-reveal {
            animation: fadeUp 0.5s var(--ease-out) both;
        }
        .c-reveal--1 { animation-delay: 0.05s; }
        .c-reveal--2 { animation-delay: 0.12s; }
        .c-reveal--3 { animation-delay: 0.19s; }
        .c-reveal--4 { animation-delay: 0.26s; }
        .c-reveal--5 { animation-delay: 0.33s; }
        .c-reveal--6 { animation-delay: 0.40s; }

        /* Ripple effect on click */
        .c-ripple {
            position: relative;
            overflow: hidden;
        }

        .c-ripple::after {
            content: '';
            position: absolute;
            inset: 0;
            background: radial-gradient(circle at center, rgba(255,255,255,0.4) 0%, transparent 60%);
            opacity: 0;
            transition: opacity 400ms;
        }

        .c-ripple:active::after {
            opacity: 1;
            transition: opacity 0ms;
        }

        /* ----- Utility ----- */
        .c-divider {
            border: none;
            border-top: 1px solid var(--border);
            margin: 1rem 0;
        }

        .c-text-muted  { color: var(--text-muted); }
        .c-text-sm      { font-size: 0.85rem; }
        .c-text-center  { text-align: center; }
        .c-mt-2         { margin-top: 0.75rem; }
        .c-mt-3         { margin-top: 1.25rem; }
        .c-mt-4         { margin-top: 1.5rem; }
        .c-mb-2         { margin-bottom: 0.75rem; }
        .c-mb-3         { margin-bottom: 1.25rem; }
        .c-mb-4         { margin-bottom: 1.5rem; }
        .c-gap           { gap: 1.25rem; }
        .c-grid-2 {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.25rem;
        }
        .c-grid-3 {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1rem;
        }

        /* Water ripple decoration */
        .c-water-mark {
            position: relative;
        }

        .c-water-mark::before {
            content: '';
            position: absolute;
            width: 150px;
            height: 150px;
            border: 1px solid rgba(14,165,233,0.08);
            border-radius: 50%;
            top: -75px;
            right: -75px;
            pointer-events: none;
        }

        .c-water-mark::after {
            content: '';
            position: absolute;
            width: 100px;
            height: 100px;
            border: 1px solid rgba(20,184,166,0.06);
            border-radius: 50%;
            top: -50px;
            right: -50px;
            pointer-events: none;
        }

        /* ----- Responsive ----- */
        @media (max-width: 768px) {
            .c-menu-btn { display: block; }

            .c-nav-links {
                display: none;
                position: absolute;
                top: 60px;
                left: 0;
                right: 0;
                background: #fff;
                flex-direction: column;
                padding: 1rem;
                border-bottom: 1px solid var(--border);
                box-shadow: var(--shadow-lg);
                margin-left: 0;
            }

            .c-nav-links.open { display: flex; }

            .c-drop-menu {
                position: static;
                box-shadow: none;
                border: none;
                padding-left: 1rem;
                display: none;
            }

            .c-drop.open .c-drop-menu { display: block; }

            .c-nav-right .c-user-pill { display: none; }

            .c-grid-2 { grid-template-columns: 1fr; }
            .c-grid-3 { grid-template-columns: 1fr; }
            .c-metric-grid { grid-template-columns: 1fr; }

            .c-hero h1 { font-size: 1.5rem; }
            .c-hero { padding: 2rem 1rem 1.5rem; }
        }

        @media (max-width: 480px) {
            .c-stat-row { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<!-- Navigation -->
<nav class="c-nav">
    <div class="c-nav-inner">
        <a class="c-brand" href="dashboard">
            <span class="c-brand-mark"><i class="bi bi-droplet-half"></i></span>
            Water AI
        </a>

        <button class="c-menu-btn" aria-label="菜单" onclick="document.querySelector('.c-nav-links').classList.toggle('open')">
            <i class="bi bi-list"></i>
        </button>

        <ul class="c-nav-links">
            <li class="c-nav-item"><a class="c-nav-link" href="dashboard"><i class="bi bi-speedometer2"></i> 仪表盘</a></li>
            <li class="c-nav-item"><a class="c-nav-link" href="index.jsp"><i class="bi bi-cpu"></i> 水质检测</a></li>
            <li class="c-nav-item"><a class="c-nav-link" href="history"><i class="bi bi-clock-history"></i> 历史记录</a></li>
            <li class="c-nav-item c-drop">
                <a class="c-nav-link" href="#"><i class="bi bi-info-circle"></i> 信息 <i class="bi bi-chevron-down" style="font-size:0.65rem;margin-left:-0.1rem;"></i></a>
                <div class="c-drop-menu">
                    <a class="c-drop-item" href="model_info.jsp"><i class="bi bi-cpu-fill"></i> AI 模型</a>
                    <a class="c-drop-item" href="water_standards.jsp"><i class="bi bi-check2-circle"></i> 水质标准</a>
                    <a class="c-drop-item" href="announcements"><i class="bi bi-megaphone"></i> 系统公告</a>
                    <a class="c-drop-item" href="warnings"><i class="bi bi-exclamation-triangle"></i> 警告列表</a>
                    <a class="c-drop-item" href="feedback.jsp"><i class="bi bi-chat-dots"></i> 用户反馈</a>
                </div>
            </li>
            <li class="c-nav-item c-drop">
                <a class="c-nav-link" href="#"><i class="bi bi-person"></i> 个人 <i class="bi bi-chevron-down" style="font-size:0.65rem;margin-left:-0.1rem;"></i></a>
                <div class="c-drop-menu">
                    <a class="c-drop-item" href="profile.jsp"><i class="bi bi-person-badge"></i> 自我介绍</a>
                    <a class="c-drop-item" href="about.jsp"><i class="bi bi-book"></i> 关于系统</a>
                    <% if ("admin".equals(currentUser)) { %>
                    <a class="c-drop-item" href="backup"><i class="bi bi-shield-check"></i> 备份管理</a>
                    <% } %>
                </div>
            </li>
        </ul>

        <div class="c-nav-right">
            <span class="c-user-pill">
                <i class="bi bi-person-circle"></i> <%= currentUser != null ? currentUser : "游客" %>
            </span>
            <a href="logout" class="c-btn-logout">
                <i class="bi bi-box-arrow-right"></i> 登出
            </a>
        </div>
    </div>
</nav>

<%-- 聊天智能体悬浮窗（全站通用，纯前端 fetch 调 FastAPI 8001） --%>
<%@ include file="chat_widget.jsp" %>
