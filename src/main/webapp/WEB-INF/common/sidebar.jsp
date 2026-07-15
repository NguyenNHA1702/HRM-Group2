<%@ page pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<aside class="sidebar">
    <div class="sidebar-brand">
        <div class="brand-icon">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#ffffff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width: 20px; height: 20px;">
                <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path>
                <circle cx="9" cy="7" r="4"></circle>
                <path d="M22 21v-2a4 4 0 0 0-3-3.87"></path>
                <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
            </svg>
        </div>
        <div class="brand-text">
            <span class="brand-name">HRMS</span>
            <span class="brand-sub">Quản lý Nhân sự</span>
        </div>
    </div>

    <nav class="sidebar-nav">
        <ul>
            <li class="nav-item ${pageContext.request.requestURI.contains('/dashboard') ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/dashboard">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><rect x="3" y="3" width="7" height="9"></rect><rect x="14" y="3" width="7" height="5"></rect><rect x="14" y="12" width="7" height="9"></rect><rect x="3" y="16" width="7" height="5"></rect></svg>
                    Dashboard
                </a>
            </li>

            <%-- PHÂN HỆ: EMPLOYEE --%>
            <c:if test="${sessionScope.roleGroup eq 'EMPLOYEE'}">
                <li class="nav-item ${pageContext.request.requestURI.contains('/cham-cong') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/cham-cong">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                        Chấm công
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/nghi-phep') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/nghi-phep">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                        Nghỉ phép
                    </a>
                </li>
                <li class="nav-section">Lương &amp; Phúc Lợi</li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/luong') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/luong">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="6" width="20" height="12" rx="2" ry="2"></rect><circle cx="12" cy="12" r="2"></circle><path d="M6 12h.01M18 12h.01"></path></svg>
                        Lương
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/admin/insurance') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admin/insurance">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 1 2.81.7A2 2 0 0 1 22 16.92z"></path><circle cx="12" cy="12" r="9"></circle><path d="M12 8v8M16 12H8" stroke-width="1.5"></path></svg>
                        Bảo hiểm
                    </a>
                </li>
                <li class="nav-section">Lịch Làm Việc</li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/schedule/employee') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/schedule/employee">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                        Lịch của tôi
                    </a>
                </li>
            </c:if>

            <%-- PHÂN HỆ: MANAGER --%>
            <c:if test="${sessionScope.roleGroup eq 'MANAGER'}">
                <li class="nav-item ${pageContext.request.requestURI.contains('/nhan-vien') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/nhan-vien">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                        Nhân viên
                    </a>
                </li>

                <li class="nav-item ${pageContext.request.requestURI.contains('/manager-attendance-explanations') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/manager-attendance-explanations">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                        Giải trình công
                    </a>
                </li>

                <li class="nav-item ${pageContext.request.requestURI.contains('/nghi-phep') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/nghi-phep">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                        Nghỉ phép
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/hr/leave-summary') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/hr/leave-summary">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18M9 21V9"/></svg>
                        Báo cáo nghỉ phép
                    </a>
                </li>
                <li class="nav-section">Lương &amp; Phúc Lợi</li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/admin/insurance') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admin/insurance">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path><circle cx="12" cy="12" r="9"></circle><path d="M12 8v8M16 12H8" stroke-width="1.5"></path></svg>
                        Bảo hiểm
                    </a>
                </li>
            </c:if>

            <%-- PHÂN HỆ: HR --%>
            <c:if test="${sessionScope.roleGroup eq 'HR'}">
                <li class="nav-item ${pageContext.request.requestURI.contains('/nhan-vien') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/nhan-vien">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                        Nhân viên
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/hr/departments') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/hr/departments">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path></svg>
                        Phòng ban
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/hr/contracts') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/hr/contracts">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width: 18px; height: 18px; fill: none;"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                        Hợp đồng
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/cham-cong') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/cham-cong">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                        Chấm công
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/hr/leave-requests') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/hr/leave-requests">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                        Nghỉ phép
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/hr/leave-balance') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/hr/leave-balance">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><polyline points="9 12 11 14 15 10"/></svg>
                        Quỹ phép
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/hr/leave-summary') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/hr/leave-summary">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18M9 21V9"/></svg>
                        Báo cáo nghỉ phép
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/hr/attendance-explanations') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/hr/attendance-explanations">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                        Giải trình công
                    </a>
                </li>

                <li class="nav-section">Lương &amp; Phúc Lợi</li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/luong') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/luong">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="6" width="20" height="12" rx="2" ry="2"></rect><circle cx="12" cy="12" r="2"></circle><path d="M6 12h.01M18 12h.01"></path></svg>
                        lương
                    </a>
                </li>

                <li class="nav-item ${pageContext.request.requestURI.contains('/admin/payroll') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admin/payrolls">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="6" width="20" height="12" rx="2" ry="2"></rect><circle cx="12" cy="12" r="2"></circle><path d="M6 12h.01M18 12h.01"></path></svg>
                        Bảng lương
                    </a>
                </li>

                <li class="nav-item ${pageContext.request.requestURI.contains('/admin/salary-scales') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admin/salary-scales">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"></polyline><polyline points="17 6 23 6 23 12"></polyline></svg>
                        Thang bảng lương
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/admin/allowance-types') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admin/allowance-types">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="7"></circle><polyline points="8.21 13.89 7 23 12 20 17 23 15.79 13.88"></polyline></svg>
                        Loại phụ cấp
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/admin/insurance') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admin/insurance">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path><circle cx="12" cy="12" r="9"></circle><path d="M12 8v8M16 12H8" stroke-width="1.5"></path></svg>
                        Bảo hiểm
                    </a>
                </li>

                <li class="nav-section">Lịch Làm Việc</li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/schedule/view') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/schedule/view">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                        Xem Lịch Trình
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/schedule/assign') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/schedule/assign">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><line x1="19" y1="8" x2="19" y2="14"></line><line x1="16" y1="11" x2="22" y2="11"></line></svg>
                        Phân Lịch Làm
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/schedule/employee') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/schedule/employee">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                        Lịch của tôi
                    </a>
                </li>
            </c:if>

            <%-- PHÂN HỆ: ADMIN --%>
            <c:if test="${sessionScope.roleGroup eq 'ADMIN'}">
                <li class="nav-item ${pageContext.request.requestURI.contains('/nhan-vien') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/nhan-vien">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                        Nhân viên
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/hr/departments') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/hr/departments">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path></svg>
                        Phòng ban
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/hr/contracts') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/hr/contracts">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width: 18px; height: 18px; fill: none;"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                        Hợp đồng
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/hr/leave-requests') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/hr/leave-requests">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                        Nghỉ phép
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/admin/leave-types') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admin/leave-types">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                            <line x1="16" y1="2" x2="16" y2="6"></line>
                            <line x1="8" y1="2" x2="8" y2="6"></line>
                            <line x1="3" y1="10" x2="21" y2="10"></line>
                            <line x1="8" y1="14" x2="16" y2="14"></line>
                            <line x1="8" y1="18" x2="12" y2="18"></line>
                        </svg>
                        Loại nghỉ phép
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/admin/work-shifts') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admin/work-shifts">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                        Ca làm việc
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/admin/holidays') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admin/holidays">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                        Ngày nghỉ lễ
                    </a>
                </li>

                <li class="nav-section">Lương &amp; Phúc Lợi</li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/admin/payroll') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admin/payrolls">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="6" width="20" height="12" rx="2" ry="2"></rect><circle cx="12" cy="12" r="2"></circle><path d="M6 12h.01M18 12h.01"></path></svg>
                        Bảng lương
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/admin/overtime') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admin/overtime">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                        Tăng ca
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/admin/payroll-bonuses') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admin/payroll-bonuses">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="7"></circle><polyline points="8.21 13.89 7 23 12 20 17 23 15.79 13.88"></polyline></svg>
                        Thưởng
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/admin/salary-scales') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admin/salary-scales">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"></polyline><polyline points="17 6 23 6 23 12"></polyline></svg>
                        Thang bảng lương
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/admin/allowance-types') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admin/allowance-types">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="7"></circle><polyline points="8.21 13.89 7 23 12 20 17 23 15.79 13.88"></polyline></svg>
                        Loại phụ cấp
                    </a>
                </li>

                <li class="nav-section">Cài Đặt Hệ Thống</li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/admin/users') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admin/users">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><circle cx="19" cy="11" r="2"></circle><path d="M19 8v1"></path><path d="M19 13v1"></path><path d="M21.6 9.5l-.87.5"></path><path d="M17.27 12l-.87.5"></path><path d="M21.6 12.5l-.87-.5"></path><path d="M17.27 10l-.87-.5"></path></svg>
                        Quản lý Users
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/admin/permissions') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admin/permissions">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
                        Phân quyền
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/cau-hinh') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/cau-hinh">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
                        Cấu hình
                    </a>
                </li>

                <li class="nav-section">Lịch Làm Việc</li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/schedule/view') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/schedule/view">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                        Xem Lịch Trình
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/schedule/assign') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/schedule/assign">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><line x1="19" y1="8" x2="19" y2="14"></line><line x1="16" y1="11" x2="22" y2="11"></line></svg>
                        Phân Lịch Làm
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/schedule/employee') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/schedule/employee">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                        Lịch của tôi
                    </a>
                </li>
            </c:if>
        </ul>
    </nav>

    <div class="sidebar-footer">
        <div class="sidebar-user">
            <a href="${pageContext.request.contextPath}/profile" class="user-profile-link" title="Xem hồ sơ cá nhân">
                <div class="user-avatar">
                    <c:choose>
                        <c:when test="${not empty sessionScope.avatarUrl}">
                            <img src="${pageContext.request.contextPath}${sessionScope.avatarUrl}" alt="Avatar">
                        </c:when>
                        <c:when test="${not empty sessionScope.fullName}">
                            <c:out value="${sessionScope.fullName.substring(0, 1).toUpperCase()}" />
                        </c:when>
                        <c:otherwise>U</c:otherwise>
                    </c:choose>
                </div>
                <div class="user-info">
                    <span class="user-name">
                        <c:out value="${not empty sessionScope.fullName ? sessionScope.fullName : 'Hệ thống'}" />
                    </span>
                    <span class="user-role">
                        <c:choose>
                            <c:when test="${sessionScope.roleGroup eq 'ADMIN'}">Admin</c:when>
                            <c:when test="${sessionScope.roleGroup eq 'HR'}">Quản lý Nhân sự</c:when>
                            <c:when test="${sessionScope.roleGroup eq 'MANAGER'}">Quản lý Bộ phận</c:when>
                            <c:otherwise>Nhân viên</c:otherwise>
                        </c:choose>
                    </span>
                </div>
            </a>
            <a href="${pageContext.request.contextPath}/logout" class="logout-icon" title="Đăng xuất">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                    <polyline points="16 17 21 12 16 7"></polyline>
                    <line x1="21" y1="12" x2="9" y2="12"></line>
                </svg>
            </a>
        </div>
    </div>
</aside>