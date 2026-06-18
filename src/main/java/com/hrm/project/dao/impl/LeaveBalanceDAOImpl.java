package com.hrm.project.dao.impl;

import com.hrm.project.dao.LeaveBalanceDAO;
import com.hrm.project.model.LeaveBalance;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LeaveBalanceDAOImpl implements LeaveBalanceDAO {

    @Override
    public List<LeaveBalance> getByEmployee(int employeeId) {

        List<LeaveBalance> list = new ArrayList<>();

        String sql =
                "SELECT lb.*, " +
                        "lt.name leave_type_name " +
                        "FROM leave_balances lb " +
                        "JOIN leave_types lt " +
                        "ON lb.leave_type_id = lt.id " +
                        "WHERE lb.employee_id=?";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setInt(1, employeeId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                LeaveBalance b = map(rs);

                b.setLeaveTypeName(
                        rs.getString("leave_type_name"));

                list.add(b);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    @Override
    public List<LeaveBalance> getAll() {
        // Tự động khởi tạo quỹ phép cho nhân viên mới hoạt động chưa có cấu hình
        String initSql =
                "INSERT IGNORE INTO leave_balances (employee_id, leave_type_id, used_days, remaining_days) " +
                "SELECT e.id, lt.id, 0.00, COALESCE(lt.days_per_year, 0) " +
                "FROM employees e " +
                "CROSS JOIN leave_types lt " +
                "WHERE e.status = 'ACTIVE' AND lt.is_active = 1 " +
                "  AND (lt.code != 'MATERNITY' OR LOWER(e.gender) IN ('nữ', 'nu', 'female', 'f')) " +
                "  AND NOT EXISTS (SELECT 1 FROM leave_balances lb WHERE lb.employee_id = e.id)";

        // Xóa các bản ghi nghỉ thai sản của nhân sự nam (nếu có do seed cũ hoặc gán nhầm)
        String cleanupSql =
                "DELETE FROM leave_balances " +
                "WHERE leave_type_id IN (SELECT id FROM leave_types WHERE code = 'MATERNITY') " +
                "  AND employee_id IN (SELECT id FROM employees WHERE LOWER(gender) NOT IN ('nữ', 'nu', 'female', 'f') OR gender IS NULL)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement psInit = con.prepareStatement(initSql);
             PreparedStatement psClean = con.prepareStatement(cleanupSql)) {
            psInit.executeUpdate();
            psClean.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }

        List<LeaveBalance> list = new ArrayList<>();

        String sql =
                "SELECT lb.*, " +
                        "e.full_name, " +
                        "lt.name leave_type_name " +
                        "FROM leave_balances lb " +
                        "JOIN employees e " +
                        "ON lb.employee_id=e.id " +
                        "JOIN leave_types lt " +
                        "ON lb.leave_type_id=lt.id";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()
        ) {

            while (rs.next()) {

                LeaveBalance b = map(rs);

                b.setEmployeeName(
                        rs.getString("full_name"));

                b.setLeaveTypeName(
                        rs.getString("leave_type_name"));

                list.add(b);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    @Override
    public boolean deductBalance(
            int employeeId,
            int leaveTypeId,
            double days) {

        String sql =
                "UPDATE leave_balances " +
                        "SET used_days = used_days + ?, " +
                        "remaining_days = remaining_days - ? " +
                        "WHERE employee_id=? " +
                        "AND leave_type_id=?";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setDouble(1, days);
            ps.setDouble(2, days);
            ps.setInt(3, employeeId);
            ps.setInt(4, leaveTypeId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public boolean updateBalance(int id, double usedDays, double remainingDays) {

        String sql =
                "UPDATE leave_balances " +
                        "SET used_days=?, remaining_days=? " +
                        "WHERE id=?";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setDouble(1, usedDays);
            ps.setDouble(2, remainingDays);
            ps.setInt(3, id);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public int resetAll() {

        String sql =
                "UPDATE leave_balances lb " +
                        "JOIN leave_types lt ON lt.id = lb.leave_type_id " +
                        "SET lb.used_days = 0, " +
                        "    lb.remaining_days = COALESCE(lt.days_per_year, 0)";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            return ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public boolean create(int employeeId, int leaveTypeId, double totalDays) {

        String sql =
                "INSERT INTO leave_balances " +
                        "(employee_id, leave_type_id, used_days, remaining_days) " +
                        "VALUES (?, ?, 0, ?)";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, employeeId);
            ps.setInt(2, leaveTypeId);
            ps.setDouble(3, totalDays);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean exists(int employeeId, int leaveTypeId) {

        String sql =
                "SELECT COUNT(*) FROM leave_balances " +
                        "WHERE employee_id=? AND leave_type_id=?";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, employeeId);
            ps.setInt(2, leaveTypeId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean delete(int id) {
        String sql = "DELETE FROM leave_balances WHERE id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private LeaveBalance map(ResultSet rs)
            throws SQLException {

        LeaveBalance b = new LeaveBalance();

        b.setId(rs.getInt("id"));

        b.setEmployeeId(
                rs.getInt("employee_id"));

        b.setLeaveTypeId(
                rs.getInt("leave_type_id"));

        b.setUsedDays(
                rs.getDouble("used_days"));

        b.setRemainingDays(
                rs.getDouble("remaining_days"));

        return b;
    }
}