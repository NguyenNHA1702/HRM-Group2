package com.hrm.project.controller;

import com.hrm.project.model.dtos.response.AttendanceSystemStatsDto;
import com.hrm.project.service.AttendanceService;
import com.hrm.project.service.impl.AttendanceServiceImpl;
import java.io.IOException;
import java.time.LocalDate;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/cham-cong/thong-ke")
public class AttendanceStatisticsController extends HttpServlet {

    private final AttendanceService attendanceService = new AttendanceServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employeeId") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED,
                    "Phiên làm việc đã hết hạn. Vui lòng đăng nhập lại.");
            return;
        }
        if (!canViewSystemStatistics((String) session.getAttribute("roleGroup"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Bạn không có quyền xem thống kê chấm công toàn hệ thống.");
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
                    attendanceService.getSystemStatistics(year, month);
            request.setAttribute("currentMonth", month);
            request.setAttribute("currentYear", year);
            request.setAttribute("statistics", statistics);
            request.getRequestDispatcher(
                    "/WEB-INF/views/hr/attendance-statistics.jsp").forward(request, response);
        } catch (IllegalStateException e) {
            throw new ServletException("Không thể tải thống kê chấm công hệ thống.", e);
        }
    }

    private int parseIntOrDefault(String value, int defaultValue) {
        if (value == null || value.isBlank()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private boolean canViewSystemStatistics(String role) {
        return "HR".equalsIgnoreCase(role)
                || "MANAGER".equalsIgnoreCase(role);
    }
}
