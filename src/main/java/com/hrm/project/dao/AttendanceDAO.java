package com.hrm.project.dao;

import com.hrm.project.model.Attendance;
import com.hrm.project.model.dtos.response.AttendanceEmployeeStatsDto;
import java.sql.SQLException;
import java.util.List;

public interface AttendanceDAO {

    List<Attendance> getAttendanceByMonth(int year, int month, int employeeId);

    int importAttendances(List<Attendance> attendances) throws SQLException;

    boolean submitExplanation(int employeeId, java.time.LocalDate date, String reason);

    List<AttendanceEmployeeStatsDto> getEmployeeStatistics(int year, int month);
}
