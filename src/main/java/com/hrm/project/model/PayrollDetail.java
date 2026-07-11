package com.hrm.project.model;

import java.sql.Timestamp;

/**
 * Chi tiết bảng lương nhân viên, chia thành 3 blocks:
 * Block 1: Ngày công & Lương cơ bản
 * Block 2: Phụ cấp & Bảo hiểm (BHXH, BHYT, BHTN)
 * Block 3: Thuế TNCN & Lương thực nhận
 */
public class PayrollDetail {
    private int id;
    private int payrollId;
    private int employeeId;

    // === BLOCK 1: Ngày công & Lương cơ bản ===
    private double basicSalary;          // Lương cơ bản (từ hợp đồng)
    private double standardDays;         // Ngày công chuẩn
    private double actualWorkedDays;     // Ngày công thực tế
    private double paidLeaveDays;        // Ngày nghỉ có lương
    private double unpaidLeaveDays;      // Ngày nghỉ không lương
    private double sickLeaveDays;        // Ngày nghỉ ốm
    private double unpaidLeaveDeduction; // Khấu trừ nghỉ không lương

    // === BLOCK 2: Phụ cấp & Bảo hiểm ===
    private double allowanceAmount;      // Tổng phụ cấp (theo position)
    private double bhxhDeduction;        // BHXH
    private double bhytDeduction;        // BHYT
    private double bhtnDeduction;        // BHTN
    private double insuranceDeduction;   // Tổng bảo hiểm (= bhxh + bhyt + bhtn)

    // === BLOCK 3: Thuế & Lương thực nhận ===
    private double grossSalary;          // Lương trước thuế
    private double taxDeduction;         // Thuế TNCN
    private double netSalary;            // Lương thực nhận

    // Metadata
    private String notes;
    private Timestamp createdAt;
    private int departmentId;            // Phòng ban tại thời điểm tính lương
    private int positionId;              // Chức vụ tại thời điểm tính lương

    // Fields for display
    private String employeeName;
    private String employeeCode;
    private String departmentName;
    private String positionName;

    // Additional fields for Employee view / history
    private int month;
    private int year;
    private String status;

    public PayrollDetail() {}

    // === Getters & Setters ===

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getPayrollId() { return payrollId; }
    public void setPayrollId(int payrollId) { this.payrollId = payrollId; }

    public int getEmployeeId() { return employeeId; }
    public void setEmployeeId(int employeeId) { this.employeeId = employeeId; }

    // Block 1
    public double getBasicSalary() { return basicSalary; }
    public void setBasicSalary(double basicSalary) { this.basicSalary = basicSalary; }

    public double getStandardDays() { return standardDays; }
    public void setStandardDays(double standardDays) { this.standardDays = standardDays; }

    public double getActualWorkedDays() { return actualWorkedDays; }
    public void setActualWorkedDays(double actualWorkedDays) { this.actualWorkedDays = actualWorkedDays; }

    public double getPaidLeaveDays() { return paidLeaveDays; }
    public void setPaidLeaveDays(double paidLeaveDays) { this.paidLeaveDays = paidLeaveDays; }

    public double getUnpaidLeaveDays() { return unpaidLeaveDays; }
    public void setUnpaidLeaveDays(double unpaidLeaveDays) { this.unpaidLeaveDays = unpaidLeaveDays; }

    public double getSickLeaveDays() { return sickLeaveDays; }
    public void setSickLeaveDays(double sickLeaveDays) { this.sickLeaveDays = sickLeaveDays; }

    public double getUnpaidLeaveDeduction() { return unpaidLeaveDeduction; }
    public void setUnpaidLeaveDeduction(double unpaidLeaveDeduction) { this.unpaidLeaveDeduction = unpaidLeaveDeduction; }

    // Block 2
    public double getAllowanceAmount() { return allowanceAmount; }
    public void setAllowanceAmount(double allowanceAmount) { this.allowanceAmount = allowanceAmount; }

    public double getBhxhDeduction() { return bhxhDeduction; }
    public void setBhxhDeduction(double bhxhDeduction) { this.bhxhDeduction = bhxhDeduction; }

    public double getBhytDeduction() { return bhytDeduction; }
    public void setBhytDeduction(double bhytDeduction) { this.bhytDeduction = bhytDeduction; }

    public double getBhtnDeduction() { return bhtnDeduction; }
    public void setBhtnDeduction(double bhtnDeduction) { this.bhtnDeduction = bhtnDeduction; }

    public double getInsuranceDeduction() { return insuranceDeduction; }
    public void setInsuranceDeduction(double insuranceDeduction) { this.insuranceDeduction = insuranceDeduction; }

    // Block 3
    public double getGrossSalary() { return grossSalary; }
    public void setGrossSalary(double grossSalary) { this.grossSalary = grossSalary; }

    public double getTaxDeduction() { return taxDeduction; }
    public void setTaxDeduction(double taxDeduction) { this.taxDeduction = taxDeduction; }

    public double getNetSalary() { return netSalary; }
    public void setNetSalary(double netSalary) { this.netSalary = netSalary; }

    // Metadata
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public int getDepartmentId() { return departmentId; }
    public void setDepartmentId(int departmentId) { this.departmentId = departmentId; }

    public int getPositionId() { return positionId; }
    public void setPositionId(int positionId) { this.positionId = positionId; }

    // Display
    public String getEmployeeName() { return employeeName; }
    public void setEmployeeName(String employeeName) { this.employeeName = employeeName; }

    public String getEmployeeCode() { return employeeCode; }
    public void setEmployeeCode(String employeeCode) { this.employeeCode = employeeCode; }

    public String getDepartmentName() { return departmentName; }
    public void setDepartmentName(String departmentName) { this.departmentName = departmentName; }

    public String getPositionName() { return positionName; }
    public void setPositionName(String positionName) { this.positionName = positionName; }

    // History view
    public int getMonth() { return month; }
    public void setMonth(int month) { this.month = month; }

    public int getYear() { return year; }
    public void setYear(int year) { this.year = year; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
