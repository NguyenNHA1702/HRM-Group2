package com.hrm.project.dao.impl;

import com.hrm.project.dao.AllowanceTypeDAO;
import com.hrm.project.model.AllowanceType;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AllowanceTypeDAOImpl implements AllowanceTypeDAO {

    private AllowanceType mapRow(ResultSet rs) throws SQLException {
        return new AllowanceType(
            rs.getInt("id"),
            rs.getString("code"),
            rs.getString("name"),
            rs.getDouble("amount"),
            rs.getString("description"),
            rs.getBoolean("is_active")
        );
    }

    @Override
    public List<AllowanceType> getAllAllowanceTypes() {
        List<AllowanceType> list = new ArrayList<>();
        String sql = "SELECT id, code, name, amount, description, is_active " +
                     "FROM allowance_types ORDER BY is_active DESC, name ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public boolean addAllowanceType(AllowanceType type) {
        String sql = "INSERT INTO allowance_types (code, name, amount, description, is_active) VALUES (?, ?, ?, ?, 1)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, type.getCode().trim().toUpperCase());
            ps.setString(2, type.getName().trim());
            ps.setDouble(3, type.getAmount());
            ps.setString(4, type.getDescription() != null ? type.getDescription().trim() : "");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean updateAllowanceType(AllowanceType type) {
        String sql = "UPDATE allowance_types SET code=?, name=?, amount=?, description=?, updated_at=NOW() WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, type.getCode().trim().toUpperCase());
            ps.setString(2, type.getName().trim());
            ps.setDouble(3, type.getAmount());
            ps.setString(4, type.getDescription() != null ? type.getDescription().trim() : "");
            ps.setInt(5, type.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean toggleActive(int id, boolean isActive) {
        String sql = "UPDATE allowance_types SET is_active=?, updated_at=NOW() WHERE id=?";
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
    public boolean isCodeExists(String code, int excludeId) {
        String sql = "SELECT COUNT(*) FROM allowance_types WHERE code = ? AND id != ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code.trim().toUpperCase());
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
