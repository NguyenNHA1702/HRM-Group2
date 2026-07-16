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

@WebServlet(name = "PayrollListController", urlPatterns = {"/admin/payrolls", "/admin/payroll/bonus/save"})
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

        if ("HR".equalsIgnoreCase(roleGroup) || "ADMIN".equalsIgnoreCase(roleGroup)) {
            com.hrm.project.dao.UserDAO userDAO = new com.hrm.project.dao.impl.UserDAOImpl();
            try {
                request.setAttribute("employeeList", userDAO.getAllEmployees());
            } catch (java.sql.SQLException e) {
                // ignore or log
            }
        }

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

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getServletPath();
        if ("/admin/payroll/bonus/save".equals(pathInfo)) {
            saveBonus(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void saveBonus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        String roleGroup = (String) session.getAttribute("roleGroup");
        if (!"HR".equalsIgnoreCase(roleGroup) && !"ADMIN".equalsIgnoreCase(roleGroup)) {
            response.sendRedirect(request.getContextPath() + "/admin/payrolls?error=no_permission");
            return;
        }

        try {
            int employeeId = Integer.parseInt(request.getParameter("employeeId"));
            int month = Integer.parseInt(request.getParameter("month"));
            int year = Integer.parseInt(request.getParameter("year"));
            double amount = Double.parseDouble(request.getParameter("amount"));
            String note = request.getParameter("note");
            Integer createdBy = (Integer) session.getAttribute("employeeId");

            com.hrm.project.model.PayrollBonus bonus = new com.hrm.project.model.PayrollBonus();
            bonus.setEmployeeId(employeeId);
            bonus.setBonusMonth(month);
            bonus.setBonusYear(year);
            bonus.setBonusType("OTHER"); // Default type if not provided from form
            bonus.setAmount(amount);
            bonus.setNote(note);
            bonus.setCreatedBy(createdBy != null ? createdBy : 0);

            com.hrm.project.dao.PayrollBonusDAO bonusDAO = new com.hrm.project.dao.impl.PayrollBonusDAOImpl();
            if (bonusDAO.add(bonus)) {
                // Flash message trick via URL or session, let's use session
                session.setAttribute("flash_success", "Đã lưu Thưởng thành công!");
            } else {
                session.setAttribute("flash_error", "Không thể lưu Thưởng, có lỗi xảy ra.");
            }
        } catch (Exception e) {
            session.setAttribute("flash_error", "Dữ liệu nhập không hợp lệ.");
        }
        
        // Redirect back to payroll list
        response.sendRedirect(request.getContextPath() + "/admin/payrolls?year=" + request.getParameter("year"));
    }
}
