package com.hrm.project.dao.impl;

import com.hrm.project.dao.AttendanceDAO;
import com.hrm.project.model.Attendance;
import com.hrm.project.model.dtos.response.AttendanceEmployeeStatsDto;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.sql.Types;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AttendanceDAOImpl implements AttendanceDAO {

    @Override
    public List<Attendance> getAttendanceByMonth(int year, int month, int employeeId) {
        List<Attendance> attendances = new ArrayList<>();
        String sql = "SELECT a.id, a.employee_id, e.employee_code, a.date, a.check_in, "
                + "a.check_out, a.status, a.note "
                + "FROM attendance a "
                + "JOIN employees e ON e.id = a.employee_id "
                + "WHERE a.employee_id = ? AND YEAR(a.date) = ? AND MONTH(a.date) = ? "
                + "ORDER BY a.date";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, employeeId);
            statement.setInt(2, year);
            statement.setInt(3, month);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    Attendance attendance = new Attendance();
                    attendance.setId(resultSet.getLong("id"));
                    attendance.setEmployeeId(resultSet.getInt("employee_id"));
                    attendance.setEmployeeCode(resultSet.getString("employee_code"));
                    attendance.setDate(resultSet.getDate("date").toLocalDate());

                    Time checkIn = resultSet.getTime("check_in");
                    Time checkOut = resultSet.getTime("check_out");
                    attendance.setCheckIn(checkIn == null ? null : checkIn.toLocalTime());
                    attendance.setCheckOut(checkOut == null ? null : checkOut.toLocalTime());
                    attendance.setStatus(resultSet.getString("status"));
                    attendance.setNote(resultSet.getString("note"));
                    attendances.add(attendance);
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Khong the tai du lieu cham cong.", e);
        }
        return attendances;
    }

    @Override
    public int importAttendances(List<Attendance> attendances) throws SQLException {
        String employeeCodeSql = "SELECT id FROM employees WHERE employee_code = ?";
        String employeeIdSql = "SELECT employee_code FROM employees WHERE id = ?";
        String upsertSql = "INSERT INTO attendance "
                + "(employee_id, date, check_in, check_out, status, note) "
                + "VALUES (?, ?, ?, ?, ?, ?) "
                + "ON DUPLICATE KEY UPDATE check_in = VALUES(check_in), "
                + "check_out = VALUES(check_out), status = VALUES(status), "
                + "note = VALUES(note)";

        try (Connection connection = DBConnection.getConnection()) {
            connection.setAutoCommit(false);
            try (PreparedStatement employeeCodeStatement = connection.prepareStatement(employeeCodeSql);
                 PreparedStatement employeeIdStatement = connection.prepareStatement(employeeIdSql);
                 PreparedStatement upsertStatement = connection.prepareStatement(upsertSql)) {
                Map<String, Integer> employeeIds = new HashMap<>();

                for (Attendance attendance : attendances) {
                    int employeeId;
                    if (attendance.getEmployeeId() != null) {
                        employeeId = validateEmployeeId(
                                attendance.getEmployeeId(),
                                attendance.getEmployeeCode(),
                                employeeIdStatement);
                    } else {
                        employeeId = resolveEmployeeId(
                                attendance.getEmployeeCode(), employeeIds, employeeCodeStatement);
                    }

                    upsertStatement.setInt(1, employeeId);
                    upsertStatement.setDate(2, Date.valueOf(attendance.getDate()));
                    setTime(upsertStatement, 3, attendance.getCheckIn());
                    setTime(upsertStatement, 4, attendance.getCheckOut());
                    upsertStatement.setString(5, attendance.getStatus());
                    upsertStatement.setString(6, attendance.getNote());
                    upsertStatement.addBatch();
                }

                int importedRows = 0;
                for (int result : upsertStatement.executeBatch()) {
                    if (result >= 0 || result == PreparedStatement.SUCCESS_NO_INFO) {
                        importedRows++;
                    }
                }
                connection.commit();
                return importedRows;
            } catch (SQLException e) {
                connection.rollback();
                throw e;
            } finally {
                connection.setAutoCommit(true);
            }
        }
    }

    @Override
    public boolean submitExplanation(int employeeId, java.time.LocalDate date, String reason) {
        String sql = "INSERT INTO attendance_explanations "
                + "(employee_id, attendance_date, reason, status) VALUES (?, ?, ?, 'PENDING') "
                + "ON DUPLICATE KEY UPDATE reason = VALUES(reason), status = 'PENDING', "
                + "reviewed_by = NULL, reviewed_at = NULL, review_comment = NULL";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, employeeId);
            statement.setDate(2, Date.valueOf(date));
            statement.setString(3, reason);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new IllegalStateException("Khong the gui giai trinh cham cong.", e);
        }
    }

    @Override
    public List<AttendanceEmployeeStatsDto> getEmployeeStatistics(int year, int month) {
        List<AttendanceEmployeeStatsDto> statistics = new ArrayList<>();
        String sql = "SELECT e.id AS employee_id, e.employee_code, e.full_name, "
                + "COALESCE(d.name, 'Chưa phân phòng') AS department_name, "
                + "COALESCE(SUM(CASE WHEN a.status IN ('PRESENT', 'LATE', 'EARLY_LEAVE') "
                + "THEN 1 ELSE 0 END), 0) AS work_days, "
                + "COALESCE(SUM(CASE WHEN a.status = 'LATE' THEN 1 ELSE 0 END), 0) "
                + "AS late_count, "
                + "COALESCE(SUM(CASE WHEN a.status = 'EARLY_LEAVE' THEN 1 ELSE 0 END), 0) "
                + "AS early_leave_count, "
                + "COALESCE(SUM(CASE WHEN a.status = 'ABSENT' THEN 1 ELSE 0 END), 0) "
                + "AS absent_count, "
                + "COALESCE(SUM(CASE WHEN a.status = 'LEAVE' THEN 1 ELSE 0 END), 0) "
                + "AS leave_count, "
                + "COALESCE(SUM(CASE WHEN a.check_out > '17:30:00' "
                + "THEN FLOOR(TIME_TO_SEC(TIMEDIFF(a.check_out, '17:30:00')) / 60) "
                + "ELSE 0 END), 0) AS overtime_minutes "
                + "FROM employees e "
                + "LEFT JOIN departments d ON d.id = e.department_id "
                + "LEFT JOIN attendance a ON a.employee_id = e.id "
                + "AND YEAR(a.date) = ? AND MONTH(a.date) = ? "
                + "WHERE COALESCE(e.status, '') <> 'TERMINATED' "
                + "GROUP BY e.id, e.employee_code, e.full_name, d.name "
                + "ORDER BY e.employee_code, e.full_name";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, year);
            statement.setInt(2, month);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    AttendanceEmployeeStatsDto employee = new AttendanceEmployeeStatsDto();
                    employee.setEmployeeId(resultSet.getInt("employee_id"));
                    employee.setEmployeeCode(resultSet.getString("employee_code"));
                    employee.setFullName(resultSet.getString("full_name"));
                    employee.setDepartmentName(resultSet.getString("department_name"));
                    employee.setWorkDays(resultSet.getInt("work_days"));
                    employee.setLateCount(resultSet.getInt("late_count"));
                    employee.setEarlyLeaveCount(resultSet.getInt("early_leave_count"));
                    employee.setAbsentCount(resultSet.getInt("absent_count"));
                    employee.setLeaveCount(resultSet.getInt("leave_count"));
                    employee.setOvertimeMinutes(resultSet.getInt("overtime_minutes"));
                    statistics.add(employee);
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Không thể tải thống kê chấm công hệ thống.", e);
        }
        return statistics;
    }

    private int validateEmployeeId(int employeeId, String employeeCode,
                                   PreparedStatement statement) throws SQLException {
        statement.setInt(1, employeeId);
        try (ResultSet resultSet = statement.executeQuery()) {
            if (!resultSet.next()) {
                throw new SQLException("Khong tim thay employee_id: " + employeeId);
            }
            if (employeeCode != null && !employeeCode.isBlank()
                    && !employeeCode.trim().equalsIgnoreCase(resultSet.getString("employee_code"))) {
                throw new SQLException(
                        "employee_id " + employeeId + " khong khop employee_code " + employeeCode);
            }
            return employeeId;
        }
    }

    private int resolveEmployeeId(String employeeCode, Map<String, Integer> cache,
                                  PreparedStatement statement) throws SQLException {
        String normalizedCode = employeeCode.trim().toUpperCase();
        Integer cachedId = cache.get(normalizedCode);
        if (cachedId != null) {
            return cachedId;
        }

        statement.setString(1, normalizedCode);
        try (ResultSet resultSet = statement.executeQuery()) {
            if (!resultSet.next()) {
                throw new SQLException("Khong tim thay ma nhan vien: " + employeeCode);
            }
            int employeeId = resultSet.getInt("id");
            cache.put(normalizedCode, employeeId);
            return employeeId;
        }
    }

    private void setTime(PreparedStatement statement, int index, LocalTime value) throws SQLException {
        if (value == null) {
            statement.setNull(index, Types.TIME);
        } else {
            statement.setTime(index, Time.valueOf(value));
        }
    }
}
