<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Departments Management</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/departments.css">

</head>
<body style="background-color: #f8f9fa;">
<div class="d-flex">
    <%@ include file="/WEB-INF/common/sidebar.jsp" %>

    <div class="container-fluid p-4">
        <div class="mb-4">
            <h2 class="font-weight-bold text-dark" style="font-size: 28px; letter-spacing: -0.5px;">Quản lý Phòng Ban</h2>
            <p class="text-muted" style="font-size: 14px;">Xin chào, <c:out value="${not empty sessionScope.fullName ? sessionScope.fullName : 'Hệ thống'}" /></p>
        </div>

        <c:if test="${not empty message}">
            <div class="alert alert-info alert-dismissible fade show border-0 shadow-sm mb-4" role="alert" style="border-left: 4px solid #6366f1 !important; background-color: #fff; color: #4e73df; border-radius: 8px;">
                    ${message}
                <button type="button" class="close" data-dismiss="alert" aria-label="Close" style="outline: none;">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
        </c:if>

        <div class="mb-4">
            <button type="button" class="btn text-white px-4 py-2"
                    style="background-color: #6366f1; border-radius: 8px; font-weight: 500; border: none; box-shadow: 0 4px 6px -1px rgba(99, 102, 241, 0.2);"
                    data-toggle="modal" data-target="#departmentModal" onclick="openAddModal()">
                + Tạo phòng ban mới
            </button>
        </div>

        <div class="card border-0 shadow-sm mb-4 p-3" style="border-radius: 12px; background: white;">
            <div class="row align-items-center">
                <div class="col-md-5 search-box-container">
                    <div class="input-group">
                        <div class="input-group-prepend">
                            <span class="input-group-text">
                                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#a0aec0" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <circle cx="11" cy="11" r="8"></circle>
                                    <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                                </svg>
                            </span>
                        </div>
                        <input type="text" id="searchKeyword" class="form-control form-control-search" placeholder="Tìm kiếm theo mã hoặc tên phòng ban..." style="height: calc(1.5em + .75rem + 10px);" oninput="onFilterChange()">
                    </div>
                </div>
                <div class="col-md-4 mt-2 mt-md-0">
                    <select id="filterParent" class="form-control filter-select" onchange="onFilterChange()">
                        <option value="">Tất cả Phòng ban cha</option>
                        <c:forEach var="d" items="${departments}">
                            <c:if test="${empty d.parentId}">
                                <option value="${d.name}">${d.name}</option>
                            </c:if>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-3 mt-2 mt-md-0">
                    <select id="filterStatus" class="form-control filter-select" onchange="onFilterChange()">
                        <option value="">Tất cả trạng thái</option>
                        <option value="1">Active</option>
                        <option value="0">Deactive</option>
                    </select>
                </div>
            </div>
        </div>

        <div class="card border-0 shadow-sm mb-4" style="border-radius: 12px; overflow: hidden;">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0" style="background: white;" id="deptTable">
                    <thead style="background-color: #fafafa; border-bottom: 2px solid #f0f0f0;">
                    <tr>
                        <th class="text-secondary font-weight-bold text-uppercase px-4 py-3" style="font-size: 11px; border: none; width: 80px;">ID</th>
                        <th class="text-secondary font-weight-bold text-uppercase py-3" style="font-size: 11px; border: none; width: 120px;">Mã Phòng</th>
                        <th class="text-secondary font-weight-bold text-uppercase py-3" style="font-size: 11px; border: none;">Tên Phòng Ban</th>
                        <th class="text-secondary font-weight-bold text-uppercase py-3" style="font-size: 11px; border: none;">Phòng Ban Cha</th>
                        <th class="text-secondary font-weight-bold text-uppercase py-3" style="font-size: 11px; border: none;">Trưởng phòng</th>
                        <th class="text-secondary font-weight-bold text-uppercase py-3" style="font-size: 11px; border: none; width: 110px;">Số nhân sự</th>
                        <th class="text-secondary font-weight-bold text-uppercase py-3" style="font-size: 11px; border: none; max-width: 300px;">Mô tả</th>
                        <th class="text-secondary font-weight-bold text-uppercase py-3" style="font-size: 11px; border: none; width: 130px;">Trạng thái</th>
                        <th class="text-secondary font-weight-bold text-uppercase text-center px-4 py-3" style="font-size: 11px; border: none; width: 100px;">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody style="font-size: 14px; color: #4a5568;">
                    <c:forEach var="dept" items="${departments}">
                        <tr class="dept-row"
                            data-code="${dept.code.toLowerCase().trim()}"
                            data-name="${dept.name.toLowerCase().trim()}"
                            data-parentname="${not empty dept.parentName ? dept.parentName.trim() : ''}"
                            data-status="${dept.isActive}"
                            style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s;">
                            <td class="px-4 text-muted">${dept.id}</td>
                            <td><span class="font-weight-bold text-dark" style="letter-spacing: 0.5px;">${dept.code}</span></td>
                            <td class="font-weight-normal text-dark">${dept.name}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty dept.parentName}">
                                        <span class="badge badge-light text-secondary border px-2 py-1" style="border-radius: 6px; font-weight: 500; background-color: #f8f9fa;">${dept.parentName}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted" style="font-size: 13px;">-</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty dept.managerName}">
                                        <span class="font-weight-normal text-dark">${dept.managerName}</span>
                                        <c:if test="${not empty dept.managerCode}">
                                            <br><small class="text-muted">${dept.managerCode}</small>
                                        </c:if>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted" style="font-size: 13px;">Chưa bổ nhiệm</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <span class="badge badge-pill text-secondary px-2 py-1" style="background-color: #f1f5f9; color: #6366f1 !important; font-weight: 600; font-size: 13px; border-radius: 50px;">
                                    <c:out value="${dept.totalEmployees}" /> người
                                </span>
                            </td>
                            <td class="text-muted" style="max-width: 300px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                <c:out value="${not empty dept.description ? dept.description : '_'}" />
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${dept.isActive == 1}">
                                        <span class="badge px-2 py-1" style="background-color: #e6f4ea; color: #137333; border-radius: 6px; font-size: 12px; font-weight: 500;">Active</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge px-2 py-1" style="background-color: #fce8e6; color: #c5221f; border-radius: 6px; font-size: 12px; font-weight: 500;">Deactive</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-center px-4">
                                <button class="btn btn-link p-0 border-0"
                                        style="outline: none; background: none;"
                                        data-toggle="modal"
                                        data-target="#departmentModal"
                                        onclick="openEditModal(this)"
                                        data-id="${dept.id}"
                                        data-code="${dept.code}"
                                        data-name="${dept.name}"
                                        data-parent="${dept.parentId}"
                                        data-desc="${dept.description}"
                                        data-active="${dept.isActive}"
                                        data-managerid="${dept.managerId}"
                                        data-managercode="${dept.managerCode}"
                                        data-managername="${dept.managerName}"
                                        title="Chỉnh sửa">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#4e73df" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                        <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                                        <path d="M18.5 2.5a2.121 2.121 0 1 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                                    </svg>
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                    <tr id="noDataRow" style="display: none;">
                        <td colspan="9" class="text-center text-muted py-4" style="background: white;">Không tìm thấy phòng ban nào phù hợp với bộ lọc!</td>
                    </tr>
                    </tbody>
                </table>
            </div>

            <div class="card-footer d-flex justify-content-between align-middle border-0 py-3" style="background: white; border-top: 1px solid #f1f5f9 !important;">
                <div class="text-muted" id="paginationInfo" style="font-size: 14px; pt: 5px;"></div>
                <nav aria-label="Page navigation">
                    <ul class="pagination pagination-sm mb-0" id="paginationControls">
                    </ul>
                </nav>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="departmentModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 12px;">
            <form action="${pageContext.request.contextPath}/hr/departments" method="POST">
                <div class="modal-header border-bottom-0 pb-0">
                    <h5 class="modal-title font-weight-bold text-dark" id="modalTitle" style="font-size: 20px;">Add New Department</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close" style="outline: none;">
                        <span aria-hidden="true" style="font-size: 24px;">&times;</span>
                    </button>
                </div>
                <div class="modal-body py-3">
                    <input type="hidden" name="action" id="modalAction" value="add">
                    <input type="hidden" name="id" id="deptId">

                    <div class="form-group mb-3">
                        <label class="text-dark font-weight-500" style="font-size: 14px;">Mã Phòng Ban <span class="text-danger">*</span></label>
                        <input type="text" name="code" id="deptCode" class="form-control" style="border-radius: 6px; padding: 10px;" required>
                    </div>
                    <div class="form-group mb-3">
                        <label class="text-dark font-weight-500" style="font-size: 14px;">Tên Phòng Ban <span class="text-danger">*</span></label>
                        <input type="text" name="name" id="deptName" class="form-control" style="border-radius: 6px; padding: 10px;" required>
                    </div>
                     <div class="form-group mb-3 position-relative">
                        <label class="text-dark font-weight-500" style="font-size: 14px;" for="manager_search">Trưởng phòng <span class="text-danger">*</span></label>
                        <input type="text" id="manager_search" class="form-control"
                               placeholder="Gõ mã NV hoặc tên để tìm..." autocomplete="off"
                               style="border-radius: 6px; padding: 10px;" required>
                        <div id="suggestion_box" class="dropdown-menu w-100 shadow-sm" style="display: none; max-height: 200px; overflow-y: auto; position: absolute; z-index: 1000; top: 100%;"></div>
                        <input type="hidden" id="manager_id" name="manager_id">
                        <small id="managerHint" class="text-muted" style="font-size: 12px; display: none;"></small>
                    </div>
                    <div class="form-group mb-3">
                        <label class="text-dark font-weight-500" style="font-size: 14px;">Phòng Ban Cha (Cấp trên)</label>
                        <select name="parentId" id="deptParent" class="form-control" style="border-radius: 6px; height: auto; padding: 8px 12px;">
                            <option value="">-- Cấp cao nhất (None) --</option>
                            <c:forEach var="d" items="${departments}">
                                <option value="${d.id}">${d.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="form-group mb-3">
                        <label class="text-dark font-weight-500" style="font-size: 14px;">Mô tả chi tiết</label>
                        <textarea name="description" id="deptDesc" class="form-control" rows="3" style="border-radius: 6px;"></textarea>
                    </div>
                    <div class="form-group mb-2">
                        <label class="text-dark font-weight-500" style="font-size: 14px;">Trạng thái hoạt động</label>
                        <select name="isActive" id="deptActive" class="form-control" style="border-radius: 6px; height: auto; padding: 8px 12px;">
                            <option value="1">Active</option>
                            <option value="0">Deactive</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer border-top-0 pt-0">
                    <button type="button" class="btn btn-light px-4" data-dismiss="modal" style="border-radius: 6px; font-weight: 500;">Hủy</button>
                    <button type="submit" class="btn text-white px-4" style="background-color: #6366f1; border-radius: 6px; font-weight: 500;">Lưu thay đổi</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/jquery@3.5.1/dist/jquery.slim.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
<script>const CTX = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/assets/js/departments.js?v=<%= System.currentTimeMillis() %>"></script>
</body>
</html>