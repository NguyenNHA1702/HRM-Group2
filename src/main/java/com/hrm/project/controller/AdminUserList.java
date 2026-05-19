package com.hrm.project.controller;

import com.hrm.project.dao.UserDAO;
import com.hrm.project.dao.impl.UserDAOImpl;
import com.hrm.project.model.UserAccountDTO;
import com.hrm.project.model.UserStatDTO;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * AdminUserServlet — hien thi trang Quan ly Users.
 * URL: GET /admin/users
 *      Params: keyword, roleGroup, status
 */
public class AdminUserList extends HttpServlet {

    private final UserDAO userDAO = new UserDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String keyword   = req.getParameter("keyword");
        String roleGroup = req.getParameter("roleGroup");
        String status    = req.getParameter("status");

        try {
            UserStatDTO stats = userDAO.getStats();
            req.setAttribute("stats", stats);

            List<UserAccountDTO> users = userDAO.getUsers(keyword, roleGroup, status);
            req.setAttribute("users", users);

            req.setAttribute("filterKeyword",   keyword   != null ? keyword   : "");
            req.setAttribute("filterRoleGroup", roleGroup != null ? roleGroup : "");
            req.setAttribute("filterStatus",    status    != null ? status    : "");

            req.setAttribute("roleGroups",  userDAO.getRoleGroups());
            req.setAttribute("departments", userDAO.getAllDepartments());
            req.setAttribute("positions",   userDAO.getAllPositions());

            req.getRequestDispatcher("/WEB-INF/views/admin/user-list.jsp")
                    .forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Loi truy van du lieu user", e);
        }
    }
}