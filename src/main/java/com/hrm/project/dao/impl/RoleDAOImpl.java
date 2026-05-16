package com.hrm.project.dao.impl;

import com.hrm.project.dao.RoleDAO;
import com.hrm.project.model.dtos.response.RoleWithCountDTO;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class RoleDAOImpl implements RoleDAO {

    @Override
    public List<RoleWithCountDTO> getAllRolesWithCount() {
        List<RoleWithCountDTO> list = new ArrayList<>();

        // Câu lệnh SQL thực hiện nhóm và đếm số lượng tài khoản liên kết với từng vai trò
        String sql = "SELECT r.id, r.name, r.description, COUNT(ua.id) AS user_count " +
                "FROM roles r " +
                "LEFT JOIN user_accounts ua ON r.id = ua.role_id " +
                "WHERE r.is_active = 1 " +
                "GROUP BY r.id, r.name, r.description";

        // Sử dụng cơ chế Try-with-resources để tự động đóng kết nối sau khi thực thi
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                RoleWithCountDTO dto = new RoleWithCountDTO();
                dto.setId(rs.getInt("id"));
                dto.setName(rs.getString("name"));
                dto.setDescription(rs.getString("description"));
                dto.setUserCount(rs.getInt("user_count"));

                list.add(dto);
            }
        } catch (SQLException e) {
            e.printStackTrace(); // Ghi nhận lỗi stack trace khi thao tác với DB gặp sự cố
        }
        return list;
    }
}