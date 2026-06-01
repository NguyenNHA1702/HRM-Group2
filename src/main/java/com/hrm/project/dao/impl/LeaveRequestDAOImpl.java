package com.hrm.project.dao.impl;

import com.hrm.project.dao.LeaveRequestDAO;
import com.hrm.project.model.LeaveRequest;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LeaveRequestDAOImpl implements LeaveRequestDAO {

    @Override
    public List<LeaveRequest> getByEmployee(int employeeId) {

        List<LeaveRequest> list = new ArrayList<>();

        String sql =
                "SELECT lr.*, " +
                        "lt.name AS leave_type_name " +
                        "FROM leave_requests lr " +
                        "JOIN leave_types lt ON lr.leave_type_id = lt.id " +
                        "WHERE lr.employee_id = ? " +
                        "ORDER BY lr.created_at DESC";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setInt(1, employeeId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                LeaveRequest r = map(rs);

                r.setLeaveTypeName(
                        rs.getString("leave_type_name"));

                list.add(r);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    @Override
    public List<LeaveRequest> getAll() {

        List<LeaveRequest> list = new ArrayList<>();

        String sql =
                "SELECT lr.*, " +
                        "e.full_name, " +
                        "d.name department_name, " +
                        "lt.name leave_type_name " +
                        "FROM leave_requests lr " +
                        "JOIN employees e ON lr.employee_id = e.id " +
                        "LEFT JOIN departments d ON e.department_id = d.id " +
                        "JOIN leave_types lt ON lr.leave_type_id = lt.id " +
                        "ORDER BY lr.created_at DESC";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                LeaveRequest r = map(rs);

                r.setEmployeeName(
                        rs.getString("full_name"));

                r.setDepartmentName(
                        rs.getString("department_name"));

                r.setLeaveTypeName(
                        rs.getString("leave_type_name"));

                list.add(r);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    @Override
    public LeaveRequest getById(int id) {

        String sql =
                "SELECT * FROM leave_requests WHERE id=?";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setInt(1, id);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return map(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    @Override
    public boolean create(LeaveRequest request) {

        String sql =
                "INSERT INTO leave_requests " +
                        "(employee_id,leave_type_id,start_date,end_date,total_days,reason,status) " +
                        "VALUES(?,?,?,?,?,?,'PENDING')";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setInt(1, request.getEmployeeId());
            ps.setInt(2, request.getLeaveTypeId());
            ps.setDate(3, request.getStartDate());
            ps.setDate(4, request.getEndDate());
            ps.setDouble(5, request.getTotalDays());
            ps.setString(6, request.getReason());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public boolean approve(int requestId, int approverId) {

        String sql =
                "UPDATE leave_requests " +
                        "SET status='APPROVED', " +
                        "reviewed_by=?, " +
                        "reviewed_at=NOW() " +
                        "WHERE id=?";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setInt(1, approverId);
            ps.setInt(2, requestId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public boolean reject(int requestId, int approverId) {

        String sql =
                "UPDATE leave_requests " +
                        "SET status='REJECTED', " +
                        "reviewed_by=?, " +
                        "reviewed_at=NOW() " +
                        "WHERE id=?";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setInt(1, approverId);
            ps.setInt(2, requestId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public boolean cancel(int requestId) {

        String sql =
                "UPDATE leave_requests " +
                        "SET status='CANCELLED' " +
                        "WHERE id=? AND status='PENDING'";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setInt(1, requestId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    private LeaveRequest map(ResultSet rs)
            throws SQLException {

        LeaveRequest r = new LeaveRequest();

        r.setId(rs.getInt("id"));
        r.setEmployeeId(rs.getInt("employee_id"));
        r.setLeaveTypeId(rs.getInt("leave_type_id"));

        r.setStartDate(rs.getDate("start_date"));
        r.setEndDate(rs.getDate("end_date"));

        r.setTotalDays(rs.getDouble("total_days"));

        r.setReason(rs.getString("reason"));
        r.setStatus(rs.getString("status"));

        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setUpdatedAt(rs.getTimestamp("updated_at"));

        return r;
    }
}