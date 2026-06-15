package com.hrm.project.service;

import com.hrm.project.model.Attendance;
import com.hrm.project.model.AttendanceImportResult;
import com.hrm.project.model.dtos.response.AttendanceSystemStatsDto;
import java.io.InputStream;
import java.util.List;

public interface AttendanceService {

    List<Attendance> getAttendanceByMonth(int year, int month, int employeeId);

    AttendanceImportResult importFromExcel(InputStream inputStream);

    boolean submitExplanation(int employeeId, String date, String reason);

    AttendanceSystemStatsDto getSystemStatistics(int year, int month);
}
