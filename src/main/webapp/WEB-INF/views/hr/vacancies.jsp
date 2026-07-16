<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Vị trí tuyển dụng | HRMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css">
    <style>
        .status-open   { color: #166534; background: #dcfce7; padding: 3px 10px; border-radius: 99px; font-size: 12px; font-weight: 500; }
        .status-closed { color: #374151; background: #f3f4f6; padding: 3px 10px; border-radius: 99px; font-size: 12px; font-weight: 500; }
        .toolbar { display: flex; gap: 10px; align-items: center; margin-bottom: 16px; flex-wrap: wrap; }
        .toolbar-search { flex: 1; min-width: 200px; position: relative; }
        .toolbar-search input, .toolbar select, .form-row input, .form-row select, .form-row textarea {
            width: 100%; padding: 8px 12px; border: 1px solid var(--border); border-radius: 8px;
            font-size: 13px; font-family: inherit; box-sizing: border-box;
        }
        .toolbar-search .icon-search { position: absolute; left: 10px; top: 50%; transform: translateY(-50%); color: var(--muted); pointer-events: none; }
        .toolbar-search input { padding-left: 36px; }
        .form-panel { background: var(--bg); border: 1px solid var(--border); border-radius: 10px; padding: 16px; margin-bottom: 16px; }
        .form-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; margin-bottom: 12px; }
        .form-row label { display: block; font-size: 12px; color: var(--muted); margin-bottom: 4px; }
        .progress-text { font-size: 12px; color: var(--muted); }
        .alert-msg { background: #eff6ff; border: 1px solid #bfdbfe; color: #1e40af; padding: 10px 14px; border-radius: 8px; margin-bottom: 16px; font-size: 13px; }
        .action-group { display: flex; gap: 8px; flex-wrap: wrap; }
    </style>
</head>
<body>

<div class="main-layout">
    <%@ include file="/WEB-INF/common/sidebar.jsp" %>

    <div class="content-area">
        <div class="page-header">
            <div>
                <h1>Vị trí tuyển dụng</h1>
                <div class="subtitle">Quản lý chiến dịch tuyển dụng — OPEN / CLOSED</div>
            </div>
            <a href="${pageContext.request.contextPath}/hr/candidates" class="btn btn-secondary btn-sm">Xem ứng viên</a>
        </div>

        <c:if test="${not empty message}">
            <div class="alert-msg"><c:out value="${message}"/></div>
        </c:if>

        <div class="card">
            <div class="form-panel">
                <h3 style="margin: 0 0 12px; font-size: 15px;">Tạo vị trí mới</h3>
                <form method="post" action="${pageContext.request.contextPath}/hr/vacancies/action">
                    <input type="hidden" name="action" value="create"/>
                    <div class="form-row">
                        <div>
                            <label>Tên vị trí *</label>
                            <input type="text" name="title" required placeholder="VD: Developer Java"/>
                        </div>
                        <div>
                            <label>Phòng ban *</label>
                            <select name="departmentId" required>
                                <option value="">-- Chọn phòng ban --</option>
                                <c:forEach items="${departments}" var="d">
                                    <c:if test="${d.isActive eq 1}">
                                        <option value="${d.id}">${d.name}</option>
                                    </c:if>
                                </c:forEach>
                            </select>
                        </div>
                        <div>
                            <label>Chức danh</label>
                            <select name="positionId">
                                <option value="">-- Tùy chọn --</option>
                                <c:forEach items="${positions}" var="p">
                                    <option value="${p.id}">${p.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div>
                            <label>Số lượng tuyển *</label>
                            <input type="number" name="headcount" value="1" min="1" required/>
                        </div>
                    </div>
                    <div class="form-row" style="grid-template-columns: 1fr;">
                        <div>
                            <label>Mô tả</label>
                            <textarea name="description" rows="2" placeholder="Yêu cầu công việc..."></textarea>
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary btn-sm">Tạo vị trí (OPEN)</button>
                </form>
            </div>

            <div class="toolbar">
                <div class="toolbar-search">
                    <span class="icon-search">&#9906;</span>
                    <input type="text" id="searchInput" placeholder="Tìm theo tên vị trí, phòng ban..." oninput="applyFilters()">
                </div>
                <select id="statusFilter" onchange="applyFilters()">
                    <option value="">Tất cả trạng thái</option>
                    <option value="OPEN">Đang mở</option>
                    <option value="CLOSED">Đã đóng</option>
                </select>
            </div>

            <div class="table-wrap">
                <table id="vacancyTable">
                    <thead>
                    <tr>
                        <th>Vị trí</th>
                        <th>Phòng ban</th>
                        <th>Chức danh</th>
                        <th>Tiến độ</th>
                        <th>Trạng thái</th>
                        <th>Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach items="${vacancies}" var="v">
                        <tr data-title="${v.title}" data-department="${v.departmentName}" data-status="${v.status}">
                            <td><strong>${v.title}</strong></td>
                            <td>${v.departmentName}</td>
                            <td>${not empty v.positionName ? v.positionName : '—'}</td>
                            <td>
                                <span class="progress-text">${v.hiredCount} / ${v.headcount} đã nhận việc</span>
                                <br><span class="progress-text">${v.candidateCount} ứng viên</span>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${v.status eq 'OPEN'}">
                                        <span class="status-open">Đang mở</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="status-closed">Đã đóng</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div class="action-group">
                                    <a href="${pageContext.request.contextPath}/hr/candidates?vacancyId=${v.id}"
                                       class="btn btn-secondary btn-sm">Ứng viên</a>
                                    <c:if test="${v.status eq 'OPEN'}">
                                        <form method="post" action="${pageContext.request.contextPath}/hr/vacancies/action" style="display:inline;">
                                            <input type="hidden" name="action" value="close"/>
                                            <input type="hidden" name="id" value="${v.id}"/>
                                            <button type="submit" class="btn btn-danger btn-sm"
                                                    onclick="return confirm('Đóng vị trí này?')">Đóng</button>
                                        </form>
                                    </c:if>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script>
    const allRows = Array.from(document.querySelectorAll('#vacancyTable tbody tr'));
    function applyFilters() {
        const keyword = document.getElementById('searchInput').value.trim().toLowerCase();
        const status = document.getElementById('statusFilter').value;
        allRows.forEach(row => {
            const title = (row.dataset.title || '').toLowerCase();
            const dept = (row.dataset.department || '').toLowerCase();
            const rowStatus = row.dataset.status || '';
            const matchKeyword = !keyword || title.includes(keyword) || dept.includes(keyword);
            const matchStatus = !status || rowStatus === status;
            row.style.display = (matchKeyword && matchStatus) ? '' : 'none';
        });
    }
</script>
</body>
</html>
