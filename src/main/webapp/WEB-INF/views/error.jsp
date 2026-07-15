<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Lỗi | HRMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/layout.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/sidebar.css" />
    <style>
        .error-container {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100vh;
            text-align: center;
        }
        .error-code {
            font-size: 72px;
            font-weight: bold;
            color: #dc2626;
        }
        .error-message {
            font-size: 24px;
            color: #334155;
            margin-top: 16px;
        }
        .btn-back {
            margin-top: 24px;
            padding: 10px 20px;
            background: #3b82f6;
            color: #fff;
            text-decoration: none;
            border-radius: 6px;
            font-weight: 500;
        }
    </style>
</head>
<body>
    <%@ include file="/WEB-INF/common/sidebar.jsp" %>
    <main class="main-content">
        <div class="error-container">
            <div class="error-code">Oops!</div>
            <div class="error-message">${errorMessage != null ? errorMessage : "Đã xảy ra lỗi hệ thống."}</div>
            <a href="${pageContext.request.contextPath}/dashboard" class="btn-back">Quay lại trang chủ</a>
        </div>
    </main>
</body>
</html>
