package com.hrm.project.service.impl;

import com.hrm.project.dao.AttendanceDAO;
import com.hrm.project.model.Attendance;
import com.hrm.project.model.dtos.response.AttendanceEmployeeStatsDto;
import com.hrm.project.model.dtos.response.AttendanceSystemStatsDto;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;
import junit.framework.TestCase;

public class AttendanceServiceImplTest extends TestCase {

    public void testCanonicalKeyNormalizesVietnameseD() {
        assertEquals("du_cong", AttendanceServiceImpl.canonicalKey("Đủ công"));
        assertEquals("di_muon", AttendanceServiceImpl.canonicalKey("Đi muộn"));
        assertEquals("dung_gio", AttendanceServiceImpl.canonicalKey("Đúng giờ"));
    }

    public void testSystemStatisticsAggregatesAllEmployees() {
        AttendanceEmployeeStatsDto first = employeeStats(20, 2, 1, 1, 120);
        AttendanceEmployeeStatsDto second = employeeStats(18, 3, 2, 0, 60);
        AttendanceServiceImpl service = new AttendanceServiceImpl(
                new StatisticsAttendanceDAO(Arrays.asList(first, second)));

        AttendanceSystemStatsDto statistics = service.getSystemStatistics(2026, 6);

        assertEquals(2, statistics.getTotalEmployees());
        assertEquals(38, statistics.getWorkDays());
        assertEquals(44, statistics.getExpectedWorkDays());
        assertEquals(5, statistics.getLateCount());
        assertEquals(3, statistics.getAbsentCount());
        assertEquals(1, statistics.getLeaveCount());
        assertEquals(180, statistics.getOvertimeMinutes());
        assertEquals("3.0h", statistics.getOvertimeHoursFormatted());
    }

    public void testWorkingDaysForJune2026() {
        assertEquals(22, AttendanceServiceImpl.countWorkingDays(2026, 6));
    }

    private AttendanceEmployeeStatsDto employeeStats(
            int workDays, int lateCount, int absentCount,
            int leaveCount, int overtimeMinutes) {
        AttendanceEmployeeStatsDto employee = new AttendanceEmployeeStatsDto();
        employee.setWorkDays(workDays);
        employee.setLateCount(lateCount);
        employee.setAbsentCount(absentCount);
        employee.setLeaveCount(leaveCount);
        employee.setOvertimeMinutes(overtimeMinutes);
        return employee;
    }

    private static class StatisticsAttendanceDAO implements AttendanceDAO {

        private final List<AttendanceEmployeeStatsDto> statistics;

        private StatisticsAttendanceDAO(List<AttendanceEmployeeStatsDto> statistics) {
            this.statistics = statistics;
        }

        @Override
        public List<Attendance> getAttendanceByMonth(int year, int month, int employeeId) {
            throw new UnsupportedOperationException();
        }

        @Override
        public int importAttendances(List<Attendance> attendances) throws SQLException {
            throw new UnsupportedOperationException();
        }

        @Override
        public boolean submitExplanation(int employeeId, LocalDate date, String reason) {
            throw new UnsupportedOperationException();
        }

        @Override
        public List<AttendanceEmployeeStatsDto> getEmployeeStatistics(int year, int month) {
            return statistics;
        }
    }
}
