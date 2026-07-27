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
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><path d="M16 8h-6a2 2 0 1 0 0 4h4a2 2 0 1 1 0 4H8"></path><path d="M12 18V6"></path></svg>
                        Lương
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/admin/insurance') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/admin/insurance">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 1 2.81.7A2 2 0 0 1 22 16.92z"></path><circle cx="12" cy="12" r="9"></circle><path d="M12 8v8M16 12H8" stroke-width="1.5"></path></svg>
                        Bảo hiểm
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

                <li class="nav-item ${pageContext.request.requestURI.contains('/nghi-phep') && !pageContext.request.requestURI.contains('/hr/leave-requests') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/nghi-phep">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                        Nghỉ phép cá nhân
                    </a>
                </li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/hr/leave-requests') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/hr/leave-requests">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
                        Duyệt nghỉ phép
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

                <li class="nav-section">Lương & Phúc Lợi</li>
                <li class="nav-item ">
                    <a href="/manager/department-payroll">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path></svg>
                        Lương Phòng Ban
                    </a>
                </li>
            </c:if>

            <%-- PHÂN HỆ: HR --%>
            <c:if test="${sessionScope.roleGroup eq 'HR'}">
                <c:choose>
                    <%-- 1. HR PAYROLL (Chuẩn theo Use Case 4.7 HR Payroll) --%>
                    <c:when test="${sessionScope.roleName eq 'HR Payroll' or sessionScope.roleName.contains('Payroll')}">
                        <li class="nav-section">Thời Gian &amp; Chấm Công</li>
                        <li class="nav-item ${pageContext.request.requestURI.contains('/cham-cong') ? 'active' : ''}">
                            <a href="${pageContext.request.contextPath}/cham-cong">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                                Chấm công
                            </a>
                        </li>

                        <li class="nav-section">Lương &amp; Phúc Lợi</li>
                        <li class="nav-item ${pageContext.request.requestURI.contains('/payrolls') || pageContext.request.requestURI.contains('/payroll') ? 'active' : ''}">
                            <a href="${pageContext.request.contextPath}/hr/payrolls">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="6" width="20" height="12" rx="2" ry="2"></rect><circle cx="12" cy="12" r="2"></circle><path d="M6 12h.01M18 12h.01"></path></svg>
                                Bảng lương
                            </a>
                        </li>
                        <li class="nav-item ${pageContext.request.requestURI.contains('/salary-scales') ? 'active' : ''}">
                            <a href="${pageContext.request.contextPath}/hr/salary-scales">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"></polyline><polyline points="17 6 23 6 23 12"></polyline></svg>
                                Thang bảng lương
                            </a>
                        </li>
                        <li class="nav-item ${pageContext.request.requestURI.contains('/allowance-types') ? 'active' : ''}">
                            <a href="${pageContext.request.contextPath}/hr/allowance-types">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="7"></circle><polyline points="8.21 13.89 7 23 12 20 17 23 15.79 13.88"></polyline></svg>
                                Loại phụ cấp
                            </a>
                        </li>
                        <li class="nav-item ${pageContext.request.requestURI.contains('/luong') ? 'active' : ''}">
                            <a href="${pageContext.request.contextPath}/luong">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><path d="M16 8h-6a2 2 0 1 0 0 4h4a2 2 0 1 1 0 4H8"></path><path d="M12 18V6"></path></svg>
                                Lương &amp; Thưởng
                            </a>
                        </li>
                    </c:when>

                    <%-- 2. HR RECRUITMENT (Chuẩn theo Use Case 4.8 HR Recruitment) --%>
                    <c:when test="${sessionScope.roleName eq 'HR Recruitment' or sessionScope.roleName.contains('Recruitment') or sessionScope.roleName.contains('Tuyển')}">
                        <li class="nav-section">Tuyển Dụng</li>
                        <li class="nav-item ${pageContext.request.requestURI.contains('/hr/vacancies') ? 'active' : ''}">
                            <a href="${pageContext.request.contextPath}/hr/vacancies">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path></svg>
                                Vị trí tuyển dụng
                            </a>
                        </li>
                        <li class="nav-item ${pageContext.request.requestURI.contains('/hr/candidates') ? 'active' : ''}">
                            <a href="${pageContext.request.contextPath}/hr/candidates">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><line x1="19" y1="8" x2="19" y2="14"></line><line x1="22" y1="11" x2="16" y2="11"></line></svg>
                                Ứng viên
                            </a>
                        </li>
                    </c:when>

                    <%-- 3. HR C&B (Chuẩn theo Use Case 4.6 HR C&B) --%>
                    <c:when test="${sessionScope.roleName eq 'HR C&B' or sessionScope.roleName eq 'HR CB' or sessionScope.roleName.contains('C&B') or sessionScope.roleName.contains('CB')}">
                        <li class="nav-section">Thời Gian &amp; Chấm Công</li>
                        <li class="nav-item ${pageContext.request.requestURI.contains('/cham-cong') && !pageContext.request.requestURI.contains('/thong-ke') ? 'active' : ''}">
                            <a href="${pageContext.request.contextPath}/cham-cong">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                                Chấm công
                            </a>
                        </li>
                        <li class="nav-item ${pageContext.request.requestURI.contains('/cham-cong/thong-ke') ? 'active' : ''}">
                            <a href="${pageContext.request.contextPath}/cham-cong/thong-ke">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="20" x2="18" y2="10"></line><line x1="12" y1="20" x2="12" y2="4"></line><line x1="6" y1="20" x2="6" y2="14"></line></svg>
                                Thống kê chấm công
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

                        <li class="nav-section">Lương &amp; Phúc Lợi</li>
                        <li class="nav-item ${pageContext.request.requestURI.contains('/luong') ? 'active' : ''}">
                            <a href="${pageContext.request.contextPath}/luong">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><path d="M16 8h-6a2 2 0 1 0 0 4h4a2 2 0 1 1 0 4H8"></path><path d="M12 18V6"></path></svg>
                                Lương &amp; Thưởng
                            </a>
                        </li>
                        <li class="nav-item ${pageContext.request.requestURI.contains('/allowance-types') ? 'active' : ''}">
                            <a href="${pageContext.request.contextPath}/hr/allowance-types">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="7"></circle><polyline points="8.21 13.89 7 23 12 20 17 23 15.79 13.88"></polyline></svg>
                                Loại phụ cấp
                            </a>
                        </li>
                        <li class="nav-item ${pageContext.request.requestURI.contains('/insurance') ? 'active' : ''}">
                            <a href="${pageContext.request.contextPath}/hr/insurance">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path><circle cx="12" cy="12" r="9"></circle><path d="M12 8v8M16 12H8" stroke-width="1.5"></path></svg>
                                Bảo hiểm
                            </a>
                        </li>
                    </c:when>

                    <%-- 4. HR TỔNG HỢP / HR MANAGER / HR DIRECTOR (Chuẩn theo Use Case 4.3 HR) --%>
                    <c:otherwise>
                        <li class="nav-section">Cơ Cấu Tổ Chức &amp; Nhân Sự</li>
                        <li class="nav-item ${pageContext.request.requestURI.contains('/hr/users') ? 'active' : ''}">
                            <a href="${pageContext.request.contextPath}/hr/users">
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

                        <li class="nav-section">Tuyển Dụng</li>
                        <li class="nav-item ${pageContext.request.requestURI.contains('/hr/vacancies') ? 'active' : ''}">
                            <a href="${pageContext.request.contextPath}/hr/vacancies">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path></svg>
                                Vị trí tuyển dụng
                            </a>
                        </li>
                        <li class="nav-item ${pageContext.request.requestURI.contains('/hr/candidates') ? 'active' : ''}">
                            <a href="${pageContext.request.contextPath}/hr/candidates">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><line x1="19" y1="8" x2="19" y2="14"></line><line x1="22" y1="11" x2="16" y2="11"></line></svg>
                                Ứng viên
                            </a>
                        </li>

                        <li class="nav-section">Thời Gian &amp; Chấm Công</li>
                        <li class="nav-item ${pageContext.request.requestURI.contains('/cham-cong') && !pageContext.request.requestURI.contains('/thong-ke') ? 'active' : ''}">
                            <a href="${pageContext.request.contextPath}/cham-cong">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                                Chấm công
                            </a>
                        </li>
                        <li class="nav-item ${pageContext.request.requestURI.contains('/hr/work-shifts') ? 'active' : ''}">
                            <a href="${pageContext.request.contextPath}/hr/work-shifts">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 14 14"></polyline></svg>
                                Ca làm việc
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
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><path d="M16 8h-6a2 2 0 1 0 0 4h4a2 2 0 1 1 0 4H8"></path><path d="M12 18V6"></path></svg>
                                Lương &amp; Thưởng
                            </a>
                        </li>
                        <li class="nav-item ${pageContext.request.requestURI.contains('/payrolls') || pageContext.request.requestURI.contains('/payroll') ? 'active' : ''}">
                            <a href="${pageContext.request.contextPath}/hr/payrolls">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="6" width="20" height="12" rx="2" ry="2"></rect><circle cx="12" cy="12" r="2"></circle><path d="M6 12h.01M18 12h.01"></path></svg>
                                Bảng lương
                            </a>
                        </li>
                        <li class="nav-item ${pageContext.request.requestURI.contains('/salary-scales') ? 'active' : ''}">
                            <a href="${pageContext.request.contextPath}/hr/salary-scales">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"></polyline><polyline points="17 6 23 6 23 12"></polyline></svg>
                                Thang bảng lương
                            </a>
                        </li>
                        <li class="nav-item ${pageContext.request.requestURI.contains('/allowance-types') ? 'active' : ''}">
                            <a href="${pageContext.request.contextPath}/hr/allowance-types">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="7"></circle><polyline points="8.21 13.89 7 23 12 20 17 23 15.79 13.88"></polyline></svg>
                                Loại phụ cấp
                            </a>
                        </li>
                        <li class="nav-item ${pageContext.request.requestURI.contains('/insurance') ? 'active' : ''}">
                            <a href="${pageContext.request.contextPath}/hr/insurance">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path><circle cx="12" cy="12" r="9"></circle><path d="M12 8v8M16 12H8" stroke-width="1.5"></path></svg>
                                Bảo hiểm
                            </a>
                        </li>
                    </c:otherwise>
                </c:choose>
            </c:if>

            <%-- PHÂN HỆ: ADMIN --%>
            <c:if test="${sessionScope.roleGroup eq 'ADMIN'}">
                <li class="nav-section">Cơ Cấu Tổ Chức</li>
                <li class="nav-item ${pageContext.request.requestURI.contains('/hr/departments') ? 'active' : ''}">
                    <a href="${pageContext.request.contextPath}/hr/departments">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path></svg>
                        Phòng ban
                    </a>
                </li>

                <li class="nav-section">Thời Gian &amp; Chấm Công</li>
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
            </c:if>
        </ul>
    </nav>

            <div class="sidebar-footer">
                <div class="sidebar-user">
                    <a href="${pageContext.request.contextPath}/profile" class="user-profile-link"
                        title="Xem hồ sơ cá nhân">
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
                                <c:out
                                    value="${not empty sessionScope.fullName ? sessionScope.fullName : 'Hệ thống'}" />
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

                    <!-- Bell Icon + Dropdown Panel -->
                    <div id="noti-wrapper" style="position: relative;">
                        <button id="notification-bell" onclick="toggleNotiPanel(event)" title="Thong bao"
                            style="background:none; border:none; cursor:pointer; position:relative; padding:4px; display:flex; align-items:center; color: #64748b;">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:20px;height:20px;">
                                <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path>
                                <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
                            </svg>
                            <span id="noti-badge" style="display:none; position:absolute; top:-4px; right:-4px; background:#ef4444; color:#fff; border-radius:50%; min-width:17px; height:17px; font-size:10px; font-weight:700; line-height:17px; text-align:center; padding:0 3px;">0</span>
                        </button>

                        <!-- Dropdown Panel -->
                        <div id="noti-panel" style="display:none; position:fixed; bottom:70px; left:16px; width:340px; max-height:450px;
                             background:#1e293b; border-radius:14px; box-shadow:0 20px 60px rgba(0,0,0,0.5);
                             z-index:9998; overflow:hidden; border:1px solid rgba(255,255,255,0.1);">
                            <div style="padding:14px 18px; border-bottom:1px solid rgba(255,255,255,0.1); display:flex; justify-content:space-between; align-items:center;">
                                <span style="color:#f1f5f9; font-weight:700; font-size:14px;">Thong bao</span>
                                <button onclick="markAllRead()" style="background:none;border:none;color:#64748b;cursor:pointer;font-size:12px;padding:0;text-decoration:underline;">Doc tat ca</button>
                            </div>
                            <div id="noti-list" style="overflow-y:auto; max-height:370px; padding:8px 0;">
                                <div id="noti-empty" style="text-align:center; padding:32px 16px; color:#64748b; font-size:13px;">
                                    Khong co thong bao moi
                                </div>
                            </div>
                        </div>
                    </div>

                    <a href="${pageContext.request.contextPath}/logout" class="logout-icon" title="Dang xuat">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                            stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                            <polyline points="16 17 21 12 16 7"></polyline>
                            <line x1="21" y1="12" x2="9" y2="12"></line>
                        </svg>
                    </a>
                </div>
            </div>
        </aside>

        <!-- Toast Notification Styles -->
        <style>
            #noti-toast-container {
                position: fixed;
                top: 20px;
                right: 20px;
                z-index: 9999;
                display: flex;
                flex-direction: column;
                gap: 10px;
                pointer-events: none;
            }
            .noti-toast {
                display: flex;
                align-items: flex-start;
                gap: 12px;
                background: #1e293b;
                color: #f8fafc;
                padding: 14px 18px;
                border-radius: 12px;
                box-shadow: 0 8px 30px rgba(0,0,0,0.35);
                min-width: 300px;
                max-width: 420px;
                pointer-events: all;
                animation: slideInToast 0.35s cubic-bezier(0.34,1.56,0.64,1) forwards;
                border-left: 4px solid #4f46e5;
            }
            .noti-toast.toast-success { border-left-color: #22c55e; }
            .noti-toast.toast-warning { border-left-color: #f59e0b; }
            .noti-toast-icon {
                width: 20px;
                height: 20px;
                flex-shrink: 0;
                margin-top: 1px;
                color: #4f46e5;
            }
            .noti-toast.toast-success .noti-toast-icon { color: #22c55e; }
            .noti-toast.toast-warning .noti-toast-icon { color: #f59e0b; }
            .noti-toast-body { flex: 1; }
            .noti-toast-title { font-weight: 700; font-size: 14px; margin-bottom: 3px; }
            .noti-toast-content { font-size: 13px; color: #94a3b8; line-height: 1.4; }
            .noti-toast-close {
                background: none; border: none; color: #64748b;
                cursor: pointer; font-size: 16px; padding: 0; line-height: 1;
                flex-shrink: 0; margin-top: -2px;
            }
            .noti-toast-close:hover { color: #f8fafc; }
            @keyframes slideInToast {
                from { opacity: 0; transform: translateX(60px) scale(0.9); }
                to   { opacity: 1; transform: translateX(0) scale(1); }
            }
            @keyframes fadeOutToast {
                from { opacity: 1; transform: translateX(0); }
                to   { opacity: 0; transform: translateX(60px); }
            }
        </style>

        <!-- Toast Container -->
        <div id="noti-toast-container"></div>

        <!-- Script Notification SSE -->
        <style>
            #noti-panel .noti-item:hover { background: rgba(255,255,255,0.05) !important; }
        </style>
        <script>
            var _notiPanelOpen = false;

            function toggleNotiPanel(e) {
                e.stopPropagation();
                var panel = document.getElementById('noti-panel');
                _notiPanelOpen = !_notiPanelOpen;
                panel.style.display = _notiPanelOpen ? 'block' : 'none';
                if (_notiPanelOpen) loadNotiPanel();
            }

            document.addEventListener('click', function(e) {
                var wrapper = document.getElementById('noti-wrapper');
                if (_notiPanelOpen && wrapper && !wrapper.contains(e.target)) {
                    document.getElementById('noti-panel').style.display = 'none';
                    _notiPanelOpen = false;
                }
            });

            function loadNotiPanel() {
                fetch('${pageContext.request.contextPath}/api/notifications/')
                    .then(function(r) { return r.json(); })
                    .then(function(list) { renderNotiList(list); })
                    .catch(function() {});
            }

            function renderNotiList(list) {
                var container = document.getElementById('noti-list');
                var empty = document.getElementById('noti-empty');
                container.querySelectorAll('.noti-item').forEach(function(el) { el.remove(); });
                if (!list || list.length === 0) { empty.style.display = 'block'; return; }
                empty.style.display = 'none';
                list.forEach(function(item) {
                    var n = item.notification || {};
                    var tc = n.type === 'SUCCESS' ? '#22c55e' : (n.type === 'WARNING' ? '#f59e0b' : '#4f46e5');
                    var div = document.createElement('div');
                    div.className = 'noti-item';
                    div.setAttribute('data-id', item.id);
                    div.style.padding = '12px 18px';
                    div.style.borderBottom = '1px solid rgba(255,255,255,0.06)';
                    div.style.cursor = 'pointer';
                    div.style.transition = 'background 0.15s';
                    div.style.background = item.read ? 'transparent' : 'rgba(79,70,229,0.08)';

                    var wrapper2 = document.createElement('div');
                    wrapper2.style.display = 'flex';
                    wrapper2.style.gap = '10px';
                    wrapper2.style.alignItems = 'flex-start';

                    var dot = document.createElement('div');
                    dot.style.width = '8px';
                    dot.style.height = '8px';
                    dot.style.borderRadius = '50%';
                    dot.style.background = item.read ? 'transparent' : tc;
                    dot.style.flexShrink = '0';
                    dot.style.marginTop = '5px';

                    var body2 = document.createElement('div');
                    body2.style.flex = '1';
                    body2.style.minWidth = '0';

                    var titleEl = document.createElement('div');
                    titleEl.style.fontWeight = '600';
                    titleEl.style.fontSize = '13px';
                    titleEl.style.color = '#f1f5f9';
                    titleEl.style.marginBottom = '2px';
                    titleEl.textContent = n.title || '';

                    var contentEl = document.createElement('div');
                    contentEl.style.fontSize = '12px';
                    contentEl.style.color = '#94a3b8';
                    contentEl.style.lineHeight = '1.4';
                    contentEl.textContent = n.content || '';

                    body2.appendChild(titleEl);
                    body2.appendChild(contentEl);
                    wrapper2.appendChild(dot);
                    wrapper2.appendChild(body2);
                    div.appendChild(wrapper2);

                    div.addEventListener('click', (function(id, el, dotEl) {
                        return function() { markOneRead(id, el, dotEl); };
                    })(item.id, div, dot));

                    container.insertBefore(div, empty);
                });
            }

            function prependNotiItem(title, content, type) {
                document.getElementById('noti-empty').style.display = 'none';
                var container = document.getElementById('noti-list');
                var tc = type === 'SUCCESS' ? '#22c55e' : (type === 'WARNING' ? '#f59e0b' : '#4f46e5');
                var div = document.createElement('div');
                div.className = 'noti-item';
                div.style.padding = '12px 18px';
                div.style.borderBottom = '1px solid rgba(255,255,255,0.06)';
                div.style.background = 'rgba(79,70,229,0.08)';

                var wrapper2 = document.createElement('div');
                wrapper2.style.display = 'flex';
                wrapper2.style.gap = '10px';
                wrapper2.style.alignItems = 'flex-start';

                var dot = document.createElement('div');
                dot.style.width = '8px'; dot.style.height = '8px';
                dot.style.borderRadius = '50%'; dot.style.background = tc;
                dot.style.flexShrink = '0'; dot.style.marginTop = '5px';

                var body2 = document.createElement('div');
                body2.style.flex = '1'; body2.style.minWidth = '0';

                var titleEl = document.createElement('div');
                titleEl.style.fontWeight = '600'; titleEl.style.fontSize = '13px';
                titleEl.style.color = '#f1f5f9'; titleEl.style.marginBottom = '2px';
                titleEl.textContent = title;

                var contentEl = document.createElement('div');
                contentEl.style.fontSize = '12px'; contentEl.style.color = '#94a3b8';
                contentEl.style.lineHeight = '1.4';
                contentEl.textContent = content;

                body2.appendChild(titleEl); body2.appendChild(contentEl);
                wrapper2.appendChild(dot); wrapper2.appendChild(body2);
                div.appendChild(wrapper2);
                container.insertBefore(div, container.firstChild);
            }

            function markOneRead(id, el, dotEl) {
                fetch('${pageContext.request.contextPath}/api/notifications/read/' + id, { method: 'POST' })
                    .then(function() {
                        el.style.background = 'transparent';
                        if (dotEl) dotEl.style.background = 'transparent';
                        decreaseBadge();
                    }).catch(function() {});
            }

            function markAllRead() {
                fetch('${pageContext.request.contextPath}/api/notifications/read-all', { method: 'POST' })
                    .then(function() {
                        var badge = document.getElementById('noti-badge');
                        badge.style.display = 'none'; badge.innerText = '0';
                        document.querySelectorAll('.noti-item').forEach(function(el) {
                            el.style.background = 'transparent';
                        });
                    }).catch(function() {});
            }

            function decreaseBadge() {
                var badge = document.getElementById('noti-badge');
                var c = Math.max(0, (parseInt(badge.innerText) || 0) - 1);
                badge.innerText = c;
                if (c <= 0) badge.style.display = 'none';
            }

            function showNotiToast(title, content, type) {
                var container = document.getElementById('noti-toast-container');
                if (!container) return;
                var tc = type === 'SUCCESS' ? 'toast-success' : (type === 'WARNING' ? 'toast-warning' : '');
                var toast = document.createElement('div');
                toast.className = 'noti-toast ' + tc;

                var svg = document.createElement('span');
                svg.innerHTML = '<svg class="noti-toast-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>';

                var bodyEl = document.createElement('div');
                bodyEl.className = 'noti-toast-body';
                var titleEl = document.createElement('div');
                titleEl.className = 'noti-toast-title';
                titleEl.textContent = title;
                var contentEl = document.createElement('div');
                contentEl.className = 'noti-toast-content';
                contentEl.textContent = content;
                bodyEl.appendChild(titleEl); bodyEl.appendChild(contentEl);

                var closeBtn = document.createElement('button');
                closeBtn.className = 'noti-toast-close';
                closeBtn.textContent = '\u00d7';
                closeBtn.onclick = function() { this.closest('.noti-toast').remove(); };

                toast.appendChild(svg.firstChild); toast.appendChild(bodyEl); toast.appendChild(closeBtn);
                container.appendChild(toast);

                setTimeout(function() {
                    toast.style.animation = 'fadeOutToast 0.3s ease forwards';
                    setTimeout(function() { if (toast.parentNode) toast.remove(); }, 300);
                }, 6000);
            }

            document.addEventListener('DOMContentLoaded', function() {
                var es = new EventSource('${pageContext.request.contextPath}/api/notifications/stream');
                es.onmessage = function(event) {
                    try {
                        var data = JSON.parse(event.data);
                        var badge = document.getElementById('noti-badge');
                        badge.innerText = (parseInt(badge.innerText) || 0) + 1;
                        badge.style.display = 'inline-block';
                        showNotiToast(data.title, data.content, data.type || 'INFO');
                        if (_notiPanelOpen) prependNotiItem(data.title, data.content, data.type || 'INFO');
                    } catch(e) {}
                };
                es.onerror = function() {
                    // Đóng kết nối lỗi ngay, tránh browser tự reconnect liên tục
                    es.close();
                };

                // ★ QUAN TRỌNG: Đóng SSE khi user rời trang → tránh kết nối zombie treo thread Tomcat
                window.addEventListener('beforeunload', function() {
                    if (es) { es.close(); }
                });

                fetch('${pageContext.request.contextPath}/api/notifications/count')
                    .then(function(r) { return r.json(); })
                    .then(function(data) {
                        if (data.count && data.count > 0) {
                            var badge = document.getElementById('noti-badge');
                            badge.innerText = data.count;
                            badge.style.display = 'inline-block';
                        }
                    }).catch(function() {});
            });
        </script>