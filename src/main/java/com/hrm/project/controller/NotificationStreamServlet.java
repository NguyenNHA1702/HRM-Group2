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

@WebServlet(name = "NotificationStreamServlet", urlPatterns = {"/api/notifications/stream"})
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

        PrintWriter writer = response.getWriter();
        
        // 3. Đăng ký kết nối này vào SSE Manager
        SSEManager.addClient(userId, writer);

        // 4. Giữ cho kết nối không bị đóng
        while (!writer.checkError()) {
            try {
                // Sleep lâu một chút để giảm tải server
                Thread.sleep(15000); 
                // Heartbeat để trình duyệt không đóng kết nối
                writer.print(": heartbeat\n\n");
                writer.flush();
            } catch (InterruptedException e) {
                break;
            }
        }

        // 5. Xóa client khi kết nối đứt
        SSEManager.removeClient(userId);
    }
}
