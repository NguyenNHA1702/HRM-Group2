package com.hrm.project.model;

import java.sql.Timestamp;

/**
 * Thưởng phát sinh cho nhân viên theo tháng.
 * HR nhập dữ liệu trước khi generate payroll.
 * 
 * bonus_type: KPI, HOLIDAY, PERFORMANCE, OTHER
 */
public class PayrollBonus {
    private int id;
    private int employeeId;
    private int bonusMonth;
    private int bonusYear;
    private String bonusType;  // KPI, HOLIDAY, PERFORMANCE, OTHER
    private double amount;
    private String note;
    private int createdBy;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Display fields
    private String employeeName;
    private String employeeCode;
    private String departmentName;

    public PayrollBonus() {}

    // === Getters & Setters ===

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getEmployeeId() { return employeeId; }
    public void setEmployeeId(int employeeId) { this.employeeId = employeeId; }

    public int getBonusMonth() { return bonusMonth; }
    public void setBonusMonth(int bonusMonth) { this.bonusMonth = bonusMonth; }

    public int getBonusYear() { return bonusYear; }
    public void setBonusYear(int bonusYear) { this.bonusYear = bonusYear; }

    public String getBonusType() { return bonusType; }
    public void setBonusType(String bonusType) { this.bonusType = bonusType; }

    public double getAmount() { return amount; }
    public void setAmount(double amount) { this.amount = amount; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    // Display
    public String getEmployeeName() { return employeeName; }
    public void setEmployeeName(String employeeName) { this.employeeName = employeeName; }

    public String getEmployeeCode() { return employeeCode; }
    public void setEmployeeCode(String employeeCode) { this.employeeCode = employeeCode; }

    public String getDepartmentName() { return departmentName; }
    public void setDepartmentName(String departmentName) { this.departmentName = departmentName; }

    /**
     * Helper: trả về label hiển thị cho loại thưởng
     */
    public String getBonusTypeLabel() {
        if (bonusType == null) return "Không xác định";
        switch (bonusType) {
            case "KPI": return "Thưởng KPI";
            case "HOLIDAY": return "Thưởng lễ";
            case "PERFORMANCE": return "Thưởng hiệu suất";
            case "OTHER": return "Thưởng khác";
            default: return bonusType;
        }
    }
}
