package com.hrm.project.dao.impl;

import com.hrm.project.dao.SalaryScaleDAO;
import com.hrm.project.model.SalaryScale;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class SalaryScaleDAOImpl implements SalaryScaleDAO {

    private SalaryScale mapRow(ResultSet rs) throws SQLException {
        return new SalaryScale(
            rs.getInt("id"),
            rs.getString("grade"),
            rs.getDouble("basic_salary"),
            rs.getString("description"),
            rs.getBoolean("is_active")
        );
    }

    @Override
    public List<SalaryScale> getAllSalaryScales() {
        List<SalaryScale> list = new ArrayList<>();
        String sql = "SELECT id, grade, basic_salary, description, is_active " +
                     "FROM salary_scales ORDER BY is_active DESC, basic_salary ASC";
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
    public List<SalaryScale> getActiveSalaryScales() {
        List<SalaryScale> list = new ArrayList<>();
        String sql = "SELECT id, grade, basic_salary, description, is_active " +
                     "FROM salary_scales WHERE is_active = 1 ORDER BY basic_salary ASC";
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
    public double getBasicSalaryById(int salaryScaleId) {
        String sql = "SELECT basic_salary FROM salary_scales WHERE id = ? AND is_active = 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, salaryScaleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("basic_salary");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    @Override
    public boolean addSalaryScale(SalaryScale scale) {
        String sql = "INSERT INTO salary_scales (grade, basic_salary, description, is_active) " +
                     "VALUES (?, ?, ?, 1)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, scale.getGrade().trim());
            ps.setDouble(2, scale.getBasicSalary());
            ps.setString(3, scale.getDescription() != null ? scale.getDescription().trim() : "");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean updateSalaryScale(SalaryScale scale) {
        String sql = "UPDATE salary_scales SET grade=?, basic_salary=?, description=?, updated_at=NOW() " +
                     "WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, scale.getGrade().trim());
            ps.setDouble(2, scale.getBasicSalary());
            ps.setString(3, scale.getDescription() != null ? scale.getDescription().trim() : "");
            ps.setInt(4, scale.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean toggleActive(int id, boolean isActive) {
        String sql = "UPDATE salary_scales SET is_active=?, updated_at=NOW() WHERE id=?";
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
    public boolean isGradeExists(String grade, int excludeId) {
        String sql = "SELECT COUNT(*) FROM salary_scales WHERE grade = ? AND id != ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, grade.trim());
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
