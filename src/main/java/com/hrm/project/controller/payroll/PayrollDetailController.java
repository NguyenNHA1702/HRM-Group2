package com.hrm.project.controller.payroll;

import com.hrm.project.dao.PayrollDAO;
import com.hrm.project.dao.impl.PayrollDAOImpl;
import com.hrm.project.dao.DepartmentDAO;
import com.hrm.project.dao.impl.DepartmentDAOImpl;
import com.hrm.project.model.Department;
import com.hrm.project.model.Payroll;
import com.hrm.project.model.PayrollDetail;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "PayrollDetailController", urlPatterns = {"/admin/payroll/detail", "/hr/payroll/detail"})
public class PayrollDetailController extends HttpServlet {
    private PayrollDAO payrollDAO;
    private DepartmentDAO departmentDAO;

    @Override
    public void init() throws ServletException {
        payrollDAO = new PayrollDAOImpl();
        departmentDAO = new DepartmentDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String roleGroup = (String) session.getAttribute("roleGroup");

        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Payroll payroll = payrollDAO.getPayrollById(id);
            if (payroll == null) {
                response.sendRedirect(request.getContextPath() + "/admin/payrolls?error=not_found");
                return;
            }

            // Filter theo phòng ban
            String deptParam = request.getParameter("departmentId");
            int departmentId = -1;
            if (deptParam != null && !deptParam.isEmpty()) {
                try { departmentId = Integer.parseInt(deptParam); } catch (NumberFormatException ignored) {}
            }

            List<PayrollDetail> details;
            if (departmentId > 0) {
                details = payrollDAO.getPayrollDetailsByDepartment(id, departmentId);
            } else {
                details = payrollDAO.getPayrollDetails(id);
            }

            // Danh sách phòng ban cho dropdown
            List<Department> departments = departmentDAO.getAllDepartments();

            request.setAttribute("payroll", payroll);
            request.setAttribute("details", details);
            request.setAttribute("departments", departments);
            request.setAttribute("selectedDepartmentId", departmentId);
            request.setAttribute("roleGroup", roleGroup);
            request.getRequestDispatcher("/WEB-INF/views/admin/payroll-details.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/payrolls?error=invalid_id");
        }
    }
}
