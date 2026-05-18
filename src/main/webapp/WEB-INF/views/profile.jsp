<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Hồ sơ cá nhân - HRMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css"/>
    <style>
        .profile-container {
            background: white;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.05);
            max-width: 900px;
            display: flex;
            gap: 40px;
        }
        .profile-sidebar {
            width: 300px;
            text-align: center;
            border-right: 1px solid #f1f5f9;
            padding-right: 40px;
        }
        .profile-main {
            flex-grow: 1;
        }
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 6px;
            font-weight: 600;
            color: #64748b;
            font-size: 0.85rem;
        }
        input[type="text"], input[type="email"], input[type="password"], select {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            font-size: 0.95rem;
            color: #1e293b;
            box-sizing: border-box;
        }
        input:read-only {
            background-color: #f8fafc;
            color: #94a3b8;
        }
        .info-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            margin-top: 8px;
        }
        .badge-active { background: #f0fdf4; color: #166534; }
        .btn-save {
            background: #6366f1;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            width: 100%;
            transition: background 0.2s;
        }
        .btn-save:hover {
            opacity: 0.9;
        }
    </style>
</head>
<body>

<div class="main-layout">
    <%@include file="/WEB-INF/common/sidebar.jsp" %>

    <div class="content-area">
        <div style="margin-bottom: 30px;">
            <h1 style="margin: 0; font-size: 1.8rem; color: #1e293b;">Hồ sơ cá nhân</h1>
            <p style="margin: 0; color: #64748b;">Mã nhân viên: <strong>${user.employeeCode}</strong></p>
        </div>

        <%-- Thông báo của phần cập nhật hồ sơ --%>
        <c:if test="${not empty param.success}">
            <div style="padding: 16px; background: #f0fdf4; color: #166534; border-radius: 10px; margin-bottom: 24px; border: 1px solid #bbf7d0;">
                <i class="fas fa-check-circle"></i> Cập nhật thông tin thành công!
            </div>
        </c:if>

        <div class="profile-container">
            <div class="profile-sidebar">
                <div style="width: 120px; height: 120px; border-radius: 50%; background: #e2e8f0; margin: 0 auto 20px; display: flex; align-items: center; justify-content: center; overflow: hidden;">
                    <c:choose>
                        <c:when test="${not empty user.avatarUrl}">
                            <img src="${user.avatarUrl}" style="width: 100%; height: 100%; object-fit: cover;">
                        </c:when>
                        <c:otherwise>
                            <i class="fas fa-user" style="font-size: 4rem; color: #94a3b8;"></i>
                        </c:otherwise>
                    </c:choose>
                </div>
                <h2 style="margin: 0; font-size: 1.25rem;">${user.fullName}</h2>
                <p style="color: #64748b; margin: 5px 0;">${user.positionName}</p>
                <div class="info-badge badge-active">${user.status}</div>

                <div style="margin-top: 30px; text-align: left; background: #f8fafc; padding: 20px; border-radius: 12px;">
                    <div style="margin-bottom: 15px;">
                        <label>Phòng ban</label>
                        <div style="font-weight: 600;">${user.departmentName}</div>
                    </div>
                    <div style="margin-bottom: 15px;">
                        <label>Vai trò hệ thống</label>
                        <div style="font-weight: 600; color: #6366f1;">${user.roleName}</div>
                    </div>
                    <div>
                        <label>Quản lý trực tiếp</label>
                        <div style="font-weight: 600;">${user.managerName != null ? user.managerName : 'N/A'}</div>
                    </div>
                </div>
            </div>

            <div class="profile-main">

                <form action="profile" method="post">
                    <input type="hidden" name="id" value="${user.employeeId}">

                    <h3 style="margin: 0 0 20px 0; font-size: 1.1rem; border-bottom: 1px solid #f1f5f9; padding-bottom: 10px;">Thông tin liên hệ</h3>

                    <div class="form-group">
                        <label>Họ và tên</label>
                        <input type="text" name="fullName" value="${user.fullName}" required>
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                        <div class="form-group">
                            <label>Email công ty (Cố định)</label>
                            <input type="email" value="${user.workEmail}" readonly>
                        </div>
                        <div class="form-group">
                            <label>Số điện thoại</label>
                            <input type="text" name="phone" value="${user.phone}">
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Email cá nhân</label>
                        <input type="email" name="personalEmail" value="${user.personalEmail}">
                    </div>

                    <div style="margin-top: 24px;">
                        <button type="submit" class="btn-save">Cập nhật hồ sơ</button>
                    </div>
                </form>

                <div style="margin-top: 40px; border-top: 1px solid #f1f5f9; padding-top: 30px;">
                    <h3 style="margin: 0 0 20px 0; font-size: 1.1rem; color: #1e293b;">Đổi mật khẩu</h3>

                    <%-- Thông báo lỗi/thành công riêng của phần đổi mật khẩu --%>
                    <c:if test="${not empty param.pwdError}">
                        <div style="padding: 12px; background: #fef2f2; color: #991b1b; border-radius: 8px; margin-bottom: 20px; font-size: 0.9rem; border: 1px solid #fca5a5;">
                            <i class="fas fa-exclamation-circle"></i> ${param.pwdError}
                        </div>
                    </c:if>

                    <c:if test="${not empty param.pwdSuccess}">
                        <div style="padding: 12px; background: #f0fdf4; color: #166534; border-radius: 8px; margin-bottom: 20px; font-size: 0.9rem; border: 1px solid #bbf7d0;">
                            <i class="fas fa-check-circle"></i> Đổi mật khẩu thành công!
                        </div>
                    </c:if>

                    <form action="change-password" method="post">
                        <div class="form-group">
                            <label>Mật khẩu hiện tại</label>
                            <input type="password" name="currentPassword" required>
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                            <div class="form-group">
                                <label>Mật khẩu mới</label>
                                <input type="password" name="newPassword" required>
                            </div>
                            <div class="form-group">
                                <label>Xác nhận mật khẩu mới</label>
                                <input type="password" name="confirmPassword" required>
                            </div>
                        </div>

                        <div style="margin-top: 24px;">
                            <button type="submit" class="btn-save" style="background: #0f172a;">Đổi mật khẩu</button>
                        </div>
                    </form>
                </div>

            </div>
        </div>
    </div>
</div>

</body>
</html>