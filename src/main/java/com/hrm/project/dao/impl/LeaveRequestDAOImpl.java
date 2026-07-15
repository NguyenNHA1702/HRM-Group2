package com.hrm.project.dao.impl;

import com.hrm.project.dao.LeaveRequestDAO;
import com.hrm.project.model.LeaveRequest;
import com.hrm.project.model.dtos.response.LeaveSummaryDto;

import java.sql.*;
import java.time.LocalDate;
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
        String updateRequestSql =
                "UPDATE leave_requests " +
                        "SET status='APPROVED', " +
                        "reviewed_by=?, " +
                        "reviewed_at=NOW() " +
                        "WHERE id=?";

        String selectRequestSql =
                "SELECT lr.employee_id, lr.start_date, lr.end_date, lt.name AS leave_type_name " +
                        "FROM leave_requests lr " +
                        "JOIN leave_types lt ON lr.leave_type_id = lt.id " +
                        "WHERE lr.id = ?";

        String upsertAttendanceSql =
                "INSERT INTO attendance (employee_id, date, check_in, check_out, status, note) " +
                        "VALUES (?, ?, NULL, NULL, 'LEAVE', ?) " +
                        "ON DUPLICATE KEY UPDATE status = 'LEAVE', check_in = NULL, check_out = NULL, note = ?";

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                // 1. Update leave request status
                try (PreparedStatement psUpdate = con.prepareStatement(updateRequestSql)) {
                    psUpdate.setInt(1, approverId);
                    psUpdate.setInt(2, requestId);
                    int updatedRows = psUpdate.executeUpdate();
                    if (updatedRows == 0) {
                        con.rollback();
                        return false;
                    }
                }

                // 2. Fetch leave request details to sync with attendance
                int employeeId = 0;
                Date startDate = null;
                Date endDate = null;
                String leaveTypeName = null;
                try (PreparedStatement psSelect = con.prepareStatement(selectRequestSql)) {
                    psSelect.setInt(1, requestId);
                    try (ResultSet rs = psSelect.executeQuery()) {
                        if (rs.next()) {
                            employeeId = rs.getInt("employee_id");
                            startDate = rs.getDate("start_date");
                            endDate = rs.getDate("end_date");
                            leaveTypeName = rs.getString("leave_type_name");
                        } else {
                            con.rollback();
                            return false;
                        }
                    }
                }

                // 3. Upsert attendance records for each day of the leave request
                if (startDate != null && endDate != null) {
                    LocalDate start = startDate.toLocalDate();
                    LocalDate end = endDate.toLocalDate();
                    try (PreparedStatement psUpsert = con.prepareStatement(upsertAttendanceSql)) {
                        for (LocalDate date = start; !date.isAfter(end); date = date.plusDays(1)) {
                            psUpsert.setInt(1, employeeId);
                            psUpsert.setDate(2, Date.valueOf(date));
                            psUpsert.setString(3, leaveTypeName);
                            psUpsert.setString(4, leaveTypeName);
                            psUpsert.addBatch();
                        }
                        psUpsert.executeBatch();
                    }
                }

                con.commit();
                return true;
            } catch (Exception e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
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

    @Override
    public List<LeaveSummaryDto> getLeaveSummaryReport(Date fromDate, Date toDate, Integer departmentId) {
        List<LeaveSummaryDto> list = new ArrayList<>();
        String sql = "SELECT " +
                "    e.id AS employee_id, " +
                "    e.employee_code, " +
                "    e.full_name, " +
                "    d.name AS department_name, " +
                "    lt.name AS leave_type_name, " +
                "    COALESCE(SUM(CASE WHEN lr.status = 'APPROVED' AND lr.start_date <= ? AND lr.end_date >= ? THEN (DATEDIFF(LEAST(lr.end_date, ?), GREATEST(lr.start_date, ?)) + 1) ELSE 0.0 END), 0.0) AS total_approved, " +
                "    COALESCE(SUM(CASE WHEN lr.status = 'PENDING' AND lr.start_date <= ? AND lr.end_date >= ? THEN (DATEDIFF(LEAST(lr.end_date, ?), GREATEST(lr.start_date, ?)) + 1) ELSE 0.0 END), 0.0) AS total_pending, " +
                "    COALESCE(lb.remaining_days, 0.0) AS remaining_days " +
                "FROM employees e " +
                "JOIN departments d ON e.department_id = d.id " +
                "CROSS JOIN leave_types lt " +
                "LEFT JOIN leave_balances lb ON e.id = lb.employee_id AND lt.id = lb.leave_type_id " +
                "LEFT JOIN leave_requests lr ON e.id = lr.employee_id AND lt.id = lr.leave_type_id " +
                "WHERE e.status = 'ACTIVE' AND lt.is_active = 1 " +
                "  AND (? IS NULL OR e.department_id = ?) " +
                "GROUP BY e.id, lt.id, e.employee_code, e.full_name, d.name, lt.name, lb.remaining_days " +
                "ORDER BY e.full_name, lt.name";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setDate(1, toDate);
            ps.setDate(2, fromDate);
            ps.setDate(3, toDate);
            ps.setDate(4, fromDate);
            ps.setDate(5, toDate);
            ps.setDate(6, fromDate);
            ps.setDate(7, toDate);
            ps.setDate(8, fromDate);
            if (departmentId == null) {
                ps.setNull(9, Types.INTEGER);
                ps.setNull(10, Types.INTEGER);
            } else {
                ps.setInt(9, departmentId);
                ps.setInt(10, departmentId);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                LeaveSummaryDto dto = new LeaveSummaryDto();
                dto.setEmployeeId(rs.getInt("employee_id"));
                dto.setEmployeeCode(rs.getString("employee_code"));
                dto.setFullName(rs.getString("full_name"));
                dto.setDepartmentName(rs.getString("department_name"));
                dto.setLeaveTypeName(rs.getString("leave_type_name"));
                dto.setTotalApprovedDays(rs.getDouble("total_approved"));
                dto.setTotalPendingDays(rs.getDouble("total_pending"));
                dto.setRemainingDays(rs.getDouble("remaining_days"));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}