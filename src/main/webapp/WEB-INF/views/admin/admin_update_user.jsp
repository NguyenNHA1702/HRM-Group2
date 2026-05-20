<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Cập nhật nhân viên - Admin</title>
    <!-- FontAwesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css"/>
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #f8fafc;
            color: #1e293b;
            margin: 0;
        }
        .main-layout {
            display: flex;
            min-height: 100vh;
        }
        .content-area {
            flex-grow: 1;
            padding: 40px;
            background: #f8fafc;
        }
        .admin-container {
            background: white;
            border-radius: 16px;
            padding: 40px;
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.05), 0 8px 10px -6px rgba(0, 0, 0, 0.02);
            border: 1px solid #e2e8f0;
            max-width: 950px;
            margin: 0 auto;
        }
        .form-section-title {
            margin: 36px 0 24px 0;
            font-size: 1.1rem;
            color: #0f172a;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 8px;
            border-bottom: 2px solid #f1f5f9;
            padding-bottom: 10px;
        }
        .form-section-title i {
            color: #6366f1;
            font-size: 1.2rem;
        }
        .grid-2 {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
        }
        .form-group {
            margin-bottom: 24px;
        }
        label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #475569;
            font-size: 0.85rem;
        }
        input[type="text"], input[type="email"], input[type="date"], select {
            width: 100%;
            height: 46px;
            padding: 10px 16px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-size: 0.9rem;
            color: #0f172a;
            box-sizing: border-box;
            background-color: #fff;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
        }
        input:focus, select:focus {
            outline: none;
            border-color: #6366f1;
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.12), 0 1px 2px 0 rgba(0, 0, 0, 0.05);
        }
        input:read-only {
            background-color: #f8fafc;
            color: #64748b;
            cursor: not-allowed;
            border-color: #e2e8f0;
            box-shadow: none;
        }
        .btn-container {
            margin-top: 40px;
            display: flex;
            gap: 16px;
            justify-content: flex-end;
        }
        .btn {
            height: 46px;
            padding: 0 24px;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            font-size: 0.9rem;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }
        .btn-primary {
            background: #6366f1;
            color: white;
            box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
        }
        .btn-primary:hover {
            background: #4f46e5;
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.2);
        }
        .btn-secondary {
            background: #f1f5f9;
            color: #475569;
            border: 1px solid #e2e8f0;
            text-decoration: none;
        }
        .btn-secondary:hover {
            background: #e2e8f0;
            color: #1e293b;
        }
        .alert {
            padding: 16px 20px;
            border-radius: 10px;
            margin-bottom: 30px;
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 0.95rem;
            font-weight: 500;
        }
        .alert-success {
            background: #f0fdf4;
            color: #166534;
            border: 1px solid #bbf7d0;
        }
        .alert-error {
            background: #fef2f2;
            color: #991b1b;
            border: 1px solid #fca5a5;
        }
        .header-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            max-width: 950px;
            margin-left: auto;
            margin-right: auto;
        }
        .user-badge {
            background: #e0e7ff;
            color: #3730a3;
            padding: 8px 16px;
            border-radius: 9999px;
            font-size: 0.85rem;
            font-weight: 600;
            border: 1px solid #c7d2fe;
            display: flex;
            align-items: center;
            gap: 6px;
        }
    </style>
</head>
<body>

