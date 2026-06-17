package com.hrm.project.controller;

import com.hrm.project.dao.PayrollDAO;
import com.hrm.project.dao.impl.PayrollDAOImpl;
import com.hrm.project.model.UserAccount;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "GeneratePayrollController", urlPatterns = {"/admin/payroll/generate"})
public class GeneratePayrollController extends HttpServlet {
    private PayrollDAO payrollDAO;

    @Override
    public void init() throws ServletException {
        payrollDAO = new PayrollDAOImpl();
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
        if (!"ADMIN".equals(roleGroup) && !"HR".equals(roleGroup)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only ADMIN or HR can generate payroll.");
            return;
        }

        try {
            int month = Integer.parseInt(request.getParameter("month"));
            int year = Integer.parseInt(request.getParameter("year"));
            int createdBy = employeeId;

            // Check if there is an existing payroll for this month and year that is already approved or paid
            com.hrm.project.model.Payroll existing = payrollDAO.getPayrollByMonthYear(month, year);
            if (existing != null && ("APPROVED".equals(existing.getStatus()) || "PAID".equals(existing.getStatus()))) {
                response.sendRedirect(request.getContextPath() + "/admin/payrolls?error=already_approved");
                return;
            }

            boolean success = payrollDAO.generatePayroll(month, year, createdBy);

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
