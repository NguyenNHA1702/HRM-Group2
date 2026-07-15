package com.hrm.project.dao.impl;

import com.hrm.project.dao.AttendanceDAO;
import com.hrm.project.model.Attendance;
import com.hrm.project.model.AttendanceExplanation;
import com.hrm.project.model.dtos.response.AttendanceEmployeeStatsDto;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.sql.Timestamp;
import java.sql.Types;
import java.time.LocalDate;
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
    public boolean submitExplanation(int employeeId, LocalDate date, String reason) {
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
    public List<AttendanceExplanation> getExplanations(Integer departmentId, String statusFilter, int page, int pageSize) {
        List<AttendanceExplanation> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT ae.id, ae.employee_id, e.full_name AS employee_name, "
                + "e.employee_code, COALESCE(d.name,'Chưa phân phòng') AS department_name, "
                + "ae.attendance_date, a.status AS attendance_status, "
                + "ae.reason, ae.status, ae.reviewed_by, "
                + "rv.full_name AS reviewed_by_name, ae.reviewed_at, "
                + "ae.review_comment, ae.created_at "
                + "FROM attendance_explanations ae "
                + "JOIN employees e ON e.id = ae.employee_id "
                + "LEFT JOIN departments d ON d.id = e.department_id "
                + "LEFT JOIN attendance a ON a.employee_id = ae.employee_id "
                + "  AND a.date = ae.attendance_date "
                + "LEFT JOIN employees rv ON rv.id = ae.reviewed_by "
                + "WHERE 1=1 ");
        
        if (departmentId != null) {
            sql.append("AND e.department_id = ? ");
        }
        if (statusFilter != null && !statusFilter.isBlank()) {
            sql.append("AND ae.status = ? ");
        }
        sql.append("ORDER BY ae.created_at DESC LIMIT ? OFFSET ?");

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            if (departmentId != null) {
                statement.setInt(idx++, departmentId);
            }
            if (statusFilter != null && !statusFilter.isBlank()) {
                statement.setString(idx++, statusFilter);
            }
            statement.setInt(idx++, pageSize);
            statement.setInt(idx, (page - 1) * pageSize);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    list.add(mapExplanation(rs));
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Không thể tải danh sách giải trình.", e);
        }
        return list;
    }

    @Override
    public int countExplanations(Integer departmentId, String statusFilter) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM attendance_explanations ae ");
        if (departmentId != null) {
            sql.append("JOIN employees e ON e.id = ae.employee_id ");
        }
        sql.append("WHERE 1=1 ");
        if (departmentId != null) {
            sql.append("AND e.department_id = ? ");
        }
        if (statusFilter != null && !statusFilter.isBlank()) {
            sql.append("AND ae.status = ? ");
        }

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            if (departmentId != null) {
                statement.setInt(idx++, departmentId);
            }
            if (statusFilter != null && !statusFilter.isBlank()) {
                statement.setString(idx++, statusFilter);
            }
            try (ResultSet rs = statement.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Không thể đếm giải trình.", e);
        }
    }

    @Override
    public boolean reviewExplanation(long id, String reviewStatus, int reviewedBy, String reviewComment) {
        String updateExp = "UPDATE attendance_explanations "
                + "SET status = ?, reviewed_by = ?, reviewed_at = NOW(), review_comment = ? "
                + "WHERE id = ?";
        // Khi APPROVED: lẩy employee_id và attendance_date từ explanation, rồi UPSERT vào attendance
        String selectInfo = "SELECT employee_id, attendance_date FROM attendance_explanations WHERE id = ?";
        String updateAtt  = "INSERT INTO attendance (employee_id, date, check_in, check_out, status, note) "
                + "VALUES (?, ?, '08:00:00', '17:30:00', 'PRESENT', 'Duyệt giải trình') "
                + "ON DUPLICATE KEY UPDATE status = 'PRESENT', note = 'Duyệt giải trình'";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // 1. Cập nhật trạng thái giải trình
                try (PreparedStatement expStmt = conn.prepareStatement(updateExp)) {
                    expStmt.setString(1, reviewStatus);
                    expStmt.setInt(2, reviewedBy);
                    expStmt.setString(3, reviewComment);
                    expStmt.setLong(4, id);
                    expStmt.executeUpdate();
                }
                // 2. Nếu APPROVED: cập nhật attendance -> PRESENT
                if ("APPROVED".equals(reviewStatus)) {
                    int empId;
                    Date attDate;
                    try (PreparedStatement selStmt = conn.prepareStatement(selectInfo)) {
                        selStmt.setLong(1, id);
                        try (ResultSet rs = selStmt.executeQuery()) {
                            if (!rs.next()) throw new SQLException("Không tìm thấy giải trình id=" + id);
                            empId   = rs.getInt("employee_id");
                            attDate = rs.getDate("attendance_date");
                        }
                    }
                    try (PreparedStatement attStmt = conn.prepareStatement(updateAtt)) {
                        attStmt.setInt(1, empId);
                        attStmt.setDate(2, attDate);
                        attStmt.executeUpdate();
                    }
                }
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Không thể xử lý giải trình.", e);
        }
    }

    @Override
    public AttendanceExplanation getExplanationByEmployeeDate(int employeeId, LocalDate date) {
        String sql = "SELECT ae.id, ae.employee_id, e.full_name AS employee_name, "
                + "e.employee_code, COALESCE(d.name,'Chưa phân phòng') AS department_name, "
                + "ae.attendance_date, a.status AS attendance_status, "
                + "ae.reason, ae.status, ae.reviewed_by, "
                + "rv.full_name AS reviewed_by_name, ae.reviewed_at, "
                + "ae.review_comment, ae.created_at "
                + "FROM attendance_explanations ae "
                + "JOIN employees e ON e.id = ae.employee_id "
                + "LEFT JOIN departments d ON d.id = e.department_id "
                + "LEFT JOIN attendance a ON a.employee_id = ae.employee_id "
                + "  AND a.date = ae.attendance_date "
                + "LEFT JOIN employees rv ON rv.id = ae.reviewed_by "
                + "WHERE ae.employee_id = ? AND ae.attendance_date = ?";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, employeeId);
            statement.setDate(2, Date.valueOf(date));
            try (ResultSet rs = statement.executeQuery()) {
                return rs.next() ? mapExplanation(rs) : null;
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Không thể tải giải trình.", e);
        }
    }

    @Override
    public Map<String, AttendanceExplanation> getExplanationsByMonth(int employeeId, int year, int month) {
        Map<String, AttendanceExplanation> map = new HashMap<>();
        String sql = "SELECT ae.id, ae.employee_id, e.full_name AS employee_name, "
                + "e.employee_code, COALESCE(d.name,'Chưa phân phòng') AS department_name, "
                + "ae.attendance_date, a.status AS attendance_status, "
                + "ae.reason, ae.status, ae.reviewed_by, "
                + "rv.full_name AS reviewed_by_name, ae.reviewed_at, "
                + "ae.review_comment, ae.created_at "
                + "FROM attendance_explanations ae "
                + "JOIN employees e ON e.id = ae.employee_id "
                + "LEFT JOIN departments d ON d.id = e.department_id "
                + "LEFT JOIN attendance a ON a.employee_id = ae.employee_id "
                + "  AND a.date = ae.attendance_date "
                + "LEFT JOIN employees rv ON rv.id = ae.reviewed_by "
                + "WHERE ae.employee_id = ? AND YEAR(ae.attendance_date) = ? AND MONTH(ae.attendance_date) = ?";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, employeeId);
            statement.setInt(2, year);
            statement.setInt(3, month);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    AttendanceExplanation ex = mapExplanation(rs);
                    if (ex.getAttendanceDate() != null) {
                        map.put(ex.getAttendanceDate().toString(), ex);
                    }
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Không thể tải danh sách giải trình theo tháng.", e);
        }
        return map;
    }

    private AttendanceExplanation mapExplanation(ResultSet rs) throws SQLException {
        AttendanceExplanation ex = new AttendanceExplanation();
        ex.setId(rs.getLong("id"));
        ex.setEmployeeId(rs.getInt("employee_id"));
        ex.setEmployeeName(rs.getString("employee_name"));
        ex.setEmployeeCode(rs.getString("employee_code"));
        ex.setDepartmentName(rs.getString("department_name"));
        ex.setAttendanceDate(rs.getDate("attendance_date").toLocalDate());
        ex.setAttendanceStatus(rs.getString("attendance_status"));
        ex.setReason(rs.getString("reason"));
        ex.setStatus(rs.getString("status"));
        int reviewedBy = rs.getInt("reviewed_by");
        if (!rs.wasNull()) ex.setReviewedBy(reviewedBy);
        ex.setReviewedByName(rs.getString("reviewed_by_name"));
        Timestamp reviewedAt = rs.getTimestamp("reviewed_at");
        if (reviewedAt != null) ex.setReviewedAt(reviewedAt.toLocalDateTime());
        ex.setReviewComment(rs.getString("review_comment"));
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) ex.setCreatedAt(createdAt.toLocalDateTime());
        return ex;
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

    @Override
    public boolean isAttendanceLocked(int year, int month) {
        String sql = "SELECT is_locked FROM attendance_locks WHERE year = ? AND month = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, year);
            stmt.setInt(2, month);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getBoolean("is_locked");
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Không thể kiểm tra trạng thái khóa chấm công.", e);
        }
        return false;
    }

    @Override
    public boolean lockAttendance(int year, int month, int lockedBy) {
        String sql = "INSERT INTO attendance_locks (year, month, is_locked, locked_by, locked_at) "
                + "VALUES (?, ?, true, ?, NOW()) "
                + "ON DUPLICATE KEY UPDATE is_locked = true, locked_by = ?, locked_at = NOW()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, year);
            stmt.setInt(2, month);
            stmt.setInt(3, lockedBy);
            stmt.setInt(4, lockedBy);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new IllegalStateException("Không thể khóa chấm công.", e);
        }
    }

    @Override
    public boolean unlockAttendance(int year, int month) {
        String sql = "UPDATE attendance_locks SET is_locked = false WHERE year = ? AND month = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, year);
            stmt.setInt(2, month);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new IllegalStateException("Không thể mở khóa chấm công.", e);
        }
    }

    @Override
    public AttendanceExplanation getExplanationById(long id) {
        String sql = "SELECT ae.id, ae.employee_id, e.full_name AS employee_name, "
                + "e.employee_code, COALESCE(d.name,'Chưa phân phòng') AS department_name, "
                + "ae.attendance_date, a.status AS attendance_status, "
                + "ae.reason, ae.status, ae.reviewed_by, "
                + "rv.full_name AS reviewed_by_name, ae.reviewed_at, "
                + "ae.review_comment, ae.created_at "
                + "FROM attendance_explanations ae "
                + "JOIN employees e ON e.id = ae.employee_id "
                + "LEFT JOIN departments d ON d.id = e.department_id "
                + "LEFT JOIN attendance a ON a.employee_id = ae.employee_id "
                + "  AND a.date = ae.attendance_date "
                + "LEFT JOIN employees rv ON rv.id = ae.reviewed_by "
                + "WHERE ae.id = ?";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, id);
            try (ResultSet rs = statement.executeQuery()) {
                return rs.next() ? mapExplanation(rs) : null;
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Không thể tải giải trình theo ID.", e);
        }
    }

    @Override
    public boolean isDepartmentAttendanceLocked(int departmentId, int year, int month) {
        String sql = "SELECT is_locked FROM department_attendance_locks WHERE department_id = ? AND year = ? AND month = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, departmentId);
            stmt.setInt(2, year);
            stmt.setInt(3, month);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getBoolean("is_locked");
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Không thể kiểm tra trạng thái khóa chấm công bộ phận.", e);
        }
        return false;
    }

    @Override
    public boolean lockDepartmentAttendance(int departmentId, int year, int month, int lockedBy) {
        String sql = "INSERT INTO department_attendance_locks (department_id, year, month, is_locked, locked_by, locked_at) "
                + "VALUES (?, ?, ?, true, ?, NOW()) "
                + "ON DUPLICATE KEY UPDATE is_locked = true, locked_by = ?, locked_at = NOW()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, departmentId);
            stmt.setInt(2, year);
            stmt.setInt(3, month);
            stmt.setInt(4, lockedBy);
            stmt.setInt(5, lockedBy);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new IllegalStateException("Không thể khóa chấm công bộ phận.", e);
        }
    }

    @Override
    public boolean unlockDepartmentAttendance(int departmentId, int year, int month) {
        String sql = "UPDATE department_attendance_locks SET is_locked = false WHERE department_id = ? AND year = ? AND month = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, departmentId);
            stmt.setInt(2, year);
            stmt.setInt(3, month);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new IllegalStateException("Không thể mở khóa chấm công bộ phận.", e);
        }
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

    @Override
    public boolean isAttendanceLockedForEmployee(int employeeId, int year, int month) {
        if (isAttendanceLocked(year, month)) {
            return true;
        }
        Integer deptId = getDepartmentIdByEmployeeId(employeeId);
        if (deptId != null) {
            return isDepartmentAttendanceLocked(deptId, year, month);
        }
        return false;
    }

    private Integer getDepartmentIdByEmployeeId(int employeeId) {
        String sql = "SELECT department_id FROM employees WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, employeeId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getObject("department_id") != null ? rs.getInt("department_id") : null;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public java.util.List<java.util.Map<String, Object>> getDepartmentLockStatuses(int year, int month) {
        java.util.List<java.util.Map<String, Object>> list = new java.util.ArrayList<>();
        String sql = "SELECT d.id AS department_id, d.name AS department_name, e.full_name AS manager_name, " +
                     "CASE WHEN dal.id IS NOT NULL THEN 1 ELSE 0 END AS is_locked " +
                     "FROM departments d " +
                     "LEFT JOIN employees e ON d.manager_id = e.id " +
                     "LEFT JOIN department_attendance_locks dal ON d.id = dal.department_id AND dal.year = ? AND dal.month = ? " +
                     "WHERE d.is_active = 1 " +
                     "ORDER BY d.name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            ps.setInt(2, month);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> map = new java.util.HashMap<>();
                    map.put("departmentId", rs.getInt("department_id"));
                    map.put("departmentName", rs.getString("department_name"));
                    map.put("managerName", rs.getString("manager_name"));
                    map.put("isLocked", rs.getInt("is_locked") == 1);
                    list.add(map);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<AttendanceEmployeeStatsDto> getDepartmentEmployeeStatistics(int departmentId, int year, int month) {
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
                + "WHERE COALESCE(e.status, '') <> 'TERMINATED' AND e.department_id = ? "
                + "GROUP BY e.id, e.employee_code, e.full_name, d.name "
                + "ORDER BY e.employee_code, e.full_name";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, year);
            statement.setInt(2, month);
            statement.setInt(3, departmentId);

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
            throw new IllegalStateException("Không thể tải thống kê chấm công bộ phận.", e);
        }
        return statistics;
    }
}
