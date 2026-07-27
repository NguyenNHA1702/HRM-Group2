package com.hrm.project.controller.payroll;

import com.hrm.project.dao.PayrollDAO;
import com.hrm.project.dao.impl.PayrollDAOImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Duyệt bảng lương theo flow mới:
 * - MANAGER: DRAFT → MANAGER_CONFIRMED (cho dept mình)
 * - HR: MANAGER_CONFIRMED → HR_FINALIZED (chốt lương cuối cùng)
 */
@WebServlet(name = "ApprovePayrollController", urlPatterns = {"/admin/payroll/approve", "/hr/payroll/approve"})
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
        String roleGroup = (String) session.getAttribute("roleGroup");

        if (employeeId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String status = request.getParameter("status");

            // Validate role-status combination
            boolean allowed = false;
            if ("MANAGER_CONFIRMED".equals(status) && "MANAGER".equals(roleGroup)) {
                allowed = true;
            } else if ("HR_FINALIZED".equals(status) && "HR".equals(roleGroup)) {
                allowed = true;
            }
            // Legacy support for old flow
            if ("APPROVED".equals(status) && "ADMIN".equals(roleGroup)) {
                allowed = true;
            }

            if (!allowed) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, 
                    "Bạn không có quyền thực hiện thao tác này. Role: " + roleGroup + ", Status: " + status);
                return;
            }

            boolean success = payrollDAO.updatePayrollStatus(id, status, employeeId);

            if (success) {
                String msg = "HR_FINALIZED".equals(status) ? "finalized" : "confirmed";
                response.sendRedirect(request.getContextPath() + "/admin/payroll/detail?id=" + id + "&success=" + msg);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/payroll/detail?id=" + id + "&error=approve_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/payrolls?error=invalid_data");
        }
    }
}
