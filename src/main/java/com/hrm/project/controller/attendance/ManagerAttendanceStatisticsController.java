package com.hrm.project.controller.attendance;

import com.hrm.project.model.dtos.response.AttendanceSystemStatsDto;
import com.hrm.project.service.AttendanceService;
import com.hrm.project.service.impl.AttendanceServiceImpl;
import com.hrm.project.dao.DepartmentDAO;
import com.hrm.project.dao.impl.DepartmentDAOImpl;

import java.io.IOException;
import java.time.LocalDate;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * ManagerAttendanceStatisticsController — Thống kê chấm công chi tiết của phòng ban dành cho Manager
 * URL: GET /manager-attendance-statistics
 */
@WebServlet("/manager-attendance-statistics")
public class ManagerAttendanceStatisticsController extends HttpServlet {

    private final AttendanceService attendanceService = new AttendanceServiceImpl();
    private final DepartmentDAO departmentDAO = new DepartmentDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employeeId") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED,
                    "Phiên làm việc đã hết hạn. Vui lòng đăng nhập lại.");
            return;
        }

        String roleGroup = (String) session.getAttribute("roleGroup");
        if (!"MANAGER".equalsIgnoreCase(roleGroup)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Bạn không có quyền xem thống kê chấm công bộ phận.");
            return;
        }

        int managerId = (Integer) session.getAttribute("employeeId");
        Integer departmentId = departmentDAO.getDepartmentIdByManagerId(managerId);

        if (departmentId == null) {
            request.setAttribute("noDepartment", true);
            request.getRequestDispatcher("/WEB-INF/views/manager/attendance-statistics.jsp")
                    .forward(request, response);
            return;
        }

        int month = parseIntOrDefault(
                request.getParameter("month"), LocalDate.now().getMonthValue());
        int year = parseIntOrDefault(
                request.getParameter("year"), LocalDate.now().getYear());
        if (month < 1 || month > 12 || year < 2000 || year > 2100) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "Tháng hoặc năm không hợp lệ.");
            return;
        }

        try {
            AttendanceSystemStatsDto statistics =
                    attendanceService.getDepartmentStatistics(departmentId, year, month);
            request.setAttribute("currentMonth", month);
            request.setAttribute("currentYear", year);
            request.setAttribute("statistics", statistics);
            request.setAttribute("noDepartment", false);
            request.getRequestDispatcher(
                    "/WEB-INF/views/manager/attendance-statistics.jsp").forward(request, response);
        } catch (IllegalStateException e) {
            throw new ServletException("Không thể tải thống kê chấm công phòng ban.", e);
        }
    }

    private int parseIntOrDefault(String value, int defaultValue) {
        if (value == null || value.isBlank()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}
