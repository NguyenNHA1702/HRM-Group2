package com.hrm.project.model;

import java.sql.Date;
import java.sql.Time;

public class EmployeeSchedule {
    private int id;
    private int employeeId;
    private String employeeCode;
    private String employeeName;
    private String departmentName;
    private int workShiftId;
    private String workShiftName;
    private Time startTime;
    private Time endTime;
    private Date scheduleDate;
    private String notes;

    public EmployeeSchedule() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getEmployeeId() { return employeeId; }
    public void setEmployeeId(int employeeId) { this.employeeId = employeeId; }

    public String getEmployeeCode() { return employeeCode; }
    public void setEmployeeCode(String employeeCode) { this.employeeCode = employeeCode; }

    public String getEmployeeName() { return employeeName; }
    public void setEmployeeName(String employeeName) { this.employeeName = employeeName; }

    public String getDepartmentName() { return departmentName; }
    public void setDepartmentName(String departmentName) { this.departmentName = departmentName; }

    public int getWorkShiftId() { return workShiftId; }
    public void setWorkShiftId(int workShiftId) { this.workShiftId = workShiftId; }

    public String getWorkShiftName() { return workShiftName; }
    public void setWorkShiftName(String workShiftName) { this.workShiftName = workShiftName; }

    public Time getStartTime() { return startTime; }
    public void setStartTime(Time startTime) { this.startTime = startTime; }

    public Time getEndTime() { return endTime; }
    public void setEndTime(Time endTime) { this.endTime = endTime; }

    public Date getScheduleDate() { return scheduleDate; }
    public void setScheduleDate(Date scheduleDate) { this.scheduleDate = scheduleDate; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    // Helpers to display formatted values
    public String getFormattedStartTime() {
        if (startTime == null) return "";
        String t = startTime.toString();
        return t.substring(0, 5);
    }

    public String getFormattedEndTime() {
        if (endTime == null) return "";
        String t = endTime.toString();
        return t.substring(0, 5);
    }
}
