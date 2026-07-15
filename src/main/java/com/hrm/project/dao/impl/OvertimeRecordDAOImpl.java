package com.hrm.project.dao.impl;

import com.hrm.project.dao.OvertimeRecordDAO;
import com.hrm.project.model.OvertimeRecord;

import java.sql.*;
import java.util.*;

public class OvertimeRecordDAOImpl implements OvertimeRecordDAO {

    private OvertimeRecord readRecord(ResultSet rs) throws SQLException {
        OvertimeRecord r = new OvertimeRecord();
        r.setId(rs.getInt("id"));
        r.setEmployeeId(rs.getInt("employee_id"));
        r.setOvertimeDate(rs.getDate("overtime_date"));
        r.setHours(rs.getDouble("hours"));
        r.setOvertimeType(rs.getString("overtime_type"));
        r.setStatus(rs.getString("status"));
        r.setCreatedBy(rs.getInt("created_by"));
        r.setNote(rs.getString("note"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        try { r.setUpdatedAt(rs.getTimestamp("updated_at")); } catch (SQLException ignored) {}
        return r;
    }

    private OvertimeRecord readRecordWithNames(ResultSet rs) throws SQLException {
        OvertimeRecord r = readRecord(rs);
        try { r.setEmployeeName(rs.getString("full_name")); } catch (SQLException ignored) {}
        try { r.setEmployeeCode(rs.getString("employee_code")); } catch (SQLException ignored) {}
        try { r.setDepartmentName(rs.getString("dept_name")); } catch (SQLException ignored) {}
        return r;
    }

    private static final String SELECT_WITH_NAMES =
            "SELECT ot.*, e.full_name, e.employee_code, d.name as dept_name " +
            "FROM overtime_records ot " +
            "JOIN employees e ON ot.employee_id = e.id " +
            "LEFT JOIN departments d ON e.department_id = d.id ";

    @Override
    public List<OvertimeRecord> getByMonth(int year, int month) {
        List<OvertimeRecord> list = new ArrayList<>();
        String sql = SELECT_WITH_NAMES +
                "WHERE YEAR(ot.overtime_date) = ? AND MONTH(ot.overtime_date) = ? " +
                "ORDER BY ot.overtime_date DESC, e.employee_code ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            ps.setInt(2, month);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(readRecordWithNames(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<OvertimeRecord> getByEmployeeMonth(int employeeId, int year, int month) {
        List<OvertimeRecord> list = new ArrayList<>();
        String sql = SELECT_WITH_NAMES +
                "WHERE ot.employee_id = ? AND YEAR(ot.overtime_date) = ? AND MONTH(ot.overtime_date) = ? " +
                "ORDER BY ot.overtime_date ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            ps.setInt(2, year);
            ps.setInt(3, month);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(readRecordWithNames(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public OvertimeRecord getById(int id) {
        String sql = SELECT_WITH_NAMES + "WHERE ot.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return readRecordWithNames(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean add(OvertimeRecord record) {
        String sql = "INSERT INTO overtime_records (employee_id, overtime_date, hours, overtime_type, status, created_by, note) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE hours = VALUES(hours), overtime_type = VALUES(overtime_type), " +
                     "status = VALUES(status), note = VALUES(note)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, record.getEmployeeId());
            ps.setDate(2, record.getOvertimeDate());
            ps.setDouble(3, record.getHours());
            ps.setString(4, record.getOvertimeType());
            ps.setString(5, record.getStatus() != null ? record.getStatus() : "PENDING");
            ps.setInt(6, record.getCreatedBy());
            ps.setString(7, record.getNote());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean update(OvertimeRecord record) {
        String sql = "UPDATE overtime_records SET employee_id = ?, overtime_date = ?, hours = ?, " +
                     "overtime_type = ?, note = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, record.getEmployeeId());
            ps.setDate(2, record.getOvertimeDate());
            ps.setDouble(3, record.getHours());
            ps.setString(4, record.getOvertimeType());
            ps.setString(5, record.getNote());
            ps.setInt(6, record.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean delete(int id) {
        String sql = "DELETE FROM overtime_records WHERE id = ?";
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
    public Map<Integer, List<OvertimeRecord>> getApprovedByMonthForPayroll(int year, int month) {
        Map<Integer, List<OvertimeRecord>> map = new HashMap<>();
        String sql = "SELECT * FROM overtime_records " +
                     "WHERE YEAR(overtime_date) = ? AND MONTH(overtime_date) = ? AND status = 'APPROVED' " +
                     "ORDER BY employee_id, overtime_date";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            ps.setInt(2, month);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OvertimeRecord r = readRecord(rs);
                    map.computeIfAbsent(r.getEmployeeId(), k -> new ArrayList<>()).add(r);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }

    @Override
    public boolean updateStatus(int id, String newStatus, int reviewedBy) {
        String sql = "UPDATE overtime_records SET status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public int countByMonth(int year, int month) {
        String sql = "SELECT COUNT(*) FROM overtime_records WHERE YEAR(overtime_date) = ? AND MONTH(overtime_date) = ?";
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
