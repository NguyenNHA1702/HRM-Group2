<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HRMS - Dashboard</title>
    <style>
        /* CSS tạm thời cho nội dung chính */
        .welcome-card {
            background: linear-gradient(135deg, #6366f1, #a855f7);
            border-radius: 20px;
            padding: 40px;
            color: white;
            margin-bottom: 30px;
            box-shadow: 0 10px 20px rgba(99, 102, 241, 0.2);
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
        }
        .stat-item {
            background: white;
            padding: 24px;
            border-radius: 16px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 4px 6px rgba(0,0,0,0.02);
        }
    </style>
</head>
<body>

<div class="main-layout">
    <!-- 1. Tùng nhúng Sidebar vào đây -->
    <%@include file="/WEB-INF/common/sidebar.jsp" %>

    <!-- 2. Phần nội dung bên phải -->
    <div class="content-area">
        <header style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px;">
            <div>
                <h1 style="margin: 0; font-size: 1.5rem; color: #1e293b;">Dashboard</h1>
                <p style="margin: 0; color: #64748b;">Chào mừng quay trở lại, Admin!</p>
            </div>
            <div style="display: flex; gap: 15px; align-items: center;">
                <div style="width: 40px; height: 40px; border-radius: 50%; background: #e2e8f0; display: flex; align-items: center; justify-content: center;">
                    <i class="fas fa-bell" style="color: #64748b;"></i>
                </div>
                <div style="text-align: right;">
                    <div style="font-weight: 600; font-size: 0.9rem;">Tùng (Admin)</div>
                    <div style="font-size: 0.75rem; color: #64748b;">Project Manager</div>
                </div>
            </div>
        </header>

        <div class="welcome-card">
            <h2 style="margin: 0 0 10px 0;">Hệ thống HRM đã sẵn sàng! 🚀</h2>
            <p style="margin: 0; opacity: 0.9;">Phần Sidebar bên trái là do Tùng phụ trách. Các thành viên khác sẽ code chức năng vào khung trắng này.</p>
        </div>

        <div class="stats-grid">
            <div class="stat-item">
                <div style="color: #64748b; font-size: 0.9rem; margin-bottom: 8px;">Tổng Nhân viên</div>
                <div style="font-size: 1.8rem; font-weight: 700; color: #1e293b;">156</div>
            </div>
            <div class="stat-item">
                <div style="color: #64748b; font-size: 0.9rem; margin-bottom: 8px;">Phòng ban</div>
                <div style="font-size: 1.8rem; font-weight: 700; color: #1e293b;">12</div>
            </div>
            <div class="stat-item">
                <div style="color: #64748b; font-size: 0.9rem; margin-bottom: 8px;">Đang làm việc</div>
                <div style="font-size: 1.8rem; font-weight: 700; color: #22c55e;">89</div>
            </div>
        </div>
        
        <div style="margin-top: 40px; padding: 40px; border: 2px dashed #cbd5e1; border-radius: 20px; text-align: center; color: #94a3b8;">
            <i class="fas fa-code" style="font-size: 3rem; margin-bottom: 20px;"></i>
            <h3>Khu vực code chức năng</h3>
            <p>Quang, Tiến, Hiền, Nguyên sẽ code nội dung vào đây.</p>
        </div>
    </div>
</div>

</body>
</html>
