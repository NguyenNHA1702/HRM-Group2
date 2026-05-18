package com.hrm.project.controller;

import com.hrm.project.model.UserAccountDTO;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/** Redirect / → dashboard nếu đã login, ngược lại → /login */
public class IndexServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("employeeId") != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        UserAccountDTO user = (session != null)
                ? (UserAccountDTO) session.getAttribute("currentUser") : null;
        if (user != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
        } else {
            resp.sendRedirect(req.getContextPath() + "/login");
        }
    }
}
