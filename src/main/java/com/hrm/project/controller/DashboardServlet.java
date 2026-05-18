package com.hrm.project.controller;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Dashboard — điều hướng sau đăng nhập theo roleGroup trong session.
 * URL: GET /dashboard
 */
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("employeeId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String roleGroup = (String) session.getAttribute("roleGroup");
        String viewPath = resolveDashboardView(roleGroup);

        req.getRequestDispatcher(viewPath).forward(req, resp);
    }

    private String resolveDashboardView(String roleGroup) {
        if (roleGroup == null) {
            return "/WEB-INF/views/auth/login.jsp";
        }
        switch (roleGroup) {
            case "ADMIN":
                return "/WEB-INF/views/admin/index.jsp";
            case "HR":
                return "/WEB-INF/views/hr/index.jsp";
            case "MANAGER":
                return "/WEB-INF/views/manager/index.jsp";
            case "EMPLOYEE":
                return "/WEB-INF/views/employee/index.jsp";
            default:
                return "/WEB-INF/views/auth/login.jsp";
        }
    }
}
