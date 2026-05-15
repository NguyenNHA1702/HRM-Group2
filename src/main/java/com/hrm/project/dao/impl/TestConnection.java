package com.hrm.project.dao.impl;

import java.sql.Connection;

public class TestConnection {
    public static void main(String[] args) {
        // Gọi hàm getConnection từ file DBConnection bạn đã tạo
        System.out.println("Đang kiểm tra kết nối...");
        Connection conn = DBConnection.getConnection();

        // Kiểm tra xem kết nối có khác null không
        if (conn != null) {
            System.out.println(">>> KẾT NỐI THÀNH CÔNG RỒI NHA!");

            // Sau khi test xong thì nên đóng lại
            DBConnection.closeConnection();
        } else {
            System.out.println(">>> KẾT NỐI THẤT BẠI. Kiểm tra lại Driver hoặc thông số!");
        }
    }
}