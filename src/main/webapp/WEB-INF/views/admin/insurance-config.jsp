<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>${canManageInsurance ? 'Quản lý Bảo hiểm' : 'Thông tin Bảo hiểm'} | HRMS</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/insurance.css"/>

    <style>
        /* ── Modal ── */
        .modal-overlay { position:fixed; inset:0; background:rgba(15,23,42,.55); display:none; align-items:center; justify-content:center; z-index:1000; padding:20px; overflow-y:auto; }
        .modal-overlay.open { display:flex; }
        .modal { background:#fff; border-radius:16px; padding:32px; width:540px; max-width:100%; box-shadow:0 24px 60px rgba(0,0,0,.18); margin:auto; }
        .modal-wide { width:660px; }
        .modal-title { font-size:18px; font-weight:700; margin-bottom:22px; display:flex; align-items:center; gap:10px; color:var(--text); }
        .modal-title svg, .modal-title i { color:var(--brand); }

        /* ── Form inside modal ── */
        .form-group { margin-bottom:16px; }
        .form-group label { display:block; font-size:13px; font-weight:600; color:var(--text); margin-bottom:6px; }
        .form-group input,
        .form-group select,
        .form-group textarea {
            width:100%; padding:10px 14px; border:1px solid var(--border);
            border-radius:9px; font-size:14px; font-family:inherit;
            transition:border-color .15s; background:#fff;
        }
        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus { outline:none; border-color:var(--brand); box-shadow:0 0 0 3px rgba(79,70,229,.12); }
        .form-group textarea { resize:vertical; min-height:80px; }
        .form-hint { font-size:12px; color:var(--muted); margin-top:5px; }
        .form-grid-2 { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
        .modal-actions { display:flex; justify-content:flex-end; gap:10px; margin-top:24px; }
        .btn-cancel { padding:9px 18px; background:#f1f5f9; border:1px solid var(--border); border-radius:9px; cursor:pointer; font-size:13px; font-family:inherit; font-weight:500; }
        .btn-cancel:hover { background:#e2e8f0; }

        /* ── Flash ── */
        .flash { display:flex; align-items:center; gap:10px; padding:14px 18px; border-radius:10px; margin-bottom:20px; font-size:13.5px; font-weight:500; }
        .flash.success { background:#dcfce7; color:#166534; border:1px solid #bbf7d0; }
        .flash.error   { background:#fee2e2; color:#b91c1c; border:1px solid #fecaca; }

        /* ── Section header ── */
        .section-block { margin-bottom:28px; }
        .section-block-header {
            display:flex; justify-content:space-between; align-items:center;
            margin-bottom:14px;
        }
        .section-block-title { font-size:16px; font-weight:700; color:var(--text); display:flex; align-items:center; gap:8px; }
        .section-block-sub   { font-size:13px; color:var(--muted); margin-top:3px; }

        /* ── Action buttons (SVG-based, like holiday-list) ── */
        .actions { display:flex; gap:4px; }
        .action-btn {
            width:32px; height:32px; border:none; background:none;
            border-radius:7px; cursor:pointer; display:inline-flex;
            align-items:center; justify-content:center; transition:all .15s;
        }
        .action-btn:hover { background:var(--bg); }
        .action-btn.edit   { color:var(--blue); }
        .action-btn.delete { color:var(--red); }
        .action-btn.save   { color:#16a34a; }
        .action-btn.cancel-edit { color:var(--muted); }
        .action-btn svg { width:16px; height:16px; fill:none; stroke:currentColor; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }

        /* ── Badge / rate display ── */
        .badge { display:inline-flex; align-items:center; padding:2px 9px; border-radius:20px; font-size:11.5px; font-weight:600; white-space:nowrap; }
        .badge-active   { background:var(--green-light);  color:#15803d; cursor:pointer; }
        .badge-inactive { background:var(--red-light);    color:#b91c1c; cursor:pointer; }
        .readonly-status { cursor:default; }
        .badge-code     { background:var(--brand-light);  color:var(--brand); font-size:11px; }

        .rate-pill-emp  { display:inline-block; background:#eef2ff; color:#4f46e5; padding:4px 12px; border-radius:20px; font-weight:700; font-size:14px; }
        .rate-pill-emp2 { display:inline-block; background:#f0fdf4; color:#16a34a; padding:4px 12px; border-radius:20px; font-weight:700; font-size:14px; }
        .rate-input-inline { display:none; width:80px; padding:6px 8px; border:2px solid var(--brand); border-radius:6px; font-size:14px; text-align:center; }

        /* ── Info/legal note ── */
        .info-note {
            margin-top:12px; padding:12px 16px; border-radius:8px;
            font-size:13px; display:flex; gap:10px; align-items:flex-start;
        }
        .info-note.warn { background:#fffbeb; border:1px solid #fde68a; color:#92400e; }
        .info-note.blue { background:#f0f9ff; border:1px solid #bae6fd; color:#0c4a6e; }
        .info-note svg { width:16px; height:16px; flex-shrink:0; margin-top:1px; fill:none; stroke:currentColor; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }

        /* ── Condition badge in group table ── */
        .cond-badge { background:#f0fdf4; color:#15803d; padding:3px 8px; border-radius:4px; font-size:12px; font-weight:500; display:inline-block; }

        /* ── Rate input inside modal ── */
        .insurance-rate-grid { display:grid; grid-template-columns:1fr 1fr 1fr; gap:12px; margin-bottom:12px; }
        .insurance-rate-input { display:flex; flex-direction:column; }
        .insurance-rate-input label { font-size:12px; color:var(--muted); margin-bottom:4px; font-weight:600; }
        .insurance-rate-input input { padding:8px 10px; border:1px solid var(--border); border-radius:9px; font-size:14px; }
        .rate-total-preview { padding:9px 12px; background:var(--bg); border:1px solid var(--border); border-radius:9px; font-size:14px; font-weight:700; color:var(--text); }

        /* â”€â”€ Pagination â”€â”€ */
        .pagination-container { display:flex; justify-content:space-between; align-items:center; padding:16px 20px; border-top:1px solid var(--border); background:#fff; border-bottom-left-radius:12px; border-bottom-right-radius:12px; font-size:13.5px; color:var(--muted); }
        .pagination { display:flex; gap:6px; list-style:none; padding:0; margin:0; }
        .page-item a { display:flex; align-items:center; justify-content:center; min-width:32px; height:32px; padding:0 8px; border:1px solid var(--border); border-radius:6px; color:var(--text); text-decoration:none; transition:all .15s; font-weight:500; }
        .page-item.active a { background:var(--brand); color:#fff; border-color:var(--brand); }
        .page-item.disabled a { opacity:.5; cursor:not-allowed; background:#f8fafc; pointer-events:none; }
        .page-item:not(.active):not(.disabled) a:hover { background:#f1f5f9; border-color:#cbd5e1; }
    </style>
</head>

<body>
<div class="main-layout">
    <jsp:include page="/WEB-INF/common/sidebar.jsp" />

    <main class="content-area">

        <script>
            window.contextPath = '${pageContext.request.contextPath}';
            window.actionUrl   = '${pageContext.request.contextPath}/admin/insurance/action';
        </script>

        <%-- Flash Messages --%>
        <c:if test="${not empty sessionScope.flash_success}">
            <div class="flash success">
                <svg viewBox="0 0 24 24" style="width:16px;height:16px;fill:none;stroke:currentColor;stroke-width:2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                ${sessionScope.flash_success}
            </div>
            <c:remove var="flash_success" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.flash_error}">
            <div class="flash error">
                <svg viewBox="0 0 24 24" style="width:16px;height:16px;fill:none;stroke:currentColor;stroke-width:2"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                ${sessionScope.flash_error}
            </div>
            <c:remove var="flash_error" scope="session"/>
        </c:if>

        <%-- Page Header --%>
        <div class="page-header">
            <div>
                <h1>${canManageInsurance ? 'Quản lý Bảo hiểm' : 'Thông tin Bảo hiểm'}</h1>
                <p class="subtitle">
                    ${canManageInsurance
                            ? 'Cấu hình tỷ lệ và đối tượng áp dụng bảo hiểm bắt buộc'
                            : 'Theo dõi tỷ lệ và đối tượng áp dụng bảo hiểm trong hệ thống'}
                </p>
            </div>
        </div>

        <%-- Stats Cards --%>
        <div class="stats-grid" style="grid-template-columns:repeat(3,1fr); margin-bottom:28px;">
            <div class="stat-card">
                <div>
                    <div class="stat-label">Tổng bảo hiểm</div>
                    <div class="stat-value" style="color:var(--blue)">${stats.totalInsurances}</div>
                </div>
                <div class="stat-icon icon-blue">
                    <svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                </div>
            </div>
            <div class="stat-card">
                <div>
                    <div class="stat-label">Đang áp dụng</div>
                    <div class="stat-value" style="color:var(--green)">${stats.activeInsurances}</div>
                </div>
                <div class="stat-icon icon-green">
                    <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
                </div>
            </div>
            <div class="stat-card">
                <div>
                    <div class="stat-label">Đã dừng</div>
                    <div class="stat-value" style="color:var(--red)">${stats.inactiveInsurances}</div>
                </div>
                <div class="stat-icon icon-red">
                    <svg viewBox="0 0 24 24"><rect x="6" y="4" width="4" height="16"/><rect x="14" y="4" width="4" height="16"/></svg>
                </div>
            </div>
        </div>

        <%-- ══════════════════════════════════════════════════════════
             SECTION 1 — Cấu hình tỷ lệ đóng bảo hiểm
             ══════════════════════════════════════════════════════════ --%>
        <div class="section-block">
            <div class="section-block-header">
                <div>
                    <div class="section-block-title">
                        <svg viewBox="0 0 24 24" style="width:18px;height:18px;fill:none;stroke:var(--brand);stroke-width:2;stroke-linecap:round;stroke-linejoin:round"><circle cx="12" cy="12" r="3"/><path d="M19.07 4.93a10 10 0 0 1 0 14.14M4.93 4.93a10 10 0 0 0 0 14.14"/></svg>
                        Cấu hình tỷ lệ đóng bảo hiểm
                    </div>
                    <p class="section-block-sub">Tỷ lệ % trích từ lương của người lao động và phần đóng góp của doanh nghiệp</p>
                </div>
                <c:if test="${canManageInsurance}">
                    <button type="button" class="btn btn-primary" onclick="openModal('createRateModal')">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width:15px;height:15px;"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                        Thêm loại bảo hiểm
                    </button>
                </c:if>
            </div>

            <div class="card">
                <div class="table-wrap">
                    <table id="rateTable">
                        <thead>
                        <tr>
                            <th>#</th>
                            <th>Loại bảo hiểm</th>
                            <th>Mã</th>
                            <th style="text-align:center;">NLĐ đóng (%)<br><small style="font-weight:400;color:var(--muted);">Trừ vào lương</small></th>
                            <th style="text-align:center;">DN đóng (%)<br><small style="font-weight:400;color:var(--muted);">Chi phí doanh nghiệp</small></th>
                            <th style="text-align:center;">Tổng (%)</th>
                            <th>Ghi chú</th>
                            <th>Trạng thái</th>
                            <c:if test="${canManageInsurance}">
                                <th>Hành động</th>
                            </c:if>
                        </tr>
                        </thead>
                        <tbody>
                        <c:choose>
                            <c:when test="${not empty insuranceRates}">
                                <c:forEach var="rate" items="${insuranceRates}" varStatus="loop">
                                    <tr id="rate-row-${rate.id}">
                                        <td>${(ratePage - 1) * pageSize + loop.count}</td>
                                        <td style="font-weight:600; color:var(--text)">${rate.name}</td>
                                        <td><span class="badge badge-code">${rate.code}</span></td>
                                        <td style="text-align:center;">
                                            <span class="rate-pill-emp" id="emp-rate-${rate.id}">${rate.employeeRate}%</span>
                                            <c:if test="${canManageInsurance}">
                                                <input type="number" class="rate-input-inline" id="emp-input-${rate.id}"
                                                       value="${rate.employeeRate}" step="0.1" min="0" max="100"
                                                       onchange="updateTotal(${rate.id})">
                                            </c:if>
                                        </td>
                                        <td style="text-align:center;">
                                            <span class="rate-pill-emp2" id="emp2-rate-${rate.id}">${rate.employerRate}%</span>
                                            <c:if test="${canManageInsurance}">
                                                <input type="number" class="rate-input-inline" id="emp2-input-${rate.id}"
                                                       style="border-color:#16a34a;"
                                                       value="${rate.employerRate}" step="0.1" min="0" max="100"
                                                       onchange="updateTotal(${rate.id})">
                                            </c:if>
                                        </td>
                                        <td style="text-align:center;">
                                            <span id="total-rate-${rate.id}" style="font-weight:700; color:var(--text);">
                                                <fmt:formatNumber value="${rate.employeeRate + rate.employerRate}" pattern="#,##0.0"/>%
                                            </span>
                                        </td>
                                        <td style="color:var(--muted); font-size:13px;">${rate.note}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${canManageInsurance}">
                                                    <span class="badge ${rate.active ? 'badge-active' : 'badge-inactive'}"
                                                          onclick="confirmToggleRate(${rate.id}, ${rate.active})">
                                                        ${rate.active ? 'Đang áp dụng' : 'Đã dừng'}
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge readonly-status ${rate.active ? 'badge-active' : 'badge-inactive'}">
                                                        ${rate.active ? 'Đang áp dụng' : 'Đã dừng'}
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <c:if test="${canManageInsurance}">
                                            <td>
                                                <div class="actions">
                                                    <button class="action-btn edit" id="edit-btn-${rate.id}"
                                                            onclick="toggleEditRate(${rate.id})" title="Chỉnh sửa">
                                                        <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                                    </button>
                                                    <button class="action-btn save" id="save-btn-${rate.id}"
                                                            onclick="saveRate(${rate.id})" title="Lưu"
                                                            style="display:none;">
                                                        <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
                                                    </button>
                                                    <button class="action-btn cancel-edit" id="cancel-btn-${rate.id}"
                                                            onclick="cancelEditRate(${rate.id})" title="Hủy"
                                                            style="display:none;">
                                                        <svg viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                                                    </button>
                                                    <button class="action-btn delete"
                                                            data-id="${rate.id}"
                                                            data-name="${rate.name}"
                                                            onclick="confirmDeleteRate(this)" title="Xóa">
                                                        <svg viewBox="0 0 24 24"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><line x1="10" y1="11" x2="10" y2="17"/><line x1="14" y1="11" x2="14" y2="17"/></svg>
                                                    </button>
                                                </div>
                                            </td>
                                        </c:if>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr><td colspan="${canManageInsurance ? 9 : 8}" style="text-align:center;padding:40px;color:var(--muted)">Chưa có cấu hình tỷ lệ bảo hiểm nào.</td></tr>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>

                <div class="pagination-container">
                    <div>
                        Hiển thị từ
                        <c:choose>
                            <c:when test="${totalRates == 0}">0</c:when>
                            <c:otherwise>${(ratePage - 1) * pageSize + 1}</c:otherwise>
                        </c:choose>
                        đến
                        <c:choose>
                            <c:when test="${ratePage * pageSize > totalRates}">${totalRates}</c:when>
                            <c:otherwise>${ratePage * pageSize}</c:otherwise>
                        </c:choose>
                        trên tổng số <strong>${totalRates}</strong> bản ghi
                    </div>

                    <c:if test="${totalRatePages > 1}">
                        <ul class="pagination">
                            <li class="page-item ${ratePage == 1 ? 'disabled' : ''}">
                                <c:url var="previousRatePageUrl" value="/admin/insurance">
                                    <c:param name="ratePage" value="${ratePage - 1}"/>
                                    <c:param name="groupPage" value="${groupPage}"/>
                                </c:url>
                                <a href="${previousRatePageUrl}#rateTable" title="Trang trước">&laquo;</a>
                            </li>

                            <c:forEach var="i" begin="1" end="${totalRatePages}">
                                <c:url var="ratePageUrl" value="/admin/insurance">
                                    <c:param name="ratePage" value="${i}"/>
                                    <c:param name="groupPage" value="${groupPage}"/>
                                </c:url>
                                <li class="page-item ${ratePage == i ? 'active' : ''}">
                                    <a href="${ratePageUrl}#rateTable">${i}</a>
                                </li>
                            </c:forEach>

                            <li class="page-item ${ratePage == totalRatePages ? 'disabled' : ''}">
                                <c:url var="nextRatePageUrl" value="/admin/insurance">
                                    <c:param name="ratePage" value="${ratePage + 1}"/>
                                    <c:param name="groupPage" value="${groupPage}"/>
                                </c:url>
                                <a href="${nextRatePageUrl}#rateTable" title="Trang sau">&raquo;</a>
                            </li>
                        </ul>
                    </c:if>
                </div>
            </div>

            <div class="info-note warn">
                <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                <span>Tỷ lệ trên áp dụng theo quy định hiện hành của Bộ LĐ-TB&XH. Khi thay đổi tỷ lệ, hệ thống sẽ tự động tính lại số tiền bảo hiểm cho tất cả nhân viên trong kỳ lương tiếp theo.</span>
            </div>
        </div>

        <%-- ══════════════════════════════════════════════════════════
             SECTION 2 — Đối tượng áp dụng bảo hiểm
             ══════════════════════════════════════════════════════════ --%>
        <div class="section-block">
            <div class="section-block-header">
                <div>
                    <div class="section-block-title">
                        <svg viewBox="0 0 24 24" style="width:18px;height:18px;fill:none;stroke:var(--brand);stroke-width:2;stroke-linecap:round;stroke-linejoin:round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                        Đối tượng áp dụng bảo hiểm
                    </div>
                    <p class="section-block-sub">Quy định nhóm người lao động thuộc diện tham gia bảo hiểm bắt buộc của công ty</p>
                </div>
                <c:if test="${canManageInsurance}">
                    <button type="button" class="btn btn-primary" onclick="openModal('createGroupModal')">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width:15px;height:15px;"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                        Thêm nhóm đối tượng
                    </button>
                </c:if>
            </div>

            <div class="card">
                <div class="table-wrap">
                    <table id="groupTable">
                        <thead>
                        <tr>
                            <th>#</th>
                            <th>Tên nhóm đối tượng</th>
                            <th>Điều kiện áp dụng</th>
                            <th>Mô tả chi tiết</th>

                            <th>Trạng thái</th>
                            <c:if test="${canManageInsurance}">
                                <th>Hành động</th>
                            </c:if>
                        </tr>
                        </thead>
                        <tbody>
                        <c:choose>
                            <c:when test="${not empty applicableGroups}">
                                <c:forEach var="grp" items="${applicableGroups}" varStatus="loop">
                                    <tr id="group-row-${grp.id}">
                                        <td>${(groupPage - 1) * pageSize + loop.count}</td>
                                        <td style="font-weight:600; color:var(--text); max-width:220px;">${grp.name}</td>
                                        <td style="max-width:200px;">
                                            <c:choose>
                                                <c:when test="${not empty grp.conditionDetail}">
                                                    <span class="cond-badge">${grp.conditionDetail}</span>
                                                </c:when>
                                                <c:otherwise><span style="color:var(--muted);">—</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="font-size:13px; color:var(--muted); max-width:320px; line-height:1.5;">
                                            <c:choose>
                                                <c:when test="${not empty grp.description}">${grp.description}</c:when>
                                                <c:otherwise><span style="color:var(--muted);">—</span></c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td>
                                            <c:choose>
                                                <c:when test="${canManageInsurance}">
                                                    <span class="badge ${grp.active ? 'badge-active' : 'badge-inactive'}"
                                                          onclick="confirmToggleGroup(${grp.id}, ${grp.active})">
                                                        ${grp.active ? 'Đang áp dụng' : 'Đã dừng'}
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge readonly-status ${grp.active ? 'badge-active' : 'badge-inactive'}">
                                                        ${grp.active ? 'Đang áp dụng' : 'Đã dừng'}
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <c:if test="${canManageInsurance}">
                                            <td>
                                                <div class="actions">
                                                    <button type="button" class="action-btn edit"
                                                            data-id="${grp.id}"
                                                            data-name="${fn:escapeXml(grp.name)}"
                                                            data-desc="${fn:escapeXml(grp.description)}"
                                                            data-cond="${fn:escapeXml(grp.conditionDetail)}"
                                                            data-active="${grp.active}"
                                                            onclick="openEditGroup(this)"
                                                            title="Chỉnh sửa">
                                                        <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                                    </button>
                                                    <button type="button" class="action-btn delete"
                                                            data-id="${grp.id}"
                                                            data-name="${fn:escapeXml(grp.name)}"
                                                            onclick="confirmDeleteGroup(this)"
                                                            title="Xóa">
                                                        <svg viewBox="0 0 24 24"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><line x1="10" y1="11" x2="10" y2="17"/><line x1="14" y1="11" x2="14" y2="17"/></svg>
                                                    </button>
                                                </div>
                                            </td>
                                        </c:if>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr><td colspan="${canManageInsurance ? 6 : 5}" style="text-align:center;padding:40px;color:var(--muted)">Chưa có nhóm đối tượng nào được cấu hình.</td></tr>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>

                <div class="pagination-container">
                    <div>
                        Hiển thị từ
                        <c:choose>
                            <c:when test="${totalGroups == 0}">0</c:when>
                            <c:otherwise>${(groupPage - 1) * pageSize + 1}</c:otherwise>
                        </c:choose>
                        đến
                        <c:choose>
                            <c:when test="${groupPage * pageSize > totalGroups}">${totalGroups}</c:when>
                            <c:otherwise>${groupPage * pageSize}</c:otherwise>
                        </c:choose>
                        trên tổng số <strong>${totalGroups}</strong> bản ghi
                    </div>

                    <c:if test="${totalGroupPages > 1}">
                        <ul class="pagination">
                            <li class="page-item ${groupPage == 1 ? 'disabled' : ''}">
                                <c:url var="previousGroupPageUrl" value="/admin/insurance">
                                    <c:param name="ratePage" value="${ratePage}"/>
                                    <c:param name="groupPage" value="${groupPage - 1}"/>
                                </c:url>
                                <a href="${previousGroupPageUrl}#groupTable" title="Trang trước">&laquo;</a>
                            </li>

                            <c:forEach var="i" begin="1" end="${totalGroupPages}">
                                <c:url var="groupPageUrl" value="/admin/insurance">
                                    <c:param name="ratePage" value="${ratePage}"/>
                                    <c:param name="groupPage" value="${i}"/>
                                </c:url>
                                <li class="page-item ${groupPage == i ? 'active' : ''}">
                                    <a href="${groupPageUrl}#groupTable">${i}</a>
                                </li>
                            </c:forEach>

                            <li class="page-item ${groupPage == totalGroupPages ? 'disabled' : ''}">
                                <c:url var="nextGroupPageUrl" value="/admin/insurance">
                                    <c:param name="ratePage" value="${ratePage}"/>
                                    <c:param name="groupPage" value="${groupPage + 1}"/>
                                </c:url>
                                <a href="${nextGroupPageUrl}#groupTable" title="Trang sau">&raquo;</a>
                            </li>
                        </ul>
                    </c:if>
                </div>
            </div>

            <div class="info-note blue">
                <svg viewBox="0 0 24 24"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="9" y1="21" x2="9" y2="9"/></svg>
                <span>
                    Đối tượng áp dụng bảo hiểm theo quy định tại Điều 2 Luật BHXH 2014 và Điều 2 Luật BHYT 2008 (sửa đổi 2014).
                    Công ty có thể bổ sung nhóm đối tượng phù hợp với thực tế và quy định nội bộ.
                </span>
            </div>
        </div>

    </main>
</div>

        <c:if test="${canManageInsurance}">
        <%-- ═══════════════════════ MODALS ════════════════════════════ --%>

        <%-- Modal Thêm loại bảo hiểm --%>
        <div class="modal-overlay" id="createRateModal">
            <div class="modal modal-wide">
                <div class="modal-title">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width:20px;height:20px;"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                    Thêm loại bảo hiểm mới
                </div>
                <form method="post" action="${pageContext.request.contextPath}/admin/insurance/action" id="createRateForm">
                    <input type="hidden" name="action" value="createRate">
                    <div class="form-grid-2">
                        <div class="form-group">
                            <label for="rateName">Tên loại bảo hiểm <span style="color:red">*</span></label>
                            <input type="text" id="rateName" name="name" placeholder="VD: Bảo hiểm xã hội" required>
                        </div>
                        <div class="form-group">
                            <label for="rateCode">Mã viết tắt <span style="color:red">*</span></label>
                            <input type="text" id="rateCode" name="code" placeholder="VD: BHXH" maxlength="10" required style="text-transform:uppercase;">
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Tỷ lệ đóng góp</label>
                        <div class="insurance-rate-grid">
                            <div class="insurance-rate-input">
                                <label for="newEmpRate">Người lao động (%)</label>
                                <input type="number" id="newEmpRate" name="employeeRate" value="0" step="0.1" min="0" max="100" required onchange="previewNewTotal()">
                            </div>
                            <div class="insurance-rate-input">
                                <label for="newEmpRate2">Doanh nghiệp (%)</label>
                                <input type="number" id="newEmpRate2" name="employerRate" value="0" step="0.1" min="0" max="100" required onchange="previewNewTotal()">
                            </div>
                            <div class="insurance-rate-input">
                                <label>Tổng tỷ lệ (%)</label>
                                <div class="rate-total-preview"><span id="newTotalPreview">0.0</span>%</div>
                            </div>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="rateNote">Ghi chú / Cơ sở pháp lý</label>
                        <input type="text" id="rateNote" name="note" placeholder="VD: Theo Luật BHXH 2014, sửa đổi 2019">
                    </div>
                    <div class="form-group">
                        <label for="rateIsActive">Trạng thái</label>
                        <select id="rateIsActive" name="isActive">
                            <option value="1">Đang áp dụng</option>
                            <option value="0">Tạm dừng</option>
                        </select>
                    </div>
                    <div class="modal-actions">
                        <button type="button" class="btn-cancel" onclick="closeModal('createRateModal')">Hủy</button>
                        <button type="submit" class="btn btn-primary">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width:14px;height:14px;"><polyline points="20 6 9 17 4 12"/></svg>
                            Thêm loại bảo hiểm
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <%-- Modal Thêm nhóm đối tượng áp dụng --%>
        <div class="modal-overlay" id="createGroupModal">
            <div class="modal modal-wide">
                <div class="modal-title">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width:20px;height:20px;"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                    Thêm nhóm đối tượng áp dụng
                </div>
                <form method="post" action="${pageContext.request.contextPath}/admin/insurance/action">
                    <input type="hidden" name="action" value="createApplicableGroup">
                    <div class="form-group">
                        <label for="newGroupName">Tên nhóm đối tượng <span style="color:red">*</span></label>
                        <input type="text" id="newGroupName" name="groupName"
                               placeholder="VD: Nhân sự chính thức (HĐLĐ từ đủ 1 tháng trở lên)"
                               required maxlength="200">
                    </div>
                    <div class="form-group">
                        <label for="newGroupCondition">Điều kiện ngắn gọn</label>
                        <input type="text" id="newGroupCondition" name="groupConditionDetail"
                               placeholder="VD: HĐLĐ ≥ 1 tháng — BHXH + BHYT + BHTN" maxlength="500">
                        <p class="form-hint">Hiển thị ngắn gọn trên bảng danh sách</p>
                    </div>
                    <div class="form-group">
                        <label for="newGroupDesc">Mô tả chi tiết</label>
                        <textarea id="newGroupDesc" name="groupDescription"
                                  placeholder="Mô tả đầy đủ điều kiện, phạm vi áp dụng và cơ sở pháp lý..."></textarea>
                    </div>
                    <div class="form-group">
                        <label for="newGroupActive">Trạng thái</label>
                        <select id="newGroupActive" name="groupIsActive">
                            <option value="1">Đang áp dụng</option>
                            <option value="0">Tạm dừng</option>
                        </select>
                    </div>
                    <div class="modal-actions">
                        <button type="button" class="btn-cancel" onclick="closeModal('createGroupModal')">Hủy</button>
                        <button type="submit" class="btn btn-primary">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width:14px;height:14px;"><polyline points="20 6 9 17 4 12"/></svg>
                            Thêm nhóm đối tượng
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <%-- Modal Sửa nhóm đối tượng áp dụng --%>
        <div class="modal-overlay" id="editGroupModal">
            <div class="modal modal-wide">
                <div class="modal-title">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width:20px;height:20px;"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                    Chỉnh sửa nhóm đối tượng
                </div>
                <form method="post" action="${pageContext.request.contextPath}/admin/insurance/action">
                    <input type="hidden" name="action" value="updateApplicableGroup">
                    <input type="hidden" name="groupId" id="editGroupId">
                    <div class="form-group">
                        <label for="editGroupName">Tên nhóm đối tượng <span style="color:red">*</span></label>
                        <input type="text" id="editGroupName" name="groupName" required maxlength="200">
                    </div>
                    <div class="form-group">
                        <label for="editGroupCondition">Điều kiện ngắn gọn</label>
                        <input type="text" id="editGroupCondition" name="groupConditionDetail" maxlength="500">
                        <p class="form-hint">Hiển thị ngắn gọn trên bảng danh sách</p>
                    </div>
                    <div class="form-group">
                        <label for="editGroupDesc">Mô tả chi tiết</label>
                        <textarea id="editGroupDesc" name="groupDescription"></textarea>
                    </div>
                    <div class="form-group">
                        <label for="editGroupActive">Trạng thái</label>
                        <select id="editGroupActive" name="groupIsActive">
                            <option value="1">Đang áp dụng</option>
                            <option value="0">Tạm dừng</option>
                        </select>
                    </div>
                    <div class="modal-actions">
                        <button type="button" class="btn-cancel" onclick="closeModal('editGroupModal')">Hủy</button>
                        <button type="submit" class="btn btn-primary">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width:14px;height:14px;"><polyline points="20 6 9 17 4 12"/></svg>
                            Lưu thay đổi
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <%-- Hidden forms cho Rate actions --%>
        <form id="updateRateForm" method="post" action="${pageContext.request.contextPath}/admin/insurance/action" style="display:none">
            <input type="hidden" name="action"       value="updateRate">
            <input type="hidden" name="id"           id="updateRateId">
            <input type="hidden" name="employeeRate" id="updateEmpRate">
            <input type="hidden" name="employerRate" id="updateEmpRate2">
        </form>

        <form id="deleteRateForm" method="post" action="${pageContext.request.contextPath}/admin/insurance/action" style="display:none">
            <input type="hidden" name="action" value="deleteRate">
            <input type="hidden" name="id"     id="deleteRateId">
        </form>

        <form id="toggleRateForm" method="post" action="${pageContext.request.contextPath}/admin/insurance/action" style="display:none">
            <input type="hidden" name="action"   value="toggleRate">
            <input type="hidden" name="id"       id="toggleRateId">
            <input type="hidden" name="isActive" id="toggleRateIsActive">
        </form>

        <%-- Hidden forms cho Applicable Group actions --%>
        <form id="toggleGroupForm" method="post" action="${pageContext.request.contextPath}/admin/insurance/action" style="display:none">
            <input type="hidden" name="action"   value="toggleApplicableGroup">
            <input type="hidden" name="groupId"  id="toggleGroupId">
            <input type="hidden" name="isActive" id="toggleGroupIsActive">
        </form>

        <form id="deleteGroupForm" method="post" action="${pageContext.request.contextPath}/admin/insurance/action" style="display:none">
            <input type="hidden" name="action"  value="deleteApplicableGroup">
            <input type="hidden" name="groupId" id="deleteGroupId">
        </form>
        </c:if>

<script>
// ══════════════════════════════════════════════════════════
// Modal helpers
// ══════════════════════════════════════════════════════════
function openModal(id)  { document.getElementById(id).classList.add('open'); }
function closeModal(id) { document.getElementById(id).classList.remove('open'); }

document.querySelectorAll('.modal-overlay').forEach(function(m) {
    m.addEventListener('click', function(e) {
        if (e.target === m) m.classList.remove('open');
    });
});

// ══════════════════════════════════════════════════════════
// Insurance Rate — Preview tổng trong modal Thêm
// ══════════════════════════════════════════════════════════
function previewNewTotal() {
    var emp  = parseFloat(document.getElementById('newEmpRate').value)  || 0;
    var emp2 = parseFloat(document.getElementById('newEmpRate2').value) || 0;
    document.getElementById('newTotalPreview').textContent = (emp + emp2).toFixed(1);
}

// ══════════════════════════════════════════════════════════
// Insurance Rate — Inline edit toggle
// ══════════════════════════════════════════════════════════
function toggleEditRate(id) {
    document.getElementById('emp-rate-'   + id).style.display = 'none';
    document.getElementById('emp2-rate-'  + id).style.display = 'none';
    document.getElementById('emp-input-'  + id).style.display = 'inline-block';
    document.getElementById('emp2-input-' + id).style.display = 'inline-block';
    document.getElementById('edit-btn-'   + id).style.display = 'none';
    document.getElementById('save-btn-'   + id).style.display = 'inline-flex';
    document.getElementById('cancel-btn-' + id).style.display = 'inline-flex';
    document.getElementById('emp-input-'  + id).focus();
}

function cancelEditRate(id) {
    var empOrig  = document.getElementById('emp-rate-'  + id).textContent.replace('%','').trim();
    var emp2Orig = document.getElementById('emp2-rate-' + id).textContent.replace('%','').trim();
    document.getElementById('emp-input-'  + id).value = empOrig;
    document.getElementById('emp2-input-' + id).value = emp2Orig;
    restoreDisplayMode(id);
}

function restoreDisplayMode(id) {
    document.getElementById('emp-rate-'   + id).style.display = 'inline-block';
    document.getElementById('emp2-rate-'  + id).style.display = 'inline-block';
    document.getElementById('emp-input-'  + id).style.display = 'none';
    document.getElementById('emp2-input-' + id).style.display = 'none';
    document.getElementById('edit-btn-'   + id).style.display = 'inline-flex';
    document.getElementById('save-btn-'   + id).style.display = 'none';
    document.getElementById('cancel-btn-' + id).style.display = 'none';
}

function updateTotal(id) {
    var emp  = parseFloat(document.getElementById('emp-input-'  + id).value) || 0;
    var emp2 = parseFloat(document.getElementById('emp2-input-' + id).value) || 0;
    document.getElementById('total-rate-' + id).textContent = (emp + emp2).toFixed(1) + '%';
}

function saveRate(id) {
    var emp  = parseFloat(document.getElementById('emp-input-'  + id).value);
    var emp2 = parseFloat(document.getElementById('emp2-input-' + id).value);
    if (isNaN(emp) || isNaN(emp2) || emp < 0 || emp2 < 0 || emp > 100 || emp2 > 100) {
        alert('Tỷ lệ phải là số từ 0 đến 100!');
        return;
    }
    document.getElementById('emp-rate-'  + id).textContent = emp.toFixed(1) + '%';
    document.getElementById('emp2-rate-' + id).textContent = emp2.toFixed(1) + '%';
    document.getElementById('updateRateId').value   = id;
    document.getElementById('updateEmpRate').value  = emp;
    document.getElementById('updateEmpRate2').value = emp2;
    document.getElementById('updateRateForm').submit();
}

// ══════════════════════════════════════════════════════════
// Insurance Rate — Toggle trạng thái
// ══════════════════════════════════════════════════════════
function confirmToggleRate(id, currentActive) {
    var newActive = !currentActive;
    var label     = newActive ? 'Đang áp dụng' : 'Đã dừng';
    if (!confirm('Bạn có chắc muốn đổi trạng thái thành "' + label + '"?')) return;
    document.getElementById('toggleRateId').value       = id;
    document.getElementById('toggleRateIsActive').value = newActive ? '1' : '0';
    document.getElementById('toggleRateForm').submit();
}

// ══════════════════════════════════════════════════════════
// Insurance Rate — Xóa
// ══════════════════════════════════════════════════════════
function confirmDeleteRate(btn) {
    var id   = btn.getAttribute('data-id');
    var name = btn.getAttribute('data-name');
    if (confirm('Bạn có chắc muốn xóa loại bảo hiểm "' + name + '"?\nThao tác này không thể hoàn tác.')) {
        document.getElementById('deleteRateId').value = id;
        document.getElementById('deleteRateForm').submit();
    }
}

// ══════════════════════════════════════════════════════════
// Applicable Group — Mở modal chỉnh sửa và điền dữ liệu
// ══════════════════════════════════════════════════════════
// ══════════════════════════════════════════════════════════
// Safe getElementById helper
// ══════════════════════════════════════════════════════════
function $id(id) {
    var el = document.getElementById(id);
    if (!el) { console.error('[Insurance] Element not found: #' + id); }
    return el;
}

function openEditGroup(btn) {
    var id       = btn.getAttribute('data-id');
    var name     = btn.getAttribute('data-name');
    var desc     = btn.getAttribute('data-desc') || '';
    var cond     = btn.getAttribute('data-cond') || '';
    var isActive = btn.getAttribute('data-active') === 'true' ? '1' : '0';

    var elId     = $id('editGroupId');
    var elName   = $id('editGroupName');
    var elDesc   = $id('editGroupDesc');
    var elCond   = $id('editGroupCondition');
    var elActive = $id('editGroupActive');

    if (!elId || !elName || !elDesc || !elCond || !elActive) {
        alert('Lỗi: Không tìm thấy form chỉnh sửa. Vui lòng tải lại trang (F5).');
        return;
    }

    elId.value   = id;
    elName.value = name;
    elDesc.value = desc;
    elCond.value = cond;

    elActive.value = isActive;
    for (var i = 0; i < elActive.options.length; i++) {
        elActive.options[i].selected = (elActive.options[i].value === isActive);
    }

    openModal('editGroupModal');
}

// ══════════════════════════════════════════════════════════
// Applicable Group — Toggle trạng thái
// ══════════════════════════════════════════════════════════
function confirmToggleGroup(id, currentActive) {
    var newActive = !currentActive;
    var label     = newActive ? 'Đang áp dụng' : 'Đã dừng';
    if (!confirm('Bạn có chắc muốn đổi trạng thái nhóm đối tượng này thành "' + label + '"?')) return;
    var toggleForm = document.getElementById('toggleGroupForm');
    if (toggleForm) {
        document.getElementById('toggleGroupId').value       = id;
        document.getElementById('toggleGroupIsActive').value = newActive ? '1' : '0';
        toggleForm.submit();
    } else {
        alert('Lỗi: Không tìm thấy form. Vui lòng tải lại trang.');
    }
}

// ══════════════════════════════════════════════════════════
// Applicable Group — Xóa
// ══════════════════════════════════════════════════════════
function confirmDeleteGroup(btn) {
    var id   = btn.getAttribute('data-id');
    var name = btn.getAttribute('data-name');
    if (!confirm('Bạn có chắc muốn xóa nhóm đối tượng "' + name + '"?\nThao tác này không thể hoàn tác.')) return;
    var deleteForm = document.getElementById('deleteGroupForm');
    if (deleteForm) {
        document.getElementById('deleteGroupId').value = id;
        deleteForm.submit();
    } else {
        alert('Lỗi: Không tìm thấy form. Vui lòng tải lại trang.');
    }
}
</script>

</body>
</html>