package com.hrm.project.controller.auth;

import com.hrm.project.model.dtos.response.LoginResponseDto;
import com.hrm.project.model.dtos.response.ModulePermissionDTO;
import com.hrm.project.service.AuthService;
import com.hrm.project.service.RolePermissionService;
import com.hrm.project.service.impl.AuthServiceImpl;
import com.hrm.project.service.impl.RolePermissionServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login", "/logout"})
public class LoginServlet extends HttpServlet {

    private final AuthService authService = new AuthServiceImpl();
    private final RolePermissionService rolePermissionService = new RolePermissionServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getServletPath();

        if ("/logout".equals(path)) {
            handleLogout(req, resp);
        } else {
            showLoginForm(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        handleLogin(req, resp);
    }

    private void handleLogin(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        if (email == null || email.isBlank() || password == null || password.isBlank()) {
            req.setAttribute("error", "Vui lòng nhập đầy đủ email và mật khẩu.");
            req.setAttribute("email", email);
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        try {
            // Sử dụng hàm login từ Interface AuthService (trả về LoginResponseDto)
            LoginResponseDto result = authService.login(email.trim(), password);

            if (result == null) {
                req.setAttribute("error", "Email hoặc mật khẩu không đúng.");
                req.setAttribute("email", email);
                req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
                return;
            }

            HttpSession oldSession = req.getSession(false);
            if (oldSession != null) oldSession.invalidate();

            HttpSession session = req.getSession(true);
            session.setMaxInactiveInterval(60 * 60); // 1 giờ

            // Đẩy các thông tin từ DTO vào Session phục vụ cho cả 4 role
            session.setAttribute("employeeId",  result.getEmployeeId());
            session.setAttribute("accountId",   result.getAccountId());
            session.setAttribute("fullName",    result.getFullName());
            session.setAttribute("work_email",  result.getWorkEmail());
            session.setAttribute("roleName",    result.getRoleName());
            session.setAttribute("roleGroup",   result.getRoleGroupCode()); // ADMIN | HR | MANAGER | EMPLOYEE
            session.setAttribute("avatarUrl",   result.getAvatarUrl());
            session.setAttribute("sessionToken", result.getSessionToken());
            session.setAttribute("roleId",      result.getRoleId());

            // --- LOAD QUYỀN VÀO SESSION (cache để tránh query DB mỗi request) ---
            // Chuyển List<DTO> thành Map<moduleCode, DTO> để tra cứu O(1)
            List<ModulePermissionDTO> permList =
                    rolePermissionService.getPermissionsByRoleId(result.getRoleId());
            Map<String, ModulePermissionDTO> userPermissions = new HashMap<>();
            for (ModulePermissionDTO perm : permList) {
                if (perm.getModuleCode() != null) {
                    userPermissions.put(perm.getModuleCode(), perm);
                }
            }
            session.setAttribute("userPermissions", userPermissions);
            System.out.println("[LOGIN] Đã nạp " + userPermissions.size() + " module quyền vào Session cho roleId=" + result.getRoleId());

            resp.sendRedirect(req.getContextPath() + "/dashboard");
        } catch (Exception e) {
            req.setAttribute("error", "Đã xảy ra lỗi hệ thống. Vui lòng thử lại.");
            req.setAttribute("email", email);
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
        }
    }

    private void handleLogout(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        resp.sendRedirect(req.getContextPath() + "/login");
    }

    private void showLoginForm(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("employeeId") != null) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }
}
