package com.hrm.project.dao.impl;

import com.hrm.project.dao.AttendanceDAO;
import com.hrm.project.model.AttendanceSummary;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class AttendanceDAOImpl implements AttendanceDAO {
    @Override
    public AttendanceSummary getSummaryByEmployeeAndPeriod(int employeeId, int month, int year) {
        String sql = "SELECT * FROM attendance_summary WHERE employee_id = ? AND month = ? AND year = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            ps.setInt(2, month);
            ps.setInt(3, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    AttendanceSummary as = new AttendanceSummary();
                    as.setId(rs.getInt("id"));
                    as.setEmployeeId(rs.getInt("employee_id"));
                    as.setMonth(rs.getInt("month"));
                    as.setYear(rs.getInt("year"));
                    as.setStandardDays(rs.getDouble("standard_days"));
                    as.setActualWorkedDays(rs.getDouble("actual_worked_days"));
                    as.setPaidLeaveDays(rs.getDouble("paid_leave_days"));
                    as.setUnpaidLeaveDays(rs.getDouble("unpaid_leave_days"));
                    as.setCreatedAt(rs.getTimestamp("created_at"));
                    as.setUpdatedAt(rs.getTimestamp("updated_at"));
                    return as;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean createOrUpdateSummary(AttendanceSummary summary) {
        String sql = "INSERT INTO attendance_summary (employee_id, month, year, standard_days, actual_worked_days, paid_leave_days, unpaid_leave_days) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE standard_days=VALUES(standard_days), actual_worked_days=VALUES(actual_worked_days), " +
                     "paid_leave_days=VALUES(paid_leave_days), unpaid_leave_days=VALUES(unpaid_leave_days)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, summary.getEmployeeId());
            ps.setInt(2, summary.getMonth());
            ps.setInt(3, summary.getYear());
            ps.setDouble(4, summary.getStandardDays());
            ps.setDouble(5, summary.getActualWorkedDays());
            ps.setDouble(6, summary.getPaidLeaveDays());
            ps.setDouble(7, summary.getUnpaidLeaveDays());
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
