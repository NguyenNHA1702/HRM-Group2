package com.hrm.project.dao.impl;

import com.hrm.project.dao.NotificationDAO;
import com.hrm.project.model.Notification;
import com.hrm.project.model.UserNotification;


import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAOImpl implements NotificationDAO {
    @Override
    public int createNotification(Notification notification) {
        String sql = "INSERT INTO notifications (title, content, type, created_by) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            pstmt.setString(1, notification.getTitle());
            pstmt.setString(2, notification.getContent());
            pstmt.setString(3, notification.getType() != null ? notification.getType() : "INFO");
            if (notification.getCreatedBy() != null) {
                pstmt.setInt(4, notification.getCreatedBy());
            } else {
                pstmt.setNull(4, Types.INTEGER);
            }
            pstmt.executeUpdate();
            try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("DB_ERROR: " + e.getMessage(), e);
        }
        return -1;
    }

    @Override
    public void addNotificationForUsers(int notificationId, List<Integer> userIds) {
        if (userIds == null || userIds.isEmpty()) return;
        String sql = "INSERT INTO user_notifications (user_id, notification_id) VALUES (?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            for (Integer userId : userIds) {
                pstmt.setInt(1, userId);
                pstmt.setInt(2, notificationId);
                pstmt.addBatch();
            }
            pstmt.executeBatch();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void addNotificationForAllUsers(int notificationId) {
        // Insert for all active user accounts, using employee_id as the user key
        String sql = "INSERT INTO user_notifications (user_id, notification_id) " +
                     "SELECT ua.employee_id, ? FROM user_accounts ua WHERE ua.is_active = TRUE";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, notificationId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void addNotificationForRoleGroup(int notificationId, String roleGroup) {
        // employees -> user_accounts -> roles -> role_groups
        String sql = "INSERT INTO user_notifications (user_id, notification_id) " +
                     "SELECT ua.employee_id, ? " +
                     "FROM user_accounts ua " +
                     "JOIN roles r ON ua.role_id = r.id " +
                     "JOIN role_groups rg ON r.group_id = rg.id " +
                     "WHERE ua.is_active = TRUE AND rg.code = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, notificationId);
            pstmt.setString(2, roleGroup);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public List<UserNotification> getUnreadNotificationsByUserId(int userId) {
        List<UserNotification> list = new ArrayList<>();
        String sql = "SELECT un.id, un.user_id, un.notification_id, un.is_read, un.read_at, " +
                     "n.title, n.content, n.type, n.created_at, n.created_by " +
                     "FROM user_notifications un " +
                     "JOIN notifications n ON un.notification_id = n.id " +
                     "WHERE un.user_id = ? AND un.is_read = FALSE " +
                     "ORDER BY n.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapToUserNotification(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<UserNotification> getNotificationsByUserId(int userId, int limit, int offset) {
        List<UserNotification> list = new ArrayList<>();
        String sql = "SELECT un.id, un.user_id, un.notification_id, un.is_read, un.read_at, " +
                     "n.title, n.content, n.type, n.created_at, n.created_by " +
                     "FROM user_notifications un " +
                     "JOIN notifications n ON un.notification_id = n.id " +
                     "WHERE un.user_id = ? " +
                     "ORDER BY n.created_at DESC LIMIT ? OFFSET ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setInt(2, limit);
            pstmt.setInt(3, offset);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapToUserNotification(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public void markAsRead(int userNotificationId, int userId) {
        String sql = "UPDATE user_notifications SET is_read = TRUE, read_at = CURRENT_TIMESTAMP " +
                     "WHERE id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userNotificationId);
            pstmt.setInt(2, userId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public int countUnreadNotifications(int userId) {
        String sql = "SELECT COUNT(*) FROM user_notifications WHERE user_id = ? AND is_read = FALSE";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private UserNotification mapToUserNotification(ResultSet rs) throws SQLException {
        UserNotification un = new UserNotification();
        un.setId(rs.getInt("id"));
        un.setUserId(rs.getInt("user_id"));
        un.setNotificationId(rs.getInt("notification_id"));
        un.setRead(rs.getBoolean("is_read"));
        un.setReadAt(rs.getTimestamp("read_at"));

        Notification n = new Notification();
        n.setId(rs.getInt("notification_id"));
        n.setTitle(rs.getString("title"));
        n.setContent(rs.getString("content"));
        n.setType(rs.getString("type"));
        n.setCreatedAt(rs.getTimestamp("created_at"));
        
        int createdBy = rs.getInt("created_by");
        if (!rs.wasNull()) {
            n.setCreatedBy(createdBy);
        }
        
        un.setNotification(n);
        return un;
    }
}
