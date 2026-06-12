package com.hrm.project.model.dtos.response;

import java.util.Locale;

public class AttendanceEmployeeStatsDto {

    private int employeeId;
    private String employeeCode;
    private String fullName;
    private String departmentName;
    private int workDays;
    private int lateCount;
    private int earlyLeaveCount;
    private int absentCount;
    private int leaveCount;
    private int overtimeMinutes;

    public int getEmployeeId() {
        return employeeId;
    }

    public void setEmployeeId(int employeeId) {
        this.employeeId = employeeId;
    }

    public String getEmployeeCode() {
        return employeeCode;
    }

    public void setEmployeeCode(String employeeCode) {
        this.employeeCode = employeeCode;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getDepartmentName() {
        return departmentName;
    }

    public void setDepartmentName(String departmentName) {
        this.departmentName = departmentName;
    }

    public int getWorkDays() {
        return workDays;
    }

    public void setWorkDays(int workDays) {
        this.workDays = workDays;
    }

    public int getLateCount() {
        return lateCount;
    }

    public void setLateCount(int lateCount) {
        this.lateCount = lateCount;
    }

    public int getEarlyLeaveCount() {
        return earlyLeaveCount;
    }

    public void setEarlyLeaveCount(int earlyLeaveCount) {
        this.earlyLeaveCount = earlyLeaveCount;
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
}
