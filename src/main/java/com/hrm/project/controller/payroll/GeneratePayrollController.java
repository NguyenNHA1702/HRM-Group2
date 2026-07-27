package com.hrm.project.controller.payroll;

import com.hrm.project.dao.AttendanceDAO;
import com.hrm.project.dao.PayrollDAO;
import com.hrm.project.dao.impl.AttendanceDAOImpl;
import com.hrm.project.dao.impl.PayrollDAOImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "GeneratePayrollController", urlPatterns = {"/admin/payroll/generate", "/hr/payroll/generate"})
public class GeneratePayrollController extends HttpServlet {
    private PayrollDAO payrollDAO;
    private AttendanceDAO attendanceDAO;

    @Override
    public void init() throws ServletException {
        payrollDAO = new PayrollDAOImpl();
        attendanceDAO = new AttendanceDAOImpl();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer employeeId = (Integer) session.getAttribute("employeeId");
        if (employeeId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String roleGroup = (String) session.getAttribute("roleGroup");
        if (!"HR".equals(roleGroup) && !"ADMIN".equals(roleGroup)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ HR mới có quyền tạo bảng lương.");
            return;
        }

        try {
            int month = Integer.parseInt(request.getParameter("month"));
            int year = Integer.parseInt(request.getParameter("year"));

            // Kiểm tra xem tất cả các phòng ban đã chốt công chưa
            if (!attendanceDAO.areAllDepartmentsLocked(year, month)) {
                response.sendRedirect(request.getContextPath() + "/admin/payrolls?error=not_all_locked");
                return;
            }

            // Check existing payroll
            com.hrm.project.model.Payroll existing = payrollDAO.getPayrollByMonthYear(month, year);
            if (existing != null && ("HR_FINALIZED".equals(existing.getStatus()) || "APPROVED".equals(existing.getStatus()) || "PAID".equals(existing.getStatus()))) {
                response.sendRedirect(request.getContextPath() + "/admin/payrolls?error=already_approved");
                return;
            }

            boolean success = payrollDAO.generatePayroll(month, year, employeeId);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/payrolls?success=generated");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/payrolls?error=generate_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            if (e.getMessage() != null && e.getMessage().contains("thiếu bảng công")) {
                response.sendRedirect(request.getContextPath() + "/admin/payrolls?error=no_attendance");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/payrolls?error=invalid_data");
            }
        }
    }
}
