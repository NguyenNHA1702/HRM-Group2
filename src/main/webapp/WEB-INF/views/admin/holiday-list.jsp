<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Cấu hình Ngày Nghỉ Lễ | HRMS</title>
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
        .form-row { display:flex; gap:12px; }
        .form-row .form-group { flex:1; }
        .modal-actions { display:flex; justify-content:flex-end; gap:10px; margin-top:24px; }
        .btn-cancel { padding:9px 18px; background:#f1f5f9; border:1px solid var(--border); border-radius:9px; cursor:pointer; font-size:13px; font-family:inherit; }
        .btn-cancel:hover { background:#e2e8f0; }
        .badge-red   { background:var(--red-light);   color:#b91c1c; }
        .badge-purple { background:var(--purple-light); color:#7c3aed; }
        .action-btn { width:32px; height:32px; border:none; background:none; border-radius:7px; cursor:pointer; display:inline-flex; align-items:center; justify-content:center; transition:all .15s; }
        .action-btn:hover { background:var(--bg); }
        .action-btn.edit     { color:var(--blue); }
        .action-btn.delete   { color:var(--red); }
        .action-btn svg { width:16px; height:16px; fill:none; stroke:currentColor; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }
        .flash { display:flex; align-items:center; gap:10px; padding:14px 18px; border-radius:10px; margin-bottom:20px; font-size:13.5px; font-weight:500; }
        .flash.success { background:#dcfce7; color:#166534; border:1px solid #bbf7d0; }
        .flash.error   { background:#fee2e2; color:#b91c1c; border:1px solid #fecaca; }
        .actions { display:flex; gap:4px; }
        .coeff-badge { background:#faf5ff; color:#6b21a8; padding:3px 8px; border-radius:6px; font-size:12.5px; font-weight:700; border:1px solid #e9d5ff; }
        
        /* Toolbar and Filter styles */
        .toolbar { background:#fff; border-radius:12px; padding:16px 20px; margin-bottom:20px; border:1px solid var(--border); display:flex; flex-wrap:wrap; justify-content:space-between; align-items:center; gap:16px; }
        .filter-form { display:flex; flex-wrap:wrap; gap:12px; align-items:center; width:100%; }
        .search-box { position:relative; min-width:260px; flex:1; }
        .search-box input { width:100%; padding:9px 14px 9px 36px; border:1px solid var(--border); border-radius:8px; font-size:13.5px; outline:none; transition:border-color .15s; }
        .search-box input:focus { border-color:var(--brand); box-shadow:0 0 0 3px rgba(79,70,229,.1); }
        .search-box svg { position:absolute; left:12px; top:50%; transform:translateY(-50%); width:16px; height:16px; color:var(--muted); }
        .filter-select { padding:9px 14px; border:1px solid var(--border); border-radius:8px; font-size:13.5px; background-color:#fff; color:var(--text); outline:none; cursor:pointer; }
        .filter-select:focus { border-color:var(--brand); }
        .filter-btn-group { display:flex; gap:8px; }
        
        /* Pagination styles */
        .pagination-container { display:flex; justify-content:space-between; align-items:center; padding:16px 20px; border-top:1px solid var(--border); background:#fff; border-bottom-left-radius:12px; border-bottom-right-radius:12px; font-size:13.5px; color:var(--muted); }
        .pagination { display:flex; gap:6px; list-style:none; padding:0; margin:0; }
        .page-item a { display:flex; align-items:center; justify-content:center; min-width:32px; height:32px; padding:0 8px; border:1px solid var(--border); border-radius:6px; color:var(--text); text-decoration:none; transition:all .15s; font-weight:500; }
        .page-item.active a { background:var(--brand); color:#fff; border-color:var(--brand); }
        .page-item.disabled a { opacity:0.5; cursor:not-allowed; background:#f8fafc; pointer-events:none; }
        .page-item a:hover:not(.active) { background:#f1f5f9; border-color:#cbd5e1; }
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
                <h1>Khai báo Ngày Nghỉ Lễ</h1>
                <p class="subtitle">Định nghĩa danh sách các ngày nghỉ lễ tết và hệ số tính lương tương ứng</p>
            </div>
            <div>
                <button class="btn btn-primary" onclick="openModal('addModal')">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width:15px;height:15px;"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    Khai báo ngày lễ
                </button>
            </div>
        </div>

        <%-- Toolbar (Search, Sort, Paging controls) --%>
        <div class="toolbar">
            <form method="get" action="${pageContext.request.contextPath}/admin/holidays" class="filter-form" id="filterForm">
                <div class="search-box">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                    <input type="text" name="keyword" placeholder="Tìm theo tên lễ hoặc mô tả..." value="${keyword}"/>
                </div>
                
                <select name="year" class="filter-select" onchange="document.getElementById('filterForm').submit()">
                    <option value="">Lọc theo: Tất cả các năm</option>
                    <c:forEach var="y" items="${years}">
                        <option value="${y}" ${year == y.toString() ? 'selected' : ''}>Năm ${y}</option>
                    </c:forEach>
                </select>
                
                <select name="sortBy" class="filter-select" onchange="document.getElementById('filterForm').submit()">
                    <option value="start_date" ${sortBy == 'start_date' ? 'selected' : ''}>Sắp xếp: Ngày bắt đầu</option>
                    <option value="name" ${sortBy == 'name' ? 'selected' : ''}>Sắp xếp: Tên ngày lễ</option>
                    <option value="end_date" ${sortBy == 'end_date' ? 'selected' : ''}>Sắp xếp: Ngày kết thúc</option>
                    <option value="salary_coefficient" ${sortBy == 'salary_coefficient' ? 'selected' : ''}>Sắp xếp: Hệ số lương</option>
                </select>
                
                <select name="sortOrder" class="filter-select" onchange="document.getElementById('filterForm').submit()">
                    <option value="DESC" ${sortOrder == 'DESC' ? 'selected' : ''}>Thứ tự: Mới nhất / Giảm dần</option>
                    <option value="ASC" ${sortOrder == 'ASC' ? 'selected' : ''}>Thứ tự: Cũ nhất / Tăng dần</option>
                </select>
                
                <select name="pageSize" class="filter-select" onchange="document.getElementById('filterForm').submit()">
                    <option value="5" ${pageSize == 5 ? 'selected' : ''}>5 bản ghi / trang</option>
                    <option value="10" ${pageSize == 10 ? 'selected' : ''}>10 bản ghi / trang</option>
                    <option value="20" ${pageSize == 20 ? 'selected' : ''}>20 bản ghi / trang</option>
                    <option value="50" ${pageSize == 50 ? 'selected' : ''}>50 bản ghi / trang</option>
                </select>
                
                <div class="filter-btn-group">
                    <button type="submit" class="btn btn-primary" style="padding:9px 16px; border-radius:8px;">Lọc</button>
                    <c:if test="${not empty keyword || not empty year || sortBy != 'start_date' || sortOrder != 'DESC' || pageSize != 5}">
                        <a href="${pageContext.request.contextPath}/admin/holidays" class="btn btn-cancel" style="padding:9px 16px; border-radius:8px; text-decoration:none; display:inline-flex; align-items:center;">Xóa lọc</a>
                    </c:if>
                </div>
            </form>
        </div>

        <%-- Table --%>
        <div class="card">
            <div class="card-header">
                <span class="card-title">Danh sách ngày nghỉ lễ</span>
            </div>
            <div class="table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Tên ngày lễ</th>
                            <th>Ngày bắt đầu</th>
                            <th>Ngày kết thúc</th>
                            <th>Hệ số lương (OT)</th>
                            <th>Mô tả</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty holidays}">
                                <tr><td colspan="7" style="text-align:center;padding:40px;color:var(--muted)">Chưa có dữ liệu ngày nghỉ lễ</td></tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="h" items="${holidays}" varStatus="st">
                                    <tr>
                                        <td>${(page - 1) * pageSize + st.index + 1}</td>
                                        <td style="font-weight:600; color:var(--text)">${h.name}</td>
                                        <td><fmt:formatDate value="${h.startDate}" pattern="dd/MM/yyyy"/></td>
                                        <td><fmt:formatDate value="${h.endDate}" pattern="dd/MM/yyyy"/></td>
                                        <td><span class="coeff-badge">x ${h.salaryCoefficient}</span></td>
                                        <td style="color:var(--muted)">${h.description}</td>
                                        <td>
                                            <div class="actions">
                                                <button class="action-btn edit" title="Chỉnh sửa"
                                                    data-id="${h.id}"
                                                    data-name="${h.name}"
                                                    data-start="${h.startDate}"
                                                    data-end="${h.endDate}"
                                                    data-coeff="${h.salaryCoefficient}"
                                                    data-desc="${h.description}"
                                                    onclick="openEdit(this)">
                                                    <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                                </button>
                                                <button class="action-btn delete" title="Xóa"
                                                    onclick="submitDelete(${h.id}, '${h.name}')">
                                                    <svg viewBox="0 0 24 24"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/><line x1="10" y1="11" x2="10" y2="17"/><line x1="14" y1="11" x2="14" y2="17"/></svg>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
            
            <%-- Pagination controls --%>
            <div class="pagination-container">
                <div>
                    Hiển thị từ <c:choose><c:when test="${totalRecords == 0}">0</c:when><c:otherwise>${(page - 1) * pageSize + 1}</c:otherwise></c:choose> 
                    đến <c:choose><c:when test="${page * pageSize > totalRecords}">${totalRecords}</c:when><c:otherwise>${page * pageSize}</c:otherwise></c:choose> 
                    trên tổng số <strong>${totalRecords}</strong> bản ghi
                </div>
                <c:if test="${totalPages > 1}">
                    <ul class="pagination">
                        <%-- Previous Page --%>
                        <li class="page-item ${page == 1 ? 'disabled' : ''}">
                            <a href="${pageContext.request.contextPath}/admin/holidays?page=${page - 1}&keyword=${keyword}&year=${year}&sortBy=${sortBy}&sortOrder=${sortOrder}&pageSize=${pageSize}" title="Trang trước">&laquo;</a>
                        </li>
                        
                        <%-- Page Numbers --%>
                        <c:forEach var="i" begin="1" end="${totalPages}">
                            <li class="page-item ${page == i ? 'active' : ''}">
                                <a href="${pageContext.request.contextPath}/admin/holidays?page=${i}&keyword=${keyword}&year=${year}&sortBy=${sortBy}&sortOrder=${sortOrder}&pageSize=${pageSize}">${i}</a>
                            </li>
                        </c:forEach>
                        
                        <%-- Next Page --%>
                        <li class="page-item ${page == totalPages ? 'disabled' : ''}">
                            <a href="${pageContext.request.contextPath}/admin/holidays?page=${page + 1}&keyword=${keyword}&year=${year}&sortBy=${sortBy}&sortOrder=${sortOrder}&pageSize=${pageSize}" title="Trang sau">&raquo;</a>
                        </li>
                    </ul>
                </c:if>
            </div>
        </div>

    </main>
</div>

<%-- ══ Modal Thêm ══ --%>
<div class="modal-overlay" id="addModal">
    <div class="modal">
        <div class="modal-title">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width:20px;height:20px;color:var(--brand)"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            Khai báo ngày nghỉ lễ mới
        </div>
        <form method="post" action="${pageContext.request.contextPath}/admin/holidays">
            <input type="hidden" name="action" value="add"/>
            <div class="form-group">
                <label>Tên ngày lễ <span style="color:red">*</span></label>
                <input type="text" name="name" placeholder="Ví dụ: Tết Nguyên Đán" required/>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>Ngày bắt đầu <span style="color:red">*</span></label>
                    <input type="date" name="startDate" required/>
                </div>
                <div class="form-group">
                    <label>Ngày kết thúc <span style="color:red">*</span></label>
                    <input type="date" name="endDate" required/>
                </div>
            </div>
            <div class="form-group">
                <label>Hệ số nhân lương (OT) <span style="color:red">*</span></label>
                <input type="number" name="salaryCoefficient" min="1.0" max="10.0" step="0.1" value="3.0" required/>
                <p class="form-hint">Nhân hệ số lương làm thêm giờ khi đi làm vào ngày này (ví dụ: Lễ Tết nhân 3.0)</p>
            </div>
            <div class="form-group">
                <label>Mô tả ngày lễ</label>
                <textarea name="description" placeholder="Thông tin chi tiết đợt nghỉ lễ này..."></textarea>
            </div>
            <div class="modal-actions">
                <button type="button" class="btn-cancel" onclick="closeModal('addModal')">Hủy</button>
                <button type="submit" class="btn btn-primary">Lưu khai báo</button>
            </div>
        </form>
    </div>
</div>

<%-- ══ Modal Sửa ══ --%>
<div class="modal-overlay" id="editModal">
    <div class="modal">
        <div class="modal-title">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width:20px;height:20px;color:var(--brand)"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
            Chỉnh sửa ngày nghỉ lễ
        </div>
        <form method="post" action="${pageContext.request.contextPath}/admin/holidays">
            <input type="hidden" name="action" value="update"/>
            <input type="hidden" name="id" id="edit_id"/>
            <div class="form-group">
                <label>Tên ngày lễ <span style="color:red">*</span></label>
                <input type="text" name="name" id="edit_name" required/>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>Ngày bắt đầu <span style="color:red">*</span></label>
                    <input type="date" name="startDate" id="edit_start_date" required/>
                </div>
                <div class="form-group">
                    <label>Ngày kết thúc <span style="color:red">*</span></label>
                    <input type="date" name="endDate" id="edit_end_date" required/>
                </div>
            </div>
            <div class="form-group">
                <label>Hệ số nhân lương (OT) <span style="color:red">*</span></label>
                <input type="number" name="salaryCoefficient" id="edit_coefficient" min="1.0" max="10.0" step="0.1" required/>
            </div>
            <div class="form-group">
                <label>Mô tả ngày lễ</label>
                <textarea name="description" id="edit_description"></textarea>
            </div>
            <div class="modal-actions">
                <button type="button" class="btn-cancel" onclick="closeModal('editModal')">Hủy</button>
                <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
            </div>
        </form>
    </div>
</div>

<form id="actionForm" method="post" action="${pageContext.request.contextPath}/admin/holidays" style="display:none">
    <input type="hidden" name="action" value="delete"/>
    <input type="hidden" name="id" id="delete_id"/>
</form>

<script>
function openModal(id)  { document.getElementById(id).classList.add('open'); }
function closeModal(id) { document.getElementById(id).classList.remove('open'); }

function openEdit(btn) {
    document.getElementById('edit_id').value = btn.getAttribute('data-id');
    document.getElementById('edit_name').value = btn.getAttribute('data-name');
    document.getElementById('edit_start_date').value = btn.getAttribute('data-start');
    document.getElementById('edit_end_date').value = btn.getAttribute('data-end');
    document.getElementById('edit_coefficient').value = btn.getAttribute('data-coeff');
    document.getElementById('edit_description').value = btn.getAttribute('data-desc');
    openModal('editModal');
}

function submitDelete(id, name) {
    if (confirm('Bạn có chắc chắn muốn xóa ngày nghỉ lễ "' + name + '" không?')) {
        document.getElementById('delete_id').value = id;
        document.getElementById('actionForm').submit();
    }
}

document.querySelectorAll('.modal-overlay').forEach(function(overlay) {
    overlay.addEventListener('click', function(e) {
        if (e.target === overlay) overlay.classList.remove('open');
    });
});
</script>
</body>
</html>
