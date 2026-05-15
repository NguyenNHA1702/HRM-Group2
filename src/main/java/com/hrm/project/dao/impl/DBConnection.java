package com.hrm.project.dao.impl;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    // Đổi "ten_database_cua_ban" thành tên Database thực tế bạn đã tạo trong MySQL
    private static final String URL = "jdbc:mysql://localhost:3306/HRM_DB?useSSL=false&serverTimezone=UTC";
    private static final String USER = "root";
    private static final String PASSWORD = "123456";

    private static Connection connection = null;

    // Hàm lấy kết nối
    public static Connection getConnection() {
        if (connection == null) {
            try {
                // Đăng ký MySQL Driver
                Class.forName("com.mysql.cj.jdbc.Driver");

                // Mở kết nối
                connection = DriverManager.getConnection(URL, USER, PASSWORD);
                System.out.println("Chúc mừng! Kết nối MySQL thành công.");
            } catch (ClassNotFoundException e) {
                System.err.println("Lỗi: Không tìm thấy MySQL Driver JAR. Hãy add thư viện vào project!");
                e.printStackTrace();
            } catch (SQLException e) {
                System.err.println("Lỗi kết nối: Sai URL hoặc Database chưa được tạo!");
                e.printStackTrace();
            }
        }
        return connection;
    }

    // Hàm đóng kết nối
    public static void closeConnection() {
        if (connection != null) {
            try {
                connection.close();
                connection = null;
                System.out.println("Đã đóng kết nối an toàn!");
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}