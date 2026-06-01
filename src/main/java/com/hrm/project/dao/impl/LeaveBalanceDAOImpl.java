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