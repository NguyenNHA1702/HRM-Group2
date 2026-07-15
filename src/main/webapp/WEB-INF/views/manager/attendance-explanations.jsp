<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Duyệt giải trình chấm công | HRMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css">
    <style>
        /* ── Status badges ── */
        .status-pending  { color: #92400e; background: #fef3c7; padding: 3px 10px; border-radius: 99px; font-size: 12px; font-weight: 500; }
        .status-approved { color: #166534; background: #dcfce7; padding: 3px 10px; border-radius: 99px; font-size: 12px; font-weight: 500; }
        .status-rejected { color: #991b1b; background: #fee2e2; padding: 3px 10px; border-radius: 99px; font-size: 12px; font-weight: 500; }

        .att-status-late      { color: #92400e; background: #fef3c7; padding: 2px 8px; border-radius: 99px; font-size: 11px; }
        .att-status-absent    { color: #991b1b; background: #fee2e2; padding: 2px 8px; border-radius: 99px; font-size: 11px; }
        .att-status-early     { color: #1e3a5f; background: #dbeafe; padding: 2px 8px; border-radius: 99px; font-size: 11px; }

        .action-group { display: flex; gap: 8px; align-items: center; }

        /* ── Toolbar ── */
        .toolbar {
            display: flex;
            gap: 10px;
            align-items: center;
            margin-bottom: 16px;
            flex-wrap: wrap;
        }
        .toolbar select {
            padding: 8px 12px;
            border: 1px solid var(--border);
            border-radius: 8px;
            font-size: 13px;
            font-family: inherit;
            color: var(--text);
            background: var(--white);
            cursor: pointer;
            transition: border-color .15s;
        }
        .toolbar select:focus {
            outline: none;
            border-color: var(--brand);
            box-shadow: 0 0 0 3px rgba(79,70,229,.12);
        }

        /* ── Flash messages ── */
        .flash-success {
            background: #dcfce7; color: #166534; border: 1px solid #bbf7d0;
            padding: 10px 16px; border-radius: 8px; margin-bottom: 16px; font-size: 13px;
        }
        .flash-error {
            background: #fee2e2; color: #991b1b; border: 1px solid #fecaca;
            padding: 10px 16px; border-radius: 8px; margin-bottom: 16px; font-size: 13px;
        }

        /* ── Empty state ── */
        .empty-state {
            text-align: center;
            padding: 40px 0;
            color: var(--muted);
            font-size: 14px;
        }

        /* ── Pagination ── */
        .pagination {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-top: 16px;
            flex-wrap: wrap;
            gap: 10px;
        }
        .pagination-info { font-size: 13px; color: var(--muted); }
        .pagination-buttons { display: flex; gap: 4px; align-items: center; }
        .page-btn {
            min-width: 32px; height: 32px; padding: 0 8px;
            border: 1px solid var(--border); border-radius: 6px;
            background: var(--white); color: var(--text);
            font-size: 13px; cursor: pointer;
            transition: background .15s, border-color .15s;
            display: inline-flex; align-items: center; justify-content: center;
            text-decoration: none;
        }
        .page-btn:hover { background: var(--bg); border-color: var(--brand); }
        .page-btn.active { background: var(--brand); color: #fff; border-color: var(--brand); font-weight: 600; }
        .page-btn.disabled { opacity: 0.4; pointer-events: none; }

        /* ── Reason cell ── */
        .reason-text {
            max-width: 250px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            display: block;
        }

        /* ── Review modal ── */
        .modal-overlay {
            display: none;
            position: fixed; inset: 0;
            background: rgba(0,0,0,0.45);
            z-index: 1000;
            align-items: center; justify-content: center;
        }
        .modal-overlay.open { display: flex; }
        .modal-box {
            background: var(--white);
            border-radius: 12px;
            padding: 28px 32px;
            width: 100%; max-width: 480px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.18);
        }
        .modal-title { font-size: 16px; font-weight: 600; margin-bottom: 16px; }
        .modal-label { font-size: 13px; font-weight: 500; color: var(--muted); margin-bottom: 6px; display: block; }
        .modal-textarea {
            width: 100%; min-height: 100px;
            padding: 10px 12px;
            border: 1px solid var(--border); border-radius: 8px;
            font-size: 13px; font-family: inherit; color: var(--text);
            resize: vertical; box-sizing: border-box;
            transition: border-color .15s;
        }
        .modal-textarea:focus { outline: none; border-color: var(--brand); box-shadow: 0 0 0 3px rgba(79,70,229,.12); }
        .modal-actions { display: flex; gap: 10px; margin-top: 18px; justify-content: flex-end; }
        .modal-info { font-size: 13px; color: var(--text); margin-bottom: 14px; line-height: 1.6; }
        .modal-info strong { color: var(--text); }
        
        /* ── Header details ── */
        .filter-bar {
            display: flex;
            align-items: center;
            background: var(--white);
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 2px;
        }
        .filter-bar select {
            border: none;
            background: transparent;
            outline: none;
            padding: 6px 12px;
            font-size: 13px;
            font-family: inherit;
            cursor: pointer;
        }
        .filter-bar .divider {
            width: 1px;
            background: var(--border);
            align-self: fill;
            margin: 4px 0;
        }
    </style>
</head>
<body>

<div class="main-layout">

    <%@ include file="/WEB-INF/common/sidebar.jsp" %>

    <div class="content-area">

        <div class="page-header" style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:16px;">
            <div>
                <h1>Giải trình chấm công phòng ban</h1>
                <div class="subtitle">Xem xét giải trình và quản lý khóa chấm công của phòng ban</div>
            </div>
            
            <c:if test="${not noDepartment}">
                <div class="header-actions" style="display:flex; gap:12px; align-items:center; flex-wrap:wrap;">
                    <form method="post" action="${pageContext.request.contextPath}/manager-attendance-explanations/action" style="display: flex; gap: 8px; align-items: center; margin: 0;">
                        <input type="hidden" name="month" value="${currentMonth}"/>
                        <input type="hidden" name="year" value="${currentYear}"/>
                        
                        <c:choose>
                            <c:when test="${isGlobalLocked}">
                                <div class="flash error" style="background:#fee2e2; border-color:#fecaca; color:#991b1b; padding:8px 12px; font-size:12px; border-radius:8px; margin:0;">
                                    🔒 Bảng công HT đã khóa bởi HR
                                </div>
                            </c:when>
                            <c:when test="${isDeptLocked}">
                                <input type="hidden" name="action" value="unlockDeptAttendance"/>
                                <button type="submit" class="btn btn-outline" style="border-color:#eab308; color:#eab308; padding: 8px 16px; border-radius: 8px; cursor: pointer;" onclick="return confirm('Bạn có chắc muốn mở khóa chấm công cho phòng ban của mình trong tháng này?')">
                                    🔓 Mở khóa bộ phận
                                </button>
                            </c:when>
                            <c:otherwise>
                                <input type="hidden" name="action" value="lockDeptAttendance"/>
                                <button type="submit" class="btn" style="background-color:#eab308; border-color:#eab308; color:white; padding: 8px 16px; border-radius: 8px; cursor: pointer; border:1px solid #eab308;" onclick="return confirm('Bạn có chắc muốn khóa chấm công cho phòng ban? Sau khi khóa, nhân viên phòng ban của bạn sẽ không thể gửi giải trình mới.')">
                                    🔒 Khóa bộ phận
                                </button>
                            </c:otherwise>
                        </c:choose>
                    </form>
                    
                    <form method="get" action="${pageContext.request.contextPath}/manager-attendance-explanations" class="filter-bar">
                        <select name="month" onchange="this.form.submit()">
                            <c:forEach var="m" begin="1" end="12">
                                <option value="${m}" ${m == currentMonth ? 'selected' : ''}>Tháng ${m}</option>
                            </c:forEach>
                        </select>
                        <div class="divider"></div>
                        <select name="year" onchange="this.form.submit()">
                            <c:forEach var="y" begin="2024" end="2026">
                                <option value="${y}" ${y == currentYear ? 'selected' : ''}>${y}</option>
                            </c:forEach>
                        </select>
                        <c:if test="${not empty statusFilter}">
                            <input type="hidden" name="status" value="${statusFilter}"/>
                        </c:if>
                    </form>
                    
                    <a class="btn btn-outline" href="${pageContext.request.contextPath}/manager-attendance-statistics?month=${currentMonth}&year=${currentYear}" style="border-color:#4f46e5; color:#4f46e5; padding: 8px 16px; border-radius: 8px; text-decoration: none; font-size: 13px; font-weight: 500; display: inline-flex; align-items: center; gap: 6px; cursor: pointer;">
                        📊 Thống kê bộ phận
                    </a>
                </div>
            </c:if>
        </div>

        <%-- Flash messages --%>
        <c:if test="${not empty sessionScope.flash_success}">
            <div class="flash-success">${sessionScope.flash_success}</div>
            <c:remove var="flash_success" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.flash_error}">
            <div class="flash-error">${sessionScope.flash_error}</div>
            <c:remove var="flash_error" scope="session"/>
        </c:if>

        <c:choose>
            <c:when test="${noDepartment}">
                <div class="card" style="padding:40px; text-align:center; color:var(--muted);">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width: 48px; height: 48px; opacity:0.6; margin-bottom:16px;">
                        <circle cx="12" cy="12" r="10"></circle>
                        <line x1="12" y1="8" x2="12" y2="12"></line>
                        <line x1="12" y1="16" x2="12.01" y2="16"></line>
                    </svg>
                    <h3>Chưa được gán bộ phận</h3>
                    <p style="margin-top:8px;">Bạn đang có chức năng quản lý nhưng chưa được chỉ định quản lý một phòng ban đang hoạt động nào.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="card">
                    <%-- Toolbar: status filter --%>
                    <div class="toolbar" style="display:flex; justify-content:space-between; align-items:center;">
                        <form method="get" action="${pageContext.request.contextPath}/manager-attendance-explanations"
                              id="filterForm" style="display:flex; gap:10px; align-items:center; flex-wrap:wrap; margin:0;">
                            <input type="hidden" name="month" value="${currentMonth}"/>
                            <input type="hidden" name="year" value="${currentYear}"/>
                            <select name="status" id="statusFilter" onchange="document.getElementById('filterForm').submit()">
                                <option value="" ${statusFilter eq '' ? 'selected' : ''}>Tất cả trạng thái</option>
                                <option value="PENDING"  ${statusFilter eq 'PENDING'  ? 'selected' : ''}>Chờ duyệt</option>
                                <option value="APPROVED" ${statusFilter eq 'APPROVED' ? 'selected' : ''}>Đã duyệt</option>
                                <option value="REJECTED" ${statusFilter eq 'REJECTED' ? 'selected' : ''}>Từ chối</option>
                            </select>
                            <span style="font-size:13px; color:var(--muted);">
                                Tổng: <strong>${total}</strong> giải trình
                            </span>
                        </form>
                        
                        <c:if test="${isDeptLocked}">
                            <div style="font-size: 13px; color: #b45309; font-weight: 500;">
                                🔒 Bảng công bộ phận tháng này đã khóa.
                            </div>
                        </c:if>
                    </div>

                    <div class="table-wrap">
                        <c:choose>
                            <c:when test="${empty explanations}">
                                <div class="empty-state">Không có giải trình nào phù hợp.</div>
                            </c:when>
                            <c:otherwise>
                                <table id="explanationTable">
                                    <thead>
                                    <tr>
                                        <th>Nhân viên</th>
                                        <th>Phòng ban</th>
                                        <th>Ngày</th>
                                        <th>Trạng thái công</th>
                                        <th>Nội dung giải trình</th>
                                        <th>Trạng thái</th>
                                        <th>Người duyệt / Ghi chú</th>
                                        <th>Thao tác</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <c:forEach items="${explanations}" var="exp">
                                        <tr>
                                            <td>
                                                <strong>${exp.employeeName}</strong><br>
                                                <small style="color:var(--muted);">${exp.employeeCode}</small>
                                            </td>
                                            <td>${exp.departmentName}</td>
                                            <td>${exp.attendanceDate}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${exp.attendanceStatus eq 'LATE'}">
                                                        <span class="att-status-late">Đi muộn</span>
                                                    </c:when>
                                                    <c:when test="${exp.attendanceStatus eq 'ABSENT'}">
                                                        <span class="att-status-absent">Vắng mặt</span>
                                                    </c:when>
                                                    <c:when test="${exp.attendanceStatus eq 'EARLY_LEAVE'}">
                                                        <span class="att-status-early">Về sớm</span>
                                                    </c:when>
                                                    <c:otherwise>${exp.attendanceStatus}</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <span class="reason-text" title="${exp.reason}">${exp.reason}</span>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${exp.status eq 'PENDING'}">
                                                        <span class="status-pending">Chờ duyệt</span>
                                                    </c:when>
                                                    <c:when test="${exp.status eq 'APPROVED'}">
                                                        <span class="status-approved">Đã duyệt</span>
                                                    </c:when>
                                                    <c:when test="${exp.status eq 'REJECTED'}">
                                                        <span class="status-rejected">Từ chối</span>
                                                    </c:when>
                                                    <c:otherwise>${exp.status}</c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty exp.reviewedByName}">
                                                        ${exp.reviewedByName}
                                                        <c:if test="${not empty exp.reviewComment}">
                                                            <br><small style="color:var(--muted); font-style:italic;">"${exp.reviewComment}"</small>
                                                        </c:if>
                                                    </c:when>
                                                    <c:otherwise><span style="color:var(--muted);">—</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:if test="${exp.status eq 'PENDING' and not isGlobalLocked and not isDeptLocked}">
                                                    <div class="action-group">
                                                        <button type="button" class="btn btn-success btn-sm btn-open-approve"
                                                                data-id="${exp.id}" data-name="${exp.employeeName}"
                                                                style="background: #166534; color: white; padding: 4px 8px; border:none; border-radius:4px; cursor:pointer;">
                                                            Duyệt
                                                        </button>
                                                        <button type="button" class="btn btn-danger btn-sm btn-open-reject"
                                                                data-id="${exp.id}" data-name="${exp.employeeName}"
                                                                style="background: #991b1b; color: white; padding: 4px 8px; border:none; border-radius:4px; cursor:pointer;">
                                                            Từ chối
                                                        </button>
                                                    </div>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    </tbody>
                                </table>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <%-- Server-side Pagination --%>
                    <c:if test="${totalPages > 1}">
                        <div class="pagination">
                            <div class="pagination-info">
                                Trang ${currentPage} / ${totalPages} &mdash; ${total} giải trình
                            </div>
                            <div class="pagination-buttons">
                                <c:choose>
                                    <c:when test="${currentPage > 1}">
                                        <a class="page-btn"
                                           href="${pageContext.request.contextPath}/manager-attendance-explanations?page=${currentPage - 1}&amp;status=${statusFilter}&amp;month=${currentMonth}&amp;year=${currentYear}">&lsaquo;</a>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="page-btn disabled">&lsaquo;</span>
                                    </c:otherwise>
                                </c:choose>

                                <c:forEach begin="1" end="${totalPages}" var="p">
                                    <c:choose>
                                        <c:when test="${p eq currentPage}">
                                            <span class="page-btn active">${p}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <a class="page-btn"
                                               href="${pageContext.request.contextPath}/manager-attendance-explanations?page=${p}&amp;status=${statusFilter}&amp;month=${currentMonth}&amp;year=${currentYear}">${p}</a>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>

                                <c:choose>
                                    <c:when test="${currentPage < totalPages}">
                                        <a class="page-btn"
                                           href="${pageContext.request.contextPath}/manager-attendance-explanations?page=${currentPage + 1}&amp;status=${statusFilter}&amp;month=${currentMonth}&amp;year=${currentYear}">&rsaquo;</a>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="page-btn disabled">&rsaquo;</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:if>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<%-- Approve Modal --%>
<div id="approveModal" class="modal-overlay">
    <div class="modal-box">
        <div class="modal-title">Duyệt giải trình chấm công</div>
        <div class="modal-info">
            Bạn có chắc chắn duyệt giải trình của nhân viên <strong id="approveEmpName"></strong>?<br>
            Trạng thái công của ngày này sẽ được cập nhật thành <strong>Đủ công (PRESENT)</strong>.
        </div>
        <form method="post" action="${pageContext.request.contextPath}/manager-attendance-explanations/action">
            <input type="hidden" name="action" value="approve"/>
            <input type="hidden" name="id" id="approveExpId"/>
            <input type="hidden" name="month" value="${currentMonth}"/>
            <input type="hidden" name="year" value="${currentYear}"/>

            <label class="modal-label" for="approveComment">Ý kiến phản hồi (Tùy chọn)</label>
            <textarea name="reviewComment" id="approveComment" class="modal-textarea" placeholder="Ví dụ: Đồng ý duyệt ngày công..."></textarea>

            <div class="modal-actions">
                <button type="button" class="page-btn" onclick="closeApproveModal()">Hủy</button>
                <button type="submit" class="page-btn active" style="background:#166534; border-color:#166534;">Xác nhận duyệt</button>
            </div>
        </form>
    </div>
</div>

<%-- Reject Modal --%>
<div id="rejectModal" class="modal-overlay">
    <div class="modal-box">
        <div class="modal-title" style="color:#991b1b;">Từ chối giải trình chấm công</div>
        <div class="modal-info">
            Từ chối yêu cầu giải trình của nhân viên <strong id="rejectEmpName"></strong>.<br>
            Vui lòng nhập lý do để phản hồi lại nhân viên.
        </div>
        <form method="post" action="${pageContext.request.contextPath}/manager-attendance-explanations/action">
            <input type="hidden" name="action" value="reject"/>
            <input type="hidden" name="id" id="rejectExpId"/>
            <input type="hidden" name="month" value="${currentMonth}"/>
            <input type="hidden" name="year" value="${currentYear}"/>

            <label class="modal-label" for="rejectComment">Lý do từ chối (Bắt buộc)</label>
            <textarea name="reviewComment" id="rejectComment" class="modal-textarea" required placeholder="Nhập lý do từ chối..."></textarea>

            <div class="modal-actions">
                <button type="button" class="page-btn" onclick="closeRejectModal()">Hủy</button>
                <button type="submit" class="page-btn active" style="background:#991b1b; border-color:#991b1b;">Từ chối giải trình</button>
            </div>
        </form>
    </div>
</div>

<script>
    // Approve modal handlers
    const approveModal = document.getElementById('approveModal');
    const approveEmpName = document.getElementById('approveEmpName');
    const approveExpId = document.getElementById('approveExpId');
    const approveComment = document.getElementById('approveComment');

    document.querySelectorAll('.btn-open-approve').forEach(btn => {
        btn.addEventListener('click', () => {
            approveEmpName.textContent = btn.getAttribute('data-name');
            approveExpId.value = btn.getAttribute('data-id');
            approveComment.value = '';
            approveModal.classList.add('open');
        });
    });

    function closeApproveModal() {
        approveModal.classList.remove('open');
    }

    // Reject modal handlers
    const rejectModal = document.getElementById('rejectModal');
    const rejectEmpName = document.getElementById('rejectEmpName');
    const rejectExpId = document.getElementById('rejectExpId');
    const rejectComment = document.getElementById('rejectComment');

    document.querySelectorAll('.btn-open-reject').forEach(btn => {
        btn.addEventListener('click', () => {
            rejectEmpName.textContent = btn.getAttribute('data-name');
            rejectExpId.value = btn.getAttribute('data-id');
            rejectComment.value = '';
            rejectModal.classList.add('open');
        });
    });

    function closeRejectModal() {
        rejectModal.classList.remove('open');
    }

    // Click outside to close modals
    window.addEventListener('click', (e) => {
        if (e.target === approveModal) closeApproveModal();
        if (e.target === rejectModal) closeRejectModal();
    });
</script>

</body>
</html>
