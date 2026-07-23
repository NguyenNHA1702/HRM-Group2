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
 * ManagerEmployeeListController — Hien thi danh sach nhan vien thuoc phong ban cho Manager.
 * URL: GET /nhan-vien, GET /manager/employees
 */
@WebServlet(name = "ManagerEmployeeListController", urlPatterns = {"/nhan-vien", "/manager/employees"})
public class ManagerEmployeeListController extends HttpServlet {

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
        
        // Neu la Admin hoac HR thi chuyen huong toi trang quan ly Users chung (/admin/users)
        if ("ADMIN".equalsIgnoreCase(roleGroup) || "HR".equalsIgnoreCase(roleGroup)) {
            resp.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        if (!"MANAGER".equalsIgnoreCase(roleGroup)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ Manager mới có quyền truy cập trang này.");
            return;
        }

        int managerId = (Integer) session.getAttribute("employeeId");

        try {
            Integer departmentId = departmentDAO.getDepartmentIdByManagerId(managerId);

            if (departmentId == null || departmentId <= 0) {
                req.setAttribute("noDepartment", true);
                req.getRequestDispatcher("/WEB-INF/views/manager/employees.jsp").forward(req, resp);
                return;
            }

            List<Department> allDepts = departmentDAO.getAllDepartments();
            String departmentName = "Phòng ban";
            if (allDepts != null) {
                for (Department d : allDepts) {
                    if (d.getId() == departmentId) {
                        departmentName = d.getName();
                        break;
                    }
                }
            }

            String keyword = req.getParameter("keyword");
            String posStr  = req.getParameter("positionId");
            String status  = req.getParameter("status");

            Integer positionId = null;
            if (posStr != null && !posStr.trim().isEmpty()) {
                try {
                    positionId = Integer.parseInt(posStr.trim());
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
            List<Position> positions = userDAO.getPositionsByDepartment(departmentId);

            req.setAttribute("noDepartment", false);
            req.setAttribute("departmentName", departmentName);
            req.setAttribute("departmentId", departmentId);
            req.setAttribute("employees", employees);
            req.setAttribute("stats", stats);
            req.setAttribute("positions", positions);
            req.setAttribute("page", page);
            req.setAttribute("pageSize", pageSize);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("totalRecords", totalRecords);

            req.setAttribute("filterKeyword", keyword != null ? keyword : "");
            req.setAttribute("filterPositionId", positionId != null ? positionId : "");
            req.setAttribute("filterStatus", status != null ? status : "");

            req.getRequestDispatcher("/WEB-INF/views/manager/employees.jsp").forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Lỗi lấy danh sách nhân viên phòng ban", e);
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
