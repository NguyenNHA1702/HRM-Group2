<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Nghỉ phép | HRMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css">
    <style>
        .modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(15, 23, 42, 0.45);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }
        .modal-overlay.open { display: flex; }

        .modal {
            background: var(--white);
            border-radius: var(--radius);
            box-shadow: 0 20px 60px rgba(0,0,0,.18);
            padding: 32px;
            width: 100%;
            max-width: 480px;
            animation: modalIn .18s ease;
        }
        @keyframes modalIn {
            from { opacity: 0; transform: translateY(-12px) scale(.97); }
            to   { opacity: 1; transform: none; }
        }

        .modal-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 24px;
        }
        .modal-header h2 { font-size: 18px; font-weight: 700; color: var(--text); }
        .modal-close {
            background: none; border: none; cursor: pointer;
            color: var(--muted); font-size: 22px; line-height: 1;
            padding: 2px 6px; border-radius: 6px; transition: background .15s;
        }
        .modal-close:hover { background: var(--bg); color: var(--text); }

        .form-group { margin-bottom: 16px; }
        .form-group label {
            display: block; font-weight: 500; margin-bottom: 6px;
            color: var(--text); font-size: 13px;
        }
        .form-control {
            width: 100%; padding: 9px 12px;
            border: 1px solid var(--border); border-radius: 8px;
            font-size: 14px; font-family: inherit; color: var(--text);
            background: var(--white); transition: border-color .15s, box-shadow .15s;
        }
        .form-control:focus {
            outline: none; border-color: var(--brand);
            box-shadow: 0 0 0 3px rgba(79,70,229,.12);
        }
        textarea.form-control { resize: vertical; }

        .modal-footer {
            display: flex; gap: 10px;
            justify-content: flex-end; margin-top: 24px;
        }

        .alert { padding: 10px 14px; border-radius: 8px; font-size: 13px; margin-bottom: 20px; }
        .alert-success { background: var(--green-light); color: #166534; }
        .alert-error   { background: var(--red-light);   color: #991b1b; }

        /* ── Toolbar search + filter ── */
        .toolbar {
            display: flex;
            gap: 10px;
            align-items: center;
            margin-bottom: 16px;
            flex-wrap: wrap;
        }
        .toolbar-search {
            flex: 1;
            min-width: 180px;
            position: relative;
        }
        .toolbar-search input {
            width: 100%;
            padding: 8px 12px 8px 36px;
            border: 1px solid var(--border);
            border-radius: 8px;
            font-size: 13px;
            font-family: inherit;
            color: var(--text);
            background: var(--white);
            box-sizing: border-box;
            transition: border-color .15s, box-shadow .15s;
        }
        .toolbar-search input:focus {
            outline: none; border-color: var(--brand);
            box-shadow: 0 0 0 3px rgba(79,70,229,.12);
        }
        .toolbar-search .icon-search {
            position: absolute; left: 10px; top: 50%;
            transform: translateY(-50%);
            color: var(--muted); font-size: 15px; pointer-events: none;
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
            outline: none; border-color: var(--brand);
            box-shadow: 0 0 0 3px rgba(79,70,229,.12);
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
        .pagination-info {
            font-size: 13px;
            color: var(--muted);
        }
        .pagination-buttons {
            display: flex;
            gap: 4px;
            align-items: center;
        }
        .page-btn {
            min-width: 32px;
            height: 32px;
            padding: 0 8px;
            border: 1px solid var(--border);
            border-radius: 6px;
            background: var(--white);
            color: var(--text);
            font-size: 13px;
            cursor: pointer;
            transition: background .15s, border-color .15s;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }
        .page-btn:hover:not(:disabled) {
            background: var(--bg);
            border-color: var(--brand);
        }
        .page-btn.active {
            background: var(--brand);
            color: #fff;
            border-color: var(--brand);
            font-weight: 600;
        }
        .page-btn:disabled {
            opacity: 0.4;
            cursor: not-allowed;
        }
    </style>
</head>
<body>

<div class="main-layout">

    <%@ include file="/WEB-INF/common/sidebar.jsp" %>

    <div class="content-area">

        <div class="page-header">
            <div>
                <h1>Đơn nghỉ phép</h1>
                <div class="subtitle">Danh sách đơn nghỉ phép của bạn</div>
            </div>
            <button class="btn btn-primary" onclick="openModal()">+ Tạo đơn</button>
        </div>

        <%-- Flash message --%>
        <c:if test="${not empty sessionScope.successMsg}">
            <div class="alert alert-success">${sessionScope.successMsg}</div>
            <c:remove var="successMsg" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.errorMsg}">
            <div class="alert alert-error">${sessionScope.errorMsg}</div>
            <c:remove var="errorMsg" scope="session"/>
        </c:if>

        <div class="card">
            <div class="card-header">
                <div class="card-title">Danh sách đơn</div>
            </div>

            <%-- Toolbar: search + filter trạng thái --%>
            <div class="toolbar">
                <div class="toolbar-search">
                    <span class="icon-search">&#9906;</span>
                    <input type="text" id="searchInput"
                           placeholder="Tìm theo loại nghỉ..."
                           oninput="applyFilters()">
                </div>
                <select id="statusFilter" onchange="applyFilters()">
                    <option value="">Tất cả trạng thái</option>
                    <option value="APPROVED">Đã duyệt</option>
                    <option value="PENDING">Chờ duyệt</option>
                    <option value="REJECTED">Từ chối</option>
                    <option value="CANCELLED">Đã hủy</option>
                </select>
            </div>

            <div class="table-wrap">
                <table id="leaveTable">
                    <thead>
                    <tr>
                        <th>Loại nghỉ</th>
                        <th>Từ ngày</th>
                        <th>Đến ngày</th>
                        <th>Số ngày</th>
                        <th>Trạng thái</th>
                        <th></th>
                    </tr>
                    </thead>
                    <tbody id="tableBody">
                    <c:forEach items="${requests}" var="r">
                        <tr data-leave-type="${r.leaveTypeName}"
                            data-status="${r.status}">
                            <td>${r.leaveTypeName}</td>
                            <td>${r.startDate}</td>
                            <td>${r.endDate}</td>
                            <td>${r.totalDays}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${r.status eq 'APPROVED'}">
                                        <span class="badge badge-green">Đã duyệt</span>
                                    </c:when>
                                    <c:when test="${r.status eq 'REJECTED'}">
                                        <span class="badge badge-red">Từ chối</span>
                                    </c:when>
                                    <c:when test="${r.status eq 'PENDING'}">
                                        <span class="badge badge-orange">Chờ duyệt</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-gray">Đã hủy</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:if test="${r.status eq 'PENDING'}">
                                    <form method="post"
                                          action="${pageContext.request.contextPath}/nghi-phep/cancel">
                                        <input type="hidden" name="id" value="${r.id}">
                                        <button class="btn btn-danger btn-sm">Hủy</button>
                                    </form>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>

                <div id="emptyState" class="empty-state" style="display:none;">
                    Không tìm thấy đơn nào phù hợp.
                </div>
            </div>

            <%-- Pagination --%>
            <div class="pagination">
                <div class="pagination-info" id="paginationInfo"></div>
                <div class="pagination-buttons" id="paginationButtons"></div>
            </div>

        </div>
    </div>
</div>

<%-- MODAL TẠO ĐƠN --%>
<div class="modal-overlay" id="createLeaveModal" onclick="handleOverlayClick(event)">
    <div class="modal">
        <div class="modal-header">
            <h2>Tạo đơn nghỉ phép</h2>
            <button class="modal-close" onclick="closeModal()" aria-label="Đóng">&#x2715;</button>
        </div>
        <form method="post" action="${pageContext.request.contextPath}/nghi-phep/create">
            <div class="form-group">
                <label for="leaveTypeId">Loại nghỉ</label>
                <select name="leaveTypeId" id="leaveTypeId" class="form-control">
                    <c:forEach items="${leaveTypes}" var="t">
                        <option value="${t.id}">${t.name}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="form-group">
                <label for="startDate">Từ ngày</label>
                <input type="date" name="startDate" id="startDate" class="form-control" required>
            </div>
            <div class="form-group">
                <label for="endDate">Đến ngày</label>
                <input type="date" name="endDate" id="endDate" class="form-control" required>
            </div>
            <div class="form-group">
                <label for="reason">Lý do</label>
                <textarea name="reason" id="reason" rows="4" class="form-control"
                          placeholder="Nhập lý do nghỉ phép..."></textarea>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeModal()">Hủy bỏ</button>
                <button type="submit" class="btn btn-primary">Gửi đơn</button>
            </div>
        </form>
    </div>
</div>

<script>
    /* ── Cấu hình ── */
    const PAGE_SIZE = 10;

    /* ── State ── */
    let currentPage = 1;
    let filteredRows = [];

    /* ── Lấy tất cả rows từ tbody ── */
    const allRows = Array.from(document.querySelectorAll('#tableBody tr'));

    /* ── Áp dụng filter + render ── */
    function applyFilters() {
        const keyword = document.getElementById('searchInput').value.trim().toLowerCase();
        const status  = document.getElementById('statusFilter').value;

        filteredRows = allRows.filter(row => {
            const leaveType = (row.dataset.leaveType || '').toLowerCase();
            const rowStatus = (row.dataset.status || '');

            const matchKeyword = !keyword || leaveType.includes(keyword);
            const matchStatus  = !status  || rowStatus === status;

            return matchKeyword && matchStatus;
        });

        currentPage = 1;
        renderPage();
    }

    /* ── Render trang hiện tại ── */
    function renderPage() {
        const total     = filteredRows.length;
        const totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE));
        if (currentPage > totalPages) currentPage = totalPages;

        const start = (currentPage - 1) * PAGE_SIZE;
        const end   = Math.min(start + PAGE_SIZE, total);

        /* Ẩn tất cả rows, hiện rows của trang */
        allRows.forEach(r => r.style.display = 'none');
        filteredRows.forEach((r, i) => {
            r.style.display = (i >= start && i < end) ? '' : 'none';
        });

        /* Empty state */
        document.getElementById('emptyState').style.display = total === 0 ? 'block' : 'none';
        document.getElementById('leaveTable').style.display  = total === 0 ? 'none'  : '';

        /* Pagination info */
        document.getElementById('paginationInfo').textContent =
            total === 0
                ? 'Không có kết quả'
                : 'Hiển thị ' + (start + 1) + '–' + end + ' / ' + total + ' đơn';

        /* Pagination buttons */
        renderPaginationButtons(totalPages);
    }

    /* ── Render nút phân trang ── */
    function renderPaginationButtons(totalPages) {
        const container = document.getElementById('paginationButtons');
        container.innerHTML = '';

        /* Nút Trước */
        const prevBtn = makeBtn('‹', currentPage === 1, () => goToPage(currentPage - 1));
        container.appendChild(prevBtn);

        /* Số trang — hiện tối đa 5 nút, có dấu "…" */
        const pages = getPageRange(currentPage, totalPages);
        pages.forEach(p => {
            if (p === '...') {
                const span = document.createElement('span');
                span.textContent = '…';
                span.style.cssText = 'padding: 0 4px; color: var(--muted); font-size:13px;';
                container.appendChild(span);
            } else {
                const btn = makeBtn(p, false, () => goToPage(p));
                if (p === currentPage) btn.classList.add('active');
                container.appendChild(btn);
            }
        });

        /* Nút Sau */
        const nextBtn = makeBtn('›', currentPage === totalPages, () => goToPage(currentPage + 1));
        container.appendChild(nextBtn);
    }

    function makeBtn(label, disabled, onClick) {
        const btn = document.createElement('button');
        btn.className = 'page-btn';
        btn.textContent = label;
        btn.disabled = disabled;
        if (!disabled) btn.addEventListener('click', onClick);
        return btn;
    }

    function goToPage(page) {
        currentPage = page;
        renderPage();
    }

    /* Tính dải số trang hiển thị (tối đa 5, có "...") */
    function getPageRange(current, total) {
        if (total <= 7) return Array.from({length: total}, (_, i) => i + 1);

        const pages = [];
        if (current <= 4) {
            for (let i = 1; i <= 5; i++) pages.push(i);
            pages.push('...', total);
        } else if (current >= total - 3) {
            pages.push(1, '...');
            for (let i = total - 4; i <= total; i++) pages.push(i);
        } else {
            pages.push(1, '...', current - 1, current, current + 1, '...', total);
        }
        return pages;
    }

    /* ── Khởi tạo ── */
    applyFilters();

    /* ── Modal ── */
    function openModal() {
        document.getElementById('createLeaveModal').classList.add('open');
        document.body.style.overflow = 'hidden';
    }
    function closeModal() {
        document.getElementById('createLeaveModal').classList.remove('open');
        document.body.style.overflow = '';
    }
    function handleOverlayClick(e) {
        if (e.target === document.getElementById('createLeaveModal')) closeModal();
    }
    document.addEventListener('keydown', e => { if (e.key === 'Escape') closeModal(); });

    <c:if test="${not empty sessionScope.openModal}">
    openModal();
    </c:if>
</script>

</body>
</html>