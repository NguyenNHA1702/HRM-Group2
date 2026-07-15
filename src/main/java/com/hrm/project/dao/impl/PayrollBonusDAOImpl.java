package com.hrm.project.dao.impl;

import com.hrm.project.dao.PayrollBonusDAO;
import com.hrm.project.model.PayrollBonus;

import java.sql.*;
import java.util.*;

public class PayrollBonusDAOImpl implements PayrollBonusDAO {

    private PayrollBonus readBonus(ResultSet rs) throws SQLException {
        PayrollBonus b = new PayrollBonus();
        b.setId(rs.getInt("id"));
        b.setEmployeeId(rs.getInt("employee_id"));
        b.setBonusMonth(rs.getInt("bonus_month"));
        b.setBonusYear(rs.getInt("bonus_year"));
        b.setBonusType(rs.getString("bonus_type"));
        b.setAmount(rs.getDouble("amount"));
        b.setNote(rs.getString("note"));
        b.setCreatedBy(rs.getInt("created_by"));
        b.setCreatedAt(rs.getTimestamp("created_at"));
        try { b.setUpdatedAt(rs.getTimestamp("updated_at")); } catch (SQLException ignored) {}
        return b;
    }

    private PayrollBonus readBonusWithNames(ResultSet rs) throws SQLException {
        PayrollBonus b = readBonus(rs);
        try { b.setEmployeeName(rs.getString("full_name")); } catch (SQLException ignored) {}
        try { b.setEmployeeCode(rs.getString("employee_code")); } catch (SQLException ignored) {}
        try { b.setDepartmentName(rs.getString("dept_name")); } catch (SQLException ignored) {}
        return b;
    }

    private static final String SELECT_WITH_NAMES =
            "SELECT pb.*, e.full_name, e.employee_code, d.name as dept_name " +
            "FROM payroll_bonuses pb " +
            "JOIN employees e ON pb.employee_id = e.id " +
            "LEFT JOIN departments d ON e.department_id = d.id ";

    @Override
    public List<PayrollBonus> getByMonth(int year, int month) {
        List<PayrollBonus> list = new ArrayList<>();
        String sql = SELECT_WITH_NAMES +
                "WHERE pb.bonus_year = ? AND pb.bonus_month = ? " +
                "ORDER BY e.employee_code ASC, pb.bonus_type ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            ps.setInt(2, month);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(readBonusWithNames(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<PayrollBonus> getByEmployeeMonth(int employeeId, int year, int month) {
        List<PayrollBonus> list = new ArrayList<>();
        String sql = SELECT_WITH_NAMES +
                "WHERE pb.employee_id = ? AND pb.bonus_year = ? AND pb.bonus_month = ? " +
                "ORDER BY pb.bonus_type ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            ps.setInt(2, year);
            ps.setInt(3, month);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(readBonusWithNames(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public PayrollBonus getById(int id) {
        String sql = SELECT_WITH_NAMES + "WHERE pb.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return readBonusWithNames(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean add(PayrollBonus bonus) {
        String sql = "INSERT INTO payroll_bonuses (employee_id, bonus_month, bonus_year, bonus_type, amount, note, created_by) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bonus.getEmployeeId());
            ps.setInt(2, bonus.getBonusMonth());
            ps.setInt(3, bonus.getBonusYear());
            ps.setString(4, bonus.getBonusType());
            ps.setDouble(5, bonus.getAmount());
            ps.setString(6, bonus.getNote());
            ps.setInt(7, bonus.getCreatedBy());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean update(PayrollBonus bonus) {
        String sql = "UPDATE payroll_bonuses SET employee_id = ?, bonus_month = ?, bonus_year = ?, " +
                     "bonus_type = ?, amount = ?, note = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bonus.getEmployeeId());
            ps.setInt(2, bonus.getBonusMonth());
            ps.setInt(3, bonus.getBonusYear());
            ps.setString(4, bonus.getBonusType());
            ps.setDouble(5, bonus.getAmount());
            ps.setString(6, bonus.getNote());
            ps.setInt(7, bonus.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean delete(int id) {
        String sql = "DELETE FROM payroll_bonuses WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public Map<Integer, List<PayrollBonus>> getByMonthForPayroll(int year, int month) {
        Map<Integer, List<PayrollBonus>> map = new HashMap<>();
        String sql = "SELECT * FROM payroll_bonuses WHERE bonus_year = ? AND bonus_month = ? ORDER BY employee_id";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            ps.setInt(2, month);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PayrollBonus b = readBonus(rs);
                    map.computeIfAbsent(b.getEmployeeId(), k -> new ArrayList<>()).add(b);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }

    @Override
    public int countByMonth(int year, int month) {
        String sql = "SELECT COUNT(*) FROM payroll_bonuses WHERE bonus_year = ? AND bonus_month = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            ps.setInt(2, month);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}
