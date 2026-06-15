package com.hrm.project.model.dtos.response;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class AttendanceSystemStatsDto {

    private int totalEmployees;
    private int workDays;
    private int expectedWorkDays;
    private int lateCount;
    private int absentCount;
    private int leaveCount;
    private int overtimeMinutes;
    private List<AttendanceEmployeeStatsDto> employees = new ArrayList<>();

    public int getTotalEmployees() {
        return totalEmployees;
    }

    public void setTotalEmployees(int totalEmployees) {
        this.totalEmployees = totalEmployees;
    }

    public int getWorkDays() {
        return workDays;
    }

    public void setWorkDays(int workDays) {
        this.workDays = workDays;
    }

    public int getExpectedWorkDays() {
        return expectedWorkDays;
    }

    public void setExpectedWorkDays(int expectedWorkDays) {
        this.expectedWorkDays = expectedWorkDays;
    }

    public int getLateCount() {
        return lateCount;
    }

    public void setLateCount(int lateCount) {
        this.lateCount = lateCount;
    }

    public int getAbsentCount() {
        return absentCount;
    }

    public void setAbsentCount(int absentCount) {
        this.absentCount = absentCount;
    }

    public int getLeaveCount() {
        return leaveCount;
    }

    public void setLeaveCount(int leaveCount) {
        this.leaveCount = leaveCount;
    }

    public int getOvertimeMinutes() {
        return overtimeMinutes;
    }

    public void setOvertimeMinutes(int overtimeMinutes) {
        this.overtimeMinutes = overtimeMinutes;
    }

    public String getOvertimeHoursFormatted() {
        return String.format(Locale.US, "%.1fh", overtimeMinutes / 60.0);
    }

    public List<AttendanceEmployeeStatsDto> getEmployees() {
        return employees;
    }

    public void setEmployees(List<AttendanceEmployeeStatsDto> employees) {
        this.employees = employees;
    }
}
