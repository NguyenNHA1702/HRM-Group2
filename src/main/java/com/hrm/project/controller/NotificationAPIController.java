package com.hrm.project.controller;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.hrm.project.dao.NotificationDAO;
import com.hrm.project.dao.impl.NotificationDAOImpl;
import com.hrm.project.model.UserAccount;
import com.hrm.project.model.UserNotification;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet(name = "NotificationAPIController", urlPatterns = {"/api/notifications/*"})
public class NotificationAPIController extends HttpServlet {
    private NotificationDAO notificationDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        notificationDAO = new NotificationDAOImpl();
        // Cấu hình Gson để parse Date đúng định dạng
        gson = new GsonBuilder().setDateFormat("yyyy-MM-dd HH:mm:ss").create();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
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

        int userId = (Integer) session.getAttribute("employeeId");
        String pathInfo = request.getPathInfo();

        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                // Lấy 50 thông báo gần nhất (cả đã đọc và chưa đọc)
                List<UserNotification> list = notificationDAO.getNotificationsByUserId(userId, 50, 0);
                out.print(gson.toJson(list));
            } else if (pathInfo.equals("/count")) {
                // Đếm số lượng chưa đọc
                int count = notificationDAO.countUnreadNotifications(userId);
                out.print("{\"count\": " + count + "}");
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"Internal Server Error\"}");
        }
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

        int userId = (Integer) session.getAttribute("employeeId");
        String pathInfo = request.getPathInfo();

        if (pathInfo != null && pathInfo.startsWith("/read/")) {
            try {
                String idStr = pathInfo.substring(6);
                int userNotificationId = Integer.parseInt(idStr);
                
                notificationDAO.markAsRead(userNotificationId, userId);
                out.print("{\"success\":true}");
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Invalid ID\"}");
            }
        } else {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        }
    }
}
