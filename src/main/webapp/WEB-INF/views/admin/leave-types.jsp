<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Loại nghỉ phép | HRMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css">
</head>
<body>

<div class="main-layout">

    <%@ include file="/WEB-INF/common/sidebar.jsp" %>

    <div class="content-area">

        <div class="page-header">
            <div>
                <h1>Loại nghỉ phép</h1>
                <div class="subtitle">Danh sách các loại nghỉ phép trong hệ thống</div>
            </div>
        </div>

        <div class="card">

            <div class="table-wrap">
                <table>
                    <thead>
                    <tr>
                        <th>Mã</th>
                        <th>Tên</th>
                        <th>Số ngày/năm</th>
                        <th>Hưởng lương</th>
                        <th>Trạng thái</th>
                    </tr>
                    </thead>

                    <tbody>
                    <c:forEach items="${leaveTypes}" var="t">
                        <tr>
                            <td>${t.code}</td>
                            <td>${t.name}</td>
                            <td>${t.daysPerYear}</td>
                            <td>${t.paidPercentage}%</td>
                            <td>
                                <c:choose>
                                    <c:when test="${t.active}">
                                        <span class="badge badge-green">Đang dùng</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-red">Ngừng dùng</span>
                                    </c:otherwise>
                                </c:choose>
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
