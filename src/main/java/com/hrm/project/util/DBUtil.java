package com.hrm.project.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * DBUtil — quản lý kết nối MySQL.
 * Chỉnh DB_URL, DB_USER, DB_PASS cho phù hợp môi trường.
 */
public class DBUtil {

    private static final String DB_URL  = "jdbc:mysql://127.0.0.1:3306/hrm_db"
            + "?useUnicode=true&characterEncoding=UTF-8"
            + "&useSSL=false&serverTimezone=Asia/Ho_Chi_Minh"
            + "&allowPublicKeyRetrieval=true";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "123456"; // ← đổi mật khẩu DB tại đây

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL Driver not found", e);
        }
    }

    /** Lấy một Connection mới. Caller phải tự đóng trong finally / try-with-resources. */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
    }

    /** Tiện ích: đóng Connection an toàn (null-safe). */
    public static void close(AutoCloseable... resources) {
        for (AutoCloseable r : resources) {
            if (r != null) {
                try { r.close(); } catch (Exception ignored) {}
            }
        }
    }
}
