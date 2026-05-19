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

        // Câu lệnh SQL thực hiện nhóm và đếm số lượng tài khoản liên kết với từng vai trò (bao gồm cả active và inactive)
        String sql = "SELECT r.id, r.name, r.description, r.is_active, COUNT(ua.id) AS user_count " +
                "FROM roles r " +
                "LEFT JOIN user_accounts ua ON r.id = ua.role_id " +
                "GROUP BY r.id, r.name, r.description, r.is_active";

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
                dto.setActive(rs.getBoolean("is_active"));

                list.add(dto);
            }
        } catch (SQLException e) {
            e.printStackTrace(); // Ghi nhận lỗi stack trace khi thao tác với DB gặp sự cố
        }
        return list;
    }

    @Override
    public boolean updateRole(int id, String name, String description) {
        String sql = "UPDATE roles SET name = ?, description = ?, updated_at = NOW() WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, description);
            ps.setInt(3, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean toggleRoleStatus(int id, boolean isActive) {
        String sql = "UPDATE roles SET is_active = ?, updated_at = NOW() WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, isActive ? 1 : 0);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean isRoleNameExists(String name, int excludeId) {
        String sql = "SELECT COUNT(*) FROM roles WHERE name = ? AND id != ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}