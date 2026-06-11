package com.hrm.project.dao;

import com.hrm.project.model.AttendanceSummary;

public interface AttendanceDAO {
    AttendanceSummary getSummaryByEmployeeAndPeriod(int employeeId, int month, int year);
    boolean createOrUpdateSummary(AttendanceSummary summary);
}
