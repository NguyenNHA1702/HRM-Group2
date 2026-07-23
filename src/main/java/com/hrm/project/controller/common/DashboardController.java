package com.hrm.project.controller.common;

import com.hrm.project.model.dtos.response.AdminStatsDto;
import com.hrm.project.model.dtos.response.EmployeeStatsDto;
import com.hrm.project.model.dtos.response.HrStatsDto;
import com.hrm.project.model.dtos.response.ManagerStatsDto;
import com.hrm.project.service.DashboardService;
import com.hrm.project.service.impl.DashboardServiceImpl;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/dashboard")
public class DashboardController extends HttpServlet {

    private final DashboardService dashboardService = new DashboardServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // 1. Kiểm tra trạng thái đăng nhập dựa theo 'employeeId' lấy từ LoginController
        if (session == null || session.getAttribute("employeeId") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Phiên làm việc đã hết hạn. Vui lòng đăng nhập lại.");
            return;
        }

        // 2. Lấy đúng phím 'roleGroup' và 'employeeId' tương thích với LoginController
        String role = (String) session.getAttribute("roleGroup");
        Integer employeeId = (Integer) session.getAttribute("employeeId");

        if (role == null || role.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Tài khoản chưa được phân vai trò hệ thống (roleGroup bị rỗng).");
            return;
        }

        try {
            // 3. Phân tuyến dữ liệu sử dụng các hàm GET chuẩn của Service
            switch (role.toUpperCase()) {
                case "ADMIN":
                    AdminStatsDto adminStats = dashboardService.getAdminStats();
                    List<Map<String, Object>> recentActivities = dashboardService.getRecentActivity(10);
                    List<Map<String, Object>> dailyLogins = dashboardService.getDailyLogins();
                    List<Map<String, Object>> usersByRole = dashboardService.getUsersByRoleGroup();

                    request.setAttribute("stats", adminStats);
                    request.setAttribute("recentActivities", recentActivities);
                    request.setAttribute("dailyLogins", dailyLogins);
                    request.setAttribute("usersByRole", usersByRole);

                    request.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(request, response);
                    break;

                case "HR":
                    HrStatsDto hrStats = dashboardService.getHrStats();
                    List<Map<String, Object>> headcountByDept = dashboardService.getHeadcountByDept();
                    List<Map<String, Object>> recruitmentTrend = dashboardService.getRecruitmentTrend();

                    request.setAttribute("stats", hrStats);
                    request.setAttribute("headcountByDept", headcountByDept);
                    request.setAttribute("recruitmentTrend", recruitmentTrend);

                    request.getRequestDispatcher("/WEB-INF/views/hr/dashboard.jsp").forward(request, response);
                    break;

                case "MANAGER":
                    if (employeeId == null) {
                        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Không tìm thấy mã định danh Quản lý (employeeId) trong Session.");
                        return;
                    }
                    ManagerStatsDto managerStats = dashboardService.getManagerStats(employeeId);
                    List<Map<String, Object>> teamStatus = dashboardService.getTeamStatusToday(employeeId);
                    List<Map<String, Object>> pendingLeaves = dashboardService.getPendingLeavesForManager(employeeId);

                    request.setAttribute("stats", managerStats);
                    request.setAttribute("teamStatus", teamStatus);
                    request.setAttribute("pendingLeaves", pendingLeaves);

                    request.getRequestDispatcher("/WEB-INF/views/manager/dashboard.jsp").forward(request, response);
                    break;

                case "EMPLOYEE":
                    if (employeeId == null) {
                        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Không tìm thấy mã định danh Nhân viên (employeeId) trong Session.");
                        return;
                    }
                    EmployeeStatsDto employeeStats = dashboardService.getEmployeeStats(employeeId);
                    List<Map<String, Object>> myRecentLeaves = dashboardService.getMyRecentLeaves(employeeId, 5);

                    request.setAttribute("stats", employeeStats);
                    request.setAttribute("myRecentLeaves", myRecentLeaves);

                    request.getRequestDispatcher("/WEB-INF/views/employee/dashboard.jsp").forward(request, response);
                    break;

                default:
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Tài khoản không được cấp quyền truy cập khu vực này.");
                    break;
            }

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Lỗi hệ thống xảy ra tại Dashboard Controller: " + e.getMessage(), e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}