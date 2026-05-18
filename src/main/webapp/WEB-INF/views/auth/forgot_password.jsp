<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quên mật khẩu - HRM System</title>
    <!-- Google Font: Outfit -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- FontAwesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            font-family: 'Outfit', sans-serif;
            background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 100%);
            color: #f8fafc;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            padding: 20px;
            box-sizing: border-box;
            overflow: hidden;
            position: relative;
        }

        /* Background glow blobs */
        .bg-blob {
            position: absolute;
            border-radius: 50%;
            filter: blur(120px);
            z-index: 1;
            opacity: 0.45;
        }
        .blob-1 {
            width: 400px;
            height: 400px;
            background: #6366f1;
            top: -100px;
            left: -100px;
        }
        .blob-2 {
            width: 400px;
            height: 400px;
            background: #a855f7;
            bottom: -150px;
            right: -100px;
        }

        .forgot-wrapper {
            background: rgba(30, 41, 59, 0.7);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 24px;
            padding: 45px;
            width: 100%;
            max-width: 480px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
            z-index: 10;
            box-sizing: border-box;
            animation: fadeIn 0.8s cubic-bezier(0.16, 1, 0.3, 1) forwards;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .logo-section {
            text-align: center;
            margin-bottom: 30px;
        }
        .logo-section i {
            font-size: 3.5rem;
            background: linear-gradient(135deg, #818cf8 0%, #c084fc 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 12px;
            filter: drop-shadow(0 4px 10px rgba(99, 102, 241, 0.3));
        }
        .logo-section h2 {
            margin: 0;
            font-size: 1.85rem;
            font-weight: 800;
            letter-spacing: -0.5px;
            background: linear-gradient(to right, #ffffff, #cbd5e1);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .logo-section p {
            color: #94a3b8;
            font-size: 0.95rem;
            margin: 8px 0 0 0;
            line-height: 1.5;
        }

        .form-group {
            margin-bottom: 24px;
            position: relative;
        }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #cbd5e1;
            font-weight: 500;
            font-size: 0.9rem;
        }
        .input-wrapper {
            position: relative;
        }
        .input-wrapper i {
            position: absolute;
            left: 16px;
            top: 50%;
            transform: translateY(-50%);
            color: #64748b;
            font-size: 1.1rem;
            transition: color 0.3s;
        }
        .form-group input[type="email"] {
            width: 100%;
            padding: 14px 16px 14px 48px;
            border: 1px solid rgba(255, 255, 255, 0.12);
            background: rgba(15, 23, 42, 0.4);
            border-radius: 12px;
            font-size: 1rem;
            color: #ffffff;
            box-sizing: border-box;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .form-group input[type="email"]::placeholder {
            color: #64748b;
        }
        .form-group input[type="email"]:focus {
            outline: none;
            border-color: #6366f1;
            background: rgba(15, 23, 42, 0.7);
            box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.15);
        }
        .form-group input[type="email"]:focus + i {
            color: #818cf8;
        }

        .btn-submit {
            width: 100%;
            padding: 14px;
            border: none;
            border-radius: 12px;
            background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
            color: #ffffff;
            font-weight: 600;
            font-size: 1rem;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(99, 102, 241, 0.3);
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 8px;
        }
        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(99, 102, 241, 0.4);
            background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
        }
        .btn-submit:active {
            transform: translateY(0);
        }

        .back-to-login {
            text-align: center;
            margin-top: 25px;
        }
        .back-to-login a {
            color: #94a3b8;
            text-decoration: none;
            font-size: 0.95rem;
            font-weight: 500;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .back-to-login a:hover {
            color: #818cf8;
        }

        /* Alert notifications */
        .alert {
            padding: 14px 18px;
            border-radius: 12px;
            margin-bottom: 24px;
            font-size: 0.92rem;
            line-height: 1.5;
            display: flex;
            align-items: flex-start;
            gap: 10px;
        }
        .alert-success {
            background: rgba(16, 185, 129, 0.15);
            border: 1px solid rgba(16, 185, 129, 0.25);
            color: #34d399;
        }
        .alert-danger {
            background: rgba(239, 68, 68, 0.15);
            border: 1px solid rgba(239, 68, 68, 0.25);
            color: #f87171;
        }
    </style>
</head>
<body>

    <div class="bg-blob blob-1"></div>
    <div class="bg-blob blob-2"></div>

    <div class="forgot-wrapper">
        <div class="logo-section">
            <i class="fa-solid fa-unlock-keyhole"></i>
            <h2>Quên mật khẩu</h2>
            <p>Nhập email công ty hoặc email cá nhân đã đăng ký với hệ thống để nhận mật khẩu tạm thời mới.</p>
        </div>

        <c:if test="${not empty error}">
            <div class="alert alert-danger">
                <i class="fa-solid fa-triangle-exclamation" style="margin-top: 3px;"></i>
                <div>${error}</div>
            </div>
        </c:if>
        
        <c:if test="${not empty success}">
            <div class="alert alert-success">
                <i class="fa-solid fa-circle-check" style="margin-top: 3px;"></i>
                <div>${success}</div>
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/forgot-password" method="post">
            <div class="form-group">
                <label for="email">Địa chỉ Email</label>
                <div class="input-wrapper">
                    <input type="email" id="email" name="email" required placeholder="example@company.com">
                    <i class="fa-solid fa-envelope"></i>
                </div>
            </div>

            <button type="submit" class="btn-submit">
                <i class="fa-solid fa-paper-plane"></i> Gửi mật khẩu mới
            </button>
        </form>

        <div class="back-to-login">
            <a href="${pageContext.request.contextPath}/index.jsp">
                <i class="fa-solid fa-arrow-left"></i> Quay lại trang chủ
            </a>
        </div>
    </div>

</body>
</html>
