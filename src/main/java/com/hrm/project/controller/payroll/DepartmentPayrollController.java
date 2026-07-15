package com.hrm.project.controller.payroll;

import com.hrm.project.dao.DepartmentDAO;
import com.hrm.project.dao.PayrollDAO;
import com.hrm.project.dao.impl.DepartmentDAOImpl;
import com.hrm.project.dao.impl.PayrollDAOImpl;
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

@WebServlet(name = "DepartmentPayrollController", urlPatterns = {"/manager/department-payroll"})
public class DepartmentPayrollController extends HttpServlet {

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
        Integer employeeId = (Integer) session.getAttribute("employeeId");
        
        if (employeeId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // Get department ID managed by this employee
            Integer departmentId = departmentDAO.getDepartmentIdByManagerId(employeeId);
            if (departmentId == null) {
                request.setAttribute("errorMessage", "Bạn không phải là quản lý của phòng ban nào.");
                request.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(request, response);
                return;
            }

            // Get all payrolls for the dropdown
            List<Payroll> payrolls = payrollDAO.getPayrollsByDepartment(departmentId);
            request.setAttribute("payrolls", payrolls);

            if (!payrolls.isEmpty()) {
                int selectedPayrollId = -1;
                String payrollIdParam = request.getParameter("payrollId");
                
                if (payrollIdParam != null && !payrollIdParam.trim().isEmpty()) {
                    selectedPayrollId = Integer.parseInt(payrollIdParam);
                } else {
                    selectedPayrollId = payrolls.get(0).getId();
                }

                request.setAttribute("selectedPayrollId", selectedPayrollId);

                // Get details for the selected payroll & department
                List<PayrollDetail> details = payrollDAO.getPayrollDetailsByDepartment(selectedPayrollId, departmentId);
                request.setAttribute("details", details);

                // Find the selected payroll object to check status
                Payroll selectedPayroll = null;
                for (Payroll p : payrolls) {
                    if (p.getId() == selectedPayrollId) {
                        selectedPayroll = p;
                        break;
                    }
                }
                request.setAttribute("selectedPayroll", selectedPayroll);

                // Calculate summary metrics
                double totalFund = 0;
                int headcount = details.size();
                
                for (PayrollDetail pd : details) {
                    totalFund += pd.getNetSalary();
                }
                
                double averageSalary = headcount > 0 ? totalFund / headcount : 0;

                request.setAttribute("totalFund", totalFund);
                request.setAttribute("headcount", headcount);
                request.setAttribute("averageSalary", averageSalary);
            }

            request.getRequestDispatcher("/WEB-INF/views/manager/department-payroll.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Lỗi: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(request, response);
        }
    }
}
