package com.hrm.project.controller.payroll;

import com.hrm.project.dao.DepartmentDAO;
import com.hrm.project.dao.PayrollDAO;
import com.hrm.project.dao.impl.DepartmentDAOImpl;
import com.hrm.project.dao.impl.PayrollDAOImpl;
import com.hrm.project.model.Payroll;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "ManagerApprovePayrollController", urlPatterns = {"/manager/department-payroll/approve"})
public class ManagerApprovePayrollController extends HttpServlet {

    private PayrollDAO payrollDAO;
    private DepartmentDAO departmentDAO;

    @Override
    public void init() throws ServletException {
        payrollDAO = new PayrollDAOImpl();
        departmentDAO = new DepartmentDAOImpl();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer employeeId = (Integer) session.getAttribute("employeeId");
        
        if (employeeId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // Verify this employee is actually a manager
            Integer departmentId = departmentDAO.getDepartmentIdByManagerId(employeeId);
            if (departmentId == null) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền quản lý phòng ban.");
                return;
            }

            int payrollId = Integer.parseInt(request.getParameter("payrollId"));

            // Verify payroll exists and is currently DRAFT
            Payroll payroll = payrollDAO.getPayrollById(payrollId);
            if (payroll == null || !"DRAFT".equals(payroll.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/manager/department-payroll?payrollId=" + payrollId + "&error=invalid_status");
                return;
            }

            // Update status to MANAGER_CONFIRMED
            boolean success = payrollDAO.updatePayrollStatus(payrollId, "MANAGER_CONFIRMED", employeeId);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/manager/department-payroll?payrollId=" + payrollId + "&success=approved");
            } else {
                response.sendRedirect(request.getContextPath() + "/manager/department-payroll?payrollId=" + payrollId + "&error=approve_failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/manager/department-payroll?error=invalid_data");
        }
    }
}
