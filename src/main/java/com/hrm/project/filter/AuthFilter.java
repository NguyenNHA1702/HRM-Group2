package com.hrm.project.filter;

import com.hrm.project.model.UserAccountDTO;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest)  request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        // Kiem tra quyen dang nhap cua Admin
        if (!isAdminAuthenticated(session)) {
            // Fix dung duong dan redirect ve /auth/login theo cau hinh web.xml
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        chain.doFilter(request, response);
    }

    private boolean isAdminAuthenticated(HttpSession session) {
        if (session == null) {
            return false;
        }

        // Kiem tra doi tuong currentUser trong session
        UserAccountDTO user = (UserAccountDTO) session.getAttribute("currentUser");
        if (user != null && "ADMIN".equals(user.getRoleGroupCode())) {
            return true;
        }

        // Backup kiem tra theo tung thuoc tinh don le cua nhom
        String roleGroup = (String) session.getAttribute("roleGroup");
        return session.getAttribute("employeeId") != null && "ADMIN".equals(roleGroup);
    }
}