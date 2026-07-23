package com.hrm.project.controller;

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

@WebServlet(name = "NotificationStreamServlet", urlPatterns = {"/api/notifications/stream"}, asyncSupported = true)
public class NotificationStreamServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Cấu hình Header chuẩn SSE
        response.setContentType("text/event-stream");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-cache");
        response.setHeader("Connection", "keep-alive");
        // Cho phép cross-origin nếu cần
        response.setHeader("Access-Control-Allow-Origin", "*");

        // 2. Lấy User ID từ session
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employeeId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        
        int userId = (Integer) session.getAttribute("employeeId");

        // 3. Bật chế độ Async để giải phóng luồng (thread) của Tomcat
        javax.servlet.AsyncContext asyncContext = request.startAsync();
        asyncContext.setTimeout(0); // Kết nối giữ vô hạn cho đến khi client ngắt

        PrintWriter writer = response.getWriter();
        
        // 4. Đăng ký kết nối này vào SSE Manager
        SSEManager.addClient(userId, writer);

        // Xóa client khi kết nối bất ngờ đứt (client đóng tab)
        asyncContext.addListener(new javax.servlet.AsyncListener() {
            public void onComplete(javax.servlet.AsyncEvent event) { SSEManager.removeClient(userId); }
            public void onTimeout(javax.servlet.AsyncEvent event) { SSEManager.removeClient(userId); }
            public void onError(javax.servlet.AsyncEvent event) { SSEManager.removeClient(userId); }
            public void onStartAsync(javax.servlet.AsyncEvent event) {}
        });
        
        // Không dùng while(true) Thread.sleep ở đây nữa để tránh cạn kiệt thread!
    }
}
