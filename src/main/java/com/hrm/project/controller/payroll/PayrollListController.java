package com.hrm.project.controller.payroll;

import com.hrm.project.dao.PayrollDAO;
import com.hrm.project.dao.impl.PayrollDAOImpl;
import com.hrm.project.dao.DepartmentDAO;
import com.hrm.project.dao.impl.DepartmentDAOImpl;
import com.hrm.project.model.Department;
import com.hrm.project.model.Payroll;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "PayrollListController", urlPatterns = {"/admin/payrolls"})
public class PayrollListController extends HttpServlet {
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
        Integer employeeId = (Integer) session.getAttribute("employeeId");

        String yearParam = request.getParameter("year");
        String searchParam = request.getParameter("search");
        String pageParam = request.getParameter("page");

        int currentYear = java.time.LocalDate.now().getYear();
        Integer year = yearParam != null && !yearParam.isEmpty() ? Integer.parseInt(yearParam) : currentYear;
        
        int page = 1;
        int limit = 10;
        if (pageParam != null && !pageParam.isEmpty()) {
            try { page = Integer.parseInt(pageParam); } catch (NumberFormatException e) { page = 1; }
        }
        int offset = (page - 1) * limit;

        List<Payroll> payrolls = payrollDAO.getPayrolls(year, searchParam, offset, limit);
        int totalCount = payrollDAO.getTotalPayrollsCount(year, searchParam);
        int totalPages = (int) Math.ceil((double) totalCount / limit);

        // Lấy danh sách phòng ban cho dropdown filter
        List<Department> departments = departmentDAO.getAllDepartments();

        request.setAttribute("payrolls", payrolls);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("selectedYear", year);
        request.setAttribute("searchKeyword", searchParam);
        request.setAttribute("currentMonth", java.time.LocalDate.now().getMonthValue());
        request.setAttribute("currentYear", currentYear);
        request.setAttribute("departments", departments);
        request.setAttribute("roleGroup", roleGroup);

        request.getRequestDispatcher("/WEB-INF/views/admin/payroll-list.jsp").forward(request, response);
    }
}
