package com.hrm.project.controller.payroll;

import com.hrm.project.dao.PayrollDAO;
import com.hrm.project.dao.impl.PayrollDAOImpl;
import com.hrm.project.model.PayrollDetail;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "EmployeeMyPayrollController", urlPatterns = {"/luong"})
public class EmployeeMyPayrollController extends HttpServlet {
    private PayrollDAO payrollDAO;

    @Override
    public void init() throws ServletException {
        payrollDAO = new PayrollDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer employeeId = (Integer) request.getSession().getAttribute("employeeId");
        if (employeeId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<PayrollDetail> details = payrollDAO.getEmployeeSalaryHistory(employeeId);
        
        request.setAttribute("details", details);
        request.getRequestDispatcher("/WEB-INF/views/employee/my-payroll.jsp").forward(request, response);
    }
}
