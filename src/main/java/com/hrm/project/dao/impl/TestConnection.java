package com.hrm.project.dao.impl;

import java.sql.Connection;
import java.sql.SQLException;

public class TestConnection {
    public static void main(String[] args) {
        System.out.println("Đang kiểm tra kết nối tới MySQL...");

        // nạp kết nối vào và Java sẽ TỰ ĐỘNG đóng conn lại một cách an toàn khi chạy xong
        try (Connection conn = DBConnection.getConnection()) {

            // Kiểm tra xem kết nối có khác null không
            if (conn != null && !conn.isClosed()) {
                System.out.println("=========================================");
                System.out.println(">>> KẾT NỐI THÀNH CÔNG RỒI NHA TIẾN ƠI!");
                System.out.println("Database URL chính xác, Driver hoạt động tốt.");
                System.out.println("=========================================");
            }

        } catch (SQLException e) {
            System.err.println("=========================================");
            System.err.println(">>> KẾT NỐI THẤT BẠI!");
            System.err.println("Lý do: " + e.getMessage());
            System.err.println("Hãy kiểm tra lại:");
            System.err.println("1. MySQL Server đã bật chưa (Cổng 3306)?");
            System.err.println("2. Mật khẩu root có đúng là 123456 không?");
            System.err.println("3. Đã tạo database tên là HRM_DB chưa?");
            System.err.println("=========================================");
            e.printStackTrace();
        }
    }
}