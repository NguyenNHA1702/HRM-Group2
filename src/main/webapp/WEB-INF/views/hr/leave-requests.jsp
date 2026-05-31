<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Duyệt nghỉ phép | HRMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css">
    <style>
        /* ── Status badge cho trạng thái dạng text thô ── */
        .status-pending  { color: #92400e; background: #fef3c7; padding: 3px 10px; border-radius: 99px; font-size: 12px; font-weight: 500; }
        .status-approved { color: #166534; background: #dcfce7; padding: 3px 10px; border-radius: 99px; font-size: 12px; font-weight: 500; }
        .status-rejected { color: #991b1b; background: #fee2e2; padding: 3px 10px; border-radius: 99px; font-size: 12px; font-weight: 500; }
        .status-cancelled{ color: #374151; background: #f3f4f6; padding: 3px 10px; border-radius: 99px; font-size: 12px; font-weight: 500; }

        .action-group { display: flex; gap: 8px; }
    </style>
</head>
<body>

<div class="main-layout">

    <%@ include file="/WEB-INF/common/sidebar.jsp" %>

    <div class="content-area">

        <div class="page-header">
            <div>
                <h1>Duyệt nghỉ phép</h1>
                <div class="subtitle">Quản lý đơn nghỉ phép của nhân viên</div>
            </div>
        </div>

        <div class="card">

            <div class="table-wrap">
                <table>
                    <thead>
                    <tr>
                        <th>Nhân viên</th>
                        <th>Phòng ban</th>
                        <th>Loại nghỉ</th>
                        <th>Số ngày</th>
                        <th>Trạng thái</th>
                        <th>Thao tác</th>
                    </tr>
                    </thead>

                    <tbody>
                    <c:forEach items="${requests}" var="r">
                        <tr>
                            <td>${r.employeeName}</td>
                            <td>${r.departmentName}</td>
                            <td>${r.leaveTypeName}</td>
                            <td>${r.totalDays}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${r.status eq 'APPROVED'}">
                                        <span class="status-approved">Đã duyệt</span>
                                    </c:when>
                                    <c:when test="${r.status eq 'REJECTED'}">
                                        <span class="status-rejected">Từ chối</span>
                                    </c:when>
                                    <c:when test="${r.status eq 'PENDING'}">
                                        <span class="status-pending">Chờ duyệt</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="status-cancelled">Đã hủy</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:if test="${r.status eq 'PENDING'}">
                                    <form method="post"
                                          action="${pageContext.request.contextPath}/hr/leave-request/action">
                                        <input type="hidden" name="id" value="${r.id}">
                                        <div class="action-group">
                                            <button name="action" value="approve"
                                                    class="btn btn-success btn-sm">
                                                Duyệt
                                            </button>
                                            <button name="action" value="reject"
                                                    class="btn btn-danger btn-sm">
                                                Từ chối
                                            </button>
                                        </div>
                                    </form>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>

        </div>

    </div>
</div>

</body>
</html>
