package com.hrm.project.controller;

import com.hrm.project.dao.PayrollDAO;
import com.hrm.project.dao.impl.PayrollDAOImpl;
import com.hrm.project.model.Payroll;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "PayrollListController", urlPatterns = {"/admin/payrolls"})
public class PayrollListController extends HttpServlet {
    private PayrollDAO payrollDAO;

    @Override
    public void init() throws ServletException {
        payrollDAO = new PayrollDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Payroll> payrolls = payrollDAO.getAllPayrolls();
        request.setAttribute("payrolls", payrolls);
        request.getRequestDispatcher("/WEB-INF/views/admin/payroll-list.jsp").forward(request, response);
    }
}
