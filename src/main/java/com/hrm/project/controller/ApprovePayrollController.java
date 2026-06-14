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

@WebServlet(name = "ApprovePayrollController", urlPatterns = {"/admin/payroll/approve"})
public class ApprovePayrollController extends HttpServlet {
    private PayrollDAO payrollDAO;

    @Override
    public void init() throws ServletException {
        payrollDAO = new PayrollDAOImpl();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer employeeId = (Integer) session.getAttribute("employeeId");
        if (employeeId == null || !"ADMIN".equals(session.getAttribute("roleGroup"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only ADMIN can approve payroll.");
            return;
        }

        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String status = request.getParameter("status");
            int approvedBy = employeeId;
            
            if (status == null || status.trim().isEmpty()) {
                status = "APPROVED";
            }

            boolean success = payrollDAO.updatePayrollStatus(id, status, approvedBy);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/payroll/detail?id=" + id + "&success=approved");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/payroll/detail?id=" + id + "&error=approve_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/payrolls?error=invalid_data");
        }
    }
}
