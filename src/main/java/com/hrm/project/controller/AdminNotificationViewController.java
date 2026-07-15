package com.hrm.project.controller;

import com.hrm.project.model.UserAccount;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "AdminNotificationViewController", urlPatterns = {"/admin/notifications"})
public class AdminNotificationViewController extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employeeId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String roleGroup = (String) session.getAttribute("roleGroup");
        if (!"ADMIN".equals(roleGroup) && !"HR".equals(roleGroup)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang này.");
            return;
        }

        request.setAttribute("pageTitle", "Gửi thông báo hệ thống");
        request.getRequestDispatcher("/WEB-INF/views/admin/admin-notifications.jsp").forward(request, response);
    }
}
