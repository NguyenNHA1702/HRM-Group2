package com.hrm.project.model.dtos.response;

/** Stats cho Employee Dashboard */
public class EmployeeStatsDto {
    private int    workDays;           // ngày công tháng này
    private double leaveRemain;        // phép còn lại
    private long   estimatedSalary;    // VND
    private int    pendingRequests;    // tổng đơn chờ duyệt

    public int    getWorkDays()               { return workDays; }
    public void   setWorkDays(int v)          { this.workDays = v; }
    public double getLeaveRemain()            { return leaveRemain; }
    public void   setLeaveRemain(double v)    { this.leaveRemain = v; }
    public long   getEstimatedSalary()        { return estimatedSalary; }
    public void   setEstimatedSalary(long v)  { this.estimatedSalary = v; }
    public int    getPendingRequests()        { return pendingRequests; }
    public void   setPendingRequests(int v)   { this.pendingRequests = v; }

    public String getEstimatedSalaryFormatted() {
        if (estimatedSalary >= 1_000_000_000L)
            return String.format("%.1f tỷ", estimatedSalary / 1_000_000_000.0);
        if (estimatedSalary >= 1_000_000L)
            return String.format("%.1fM", estimatedSalary / 1_000_000.0);
        return String.format("%,d đ", estimatedSalary);
    }
}