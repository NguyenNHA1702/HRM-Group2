package com.hrm.project.controller;

import com.google.gson.Gson;
import com.hrm.project.dao.NotificationDAO;
import com.hrm.project.dao.impl.NotificationDAOImpl;
import com.hrm.project.model.Notification;
import com.hrm.project.model.UserAccount;
import com.hrm.project.utils.SSEManager;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.stream.Collectors;

@WebServlet(name = "AdminNotificationServlet", urlPatterns = {"/api/admin/notifications/send"})
public class AdminNotificationServlet extends HttpServlet {
    private NotificationDAO notificationDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        notificationDAO = new NotificationDAOImpl();
        gson = new Gson();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employeeId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"error\":\"Unauthorized\"}");
            return;
        }

        int employeeId = (Integer) session.getAttribute("employeeId");
        String roleGroup = (String) session.getAttribute("roleGroup");

        // Chỉ Admin hoặc HR mới được gửi thông báo toàn hệ thống
        if (!"ADMIN".equals(roleGroup) && !"HR".equals(roleGroup)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.print("{\"error\":\"Forbidden\"}");
            return;
        }

        try {
            // Đọc JSON payload từ request body (title, content, type)
            String requestData = request.getReader().lines().collect(Collectors.joining());
            Notification noti = gson.fromJson(requestData, Notification.class);
            noti.setCreatedBy(employeeId);
            if (noti.getType() == null) {
                noti.setType("INFO");
            }

            int notiId = notificationDAO.createNotification(noti);
            if (notiId > 0) {
                // Áp dụng cho toàn bộ User Active
                notificationDAO.addNotificationForAllUsers(notiId);

                // Push realtime cho tất cả đang online
                String payload = "{\"title\":\"" + noti.getTitle() + "\", \"content\":\"" + noti.getContent() + "\"}";
                SSEManager.broadcastNotification(payload);

                out.print("{\"success\":true}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\":\"Failed to save notification\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            String msg = e.getMessage() != null ? e.getMessage().replace("\"", "\\\"") : "Unknown error";
            out.print("{\"error\":\"" + msg + "\"}");
        }
    }
}
