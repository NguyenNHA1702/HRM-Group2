<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Ứng viên | HRMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css">
    <style>
        .status-new          { color: #92400e; background: #fef3c7; padding: 3px 10px; border-radius: 99px; font-size: 12px; font-weight: 500; }
        .status-interviewing { color: #1e40af; background: #dbeafe; padding: 3px 10px; border-radius: 99px; font-size: 12px; font-weight: 500; }
        .status-offered      { color: #7c3aed; background: #ede9fe; padding: 3px 10px; border-radius: 99px; font-size: 12px; font-weight: 500; }
        .status-hired        { color: #166534; background: #dcfce7; padding: 3px 10px; border-radius: 99px; font-size: 12px; font-weight: 500; }
        .status-rejected     { color: #991b1b; background: #fee2e2; padding: 3px 10px; border-radius: 99px; font-size: 12px; font-weight: 500; }
        .toolbar { display: flex; gap: 10px; align-items: center; margin-bottom: 16px; flex-wrap: wrap; }
        .toolbar-search { flex: 1; min-width: 200px; position: relative; }
        .toolbar-search input, .toolbar select, .form-row input, .form-row select, .form-row textarea {
            width: 100%; padding: 8px 12px; border: 1px solid var(--border); border-radius: 8px;
            font-size: 13px; font-family: inherit; box-sizing: border-box;
        }
        .toolbar-search .icon-search { position: absolute; left: 10px; top: 50%; transform: translateY(-50%); color: var(--muted); pointer-events: none; }
        .toolbar-search input { padding-left: 36px; }
        .form-panel { background: var(--bg); border: 1px solid var(--border); border-radius: 10px; padding: 16px; margin-bottom: 16px; }
        .form-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 12px; margin-bottom: 12px; }
        .form-row label { display: block; font-size: 12px; color: var(--muted); margin-bottom: 4px; }
        .vacancy-banner { background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 10px; padding: 12px 16px; margin-bottom: 16px; }
        .vacancy-banner h3 { margin: 0 0 4px; font-size: 16px; }
        .vacancy-banner p { margin: 0; font-size: 13px; color: var(--muted); }
        .alert-msg { background: #eff6ff; border: 1px solid #bfdbfe; color: #1e40af; padding: 10px 14px; border-radius: 8px; margin-bottom: 16px; font-size: 13px; }
        .action-group { display: flex; gap: 6px; flex-wrap: wrap; }
    </style>
</head>
<body>

<div class="main-layout">
    <%@ include file="/WEB-INF/common/sidebar.jsp" %>

    <div class="content-area">
        <div class="page-header">
            <div>
                <h1>Hồ sơ ứng viên</h1>
                <div class="subtitle">NEW → INTERVIEWING → OFFERED → HIRED / REJECTED</div>
            </div>
            <a href="${pageContext.request.contextPath}/hr/vacancies" class="btn btn-secondary btn-sm">Vị trí tuyển dụng</a>
        </div>

        <c:if test="${not empty message}">
            <div class="alert-msg"><c:out value="${message}"/></div>
        </c:if>

        <c:if test="${not empty vacancy}">
            <div class="vacancy-banner">
                <h3>${vacancy.title}</h3>
                <p>${vacancy.departmentName}
                    <c:if test="${not empty vacancy.positionName}"> · ${vacancy.positionName}</c:if>
                    · Tiến độ: ${vacancy.hiredCount}/${vacancy.headcount} đã nhận việc
                    · <c:choose>
                        <c:when test="${vacancy.status eq 'OPEN'}">Đang mở</c:when>
                        <c:otherwise>Đã đóng</c:otherwise>
                    </c:choose>
                </p>
            </div>
        </c:if>

        <div class="card">
            <c:if test="${not empty openVacancies}">
                <div class="form-panel">
                    <h3 style="margin: 0 0 12px; font-size: 15px;">Thêm ứng viên mới</h3>
                    <form method="post" action="${pageContext.request.contextPath}/hr/candidates/action">
                        <input type="hidden" name="action" value="create"/>
                        <div class="form-row">
                            <div>
                                <label>Vị trí (OPEN) *</label>
                                <select name="vacancyId" required>
                                    <c:forEach items="${openVacancies}" var="v">
                                        <option value="${v.id}"
                                            <c:if test="${not empty vacancy and vacancy.id eq v.id}">selected</c:if>>
                                            ${v.title} — ${v.departmentName}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div>
                                <label>Họ tên *</label>
                                <input type="text" name="fullName" required/>
                            </div>
                            <div>
                                <label>Email</label>
                                <input type="email" name="email"/>
                            </div>
                            <div>
                                <label>Điện thoại</label>
                                <input type="text" name="phone"/>
                            </div>
                        </div>
                        <div class="form-row">
                            <div>
                                <label>Link CV</label>
                                <input type="text" name="resumeUrl" placeholder="https://..."/>
                            </div>
                            <div style="grid-column: span 2;">
                                <label>Ghi chú</label>
                                <textarea name="notes" rows="1"></textarea>
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary btn-sm">Thêm ứng viên (NEW)</button>
                    </form>
                </div>
            </c:if>

            <div class="toolbar">
                <div class="toolbar-search">
                    <span class="icon-search">&#9906;</span>
                    <input type="text" id="searchInput" placeholder="Tìm theo tên, email..." oninput="applyFilters()">
                </div>
                <select id="statusFilter" onchange="applyFilters()">
                    <option value="">Tất cả trạng thái</option>
                    <option value="NEW">Mới nhận</option>
                    <option value="INTERVIEWING">Đang phỏng vấn</option>
                    <option value="OFFERED">Đề nghị làm việc</option>
                    <option value="HIRED">Đã nhận việc</option>
                    <option value="REJECTED">Từ chối</option>
                </select>
            </div>

            <div class="table-wrap">
                <table id="candidateTable">
                    <thead>
                    <tr>
                        <th>Ứng viên</th>
                        <th>Liên hệ</th>
                        <c:if test="${empty vacancy}"><th>Vị trí</th></c:if>
                        <th>Trạng thái</th>
                        <th>Thao tác</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach items="${candidates}" var="c">
                        <tr data-name="${c.fullName}" data-email="${c.email}" data-status="${c.status}">
                            <td>
                                <strong>${c.fullName}</strong>
                                <c:if test="${not empty c.resumeUrl}">
                                    <br><a href="${c.resumeUrl}" target="_blank" style="font-size:12px;">Xem CV</a>
                                </c:if>
                            </td>
                            <td>
                                <c:if test="${not empty c.email}">${c.email}<br></c:if>
                                ${not empty c.phone ? c.phone : '—'}
                            </td>
                            <c:if test="${empty vacancy}">
                                <td>${c.vacancyTitle}<br><span style="font-size:12px;color:var(--muted)">${c.departmentName}</span></td>
                            </c:if>
                            <td>
                                <c:choose>
                                    <c:when test="${c.status eq 'NEW'}"><span class="status-new">Mới nhận</span></c:when>
                                    <c:when test="${c.status eq 'INTERVIEWING'}"><span class="status-interviewing">Đang PV</span></c:when>
                                    <c:when test="${c.status eq 'OFFERED'}"><span class="status-offered">Offer</span></c:when>
                                    <c:when test="${c.status eq 'HIRED'}"><span class="status-hired">Đã nhận việc</span></c:when>
                                    <c:otherwise><span class="status-rejected">Từ chối</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <form method="post" action="${pageContext.request.contextPath}/hr/candidates/action">
                                    <input type="hidden" name="id" value="${c.id}"/>
                                    <div class="action-group">
                                        <c:if test="${c.status eq 'NEW'}">
                                            <button name="action" value="interview" class="btn btn-primary btn-sm">Pass CV</button>
                                            <button name="action" value="reject" class="btn btn-danger btn-sm">Trượt CV</button>
                                        </c:if>
                                        <c:if test="${c.status eq 'INTERVIEWING'}">
                                            <button name="action" value="offer" class="btn btn-primary btn-sm">Đạt PV</button>
                                            <button name="action" value="reject" class="btn btn-danger btn-sm">Trượt PV</button>
                                        </c:if>
                                        <c:if test="${c.status eq 'OFFERED'}">
                                            <button name="action" value="hire" class="btn btn-success btn-sm">Đồng ý Offer</button>
                                            <button name="action" value="reject" class="btn btn-danger btn-sm">Từ chối Offer</button>
                                        </c:if>
                                    </div>
                                </form>
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
    const allRows = Array.from(document.querySelectorAll('#candidateTable tbody tr'));
    function applyFilters() {
        const keyword = document.getElementById('searchInput').value.trim().toLowerCase();
        const status = document.getElementById('statusFilter').value;
        allRows.forEach(row => {
            const name = (row.dataset.name || '').toLowerCase();
            const email = (row.dataset.email || '').toLowerCase();
            const rowStatus = row.dataset.status || '';
            const matchKeyword = !keyword || name.includes(keyword) || email.includes(keyword);
            const matchStatus = !status || rowStatus === status;
            row.style.display = (matchKeyword && matchStatus) ? '' : 'none';
        });
    }
</script>
</body>
</html>
