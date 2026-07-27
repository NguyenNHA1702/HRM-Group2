package com.hrm.project.controller.user;

import com.hrm.project.dao.DepartmentDAO;
import com.hrm.project.dao.UserDAO;
import com.hrm.project.dao.impl.DepartmentDAOImpl;
import com.hrm.project.dao.impl.UserDAOImpl;
import com.hrm.project.model.Department;
import com.hrm.project.model.Position;
import com.hrm.project.model.UserAccount;
import com.hrm.project.model.UserStatDTO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * HrEmployeeListController — Hien thi danh sach toan bo nhan vien cho HR.
 * URL: GET /hr/users
 */
@WebServlet(name = "HrEmployeeListController", urlPatterns = {"/hr/users"})
public class HrEmployeeListController extends HttpServlet {

    private final UserDAO userDAO = new UserDAOImpl();
    private final DepartmentDAO departmentDAO = new DepartmentDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("employeeId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String roleGroup = (String) session.getAttribute("roleGroup");
        
        // Chi cho phep HR (hoac ADMIN neu can thiet)
        if (!"HR".equalsIgnoreCase(roleGroup) && !"ADMIN".equalsIgnoreCase(roleGroup)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ HR hoặc Admin mới có quyền truy cập trang này.");
            return;
        }

        try {
            String keyword = req.getParameter("keyword");
            String posStr  = req.getParameter("positionId");
            String status  = req.getParameter("status");
            String deptStr = req.getParameter("departmentId");

            Integer positionId = null;
            if (posStr != null && !posStr.trim().isEmpty()) {
                try {
                    positionId = Integer.parseInt(posStr.trim());
                } catch (NumberFormatException ignored) {}
            }
            
            Integer departmentId = null;
            if (deptStr != null && !deptStr.trim().isEmpty()) {
                try {
                    departmentId = Integer.parseInt(deptStr.trim());
                } catch (NumberFormatException ignored) {}
            }

            int page = parsePositiveInt(req.getParameter("page"), 1);
            int pageSize = 10;

            int totalRecords = userDAO.getEmployeesCountByDepartment(departmentId, keyword, positionId, status);
            int totalPages = Math.max(1, (int) Math.ceil((double) totalRecords / pageSize));
            if (page > totalPages) {
                page = totalPages;
            }

            List<UserAccount> employees = userDAO.getEmployeesByDepartment(departmentId, keyword, positionId, status, page, pageSize);
            UserStatDTO stats = userDAO.getDepartmentEmployeeStats(departmentId);
            
            // For HR, fetch all departments and all positions for the filter dropdowns
            List<Department> departments = departmentDAO.getAllDepartments();
            List<Position> positions = userDAO.getAllPositions();

            req.setAttribute("employees", employees);
            req.setAttribute("stats", stats);
            req.setAttribute("departments", departments);
            req.setAttribute("positions", positions);
            req.setAttribute("page", page);
            req.setAttribute("pageSize", pageSize);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("totalRecords", totalRecords);

            req.setAttribute("filterKeyword", keyword != null ? keyword : "");
            req.setAttribute("filterDepartmentId", departmentId != null ? departmentId : "");
            req.setAttribute("filterPositionId", positionId != null ? positionId : "");
            req.setAttribute("filterStatus", status != null ? status : "");

            req.getRequestDispatcher("/WEB-INF/views/hr/users.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Lỗi lấy danh sách toàn bộ nhân viên cho HR", e);
        }
    }

    private int parsePositiveInt(String value, int defaultValue) {
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        try {
            int parsed = Integer.parseInt(value.trim());
            return parsed > 0 ? parsed : defaultValue;
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}
