package com.hrm.project.utils;

import java.io.PrintWriter;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class SSEManager {
    // Lưu trữ PrintWriter của từng user_id đang online
    private static final Map<Integer, PrintWriter> clients = new ConcurrentHashMap<>();

    public static void addClient(int userId, PrintWriter writer) {
        clients.put(userId, writer);
    }

    public static void removeClient(int userId) {
        clients.remove(userId);
    }

    // Gửi thông báo tới 1 user cụ thể
    public static void sendNotification(int userId, String jsonMessage) {
        PrintWriter writer = clients.get(userId);
        if (writer != null) {
            try {
                // Chuẩn SSE: "data: {json}\n\n"
                writer.print("data: " + jsonMessage + "\n\n");
                writer.flush();
                if (writer.checkError()) {
                    removeClient(userId);
                }
            } catch (Exception e) {
                removeClient(userId);
            }
        }
    }
    
    // Gửi thông báo cho nhiều user
    public static void sendNotificationToUsers(Iterable<Integer> userIds, String jsonMessage) {
        for (Integer userId : userIds) {
            sendNotification(userId, jsonMessage);
        }
    }

    // Bắn thông báo cho toàn bộ hệ thống
    public static void broadcastNotification(String jsonMessage) {
        for (Integer userId : clients.keySet()) {
            sendNotification(userId, jsonMessage);
        }
    }
}
