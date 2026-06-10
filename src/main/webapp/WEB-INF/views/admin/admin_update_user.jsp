<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Cập nhật nhân viên - Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css"/>
    <style>
        body { font-family: 'Inter', sans-serif; background-color: #f8fafc; color: #1e293b; margin: 0; }
        .main-layout { display: flex; min-height: 100vh; }
        .content-area { flex-grow: 1; padding: 40px; background: #f8fafc; }
        
        /* ── Header ── */
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; max-width: 1000px; margin-left: auto; margin-right: auto; }
        .page-title h1 { margin: 0; font-size: 1.8rem; color: #0f172a; font-weight: 800; }
        .page-title p { margin: 5px 0 0 0; color: #64748b; font-size: 0.95rem; }
        .user-badge { background: #e0e7ff; color: #3730a3; padding: 8px 16px; border-radius: 99px; font-size: 0.85rem; font-weight: 600; border: 1px solid #c7d2fe; display: flex; align-items: center; gap: 6px; }

        /* ── Main Container & Tabs ── */
        .admin-container { background: white; border-radius: 16px; box-shadow: 0 10px 25px -5px rgba(0,0,0,0.05), 0 8px 10px -6px rgba(0,0,0,0.02); border: 1px solid #e2e8f0; max-width: 1000px; margin: 0 auto; overflow: hidden; }
        .tabs { display: flex; border-bottom: 1px solid #e2e8f0; background: #f8fafc; }
        .tab-btn { flex: 1; padding: 18px 24px; text-align: center; font-weight: 600; font-size: 0.95rem; color: #64748b; background: transparent; border: none; border-bottom: 3px solid transparent; cursor: pointer; transition: all 0.2s; }
        .tab-btn:hover { color: #334155; background: #f1f5f9; }
        .tab-btn.active { color: #4f46e5; border-bottom-color: #4f46e5; background: white; }
        .tab-btn i { margin-right: 8px; }
        
        .tab-content { display: none; padding: 36px 40px; animation: fadeIn 0.3s ease; }
        .tab-content.active { display: block; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(5px); } to { opacity: 1; transform: translateY(0); } }

        /* ── Form Elements ── */
        .grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }
        .form-group { margin-bottom: 24px; }
        label { display: block; margin-bottom: 8px; font-weight: 600; color: #475569; font-size: 0.85rem; }
        input[type="text"], input[type="email"], input[type="date"], select { width: 100%; height: 46px; padding: 10px 16px; border: 1px solid #cbd5e1; border-radius: 8px; font-size: 0.9rem; color: #0f172a; box-sizing: border-box; background-color: #fff; transition: all 0.2s; box-shadow: 0 1px 2px 0 rgba(0,0,0,0.05); }
        input:focus, select:focus { outline: none; border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,0.12); }
        input:read-only { background-color: #f8fafc; color: #64748b; cursor: not-allowed; border-color: #e2e8f0; }

        /* ── Allowance Custom Checkboxes (Pills) ── */
        .allowance-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 12px; }
        .allowance-card { display: flex; align-items: flex-start; padding: 14px 16px; border: 1px solid #e2e8f0; border-radius: 10px; cursor: pointer; transition: all 0.2s; background: #fff; }
        .allowance-card:hover { border-color: #cbd5e1; background: #f8fafc; }
        .allowance-card input[type="checkbox"] { display: none; }
        .allowance-card.selected { border-color: #6366f1; background: #eef2ff; box-shadow: 0 0 0 1px #6366f1; }
        .allowance-icon { width: 20px; height: 20px; border-radius: 50%; border: 2px solid #cbd5e1; margin-right: 12px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; margin-top: 2px; transition: all 0.2s; }
        .allowance-card.selected .allowance-icon { border-color: #4f46e5; background: #4f46e5; }
        .allowance-card.selected .allowance-icon::after { content: '\f00c'; font-family: 'Font Awesome 6 Free'; font-weight: 900; color: white; font-size: 10px; }
        .allowance-info { flex-grow: 1; }
        .allowance-name { font-weight: 600; color: #1e293b; font-size: 0.95rem; display: block; margin-bottom: 4px; }
        .allowance-amount { color: #6366f1; font-weight: 700; font-size: 0.9rem; }
        .allowance-code { color: #64748b; font-size: 0.8rem; margin-left: 6px; font-weight: normal; }

        /* ── Actions ── */
        .form-actions { padding: 24px 40px; background: #f8fafc; border-top: 1px solid #e2e8f0; display: flex; justify-content: flex-end; gap: 16px; }
        .btn { height: 46px; padding: 0 24px; border: none; border-radius: 8px; font-weight: 600; cursor: pointer; font-size: 0.95rem; transition: all 0.2s; display: inline-flex; align-items: center; justify-content: center; gap: 8px; text-decoration: none; }
        .btn-primary { background: #4f46e5; color: white; box-shadow: 0 2px 4px rgba(79,70,229,0.15); }
        .btn-primary:hover { background: #4338ca; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(79,70,229,0.25); }
        .btn-secondary { background: white; color: #475569; border: 1px solid #cbd5e1; }
        .btn-secondary:hover { background: #f1f5f9; color: #1e293b; }

        /* Alerts */
        .alert { padding: 16px 20px; border-radius: 10px; margin-bottom: 24px; display: flex; align-items: center; gap: 12px; font-size: 0.95rem; font-weight: 500; }
        .alert-success { background: #f0fdf4; color: #166534; border: 1px solid #bbf7d0; }
        .alert-error { background: #fef2f2; color: #991b1b; border: 1px solid #fca5a5; }
    </style>
</head>
<body>

<div class="main-layout">
    <%@include file="/WEB-INF/common/sidebar.jsp" %>

    <div class="content-area">
        <div class="page-header">
            <div class="page-title">
                <h1>Hồ sơ nhân viên</h1>
                <p>Quản lý và cập nhật thông tin chi tiết</p>
            </div>
            <div class="user-badge">
                <i class="fa-solid fa-id-card"></i> Mã NV: ${user.employeeCode}
            </div>
        </div>

        <div class="admin-container">
            <form action="${pageContext.request.contextPath}/admin/user/update" method="post">
                <input type="hidden" name="id" value="${user.employeeId}">

                <!-- Tab Navigation -->
                <div class="tabs">
                    <button type="button" class="tab-btn active" onclick="switchTab(event, 'tab-personal')">
                        <i class="fa-solid fa-user-pen"></i> Thông tin cá nhân
                    </button>
                    <button type="button" class="tab-btn" onclick="switchTab(event, 'tab-job')">
                        <i class="fa-solid fa-briefcase"></i> Chức vụ & Mức lương
                    </button>
                    <button type="button" class="tab-btn" onclick="switchTab(event, 'tab-role')">
                        <i class="fa-solid fa-shield-halved"></i> Phân quyền & Trạng thái
                    </button>
                </div>

                <!-- Tab 1: Thông tin cá nhân -->
                <div id="tab-personal" class="tab-content active">
                    <c:if test="${not empty param.success}"><div class="alert alert-success"><i class="fa-solid fa-circle-check"></i> Cập nhật thành công!</div></c:if>
                    <c:if test="${not empty param.error}"><div class="alert alert-error"><i class="fa-solid fa-circle-xmark"></i> Cập nhật thất bại. Vui lòng kiểm tra lại.</div></c:if>

                    <div class="grid-2">
                        <div class="form-group">
                            <label>Họ và tên nhân viên</label>
                            <input type="text" name="fullName" value="${user.fullName}" required placeholder="Nguyễn Văn A">
                        </div>
                        <div class="form-group">
                            <label>Số điện thoại</label>
                            <input type="text" name="phone" value="${user.phone}" placeholder="09xxxxxxxx">
                        </div>
                    </div>

                    <div class="grid-2">
                        <div class="form-group">
                            <label>Ngày sinh</label>
                            <input type="date" name="dateOfBirth" value="${user.dateOfBirth}">
                        </div>
                        <div class="form-group">
                            <label>Giới tính</label>
                            <select name="gender">
                                <option value="">-- Chọn giới tính --</option>
                                <option value="Male" ${user.gender == 'Male' ? 'selected' : ''}>Nam</option>
                                <option value="Female" ${user.gender == 'Female' ? 'selected' : ''}>Nữ</option>
                                <option value="Other" ${user.gender == 'Other' ? 'selected' : ''}>Khác</option>
                            </select>
                        </div>
                    </div>

                    <div class="grid-2">
                        <div class="form-group">
                            <label>Email cá nhân</label>
                            <input type="email" name="personalEmail" value="${user.personalEmail}" placeholder="example@gmail.com">
                        </div>
                        <div class="form-group">
                            <label>Email công ty (Tự động)</label>
                            <input type="email" value="${user.workEmail}" readonly title="Email này do hệ thống cấp định, không thể sửa đổi">
                        </div>
                    </div>
                </div>

                <!-- Tab 2: Chức vụ & Mức lương -->
                <div id="tab-job" class="tab-content">
                    <div class="grid-2">
                        <div class="form-group">
                            <label>Phòng ban trực thuộc</label>
                            <select name="departmentId" id="departmentId">
                                <option value="">-- Chưa xếp phòng ban --</option>
                                <c:forEach items="${departments}" var="dept">
                                    <option value="${dept.id}" ${user.departmentId == dept.id ? 'selected' : ''}>${dept.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Vị trí / Chức vụ</label>
                            <select name="positionId" id="positionId" data-selected="${user.positionId}">
                                <option value="">-- Chọn chức vụ --</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Thang Bảng Lương (Basic Salary Scale)</label>
                        <select name="salaryScaleId">
                            <option value="">-- Chưa áp dụng / Hợp đồng thử việc --</option>
                            <c:forEach items="${salaryScales}" var="scale">
                                <c:if test="${scale.active || user.salaryScaleId == scale.id}">
                                    <option value="${scale.id}" ${user.salaryScaleId == scale.id ? 'selected' : ''}>
                                        Bậc ${scale.grade} - Lương CB: <fmt:formatNumber value="${scale.basicSalary}" pattern="#,##0"/> VNĐ
                                    </option>
                                </c:if>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="form-group" style="margin-top: 32px;">
                        <label style="font-size: 1rem; border-bottom: 2px solid #f1f5f9; padding-bottom: 8px; margin-bottom: 16px;">
                            <i class="fa-solid fa-money-bill-wave" style="color: #4f46e5;"></i> Các loại Phụ Cấp (Allowances)
                        </label>
                        <div class="allowance-grid">
                            <c:forEach items="${allowanceTypes}" var="allowance">
                                <c:set var="isSelected" value="false" />
                                <c:if test="${user.allowanceTypeIds != null}">
                                    <c:forEach items="${user.allowanceTypeIds}" var="selId">
                                        <c:if test="${allowance.id == selId}"><c:set var="isSelected" value="true" /></c:if>
                                    </c:forEach>
                                </c:if>
                                
                                <c:if test="${allowance.active || isSelected}">
                                    <label class="allowance-card ${isSelected ? 'selected' : ''}" onclick="toggleAllowanceCard(this)">
                                        <div class="allowance-icon"></div>
                                        <input type="checkbox" name="allowanceTypeIds" value="${allowance.id}" ${isSelected ? 'checked' : ''}>
                                        <div class="allowance-info">
                                            <span class="allowance-name">
                                                ${allowance.name} <span class="allowance-code">(${allowance.code})</span>
                                            </span>
                                            <span class="allowance-amount">+ <fmt:formatNumber value="${allowance.amount}" pattern="#,##0"/> VNĐ</span>
                                        </div>
                                    </label>
                                </c:if>
                            </c:forEach>
                        </div>
                    </div>
                </div>

                <!-- Tab 3: Phân quyền & Trạng thái -->
                <div id="tab-role" class="tab-content">
                    <div class="grid-2">
                        <div class="form-group">
                            <label>Nhóm quyền hệ thống (Role)</label>
                            <select name="roleId" required>
                                <option value="">-- Chỉ định nhóm quyền --</option>
                                <c:forEach items="${roles}" var="role">
                                    <option value="${role.id}" ${user.roleId == role.id ? 'selected' : ''}>${role.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Trạng thái nhân sự</label>
                            <select name="status" required>
                                <option value="PROBATION" ${user.status == 'PROBATION' ? 'selected' : ''}>Thử việc (PROBATION)</option>
                                <option value="ACTIVE" ${user.status == 'ACTIVE' ? 'selected' : ''}>Đang làm việc (ACTIVE)</option>
                                <option value="ON_LEAVE" ${user.status == 'ON_LEAVE' ? 'selected' : ''}>Nghỉ thai sản/không lương (ON_LEAVE)</option>
                                <option value="TERMINATED" ${user.status == 'TERMINATED' ? 'selected' : ''}>Đã nghỉ việc (TERMINATED)</option>
                            </select>
                        </div>
                    </div>
                </div>

                <!-- Global Actions -->
                <div class="form-actions">
                    <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-secondary">Hủy bỏ</a>
                    <button type="submit" class="btn btn-primary">
                        <i class="fa-solid fa-floppy-disk"></i> Lưu thay đổi hồ sơ
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    // ── Tab Logic ──
    function switchTab(evt, tabId) {
        document.querySelectorAll('.tab-content').forEach(tab => tab.classList.remove('active'));
        document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
        document.getElementById(tabId).classList.add('active');
        evt.currentTarget.classList.add('active');
    }

    // ── Allowance Card Toggle Logic ──
    function toggleAllowanceCard(card) {
        // Since the label wraps the checkbox, clicking it automatically toggles the checkbox state.
        // We just need to update the visual class.
        // Use a small timeout to allow checkbox native state to flip first
        setTimeout(() => {
            const checkbox = card.querySelector('input[type="checkbox"]');
            if (checkbox.checked) {
                card.classList.add('selected');
            } else {
                card.classList.remove('selected');
            }
        }, 10);
    }

    // ── Dynamic Position Filter ──
    const positions = [
        <c:forEach items="${positions}" var="p" varStatus="status">
            { id: ${p.id}, name: '${p.name}', departmentId: ${p.departmentId} }${!status.last ? ',' : ''}
        </c:forEach>
    ];

    function filterPositions() {
        const deptSelect = document.getElementById('departmentId');
        const posSelect = document.getElementById('positionId');
        const selectedDeptId = deptSelect.value;
        const previouslySelectedPosId = posSelect.getAttribute('data-selected');

        posSelect.innerHTML = '<option value="">-- Chọn chức vụ --</option>';

        if (!selectedDeptId) return;

        const filteredPositions = positions.filter(pos => pos.departmentId == selectedDeptId);
        filteredPositions.forEach(pos => {
            const opt = document.createElement('option');
            opt.value = pos.id;
            opt.textContent = pos.name;
            if (pos.id == previouslySelectedPosId) opt.selected = true;
            posSelect.appendChild(opt);
        });
    }

    document.getElementById('departmentId').addEventListener('change', filterPositions);
    window.addEventListener('DOMContentLoaded', filterPositions);
</script>

</body>
</html>
