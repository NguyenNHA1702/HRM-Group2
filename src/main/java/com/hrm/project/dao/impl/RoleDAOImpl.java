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

        // Câu lệnh SQL thực hiện nhóm và đếm số lượng tài khoản liên kết với từng vai trò, kèm trạng thái và nhóm
        String sql = "SELECT r.id, r.name, r.description, r.is_active, r.group_id, rg.name AS group_name, COUNT(ua.id) AS user_count " +
                "FROM roles r " +
                "LEFT JOIN role_groups rg ON r.group_id = rg.id " +
                "LEFT JOIN user_accounts ua ON r.id = ua.role_id " +
                "GROUP BY r.id, r.name, r.description, r.is_active, r.group_id, rg.name " +
                "ORDER BY r.id ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                RoleWithCountDTO dto = new RoleWithCountDTO();
                dto.setId(rs.getInt("id"));
                dto.setName(rs.getString("name"));
                dto.setDescription(rs.getString("description"));
                dto.setUserCount(rs.getInt("user_count"));
                dto.setActive(rs.getInt("is_active") == 1);
                dto.setGroupId(rs.getInt("group_id"));
                dto.setGroupName(rs.getString("group_name"));

                list.add(dto);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public boolean updateRole(int id, String name, String description, int groupId) {
        String sql = "UPDATE roles SET name = ?, description = ?, group_id = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, name);
            ps.setString(2, description);
            ps.setInt(3, groupId);
            ps.setInt(4, id);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean toggleRoleActive(int id, boolean isActive) {
        String sql = "UPDATE roles SET is_active = ? WHERE id = ?";
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
    public boolean createRole(String name, String description, int groupId) {
        String sql = "INSERT INTO roles (name, description, group_id, is_active) VALUES (?, ?, ?, 1)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, name);
            ps.setString(2, description);
            ps.setInt(3, groupId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}