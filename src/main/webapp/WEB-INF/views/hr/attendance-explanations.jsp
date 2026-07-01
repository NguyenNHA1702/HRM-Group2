<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Giải trình chấm công | HRMS</title>
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
    </style>
</head>
<body>

<div class="main-layout">

    <%@ include file="/WEB-INF/common/sidebar.jsp" %>

    <div class="content-area">

        <div class="page-header">
            <div>
                <h1>Giải trình chấm công</h1>
                <div class="subtitle">Xem xét và phê duyệt yêu cầu giải trình của nhân viên</div>
            </div>
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

        <div class="card">

            <%-- Toolbar: status filter --%>
            <div class="toolbar">
                <form method="get" action="${pageContext.request.contextPath}/hr/attendance-explanations"
                      id="filterForm" style="display:flex; gap:10px; align-items:center; flex-wrap:wrap;">
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
                                        <c:if test="${exp.status eq 'PENDING'}">
                                            <div class="action-group">
                                                <button type="button" class="btn btn-success btn-sm btn-open-approve"
                                                        data-id="${exp.id}" data-name="${exp.employeeName}">
                                                    Duyệt
                                                </button>
                                                <button type="button" class="btn btn-danger btn-sm btn-open-reject"
                                                        data-id="${exp.id}" data-name="${exp.employeeName}">
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
                                   href="${pageContext.request.contextPath}/hr/attendance-explanations?page=${currentPage - 1}&amp;status=${statusFilter}">&lsaquo;</a>
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
                                       href="${pageContext.request.contextPath}/hr/attendance-explanations?page=${p}&amp;status=${statusFilter}">${p}</a>
                                </c:otherwise>
                            </c:choose>
                        </c:forEach>

                        <c:choose>
                            <c:when test="${currentPage < totalPages}">
                                <a class="page-btn"
                                   href="${pageContext.request.contextPath}/hr/attendance-explanations?page=${currentPage + 1}&amp;status=${statusFilter}">&rsaquo;</a>
                            </c:when>
                            <c:otherwise>
                                <span class="page-btn disabled">&rsaquo;</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:if>

        </div>
    </div>
</div>

<%-- Approve Modal --%>
<div class="modal-overlay" id="approveModal">
    <div class="modal-box">
        <div class="modal-title">&#9989; Chấp nhận giải trình</div>
        <div class="modal-info" id="approveInfo"></div>
        <form method="post" action="${pageContext.request.contextPath}/hr/attendance-explanations/action">
            <input type="hidden" name="action" value="approve">
            <input type="hidden" name="id" id="approveId">
            <label class="modal-label" for="approveComment">Ghi chú (tuỳ chọn)</label>
            <textarea class="modal-textarea" id="approveComment" name="reviewComment"
                      placeholder="Nhập ghi chú cho nhân viên..."></textarea>
            <div class="modal-actions">
                <button type="button" class="btn btn-secondary" onclick="closeModal('approveModal')">Huỷ</button>
                <button type="submit" class="btn btn-success">Xác nhận duyệt</button>
            </div>
        </form>
    </div>
</div>

<%-- Reject Modal --%>
<div class="modal-overlay" id="rejectModal">
    <div class="modal-box">
        <div class="modal-title">&#10060; Từ chối giải trình</div>
        <div class="modal-info" id="rejectInfo"></div>
        <form method="post" action="${pageContext.request.contextPath}/hr/attendance-explanations/action">
            <input type="hidden" name="action" value="reject">
            <input type="hidden" name="id" id="rejectId">
            <label class="modal-label" for="rejectComment">Lý do từ chối <span style="color:#991b1b;">*</span></label>
            <textarea class="modal-textarea" id="rejectComment" name="reviewComment"
                      placeholder="Nhập lý do từ chối..." required></textarea>
            <div class="modal-actions">
                <button type="button" class="btn btn-secondary" onclick="closeModal('rejectModal')">Huỷ</button>
                <button type="submit" class="btn btn-danger">Xác nhận từ chối</button>
            </div>
        </form>
    </div>
</div>

<script>
    /* ── Event delegation cho buttons Duyệt / Từ chối ── */
    document.addEventListener('click', function(e) {
        var btnApprove = e.target.closest('.btn-open-approve');
        var btnReject  = e.target.closest('.btn-open-reject');

        if (btnApprove) {
            var id   = btnApprove.dataset.id;
            var name = btnApprove.dataset.name;
            // Lấy date từ cột thứ 3 của cùng row
            var row  = btnApprove.closest('tr');
            var date = row ? (row.cells[2] ? row.cells[2].textContent.trim() : '') : '';
            openApproveModal(id, name, date);
        } else if (btnReject) {
            var id2   = btnReject.dataset.id;
            var name2 = btnReject.dataset.name;
            var row2  = btnReject.closest('tr');
            var date2 = row2 ? (row2.cells[2] ? row2.cells[2].textContent.trim() : '') : '';
            openRejectModal(id2, name2, date2);
        }
    });

    function openApproveModal(id, name, date) {
        document.getElementById('approveId').value = id;
        document.getElementById('approveInfo').innerHTML =
            'Nhân viên: <strong>' + name + '</strong><br>Ngày: <strong>' + date + '</strong><br>' +
            'Trạng thái chấm công sẽ được cập nhật thành <strong style="color:#16a34a">Đủ công</strong>.';
        document.getElementById('approveComment').value = '';
        document.getElementById('approveModal').classList.add('open');
        document.body.style.overflow = 'hidden';
    }

    function openRejectModal(id, name, date) {
        document.getElementById('rejectId').value = id;
        document.getElementById('rejectInfo').innerHTML =
            'Nhân viên: <strong>' + name + '</strong><br>Ngày: <strong>' + date + '</strong>';
        document.getElementById('rejectComment').value = '';
        document.getElementById('rejectModal').classList.add('open');
        document.body.style.overflow = 'hidden';
    }

    function closeModal(id) {
        document.getElementById(id).classList.remove('open');
        document.body.style.overflow = '';
    }

    // Đóng modal khi click vùng ngoài
    document.querySelectorAll('.modal-overlay').forEach(function(overlay) {
        overlay.addEventListener('click', function(e) {
            if (e.target === this) {
                this.classList.remove('open');
                document.body.style.overflow = '';
            }
        });
    });

    // Đóng bằng Escape
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            document.querySelectorAll('.modal-overlay.open').forEach(function(m) {
                m.classList.remove('open');
            });
            document.body.style.overflow = '';
        }
    });
</script>

</body>
</html>
