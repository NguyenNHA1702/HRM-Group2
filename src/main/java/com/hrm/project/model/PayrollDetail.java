package com.hrm.project.model;

import java.sql.Timestamp;

public class PayrollDetail {
    private int id;
    private int payrollId;
    private int employeeId;
    private double basicSalary;
    private double allowanceAmount;
    private double insuranceDeduction;
    private double taxDeduction;
    private double unpaidLeaveDeduction;
    private double netSalary;
    private String notes;
    private Timestamp createdAt;

    // Fields for display
    private String employeeName;
    private String employeeCode;
    private String departmentName;
    private String positionName;
    
    // Additional fields for Employee view
    private int month;
    private int year;
    private String status;

    public PayrollDetail() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getPayrollId() { return payrollId; }
    public void setPayrollId(int payrollId) { this.payrollId = payrollId; }

    public int getEmployeeId() { return employeeId; }
    public void setEmployeeId(int employeeId) { this.employeeId = employeeId; }

    public double getBasicSalary() { return basicSalary; }
    public void setBasicSalary(double basicSalary) { this.basicSalary = basicSalary; }

    public double getAllowanceAmount() { return allowanceAmount; }
    public void setAllowanceAmount(double allowanceAmount) { this.allowanceAmount = allowanceAmount; }

    public double getInsuranceDeduction() { return insuranceDeduction; }
    public void setInsuranceDeduction(double insuranceDeduction) { this.insuranceDeduction = insuranceDeduction; }

    public double getTaxDeduction() { return taxDeduction; }
    public void setTaxDeduction(double taxDeduction) { this.taxDeduction = taxDeduction; }

    public double getUnpaidLeaveDeduction() { return unpaidLeaveDeduction; }
    public void setUnpaidLeaveDeduction(double unpaidLeaveDeduction) { this.unpaidLeaveDeduction = unpaidLeaveDeduction; }

    public double getNetSalary() { return netSalary; }
    public void setNetSalary(double netSalary) { this.netSalary = netSalary; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getEmployeeName() { return employeeName; }
    public void setEmployeeName(String employeeName) { this.employeeName = employeeName; }

    public String getEmployeeCode() { return employeeCode; }
    public void setEmployeeCode(String employeeCode) { this.employeeCode = employeeCode; }

    public String getDepartmentName() { return departmentName; }
    public void setDepartmentName(String departmentName) { this.departmentName = departmentName; }

    public String getPositionName() { return positionName; }
    public void setPositionName(String positionName) { this.positionName = positionName; }

    public int getMonth() { return month; }
    public void setMonth(int month) { this.month = month; }

    public int getYear() { return year; }
    public void setYear(int year) { this.year = year; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
