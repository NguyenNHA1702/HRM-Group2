package com.hrm.project.controller.payroll;

import com.hrm.project.dao.PayrollDAO;
import com.hrm.project.dao.impl.PayrollDAOImpl;
import com.hrm.project.model.Payroll;
import com.hrm.project.model.PayrollDetail;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "PayrollDetailController", urlPatterns = {"/admin/payroll/detail"})
public class PayrollDetailController extends HttpServlet {
    private PayrollDAO payrollDAO;

    @Override
    public void init() throws ServletException {
        payrollDAO = new PayrollDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Payroll payroll = payrollDAO.getPayrollById(id);
            if (payroll == null) {
                response.sendRedirect(request.getContextPath() + "/admin/payrolls?error=not_found");
                return;
            }

            List<PayrollDetail> details = payrollDAO.getPayrollDetails(id);
            


            request.setAttribute("payroll", payroll);
            request.setAttribute("details", details);
            request.getRequestDispatcher("/WEB-INF/views/admin/payroll-details.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/payrolls?error=invalid_id");
        }
    }
}
