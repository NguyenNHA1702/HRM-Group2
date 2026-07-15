<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <title>Lương Phòng Ban | HRMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="/assets/css/layout.css" />
    <link rel="stylesheet" href="/assets/css/sidebar.css" />
    <style>
        .page-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:24px; border-bottom:1px solid #e2e8f0; padding-bottom:16px; }
        .page-title-group .page-title { font-size:22px; font-weight:700; color:var(--text); margin:0; }
        .page-title-group .page-subtitle { font-size:13px; color:#64748b; margin-top:4px; }
        
        .summary-cards { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 24px; }
        .card { background: #fff; border-radius: 12px; padding: 20px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); border: 1px solid #f1f5f9; position: relative; overflow: hidden; }
        .card::before { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 4px; }
        .card-fund::before { background: #10b981; }
        .card-headcount::before { background: #3b82f6; }
        .card-average::before { background: #8b5cf6; }
        
        .card-title { font-size: 13px; color: #64748b; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 8px; }
        .card-value { font-size: 28px; font-weight: 700; color: #0f172a; }
        .card-icon { position: absolute; right: 20px; top: 50%; transform: translateY(-50%); font-size: 48px; opacity: 0.05; }
        .card-fund .card-icon { color: #10b981; }
        .card-headcount .card-icon { color: #3b82f6; }
        .card-average .card-icon { color: #8b5cf6; }

        .filter-bar { background: #fff; padding: 16px 20px; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); margin-bottom: 24px; display: flex; gap: 16px; align-items: center; border: 1px solid #e2e8f0; }
        .filter-bar form { display: flex; gap: 16px; align-items: center; margin: 0; }
        .filter-bar select { padding: 10px 16px; border: 1px solid #cbd5e1; border-radius: 8px; outline: none; font-size: 14px; min-width: 200px; color: #334155; font-weight: 500; cursor: pointer; }
        .filter-bar select:focus { border-color: #4f46e5; box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1); }
        .filter-bar .btn { padding: 10px 20px; border: none; background: #4f46e5; color: white; border-radius: 8px; font-weight: 600; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; font-size: 14px; transition: all 0.2s; }
        .filter-bar .btn:hover { background: #4338ca; transform: translateY(-1px); }

        .table-container { background:#fff; border-radius:12px; border:1px solid #e2e8f0; overflow:hidden; box-shadow:0 1px 3px rgba(0,0,0,0.05); }
        .data-table { width:100%; border-collapse:collapse; }
        .data-table th { background:#f8fafc; padding:12px 16px; text-align:left; font-size:12px; text-transform:uppercase; font-weight:600; color:#64748b; border-bottom:1px solid #e2e8f0; }
        .data-table td { padding:14px 16px; border-bottom:1px solid #f1f5f9; font-size:14px; color:#334155; vertical-align:middle; }
        .data-table tr:hover { background:#f8fafc; }
        
        .currency { font-weight:600; color:#0f172a; font-family:monospace; font-size:15px; }
        .currency.positive { color:#059669; }
        .currency.negative { color:#dc2626; }

        .btn-icon { background:transparent; border:none; color:#64748b; cursor:pointer; padding:8px; border-radius:6px; transition:all 0.2s; }
        .btn-icon:hover { background:#f1f5f9; color:#4f46e5; }
        
        .badge { padding:6px 14px; border-radius:20px; font-size:12px; font-weight:600; display:inline-flex; align-items: center; gap: 6px; }
        .badge-yellow { background:#fef3c7; color:#92400e; border: 1px solid #fde68a; }
        .badge-green { background:#d1fae5; color:#065f46; border: 1px solid #a7f3d0; }
        .badge-blue { background:#dbeafe; color:#1e3a8a; border: 1px solid #bfdbfe; }
        
        .btn-approve { padding:8px 16px; border-radius:8px; font-weight:600; cursor:pointer; text-decoration:none; display:inline-flex; align-items:center; gap:8px; border:none; font-size:13px; background:#10b981; color:#fff; transition: all 0.2s; box-shadow: 0 2px 4px rgba(16, 185, 129, 0.2); }
        .btn-approve:hover { background:#059669; transform: translateY(-1px); box-shadow: 0 4px 6px rgba(16, 185, 129, 0.3); }

        .empty-state { text-align: center; padding: 60px 20px; color: #64748b; }
        .empty-state i { font-size: 48px; color: #cbd5e1; margin-bottom: 16px; }
        .empty-state h3 { font-size: 18px; font-weight: 600; color: #334155; margin: 0 0 8px 0; }
        .empty-state p { margin: 0; font-size: 14px; }
    </style>
</head>
<body>
    <%@ include file="/WEB-INF/common/sidebar.jsp" %>
    <main class="main-content">
        <div class="page-header">
            <div class="page-title-group">
                <h1 class="page-title">Quỹ Lương Phòng Ban</h1>
                <p class="page-subtitle">Tổng quan ngân sách và chi tiết lương từng nhân sự trong phòng ban</p>
            </div>
            
            <c:if test="">
                <div class="header-actions">
                    <c:choose>
                        <c:when test="">
                            <span class="badge badge-yellow"><i class="fas fa-edit"></i> Bản nháp - Chờ duyệt</span>
                            <form action="/manager/department-payroll/approve" method="post" style="margin:0;">
                                <input type="hidden" name="payrollId" value="">
                                <button type="submit" class="btn-approve" onclick="return confirm('Bạn xác nhận duyệt bảng lương tháng / của phòng ban? Sau khi duyệt sẽ chuyển sang HR xử lý.')">
                                    <i class="fas fa-check-circle"></i> Duyệt Bảng Lương
                                </button>
                            </form>
                        </c:when>
                        <c:when test="">
                            <span class="badge badge-blue"><i class="fas fa-user-check"></i> Đã duyệt</span>
                        </c:when>
                        <c:when test="">
                            <span class="badge badge-green"><i class="fas fa-check-double"></i> Đã chốt</span>
                        </c:when>
                    </c:choose>
                </div>
            </c:if>
        </div>

        <c:if test="">
            <div style="background:#d1fae5; color:#065f46; padding:12px 16px; border-radius:8px; margin-bottom:20px; font-weight:500;">
                <i class="fas fa-check-circle" style="margin-right:8px;"></i> Thao tác thành công!
            </div>
        </c:if>
        <c:if test="">
            <div style="background:#fee2e2; color:#991b1b; padding:12px 16px; border-radius:8px; margin-bottom:20px; font-weight:500;">
                <i class="fas fa-exclamation-circle" style="margin-right:8px;"></i> Có lỗi xảy ra, vui lòng thử lại!
            </div>
        </c:if>

        <c:choose>
            <c:when test="">
                <div class="table-container empty-state">
                    <i class="fas fa-folder-open"></i>
                    <h3>Chưa có dữ liệu bảng lương</h3>
                    <p>Hiện tại hệ thống chưa có bảng lương nào được tạo cho phòng ban của bạn.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="filter-bar">
                    <form action="/manager/department-payroll" method="get">
                        <select name="payrollId">
                            <c:forEach var="p" items="">
                                <option value="" >
                                    Tháng  / 
                                </option>
                            </c:forEach>
                        </select>
                        <button type="submit" class="btn"><i class="fas fa-filter"></i> Xem báo cáo</button>
                    </form>
                </div>

                <c:if test="">
                    <div class="summary-cards">
                        <div class="card card-fund">
                            <i class="fas fa-coins card-icon"></i>
                            <div class="card-title">Tổng Quỹ Lương</div>
                            <div class="card-value"><fmt:formatNumber value="" type="number" maxFractionDigits="0"/> đ</div>
                        </div>
                        <div class="card card-headcount">
                            <i class="fas fa-users card-icon"></i>
                            <div class="card-title">Số Lượng Nhân Sự</div>
                            <div class="card-value"></div>
                        </div>
                        <div class="card card-average">
                            <i class="fas fa-chart-pie card-icon"></i>
                            <div class="card-title">Lương Trung Bình / Người</div>
                            <div class="card-value"><fmt:formatNumber value="" type="number" maxFractionDigits="0"/> đ</div>
                        </div>
                    </div>

                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>MNV</th>
                                    <th>Họ và Tên</th>
                                    <th>Ngày Công</th>
                                    <th style="text-align:right">Lương Cơ Bản</th>
                                    <th style="text-align:right">Tổng Phụ Cấp</th>
                                    <th style="text-align:right">Khấu Trừ</th>
                                    <th style="text-align:right">Thực Nhận</th>
                                    <th style="text-align:center">Chi Tiết</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="d" items="">
                                    <tr>
                                        <td style="font-weight:600; color:#4f46e5;">EMP</td>
                                        <td>
                                            <div style="font-weight:600;"></div>
                                            <div style="font-size:12px; color:#64748b;"></div>
                                        </td>
                                        <td> ngày</td>
                                        <td style="text-align:right" class="currency"><fmt:formatNumber value="" type="number" maxFractionDigits="0"/></td>
                                        <td style="text-align:right" class="currency positive">+<fmt:formatNumber value="" type="number" maxFractionDigits="0"/></td>
                                        <td style="text-align:right" class="currency negative">-<fmt:formatNumber value="" type="number" maxFractionDigits="0"/></td>
                                        <td style="text-align:right; font-size:16px;" class="currency positive"><fmt:formatNumber value="" type="number" maxFractionDigits="0"/> đ</td>
                                        <td style="text-align:center">
                                            <button class="btn-icon" onclick="viewSalaryDetail(this)"
                                                data-emp-id="EMP"
                                                data-emp-name=""
                                                data-position=""
                                                data-dept="/"
                                                data-working-days=""
                                                data-basic=""
                                                data-total-allowance=""
                                                data-overtime=""
                                                data-total-deduction=""
                                                data-net="">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:if>
            </c:otherwise>
        </c:choose>

        <!-- MODAL NOT FOUND -->
    </main>
<!-- SCRIPT NOT FOUND -->
</body>
</html>