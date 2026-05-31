<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%--
  create-leave.jsp — Trang tạo đơn dạng standalone (fallback).
  Khi đã tích hợp modal vào leave-request.jsp, trang này có thể không cần dùng nữa.
  Giữ lại phòng khi controller redirect trực tiếp đến /WEB-INF/views/employee/create-leave.jsp.
--%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Tạo đơn nghỉ phép | HRMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css">
    <style>
        .form-group { margin-bottom: 16px; }
        .form-group label {
            display: block;
            font-weight: 500;
            margin-bottom: 6px;
            font-size: 13px;
        }
        .form-control {
            width: 100%;
            padding: 9px 12px;
            border: 1px solid var(--border);
            border-radius: 8px;
            font-size: 14px;
            font-family: inherit;
            color: var(--text);
            background: var(--white);
            transition: border-color .15s, box-shadow .15s;
        }
        .form-control:focus {
            outline: none;
            border-color: var(--brand);
            box-shadow: 0 0 0 3px rgba(79,70,229,.12);
        }
        textarea.form-control { resize: vertical; }
    </style>
</head>
<body>

<div class="main-layout">

    <%@ include file="/WEB-INF/common/sidebar.jsp" %>

    <div class="content-area">

        <div class="page-header">
            <div>
                <h1>Tạo đơn nghỉ phép</h1>
            </div>
            <a href="${pageContext.request.contextPath}/nghi-phep"
               class="btn btn-secondary">
                ← Quay lại
            </a>
        </div>

        <div class="card" style="max-width: 560px;">
            <div class="card-body" style="padding: 28px;">

                <form method="post"
                      action="${pageContext.request.contextPath}/nghi-phep/create">

                    <div class="form-group">
                        <label for="leaveTypeId">Loại nghỉ</label>
                        <select name="leaveTypeId" id="leaveTypeId" class="form-control">
                            <c:forEach items="${leaveTypes}" var="t">
                                <option value="${t.id}">${t.name}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="startDate">Từ ngày</label>
                        <input type="date" name="startDate" id="startDate"
                               class="form-control" required>
                    </div>

                    <div class="form-group">
                        <label for="endDate">Đến ngày</label>
                        <input type="date" name="endDate" id="endDate"
                               class="form-control" required>
                    </div>

                    <div class="form-group">
                        <label for="reason">Lý do</label>
                        <textarea name="reason" id="reason" rows="5"
                                  class="form-control"
                                  placeholder="Nhập lý do nghỉ phép..."></textarea>
                    </div>

                    <div style="display:flex; gap:10px; margin-top:8px;">
                        <button type="submit" class="btn btn-primary">Gửi đơn</button>
                        <a href="${pageContext.request.contextPath}/nghi-phep"
                           class="btn btn-secondary">Hủy</a>
                    </div>

                </form>

            </div>
        </div>

    </div>
</div>

</body>
</html>
