<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <title>Cấu Hình Phụ Cấp Theo Chức Vụ | HRMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css" />
    <style>
        .page-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:24px; border-bottom:1px solid #e2e8f0; padding-bottom:16px; }
        .page-title { font-size:22px; font-weight:700; color:var(--text); margin:0; }
        .page-subtitle { font-size:13px; color:#64748b; margin-top:4px; }
        .btn { padding:10px 18px; border-radius:8px; font-weight:600; cursor:pointer; text-decoration:none; display:inline-flex; align-items:center; gap:8px; border:none; font-size:14px; }
        .btn-primary { background:#4f46e5; color:#fff; }
        .btn-outline { background:transparent; border:1px solid #cbd5e1; color:#475569; }
        .btn-sm { padding:6px 12px; font-size:13px; }

        .alert { padding:12px 16px; border-radius:8px; margin-bottom:16px; font-size:14px; }
        .alert-success { background:#d1fae5; color:#065f46; border:1px solid #6ee7b7; }

        .pos-grid { display:grid; grid-template-columns:repeat(auto-fill, minmax(400px, 1fr)); gap:16px; }
        .pos-card { background:#fff; border:1px solid #e2e8f0; border-radius:12px; padding:20px; }
        .pos-card .pos-name { font-size:16px; font-weight:700; color:#0f172a; margin-bottom:4px; }
        .pos-card .pos-code { font-size:12px; color:#64748b; margin-bottom:12px; }

        .allowance-list { list-style:none; padding:0; margin:0 0 12px 0; }
        .allowance-list li { padding:6px 0; display:flex; justify-content:space-between; border-bottom:1px solid #f1f5f9; font-size:14px; }
        .allowance-list .name { color:#334155; }
        .allowance-list .amount { font-weight:600; color:#059669; font-family:'Roboto Mono',monospace; }
        .no-allowance { color:#94a3b8; font-size:13px; font-style:italic; margin-bottom:12px; }

        /* Modal */
        .modal-overlay { display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,.5); z-index:1000; align-items:center; justify-content:center; }
        .modal-overlay.active { display:flex; }
        .modal { background:#fff; border-radius:16px; padding:24px; width:500px; max-width:90vw; max-height:80vh; overflow-y:auto; }
        .modal h3 { margin:0 0 16px 0; font-size:18px; }
        .modal .checkbox-list { list-style:none; padding:0; }
        .modal .checkbox-list li { padding:8px 0; border-bottom:1px solid #f1f5f9; display:flex; align-items:center; gap:8px; }
        .modal .checkbox-list label { cursor:pointer; flex:1; display:flex; justify-content:space-between; }
        .modal-actions { display:flex; gap:8px; justify-content:flex-end; margin-top:16px; }
    </style>
</head>
<body>
<div class="main-layout">
    <jsp:include page="/WEB-INF/common/sidebar.jsp" />
    <main class="content-area">

            <c:if test="${param.success == 'saved'}">
                <div class="alert alert-success"><i class="fas fa-check-circle"></i> Lưu cấu hình phụ cấp thành công!</div>
            </c:if>

            <div class="page-header">
                <div>
                    <h1 class="page-title"><i class="fas fa-cog"></i> Cấu Hình Phụ Cấp Theo Chức Vụ</h1>
                    <p class="page-subtitle">Gán các loại phụ cấp cho từng chức vụ (position). Khi tính lương, hệ thống sẽ lấy phụ cấp theo chức vụ của nhân viên.</p>
                </div>
                <a href="${pageContext.request.contextPath}/admin/payrolls" class="btn btn-outline btn-sm">
                    <i class="fas fa-arrow-left"></i> Quay lại
                </a>
            </div>

            <div class="pos-grid">
                <c:forEach var="entry" items="${positionsWithAllowances}">
                    <c:set var="pos" value="${entry.key}" />
                    <c:set var="allowances" value="${entry.value}" />
                    <div class="pos-card">
                        <div class="pos-name"><i class="fas fa-user-tag"></i> ${pos.name}</div>
                        <div class="pos-code">${pos.code}</div>

                        <c:choose>
                            <c:when test="${empty allowances}">
                                <div class="no-allowance">Chưa gán phụ cấp nào</div>
                            </c:when>
                            <c:otherwise>
                                <ul class="allowance-list">
                                    <c:set var="total" value="0" />
                                    <c:forEach var="at" items="${allowances}">
                                        <c:set var="total" value="${total + at.amount}" />
                                        <li>
                                            <span class="name">${at.name}</span>
                                            <span class="amount"><fmt:formatNumber value="${at.amount}" pattern="#,##0" /> đ</span>
                                        </li>
                                    </c:forEach>
                                </ul>
                                <div style="text-align:right; font-weight:700; color:#0f172a; font-size:15px;">
                                    Tổng: <fmt:formatNumber value="${total}" pattern="#,##0" /> đ
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <button class="btn btn-sm btn-primary" style="margin-top:12px;"
                                onclick="openEditModal(${pos.id}, '${pos.name}')">
                            <i class="fas fa-edit"></i> Chỉnh sửa
                        </button>
                    </div>
                </c:forEach>
            </div>

        </div>
    </main>
</div>

<!-- Edit Modal -->
<div id="editModal" class="modal-overlay">
    <div class="modal">
        <h3 id="modalTitle">Chỉnh sửa phụ cấp</h3>
        <form id="editForm" action="${pageContext.request.contextPath}/admin/position-allowances" method="post">
            <input type="hidden" id="modalPositionId" name="positionId" />
            <ul class="checkbox-list">
                <c:forEach var="at" items="${allAllowanceTypes}">
                    <li>
                        <input type="checkbox" name="allowanceTypeIds" value="${at.id}" id="at_${at.id}" class="at-checkbox" data-at-id="${at.id}" />
                        <label for="at_${at.id}">
                            <span>${at.name} (${at.code})</span>
                            <span style="font-weight:600; color:#059669;"><fmt:formatNumber value="${at.amount}" pattern="#,##0" /> đ</span>
                        </label>
                    </li>
                </c:forEach>
            </ul>
            <div class="modal-actions">
                <button type="button" class="btn btn-outline btn-sm" onclick="closeEditModal()">Hủy</button>
                <button type="submit" class="btn btn-primary btn-sm"><i class="fas fa-save"></i> Lưu</button>
            </div>
        </form>
    </div>
</div>

<script>
// Store current allowances per position from server data
var positionAllowances = {};
<c:forEach var="entry" items="${positionsWithAllowances}">
    <c:set var="pos" value="${entry.key}" />
    positionAllowances[${pos.id}] = [<c:forEach var="at" items="${entry.value}" varStatus="s">${at.id}<c:if test="${!s.last}">,</c:if></c:forEach>];
</c:forEach>

function openEditModal(posId, posName) {
    document.getElementById('modalTitle').textContent = 'Phụ cấp: ' + posName;
    document.getElementById('modalPositionId').value = posId;
    // Reset all checkboxes
    document.querySelectorAll('.at-checkbox').forEach(function(cb) { cb.checked = false; });
    // Check current ones
    var current = positionAllowances[posId] || [];
    current.forEach(function(atId) {
        var el = document.getElementById('at_' + atId);
        if (el) el.checked = true;
    });
    document.getElementById('editModal').classList.add('active');
}
function closeEditModal() {
    document.getElementById('editModal').classList.remove('active');
}
document.getElementById('editModal').addEventListener('click', function(e) {
    if (e.target === this) closeEditModal();
});
</script>
</body>
</html>
