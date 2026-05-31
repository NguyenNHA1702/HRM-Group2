<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Loại nghỉ phép | HRMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css">
    <style>
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
        .empty-state {
            text-align: center;
            padding: 40px 0;
            color: var(--muted);
            font-size: 14px;
        }
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
                <h1>Loại nghỉ phép</h1>
                <div class="subtitle">Danh sách các loại nghỉ phép trong hệ thống</div>
            </div>
        </div>

        <div class="card">

            <div class="toolbar">
                <div class="toolbar-search">
                    <span class="icon-search">&#9906;</span>
                    <input type="text" id="searchInput"
                           placeholder="Tìm theo mã hoặc tên..."
                           oninput="applyFilters()">
                </div>
                <select id="statusFilter" onchange="applyFilters()">
                    <option value="">Tất cả trạng thái</option>
                    <option value="active">Đang dùng</option>
                    <option value="inactive">Ngừng dùng</option>
                </select>
            </div>

            <div class="table-wrap">
                <table id="leaveTypeTable">
                    <thead>
                    <tr>
                        <th>Mã</th>
                        <th>Tên</th>
                        <th>Số ngày/năm</th>
                        <th>Hưởng lương</th>
                        <th>Trạng thái</th>
                    </tr>
                    </thead>
                    <tbody id="tableBody">
                    <c:forEach items="${leaveTypes}" var="t">
                        <tr data-code="${t.code}"
                            data-name="${t.name}"
                            data-active="${t.active}">
                            <td>${t.code}</td>
                            <td>${t.name}</td>
                            <td>${t.daysPerYear}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${t.paid}">
                                        <span class="badge badge-green">Có</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-gray">Không</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${t.active}">
                                        <span class="badge badge-green">Đang dùng</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-red">Ngừng dùng</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>

                <div id="emptyState" class="empty-state" style="display:none;">
                    Không tìm thấy loại nghỉ phép nào phù hợp.
                </div>
            </div>

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
            const code   = (row.dataset.code || '').toLowerCase();
            const name   = (row.dataset.name || '').toLowerCase();
            const active = row.dataset.active;

            const matchKeyword = !keyword || code.includes(keyword) || name.includes(keyword);
            const matchStatus  = !status
                || (status === 'active'   && active === 'true')
                || (status === 'inactive' && active === 'false');

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

        document.getElementById('emptyState').style.display     = total === 0 ? 'block' : 'none';
        document.getElementById('leaveTypeTable').style.display  = total === 0 ? 'none'  : '';

        document.getElementById('paginationInfo').textContent =
            total === 0
                ? 'Không có kết quả'
                : 'Hiển thị ' + (start + 1) + '–' + end + ' / ' + total + ' loại';

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

    function goToPage(page) { currentPage = page; renderPage(); }

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