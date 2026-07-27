package com.hrm.project.util;

import com.hrm.project.dao.impl.DBConnection;

import java.sql.Connection;
import java.sql.SQLException;

/**
 * DBUtil — Proxy tới DBConnection (HikariCP pool).
 * Giữ lại class này để không vỡ code DAO cũ đang import DBUtil.
 */
public class DBUtil {

    /** Lấy Connection từ HikariCP pool (ủy quyền cho DBConnection). */
    public static Connection getConnection() throws SQLException {
        return DBConnection.getConnection();
    }

    /** Tiện ích: đóng resource an toàn (null-safe). */
    public static void close(AutoCloseable... resources) {
        for (AutoCloseable r : resources) {
            if (r != null) {
                try { r.close(); } catch (Exception ignored) {}
            }
        }
    }
}
