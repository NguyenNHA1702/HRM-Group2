package com.hrm.project.model.dtos.response;

public class LeaveSummaryDto {
    private int employeeId;
    private String employeeCode;
    private String fullName;
    private String departmentName;
    private String leaveTypeName;
    private double totalApprovedDays;
    private double totalPendingDays;
    private double remainingDays;

    public LeaveSummaryDto() {
    }

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

    public String getLeaveTypeName() {
        return leaveTypeName;
    }

    public void setLeaveTypeName(String leaveTypeName) {
        this.leaveTypeName = leaveTypeName;
    }

    public double getTotalApprovedDays() {
        return totalApprovedDays;
    }

    public void setTotalApprovedDays(double totalApprovedDays) {
        this.totalApprovedDays = totalApprovedDays;
    }

    public double getTotalPendingDays() {
        return totalPendingDays;
    }

    public void setTotalPendingDays(double totalPendingDays) {
        this.totalPendingDays = totalPendingDays;
    }

    public double getRemainingDays() {
        return remainingDays;
    }

    public void setRemainingDays(double remainingDays) {
        this.remainingDays = remainingDays;
    }
}
