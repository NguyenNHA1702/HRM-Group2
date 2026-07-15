package com.hrm.project.dao;

import com.hrm.project.model.Notification;
import com.hrm.project.model.UserNotification;

import java.util.List;

public interface NotificationDAO {
    // Tạo 1 thông báo
    int createNotification(Notification notification);
    
    // Áp dụng thông báo cho nhiều người dùng
    void addNotificationForUsers(int notificationId, List<Integer> userIds);
    
    // Áp dụng thông báo cho toàn bộ người dùng active
    void addNotificationForAllUsers(int notificationId);
    
    // Áp dụng thông báo cho một nhóm Role cụ thể (VD: 'HR', 'MANAGER')
    void addNotificationForRoleGroup(int notificationId, String roleGroup);
    
    // Lấy thông báo chưa đọc của 1 người
    List<UserNotification> getUnreadNotificationsByUserId(int userId);
    
    // Lấy tất cả thông báo của 1 người (để phân trang/xem tất cả)
    List<UserNotification> getNotificationsByUserId(int userId, int limit, int offset);
    
    // Đánh dấu đã đọc
    void markAsRead(int userNotificationId, int userId);
    
    // Đếm số lượng thông báo chưa đọc
    int countUnreadNotifications(int userId);
}
