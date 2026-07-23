<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Duyệt nghỉ phép | HRMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css">
    <style>
        .status-pending  { color: #92400e; background: #fef3c7; padding: 3px 10px; border-radius: 99px; font-size: 12px; font-weight: 500; }
        .status-approved { color: #166534; background: #dcfce7; padding: 3px 10px; border-radius: 99px; font-size: 12px; font-weight: 500; }
        .status-rejected { color: #991b1b; background: #fee2e2; padding: 3px 10px; border-radius: 99px; font-size: 12px; font-weight: 500; }
        .status-cancelled{ color: #374151; background: #f3f4f6; padding: 3px 10px; border-radius: 99px; font-size: 12px; font-weight: 500; }

        .action-group { display: flex; gap: 8px; }

        /* ── Toolbar ── */
        .toolbar {
            display: flex;
            gap: 10px;
            align-items: center;
            margin-bottom: 16px;
            flex-wrap: wrap;
        }
        .toolbar-search {
            flex: 1;
            min-width: 200px;
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
            outline: none;
            border-color: var(--brand);
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
            outline: none;
            border-color: var(--brand);
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
        .pagination-info { font-size: 13px; color: var(--muted); }
        .pagination-buttons { display: flex; gap: 4px; align-items: center; }
        .page-btn {
            min-width: 32px; height: 32px; padding: 0 8px;
            border: 1px solid var(--border); border-radius: 6px;
            background: var(--white); color: var(--text);
            font-size: 13px; cursor: pointer;
            transition: background .15s, border-color .15s;
            display: inline-flex; align-items: center; justify-content: center;
        }
        .page-btn:hover:not(:disabled) { background: var(--bg); border-color: var(--brand); }
        .page-btn.active { background: var(--brand); color: #fff; border-color: var(--brand); font-weight: 600; }
        .page-btn:disabled { opacity: 0.4; cursor: not-allowed; }
    </style>
</head>
<body>

<div class="main-layout">

    <%@ include file="/WEB-INF/common/sidebar.jsp" %>

    <div class="content-area">

        <div class="page-header">
            <div>
                <h1>Duyệt nghỉ phép</h1>
                <div class="subtitle">Quản lý đơn nghỉ phép của nhân viên</div>
            </div>
        </div>

        <div class="card">

            <%-- Toolbar --%>
            <div class="toolbar">
                <div class="toolbar-search">
                    <span class="icon-search">&#9906;</span>
                    <input type="text" id="searchInput"
                           placeholder="Tìm nhân viên hoặc phòng ban..."
                           oninput="applyFilters()">
                </div>
                <select id="statusFilter" onchange="applyFilters()">
                    <option value="">Tất cả trạng thái</option>
                    <option value="PENDING">Chờ duyệt</option>
                    <option value="APPROVED">Đã duyệt</option>
                    <option value="REJECTED">Từ chối</option>
                    <option value="CANCELLED">Đã hủy</option>
                </select>
            </div>

            <div class="table-wrap">
                <table id="leaveTable">
                    <thead>
                    <tr>
                        <th>Nhân viên</th>
                        <th>Phòng ban</th>
                        <th>Loại nghỉ</th>
                        <th>Số ngày</th>
                        <th>Trạng thái</th>
                        <th>Thao tác</th>
                    </tr>
                    </thead>

                    <tbody id="tableBody">
                    <c:forEach items="${requests}" var="r">
                        <tr data-employee="${r.employeeName}"
                            data-department="${r.departmentName}"
                            data-status="${r.status}">
                            <td>${r.employeeName}</td>
                            <td>${r.departmentName}</td>
                            <td>${r.leaveTypeName}</td>
                            <td>${r.totalDays}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${r.status eq 'APPROVED'}">
                                        <span class="status-approved">Đã duyệt</span>
                                    </c:when>
                                    <c:when test="${r.status eq 'REJECTED'}">
                                        <span class="status-rejected">Từ chối</span>
                                    </c:when>
                                    <c:when test="${r.status eq 'PENDING' || r.status.startsWith('PENDING')}">
                                        <span class="status-pending">Chờ duyệt</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="status-cancelled">Đã hủy</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:if test="${r.status eq 'PENDING' || r.status.startsWith('PENDING')}">
                                    <form method="post"
                                          action="${pageContext.request.contextPath}/hr/leave-request/action">
                                        <input type="hidden" name="id" value="${r.id}">
                                        <div class="action-group">
                                            <button name="action" value="approve"
                                                    class="btn btn-success btn-sm">Duyệt</button>
                                            <button name="action" value="reject"
                                                    class="btn btn-danger btn-sm">Từ chối</button>
                                        </div>
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

<script>
    const PAGE_SIZE = 10;
    let currentPage = 1;
    let filteredRows = [];

    const allRows = Array.from(document.querySelectorAll('#tableBody tr'));

    function applyFilters() {
        const keyword = document.getElementById('searchInput').value.trim().toLowerCase();
        const status  = document.getElementById('statusFilter').value;

        filteredRows = allRows.filter(row => {
            const employee   = (row.dataset.employee   || '').toLowerCase();
            const department = (row.dataset.department || '').toLowerCase();
            const rowStatus  = (row.dataset.status     || '');

            const matchKeyword = !keyword || employee.includes(keyword) || department.includes(keyword);
            const matchStatus  = !status  || rowStatus === status || (status === 'PENDING' && rowStatus.startsWith('PENDING'));

            return matchKeyword && matchStatus;
        });

        currentPage = 1;
        renderPage();
    }

    function renderPage() {
        const total      = filteredRows.length;
        const totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE));
        if (currentPage > totalPages) currentPage = totalPages;

        const start = (currentPage - 1) * PAGE_SIZE;
        const end   = Math.min(start + PAGE_SIZE, total);

        allRows.forEach(r => r.style.display = 'none');
        filteredRows.forEach((r, i) => {
            r.style.display = (i >= start && i < end) ? '' : 'none';
        });

        document.getElementById('emptyState').style.display = total === 0 ? 'block' : 'none';
        document.getElementById('leaveTable').style.display  = total === 0 ? 'none'  : '';

        document.getElementById('paginationInfo').textContent =
            total === 0
                ? 'Không có kết quả'
                : 'Hiển thị ' + (start + 1) + '–' + end + ' / ' + total + ' đơn';

        renderPaginationButtons(totalPages);
    }

    function renderPaginationButtons(totalPages) {
        const container = document.getElementById('paginationButtons');
        container.innerHTML = '';

        container.appendChild(makeBtn('‹', currentPage === 1, () => goToPage(currentPage - 1)));

        getPageRange(currentPage, totalPages).forEach(p => {
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

        container.appendChild(makeBtn('›', currentPage === totalPages, () => goToPage(currentPage + 1)));
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

    function getPageRange(current, total) {
        if (total <= 7) return Array.from({length: total}, (_, i) => i + 1);
        if (current <= 4) return [...Array.from({length: 5}, (_, i) => i + 1), '...', total];
        if (current >= total - 3) return [1, '...', ...Array.from({length: 5}, (_, i) => total - 4 + i)];
        return [1, '...', current - 1, current, current + 1, '...', total];
    }

    applyFilters();
</script>

</body>
</html>