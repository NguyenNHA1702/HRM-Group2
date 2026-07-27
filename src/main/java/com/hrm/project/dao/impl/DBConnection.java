package com.hrm.project.dao.impl;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.sql.Connection;
import java.sql.SQLException;

/**
 * DBConnection — Quản lý kết nối MySQL bằng HikariCP Connection Pool.
 *
 * TRƯỚC: Mỗi request = 1 DriverManager.getConnection() → mở kết nối TCP mới.
 *        Click nhanh 10 lần = 10 kết nối cùng lúc → MySQL chặn → nghẽn.
 *
 * SAU:   HikariCP giữ sẵn pool 10 connection tái sử dụng.
 *        Click nhanh 10 lần = mượn 10 connection có sẵn → trả về pool → siêu nhanh.
 */
public class DBConnection {

    private static final HikariDataSource dataSource;

    static {
        HikariConfig config = new HikariConfig();

        // ── Cấu hình kết nối MySQL ──────────────────────────────────
        config.setJdbcUrl("jdbc:mysql://127.0.0.1:3306/HRM_DB"
                + "?useUnicode=true&characterEncoding=UTF-8"
                + "&useSSL=false&allowPublicKeyRetrieval=true"
                + "&serverTimezone=Asia/Ho_Chi_Minh");
        config.setUsername("root");
        config.setPassword("123456");

        // ── Cấu hình Pool ───────────────────────────────────────────
        config.setMaximumPoolSize(15);          // Tối đa 15 kết nối đồng thời
        config.setMinimumIdle(3);               // Giữ sẵn 3 kết nối khi rảnh
        config.setConnectionTimeout(30_000);    // Chờ tối đa 30s nếu pool đầy
        config.setIdleTimeout(600_000);         // Đóng kết nối rảnh sau 10 phút
        config.setMaxLifetime(1_800_000);       // Tái tạo kết nối sau 30 phút
        config.setLeakDetectionThreshold(60_000); // Cảnh báo nếu quên đóng connection sau 60s

        // ── Tối ưu hiệu năng ────────────────────────────────────────
        config.setPoolName("HRM-HikariPool");
        config.addDataSourceProperty("cachePrepStmts", "true");
        config.addDataSourceProperty("prepStmtCacheSize", "250");
        config.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");

        dataSource = new HikariDataSource(config);
    }

    /**
     * Lấy một Connection từ pool. Caller PHẢI đóng bằng try-with-resources.
     * Connection.close() sẽ TRẢ VỀ pool thay vì đóng thật → tái sử dụng.
     */
    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }

    /**
     * Đóng pool khi ứng dụng shutdown (gọi từ ServletContextListener).
     */
    public static void shutdown() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
        }
    }

    // Giữ lại để không vỡ code cũ
    @Deprecated
    public static void closeConnection() {
        // Không làm gì — connection tự trả về pool khi close()
    }
}