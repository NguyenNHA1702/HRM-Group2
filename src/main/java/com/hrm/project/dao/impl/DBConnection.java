package com.hrm.project.dao.impl;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    private static final String URL = "jdbc:mysql://localhost:3306/HRM_DB?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8";
    private static final String USER = "root";
    private static final String PASSWORD = "123456";

    // ĐÃ XÓA: Biến static connection dùng chung (Nguyên nhân gây sập luồng)

    /**
     * Hàm lấy kết nối MỚI hoàn toàn mỗi lần gọi.
     * Các hàm DAO sử dụng xong phải tự bọc try-with-resources để đóng kết nối lại.
     */
    public static Connection getConnection() throws SQLException {
        try {
            // Đăng ký MySQL Driver
            Class.forName("com.mysql.cj.jdbc.Driver");

            // Luôn trả về một Connection độc lập mới tinh
            return DriverManager.getConnection(URL, USER, PASSWORD);

        } catch (ClassNotFoundException e) {
            System.err.println("Lỗi: Không tìm thấy MySQL Driver JAR. Hãy add thư viện vào project!");
            throw new SQLException("MySQL Driver not found", e);
        }
    }

    // Hàm này không cần thiết nữa vì các file DAO đã tự dùng try-with-resources để tự đóng kết nối an toàn
    @Deprecated
    public static void closeConnection() {
        // Để trống để tránh làm vỡ các code cũ của nhóm nếu có chỗ nào lỡ gọi hàm này
    }
}