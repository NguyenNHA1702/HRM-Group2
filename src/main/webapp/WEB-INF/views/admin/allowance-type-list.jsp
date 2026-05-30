<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Loại Phụ Cấp | HRMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css"/>
    <style>
        .modal-overlay { position:fixed; inset:0; background:rgba(15,23,42,.55); display:none; align-items:center; justify-content:center; z-index:1000; padding:20px; }
        .modal-overlay.open { display:flex; }
        .modal { background:#fff; border-radius:16px; padding:32px; width:500px; max-width:100%; box-shadow:0 24px 60px rgba(0,0,0,.18); }
        .modal-title { font-size:18px; font-weight:700; margin-bottom:22px; display:flex; align-items:center; gap:10px; color:var(--text); }
        .form-group { margin-bottom:16px; }
        .form-group label { display:block; font-size:13px; font-weight:600; color:var(--text); margin-bottom:6px; }
        .form-group input, .form-group textarea { width:100%; padding:10px 14px; border:1px solid var(--border); border-radius:9px; font-size:14px; font-family:inherit; transition:border-color .15s; }
        .form-group input:focus, .form-group textarea:focus { outline:none; border-color:var(--brand); box-shadow:0 0 0 3px rgba(79,70,229,.12); }
        .form-group textarea { resize:vertical; min-height:72px; }
        .form-hint { font-size:12px; color:var(--muted); margin-top:4px; }
        .modal-actions { display:flex; justify-content:flex-end; gap:10px; margin-top:24px; }
        .btn-cancel { padding:9px 18px; background:#f1f5f9; border:1px solid var(--border); border-radius:9px; cursor:pointer; font-size:13px; font-family:inherit; }
        .btn-cancel:hover { background:#e2e8f0; }
        .badge-green { background:var(--green-light); color:#15803d; }
        .badge-red   { background:var(--red-light);   color:#b91c1c; }
        .badge-purple { background:var(--purple-light); color:#7c3aed; }
        .action-btn { width:32px; height:32px; border:none; background:none; border-radius:7px; cursor:pointer; display:inline-flex; align-items:center; justify-content:center; transition:all .15s; }
        .action-btn:hover { background:var(--bg); }
        .action-btn.edit     { color:var(--blue); }
        .action-btn.deact    { color:var(--orange); }
        .action-btn.activate { color:var(--green); }
        .action-btn svg { width:16px; height:16px; fill:none; stroke:currentColor; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }
        .flash { display:flex; align-items:center; gap:10px; padding:14px 18px; border-radius:10px; margin-bottom:20px; font-size:13.5px; font-weight:500; }
        .flash.success { background:#dcfce7; color:#166534; border:1px solid #bbf7d0; }
        .flash.error   { background:#fee2e2; color:#b91c1c; border:1px solid #fecaca; }
        .actions { display:flex; gap:4px; }
        .code-badge { font-family:monospace; background:#f1f5f9; color:var(--brand); padding:3px 8px; border-radius:6px; font-size:12px; font-weight:700; letter-spacing:.5px; }
    </style>
</head>
<body>
<div class="main-layout">
    <jsp:include page="/WEB-INF/common/sidebar.jsp" />

    <main class="content-area">

        <%-- Flash messages --%>
        <c:if test="${not empty sessionScope.flash_success}">
            <div class="flash success">${sessionScope.flash_success}</div>
            <c:remove var="flash_success" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.flash_error}">
            <div class="flash error">${sessionScope.flash_error}</div>
            <c:remove var="flash_error" scope="session"/>
        </c:if>

        <%-- Page header --%>
        <div class="page-header">
            <div>
                <h1>Loại Phụ Cấp</h1>
                <p class="subtitle">Danh mục các loại phụ cấp áp dụng cho nhân viên</p>
            </div>
            <div>
                <button class="btn btn-primary" onclick="openModal('addModal')">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width:15px;height:15px;"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    Thêm loại phụ cấp
                </button>
            </div>
        </div>

        <%-- Stats --%>
        <div class="stats-grid mb-24">
            <div class="stat-card">
                <div>
                    <p class="stat-label">Tổng loại phụ cấp</p>
                    <p class="stat-value">${allowanceTypes.size()} loại</p>
                </div>
                <div class="stat-icon icon-purple">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
                </div>
            </div>
            <div class="stat-card">
                <div>
                    <p class="stat-label">Đang áp dụng</p>
                    <p class="stat-value">
                        <c:set var="activeCount" value="0"/>
                        <c:forEach var="t" items="${allowanceTypes}">
                            <c:if test="${t.active}"><c:set var="activeCount" value="${activeCount + 1}"/></c:if>
                        </c:forEach>
                        ${activeCount} loại
                    </p>
                </div>
                <div class="stat-icon icon-green">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
                </div>
            </div>
            <div class="stat-card">
                <div>
                    <p class="stat-label">Tổng phụ cấp/tháng</p>
                    <p class="stat-value" style="font-size:17px;">
                        <c:set var="totalAmount" value="0"/>
                        <c:forEach var="t" items="${allowanceTypes}">
                            <c:if test="${t.active}"><c:set var="totalAmount" value="${totalAmount + t.amount}"/></c:if>
                        </c:forEach>
                        <fmt:formatNumber value="${totalAmount}" type="number" maxFractionDigits="0"/> đ
                    </p>
                </div>
                <div class="stat-icon icon-orange">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
                </div>
            </div>
        </div>

        <%-- Table --%>
        <div class="card">
            <div class="card-header">
                <span class="card-title">Danh sách loại phụ cấp</span>
            </div>
            <div class="table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Mã phụ cấp</th>
                            <th>Tên loại phụ cấp</th>
                            <th>Mức tiền / tháng</th>
                            <th>Mô tả</th>
                            <th>Trạng thái</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty allowanceTypes}">
                                <tr><td colspan="7" style="text-align:center;padding:40px;color:var(--muted)">Chưa có dữ liệu</td></tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="t" items="${allowanceTypes}" varStatus="st">
                                    <tr>
                                        <td>${st.index + 1}</td>
                                        <td><span class="code-badge">${t.code}</span></td>
                                        <td style="font-weight:600">${t.name}</td>
                                        <td style="font-weight:600; color:var(--green)">
                                            <fmt:formatNumber value="${t.amount}" type="number" maxFractionDigits="0"/> VNĐ
                                        </td>
                                        <td style="color:var(--muted)">${t.description}</td>
                                        <td><span class="badge ${t.statusBadgeClass}">${t.statusLabel}</span></td>
                                        <td>
                                            <div class="actions">
                                                <button class="action-btn edit" title="Chỉnh sửa"
                                                    onclick="openEdit(${t.id},'${t.code}','${t.name}',${t.amount},'${t.description}')">
                                                    <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                                </button>
                                                <c:choose>
                                                    <c:when test="${t.active}">
                                                        <button class="action-btn deact" title="Vô hiệu hóa"
                                                            onclick="submitAction('${pageContext.request.contextPath}/admin/allowance-types','deactivate',${t.id})">
                                                            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
                                                        </button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button class="action-btn activate" title="Kích hoạt lại"
                                                            onclick="submitAction('${pageContext.request.contextPath}/admin/allowance-types','activate',${t.id})">
                                                            <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
                                                        </button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>

    </main>
</div>

<%-- ══ Modal Thêm ══ --%>
<div class="modal-overlay" id="addModal">
    <div class="modal">
        <div class="modal-title">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width:20px;height:20px;color:var(--brand)"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            Thêm loại phụ cấp mới
        </div>
        <form method="post" action="${pageContext.request.contextPath}/admin/allowance-types">
            <input type="hidden" name="action" value="add"/>
            <div class="form-group">
                <label>Mã phụ cấp <span style="color:red">*</span></label>
                <input type="text" name="code" placeholder="Ví dụ: LUNCH" style="text-transform:uppercase" required/>
                <p class="form-hint">Mã viết tắt bằng chữ IN HOA, không dấu, không khoảng trắng. Phải là duy nhất.</p>
            </div>
            <div class="form-group">
                <label>Tên loại phụ cấp <span style="color:red">*</span></label>
                <input type="text" name="name" placeholder="Ví dụ: Phụ cấp ăn trưa" required/>
            </div>
            <div class="form-group">
                <label>Mức tiền / tháng (VNĐ) <span style="color:red">*</span></label>
                <input type="number" name="amount" min="0" step="50000" placeholder="Ví dụ: 730000" required/>
            </div>
            <div class="form-group">
                <label>Mô tả</label>
                <textarea name="description" placeholder="Mô tả chi tiết về loại phụ cấp này..."></textarea>
            </div>
            <div class="modal-actions">
                <button type="button" class="btn-cancel" onclick="closeModal('addModal')">Hủy</button>
                <button type="submit" class="btn btn-primary">Thêm loại phụ cấp</button>
            </div>
        </form>
    </div>
</div>

<%-- ══ Modal Sửa ══ --%>
<div class="modal-overlay" id="editModal">
    <div class="modal">
        <div class="modal-title">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width:20px;height:20px;color:var(--brand)"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
            Chỉnh sửa loại phụ cấp
        </div>
        <form method="post" action="${pageContext.request.contextPath}/admin/allowance-types">
            <input type="hidden" name="action" value="update"/>
            <input type="hidden" name="id" id="edit_id"/>
            <div class="form-group">
                <label>Mã phụ cấp <span style="color:red">*</span></label>
                <input type="text" name="code" id="edit_code" style="text-transform:uppercase" required/>
            </div>
            <div class="form-group">
                <label>Tên loại phụ cấp <span style="color:red">*</span></label>
                <input type="text" name="name" id="edit_name" required/>
            </div>
            <div class="form-group">
                <label>Mức tiền / tháng (VNĐ) <span style="color:red">*</span></label>
                <input type="number" name="amount" id="edit_amount" min="0" step="50000" required/>
            </div>
            <div class="form-group">
                <label>Mô tả</label>
                <textarea name="description" id="edit_description"></textarea>
            </div>
            <div class="modal-actions">
                <button type="button" class="btn-cancel" onclick="closeModal('editModal')">Hủy</button>
                <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
            </div>
        </form>
    </div>
</div>

<form id="actionForm" method="post" action="" style="display:none">
    <input type="hidden" name="action" id="af_action"/>
    <input type="hidden" name="id"     id="af_id"/>
</form>

<script>
function openModal(id)  { document.getElementById(id).classList.add('open'); }
function closeModal(id) { document.getElementById(id).classList.remove('open'); }

function openEdit(id, code, name, amount, description) {
    document.getElementById('edit_id').value          = id;
    document.getElementById('edit_code').value        = code;
    document.getElementById('edit_name').value        = name;
    document.getElementById('edit_amount').value      = amount;
    document.getElementById('edit_description').value = description;
    openModal('editModal');
}

function submitAction(url, action, id) {
    if (action === 'deactivate' && !confirm('Bạn có chắc muốn vô hiệu hóa loại phụ cấp này không?')) return;
    var form = document.getElementById('actionForm');
    form.action = url;
    document.getElementById('af_action').value = action;
    document.getElementById('af_id').value     = id;
    form.submit();
}

document.querySelectorAll('.modal-overlay').forEach(function(overlay) {
    overlay.addEventListener('click', function(e) {
        if (e.target === overlay) overlay.classList.remove('open');
    });
});
</script>
</body>
</html>
