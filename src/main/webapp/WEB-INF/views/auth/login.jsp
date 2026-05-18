<%--
  Created by IntelliJ IDEA.
  User: brave
  Date: 5/16/2026
  Time: 2:25 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- gọi css từ login.css --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/login.css" type="text/css">

<%-- sử dụng class .login-page để nhận css --%>
<div class="login-page">
    <div class="card">
        <div class="logo-wrap">
            <div class="logo-icon">
                <svg width="28" height="28" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" viewBox="0 0 24 24">
                    <path d="M9 12h6M9 16h6M17 3H7a2 2 0 00-2 2v14a2 2 0 002 2h10a2 2 0 002-2V5a2 2 0 00-2-2z"/>
                    <path d="M9 8h6"/>
                </svg>
            </div>
            <div class="logo-title">HRMS</div>
            <div class="logo-sub">Hệ thống quản lý nhân sự</div>
        </div>

        <%-- error msg từ servlet nếu có --%>
        <c:if test="${not empty error}">
            <div class="alert alert-danger">
                <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                    <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
                </svg>
                ${error}
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/login" method="post" autocomplete="off">
            <div class="form-group">
                <label for="email">Email</label>
                <div class="input-wrap">
                    <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <rect x="2" y="4" width="20" height="16" rx="2"/><path d="M2 7l10 7 10-7"/>
                    </svg>
                    <input type="email" id="email" name="email"
                           value="${not empty email ? email : ''}"
                           placeholder="email@company.com" required>
                </div>
            </div>

            <div class="form-group">
                <label for="password">Mật khẩu</label>
                <div class="input-wrap">
                    <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/>
                    </svg>
                    <input type="password" id="password" name="password" placeholder="••••••••" required>
                </div>
            </div>

            <div class="form-actions-helper">
                <a href="${pageContext.request.contextPath}/forgot-password" class="forgot-password-link">Quên mật khẩu?</a>
            </div>

            <button type="submit" class="btn-login">Đăng nhập</button>
        </form>
        <%-- Danh sách tài khoản mẫu dùng nhanh --%>
        <div class="demo-box">
            <div class="demo-title">Tài khoản demo</div>
            <div class="demo-row">
                <span class="demo-role">Admin</span>
                <span class="demo-creds">tong.nv@company.com / 123456</span>
                <span class="demo-fill" onclick="fillDemo('tong.nv@company.com','123456')">Dùng</span>
            </div>
            <div class="demo-row">
                <span class="demo-role">HR</span>
                <span class="demo-creds">nhan.tt@company.com / 123456</span>
                <span class="demo-fill" onclick="fillDemo('nhan.tt@company.com','123456')">Dùng</span>
            </div>
            <div class="demo-row">
                <span class="demo-role">Manager</span>
                <span class="demo-creds">nghe.pc@company.com / 123456</span>
                <span class="demo-fill" onclick="fillDemo('nghe.pc@company.com','123456')">Dùng</span>
            </div>
            <div class="demo-row">
                <span class="demo-role">Employee</span>
                <span class="demo-creds">tuyen.lh@company.com / 123456</span>
                <span class="demo-fill" onclick="fillDemo('tuyen.lh@company.com','123456')">Dùng</span>
            </div>
        </div>
    </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/filldemo.js"></script>