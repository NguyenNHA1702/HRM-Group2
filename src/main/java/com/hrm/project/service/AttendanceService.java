package com.hrm.project.service;

import com.hrm.project.model.Attendance;
import com.hrm.project.model.AttendanceExplanation;
import com.hrm.project.model.AttendanceImportResult;
import com.hrm.project.model.dtos.response.AttendanceSystemStatsDto;
import java.io.InputStream;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface AttendanceService {

    List<Attendance> getAttendanceByMonth(int year, int month, int employeeId);

    AttendanceImportResult importFromExcel(InputStream inputStream);

    /**
     * Đọc dòng đầu tiên có ngày hợp lệ trong file Excel để xác định tháng/năm của dữ liệu.
     * Trả về mảng [year, month] hoặc null nếu không tìm được ngày nào.
     */
    int[] detectImportMonthYear(byte[] fileData);

    boolean submitExplanation(int employeeId, String date, String reason);

    AttendanceSystemStatsDto getSystemStatistics(int year, int month);

    // ── Explanation management ──
    List<AttendanceExplanation> getExplanations(String statusFilter, int page, int pageSize);

    int countExplanations(String statusFilter);

    boolean reviewExplanation(long id, String reviewStatus, int reviewedBy, String reviewComment);

    AttendanceExplanation getExplanationByEmployeeDate(int employeeId, LocalDate date);

    Map<String, AttendanceExplanation> getExplanationsByMonth(int employeeId, int year, int month);

    boolean isAttendanceLocked(int year, int month);

    boolean lockAttendance(int year, int month, int lockedBy);

    boolean unlockAttendance(int year, int month);
}