<div class="main-layout">
    <%@include file="/WEB-INF/common/sidebar.jsp" %>

    <div class="content-area">
        <div class="header-section">
            <div>
                <h1 style="margin: 0; font-size: 1.8rem; color: #0f172a; font-weight: 800;">Quản lý nhân viên</h1>
                <p style="margin: 5px 0 0 0; color: #64748b; font-size: 0.95rem;">Cập nhật thông tin chi tiết nhân viên hệ thống</p>
            </div>
            <div class="user-badge">
                <i class="fa-solid fa-id-card"></i> Mã NV: ${user.employeeCode}
            </div>
        </div>

        <div class="admin-container">
            <c:if test="${not empty param.success}">
                <div class="alert alert-success">
                    <i class="fa-solid fa-circle-check" style="font-size: 1.2rem;"></i> Cập nhật thông tin nhân viên thành công!
                </div>
            </c:if>
            <c:if test="${not empty param.error}">
                <div class="alert alert-error">
                    <i class="fa-solid fa-circle-xmark" style="font-size: 1.2rem;"></i> Cập nhật thất bại. Vui lòng kiểm tra lại dữ liệu.
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/admin/user/update" method="post">
                <input type="hidden" name="id" value="${user.employeeId}">

                <!-- Phần 1: Thông tin cá nhân -->
                <div class="form-section-title">
                    <i class="fa-solid fa-user-gear"></i> Thông tin cá nhân
                </div>
                
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
                        <label>Email công ty (Chỉ đọc)</label>
                        <input type="email" value="${user.workEmail}" readonly>
                    </div>
                </div>

                <!-- Phần 2: Thông tin công việc & Phân quyền -->
                <div class="form-section-title">
                    <i class="fa-solid fa-briefcase"></i> Công việc & Phân quyền
                </div>

                <div class="grid-2">
                    <div class="form-group">
                        <label>Phòng ban</label>
                        <select name="departmentId" id="departmentId">
                            <option value="">-- Chọn phòng ban --</option>
                            <c:forEach items="${departments}" var="dept">
                                <option value="${dept.id}" ${user.departmentId == dept.id ? 'selected' : ''}>${dept.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Chức vụ / Vị trí</label>
                        <select name="positionId" id="positionId" data-selected="${user.positionId}">
                            <option value="">-- Chọn chức vụ --</option>
                        </select>
                    </div>
                </div>

                <div class="grid-2">
                    <div class="form-group">
                        <label>Quyền hệ thống (Role)</label>
                        <select name="roleId" required>
                            <option value="">-- Chọn quyền --</option>
                            <c:forEach items="${roles}" var="role">
                                <option value="${role.id}" ${user.roleId == role.id ? 'selected' : ''}>${role.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Trạng thái hoạt động</label>
                        <select name="status" required>
                            <option value="PROBATION" ${user.status == 'PROBATION' ? 'selected' : ''}>Thử việc (PROBATION)</option>
                            <option value="ACTIVE" ${user.status == 'ACTIVE' ? 'selected' : ''}>Đang hoạt động (ACTIVE)</option>
                            <option value="ON_LEAVE" ${user.status == 'ON_LEAVE' ? 'selected' : ''}>Nghỉ phép tạm thời (ON_LEAVE)</option>
                            <option value="TERMINATED" ${user.status == 'TERMINATED' ? 'selected' : ''}>Đã nghỉ việc (TERMINATED)</option>
                        </select>
                    </div>
                </div>

                <!-- Nút thao tác -->
                <div class="btn-container">
                    <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-secondary">
                        <i class="fa-solid fa-arrow-left"></i> Quay lại
                    </a>
                    <button type="submit" class="btn btn-primary">
                        <i class="fa-solid fa-floppy-disk"></i> Lưu thay đổi
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    // Dữ liệu chức vụ truyền từ Backend sang JSP dưới dạng JSON để JS filter động
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

        // Reset danh sách chức vụ
        posSelect.innerHTML = '<option value="">-- Chọn chức vụ --</option>';

        if (!selectedDeptId) {
            return;
        }

        // Lọc các chức vụ có departmentId trùng với phòng ban được chọn
        const filteredPositions = positions.filter(pos => pos.departmentId == selectedDeptId);

        filteredPositions.forEach(pos => {
            const opt = document.createElement('option');
            opt.value = pos.id;
            opt.textContent = pos.name;
            if (pos.id == previouslySelectedPosId) {
                opt.selected = true;
            }
            posSelect.appendChild(opt);
        });
    }

    // Lắng nghe sự kiện thay đổi phòng ban để lọc chức vụ
    document.getElementById('departmentId').addEventListener('change', filterPositions);

    // Chạy lần đầu tiên khi load trang để fill chức vụ mặc định của nhân viên
    window.addEventListener('DOMContentLoaded', filterPositions);
</script>

</body>
</html>
