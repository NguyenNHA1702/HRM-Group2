package com.hrm.project.dao;

import com.hrm.project.model.Attendance;
import com.hrm.project.model.AttendanceExplanation;
import com.hrm.project.model.dtos.response.AttendanceEmployeeStatsDto;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface AttendanceDAO {

    List<Attendance> getAttendanceByMonth(int year, int month, int employeeId);

    int importAttendances(List<Attendance> attendances) throws SQLException;

    boolean submitExplanation(int employeeId, LocalDate date, String reason);

    List<AttendanceEmployeeStatsDto> getEmployeeStatistics(int year, int month);

    // ── Explanation management ──
    List<AttendanceExplanation> getExplanations(String statusFilter, int page, int pageSize);

    int countExplanations(String statusFilter);

    boolean reviewExplanation(long id, String reviewStatus, int reviewedBy, String reviewComment);

    AttendanceExplanation getExplanationByEmployeeDate(int employeeId, LocalDate date);

    Map<String, AttendanceExplanation> getExplanationsByMonth(int employeeId, int year, int month);

    // ── Attendance lock (global - backward compatible) ──
    boolean isAttendanceLocked(int year, int month);

    boolean lockAttendance(int year, int month, int lockedBy);

    boolean unlockAttendance(int year, int month);

    // ── Attendance lock by department (new) ──
    boolean isAttendanceLockedByDepartment(int year, int month, int departmentId);

    boolean lockAttendanceByDepartment(int year, int month, int departmentId, int lockedBy);

    boolean unlockAttendanceByDepartment(int year, int month, int departmentId);

    /**
     * Lấy danh sách department_id đã chốt công trong tháng/năm.
     */
    List<Integer> getLockedDepartmentIds(int year, int month);

    /**
     * Kiểm tra tất cả phòng ban đã chốt công chưa.
     */
    boolean areAllDepartmentsLocked(int year, int month);
}
