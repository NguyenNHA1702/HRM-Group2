package com.hrm.project.controller;

import com.hrm.project.model.UserAccountDTO;
import com.hrm.project.model.dtos.response.LoginResponseDto;
import com.hrm.project.service.AuthService;
import com.hrm.project.service.impl.AuthServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * AuthServlet — xu ly /auth/login va /auth/logout.
 */
public class AuthServlet extends HttpServlet {

    private final AuthService authService = new AuthServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getPathInfo();

        if ("/logout".equals(path)) {
            HttpSession session = req.getSession(false);
            if (session != null) session.invalidate();
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp")
                .forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String email    = req.getParameter("email");
        String password = req.getParameter("password");

        try {
            LoginResponseDto login = authService.login(email, password);
            if (login == null) {
                req.setAttribute("error", "Email hoac mat khau khong dung.");
                req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp")
                        .forward(req, resp);
                return;
            }

            if (!"ADMIN".equals(login.getRoleGroupCode())) {
                req.setAttribute("error", "Tai khoan khong co quyen truy cap trang Admin.");
                req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp")
                        .forward(req, resp);
                return;
            }

            HttpSession session = req.getSession(true);

            // Fix loi can thiep session: Dat ca 2 name de map trung voi Filter va JSP view
            UserAccountDTO userDto = toUserAccountDTO(login);
            session.setAttribute("currentUser", userDto);
            session.setAttribute("user", userDto);

            session.setMaxInactiveInterval(30 * 60);

            session.setAttribute("employeeId", login.getEmployeeId());
            session.setAttribute("accountId", login.getAccountId());
            session.setAttribute("fullName", login.getFullName());
            session.setAttribute("work_email", login.getWorkEmail());
            session.setAttribute("roleName", login.getRoleName());
            session.setAttribute("roleGroup", login.getRoleGroupCode());

            resp.sendRedirect(req.getContextPath() + "/dashboard");

        } catch (Exception e) {
            req.setAttribute("error", "Loi he thong: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp")
                    .forward(req, resp);
        }
    }

    private UserAccountDTO toUserAccountDTO(LoginResponseDto login) {
        UserAccountDTO user = new UserAccountDTO();
        user.setId(login.getAccountId());
        user.setUsername(login.getWorkEmail());
        user.setFullName(login.getFullName());
        user.setRoleGroupCode(login.getRoleGroupCode());
        user.setRoleName(login.getRoleName());
        user.setActive(true);
        return user;
    }
}