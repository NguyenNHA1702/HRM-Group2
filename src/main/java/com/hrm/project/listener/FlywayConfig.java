package com.hrm.project.listener;

import org.flywaydb.core.Flyway;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

@WebListener
public class FlywayConfig implements ServletContextListener {
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("=========================================================");
        System.out.println("[FLYWAY LOGGER] BẮT ĐẦU KHỞI CHẠY LÝ TRÌNH ĐỒNG BỘ DB...");

        String dbName = "HRM_DB";
        String serverUrl = "jdbc:mysql://127.0.0.1:3306/?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8";
        String user = "root";
        String pass = "123456";

        try {
            System.out.println("[FLYWAY LOGGER] Bước 1: Đang nạp Driver kết nối MySQL...");
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("[FLYWAY LOGGER] -> Nạp Driver MySQL thành công!");
        } catch (ClassNotFoundException e) {
            System.err.println("[FLYWAY LOGGER] -> THẤT BẠI: Không tìm thấy Driver MySQL! Kiểm tra lại pom.xml");
            e.printStackTrace();
            return;
        }

        // Dùng khối try-catch bổ sung bắt RuntimeException từ Flyway
        try {
            System.out.println("[FLYWAY LOGGER] Bước 2: Đang kết nối tới MySQL Server gốc (127.0.0.1:3309)...");
            try (Connection conn = DriverManager.getConnection(serverUrl, user, pass);
                 Statement stmt = conn.createStatement()) {

                System.out.println("[FLYWAY LOGGER] Bước 3: Kiểm tra và tự động tạo Database [" + dbName + "] nếu chưa có...");
                stmt.executeUpdate("CREATE DATABASE IF NOT EXISTS " + dbName +
                        " CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
                System.out.println("[FLYWAY LOGGER] -> Tạo/Kiểm tra Database [" + dbName + "] thành công!");
            }

            System.out.println("[FLYWAY LOGGER] Bước 4: Khởi cấu hình tham số cho Flyway Engine...");
            String dbUrl = "jdbc:mysql://127.0.0.1:3306/" + dbName + "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8";

            Flyway flyway = Flyway.configure()
                    .dataSource(dbUrl, user, pass)
                    .locations("classpath:db/migration") // Khóa cứng đường dẫn quét thư mục resources công khai
                    .baselineOnMigrate(true)
                    .outOfOrder(true)
                    .load();

            System.out.println("[FLYWAY LOGGER] Bước 5: Thực thi repair và migrate...");
            flyway.repair(); // FIX FAILED MIGRATIONS
            int migrationCount = flyway.migrate().migrationsExecuted;

            System.out.println("[FLYWAY LOGGER] -> THÀNH CÔNG RỰC RỠ: Đã chạy thành công " + migrationCount + " file SQL migration!");
            System.out.println(">>> Flyway Migration đã hoàn tất cấu trúc dữ liệu cho cả nhóm!");

        } catch (SQLException e) {
            System.err.println("[FLYWAY LOGGER] >>> LỖI HỆ THỐNG: Sự cố tương tác JDBC/SQL!");
            e.printStackTrace();
        } catch (Throwable t) {
            // ĐÂY LÀ ĐOẠN KHÓA CHỐT: Bắt lỗi sập ngầm của Flyway
            System.err.println("=========================================================");
            System.err.println("[FLYWAY LOGGER] >>> PHÁT HIỆN LỖI CHÍ MẠNG KHIẾN APP BỊ SẬP (404):");
            System.err.println("Lý do: " + t.getMessage());
            System.err.println("Chi tiết Stack Trace lỗi ẩn dưới đây:");
            t.printStackTrace();
            System.err.println("=========================================================");
        }
        System.out.println("=========================================================");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Hàm để trống khi kết thúc vòng đời ứng dụng
    }
}