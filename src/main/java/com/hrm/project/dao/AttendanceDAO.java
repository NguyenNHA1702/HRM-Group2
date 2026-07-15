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
    List<AttendanceExplanation> getExplanations(Integer departmentId, String statusFilter, int page, int pageSize);

    int countExplanations(Integer departmentId, String statusFilter);

    boolean reviewExplanation(long id, String reviewStatus, int reviewedBy, String reviewComment);

    AttendanceExplanation getExplanationById(long id);

    AttendanceExplanation getExplanationByEmployeeDate(int employeeId, LocalDate date);

    Map<String, AttendanceExplanation> getExplanationsByMonth(int employeeId, int year, int month);

    boolean isAttendanceLocked(int year, int month);

    boolean lockAttendance(int year, int month, int lockedBy);

    boolean unlockAttendance(int year, int month);

    boolean isDepartmentAttendanceLocked(int departmentId, int year, int month);

    boolean lockDepartmentAttendance(int departmentId, int year, int month, int lockedBy);

    boolean unlockDepartmentAttendance(int departmentId, int year, int month);

    boolean isAttendanceLockedForEmployee(int employeeId, int year, int month);

    java.util.List<java.util.Map<String, Object>> getDepartmentLockStatuses(int year, int month);

    List<AttendanceEmployeeStatsDto> getDepartmentEmployeeStatistics(int departmentId, int year, int month);
}
